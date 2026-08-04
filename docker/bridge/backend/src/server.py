"""
Dify WebSocket Bridge Server (サーバ側VOICEVOX音声合成)

Difyの workflows/run(ノンストリーミングAPI)応答を文分割 → VOICEVOXでWAV生成 → WebSocket送信。

プロトコル(フロントエンド向け):
  送信: 生テキスト(JSON化しない) — websocket.send(text)

  受信(テキストフレーム, JSON):
    { type: "speech_text", text: string }
    { type: "speech_done", aborted?: boolean, reason?: string }
    { type: "periodic_update", message: unknown }

  受信(バイナリフレーム):
    直前の speech_text に対応するWAV音声(ArrayBuffer)
"""

import asyncio
import json
import re
import time
import uuid
from functools import partial
from typing import Iterator

import requests
import websockets

from utils.session_manager import SessionManager
from config import settings

# ── 設定 ──
DIFY_BASE_URL = settings.dify_base_url
DIFY_API_KEY = settings.dify_api_key
DIFY_USER_ID = settings.dify_user_id
DIFY_STATE_ENDPOINT = settings.dify_state_endpoint
DIFY_TIMEOUT_SEC = settings.dify_timeout_sec
WEBSOCKET_PORT = settings.websocket_port
VOICEVOX_URL = settings.voicevox_url
VOICEVOX_SPEED_SCALE = settings.voicevox_speed_scale

SENTENCE_ENDINGS = re.compile(r"(.*?[。！？\n])")
MAX_TOTAL_CHARS = 1000
MAX_SENTENCES = 30
DUPLICATE_LIMIT = 3
CHUNK_IDLE_TIMEOUT = 15.0


# ─────────────────────────────────────────
# VOICEVOX
# ─────────────────────────────────────────
def _text_to_voicevox_wav(text: str, speaker_id: int = 1, speed_scale: float = 1.0) -> bytes | None:
    try:
        print(f"[VOICEVOX] 音声生成開始: {text}")
        query_res = requests.post(
            f"{VOICEVOX_URL}/audio_query", params={"text": text, "speaker": speaker_id}, timeout=5
        )
        query_res.raise_for_status()
        query_json = query_res.json()
        query_json["speedScale"] = speed_scale

        synth_res = requests.post(
            f"{VOICEVOX_URL}/synthesis", params={"speaker": speaker_id}, json=query_json, timeout=5
        )
        synth_res.raise_for_status()
        return synth_res.content
    except Exception as e:
        print(f"[-] VOICEVOX Error: {e}")
        return None


# ─────────────────────────────────────────
# Dify呼び出し
# ─────────────────────────────────────────
def _build_payload(user_text: str, conversation_id: str = "") -> dict:
    payload = {"inputs": {"query": user_text}, "response_mode": "blocking", "user": DIFY_USER_ID}
    if conversation_id:
        payload["conversation_id"] = conversation_id
    return payload


def _build_headers() -> dict:
    return {"Content-Type": "application/json", "Authorization": f"Bearer {DIFY_API_KEY}"}


def _call_workflow_api(payload: dict, headers: dict, endpoint: str) -> tuple[dict | None, float]:
    start_time = time.time()
    try:
        res = requests.post(endpoint, json=payload, headers=headers, timeout=DIFY_TIMEOUT_SEC)
        elapsed = time.time() - start_time
        if not res.ok:
            print(f"[-] Status: {res.status_code}")
            print(f"[-] Response body: {res.text}")
        res.raise_for_status()
        return res.json(), elapsed
    except requests.exceptions.ConnectionError:
        print(f"[-] Network Error: Failed to reach backend service at {endpoint}.")
        return None, time.time() - start_time
    except Exception as e:
        print(f"[-] Runtime Exception: Unexpected failure occurred: {e}")
        return None, time.time() - start_time


def _extract_message(result: dict) -> str | None:
    if not isinstance(result, dict):
        return None
    outputs = result.get("data", {}).get("outputs")
    if isinstance(outputs, dict):
        return outputs.get("answer") or outputs.get("text")
    if isinstance(outputs, str):
        return outputs
    return None


def _monitor_agent_status() -> str | None:
    if not DIFY_STATE_ENDPOINT:
        return None
    try:
        payload = _build_payload("")
        headers = _build_headers()
        result, _ = _call_workflow_api(payload, headers, DIFY_STATE_ENDPOINT)
        return _extract_message(result) if result else None
    except Exception as e:
        print(f"[-] Error in _monitor_agent_status: {e}")
        return None


class DifyChunkSource:
    """Difyはノンストリーミングのため、応答全文を1回のchunkとしてyieldする。"""

    def __init__(self):
        self.conversations: dict[str, str] = {}

    def chunks(self, user_text: str, session_id: str) -> Iterator[str]:
        conversation_id = self.conversations.get(session_id, "")
        payload = _build_payload(user_text, conversation_id)
        headers = _build_headers()
        endpoint = f"{DIFY_BASE_URL}/workflows/run"

        result, _ = _call_workflow_api(payload, headers, endpoint)
        if result:
            self.conversations[session_id] = result.get("conversation_id", conversation_id)
            text = _extract_message(result)
            if text:
                yield text


# ─────────────────────────────────────────
# WSサーバ
# ─────────────────────────────────────────
class DifyWSServer:
    def __init__(self, host: str = "0.0.0.0", port: int = WEBSOCKET_PORT):
        self.host = host
        self.port = port
        self.session_mgr = SessionManager(timeout=60.0)
        self.clients = set()
        self.chunk_source = DifyChunkSource()

    async def handler(self, websocket):
        session_id = self.session_mgr.get_id()
        self.clients.add(websocket)
        print(f"[+] Client connected. Session ID: {session_id}")

        try:
            async for message in websocket:
                # 一定時間は、前回の質問の内容を踏まえて回答
                #session_id = str(uuid.uuid4())
                session_id = self.session_mgr.get_id()
                print(f"[Client -> WS]: {message} (session: {session_id})")

                loop = asyncio.get_running_loop()

                buffer = ""
                total_chars = 0
                sentence_count = 0
                last_sentence = None
                duplicate_count = 0
                aborted = False
                abort_reason = ""

                queue: asyncio.Queue = asyncio.Queue()

                def fetch_chunks(_text=message, _sid=session_id):
                    for chunk in self.chunk_source.chunks(_text, _sid):
                        loop.call_soon_threadsafe(queue.put_nowait, chunk)
                    loop.call_soon_threadsafe(queue.put_nowait, None)

                loop.run_in_executor(None, fetch_chunks)

                while True:
                    try:
                        chunk = await asyncio.wait_for(queue.get(), timeout=CHUNK_IDLE_TIMEOUT)
                    except asyncio.TimeoutError:
                        print("[!] チャンクが一定時間届かないため強制終了します。")
                        aborted = True
                        abort_reason = "idle_timeout"
                        break

                    if chunk is None:
                        break

                    buffer += chunk
                    total_chars += len(chunk)

                    if total_chars > MAX_TOTAL_CHARS:
                        print("[!] 文字数上限を超えたため強制終了します。")
                        aborted = True
                        abort_reason = "max_chars"
                        break

                    matches = SENTENCE_ENDINGS.findall(buffer)
                    if matches:
                        for sentence in matches:
                            sentence_clean = sentence.strip()
                            if not sentence_clean:
                                continue

                            if sentence_clean == last_sentence:
                                duplicate_count += 1
                            else:
                                duplicate_count = 0
                            last_sentence = sentence_clean

                            if duplicate_count >= DUPLICATE_LIMIT:
                                print("[!] 同一文の繰り返しを検知。強制終了します。")
                                aborted = True
                                abort_reason = "duplicate"
                                break

                            sentence_count += 1
                            if sentence_count > MAX_SENTENCES:
                                print("[!] 文数上限を超えたため強制終了します。")
                                aborted = True
                                abort_reason = "max_sentences"
                                break

                            await self._send_sentence(websocket, sentence_clean, loop)

                        buffer = SENTENCE_ENDINGS.sub("", buffer)

                    if aborted:
                        break

                if not aborted and buffer.strip():
                    await self._send_sentence(websocket, buffer.strip(), loop)

                done_payload = {"type": "speech_done"}
                if aborted:
                    done_payload["aborted"] = True
                    done_payload["reason"] = abort_reason
                await websocket.send(json.dumps(done_payload, ensure_ascii=False))
                print(f"[+] Response completed for session {session_id} (aborted={aborted})")

        except websockets.exceptions.ConnectionClosedError:
            print("[-] Client disconnected unexpectedly.")
        finally:
            self.clients.discard(websocket)
            print(f"[+] Session terminated: {session_id}")

    async def _send_sentence(self, websocket, sentence: str, loop: asyncio.AbstractEventLoop):
        print(f"[Send Sentence]: {sentence}")
        await websocket.send(json.dumps({"type": "speech_text", "text": sentence}, ensure_ascii=False))
        wav_bytes = await loop.run_in_executor(
            None, partial(_text_to_voicevox_wav, sentence, speaker_id=1, speed_scale=VOICEVOX_SPEED_SCALE)
        )
        if wav_bytes:
            await websocket.send(wav_bytes)

    async def push_loop(self, interval_seconds: float = 5.0):
        while True:
            loop = asyncio.get_running_loop()
            message_text = await loop.run_in_executor(None, _monitor_agent_status)

            if message_text:
                try:
                    parsed_message = json.loads(message_text)
                except (json.JSONDecodeError, TypeError):
                    parsed_message = message_text

                data = {"type": "periodic_update", "message": parsed_message}
                if self.clients:
                    websockets.broadcast(self.clients, json.dumps(data, ensure_ascii=False))

            await asyncio.sleep(interval_seconds)

    async def start(self):
        asyncio.create_task(self.push_loop(interval_seconds=5.0))
        async with websockets.serve(
            self.handler, self.host, self.port, ping_interval=20, ping_timeout=20
        ):
            print(f"[+] WebSocket Server running on ws://{self.host}:{self.port}")
            await asyncio.Future()


if __name__ == "__main__":
    server = DifyWSServer(host="0.0.0.0", port=WEBSOCKET_PORT)
    try:
        asyncio.run(server.start())
    except KeyboardInterrupt:
        print("\n[+] Exited by user.")