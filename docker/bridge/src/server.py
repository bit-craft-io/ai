import asyncio
import json
import time
from functools import partial

import websockets
import requests

from utils.session_manager import SessionManager
from config import settings

# ── Dify設定（config.pyのSettingsから取得） ──
DIFY_BASE_URL = settings.dify_base_url
DIFY_API_KEY = settings.dify_api_key
DIFY_USER_ID = settings.dify_user_id
# 監視用（periodic_update）に叩くエンドポイント。Difyには専用の「状態確認フロー」概念が
# 無いため、任意設定制にしてある。空文字ならpush_loopは自動的に無効化される。
DIFY_STATE_ENDPOINT = settings.dify_state_endpoint
DIFY_TIMEOUT_SEC = settings.dify_timeout_sec
WEBSOCKET_PORT = settings.websocket_port


def _build_payload(user_text: str, conversation_id: str = "") -> dict:
    payload = {
        "inputs": {"message": user_text},
        "response_mode": "blocking",
        "user": DIFY_USER_ID,
    }
    if conversation_id:
        payload["conversation_id"] = conversation_id
    return payload


def _build_headers() -> dict:
    return {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {DIFY_API_KEY}",
    }


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
    """workflows/run のレスポンス data.outputs から本文を取り出す。
    outputs のキー名はワークフロー側の出力変数名に依存するため、
    'message' / 'text' の両方を試し、無ければ outputs 自体を文字列として扱う。
    """
    if not isinstance(result, dict):
        return None
    outputs = result.get("data", {}).get("outputs")
    if isinstance(outputs, dict):
        return outputs.get("message") or outputs.get("text")
    if isinstance(outputs, str):
        return outputs
    return None


def _monitor_agent_status(status_context: dict) -> str | None:
    if not status_context.get("is_monitoring", True) or not DIFY_STATE_ENDPOINT:
        return None

    try:
        payload = _build_payload("")
        headers = _build_headers()
        result, _ = _call_workflow_api(payload, headers, DIFY_STATE_ENDPOINT)

        message_text = _extract_message(result) if result else None
        if not message_text:
            print("\n[-] Error: Payload extraction failed. Output stream is empty.")

        return message_text
    except Exception as e:
        print(f"[-] Error in _monitor_agent_status: {e}")
        return None


class DifyWSServer:
    def __init__(self, host: str = "0.0.0.0", port: int = WEBSOCKET_PORT):
        self.host = host
        self.port = port
        self.session_mgr = SessionManager(timeout=60.0)
        self.clients = set()
        # Dify は session_id ではなく conversation_id で会話継続するため、
        # WSのセッションIDとconversation_idを紐付けて保持する
        self.conversations: dict[str, str] = {}

    async def handler(self, websocket):
        session_id = self.session_mgr.get_id()
        self.clients.add(websocket)
        print(f"[+] Client connected. Session ID: {session_id}")

        try:
            async for message in websocket:
                print(f"[Client -> WS]: {message}")

                loop = asyncio.get_running_loop()
                conversation_id = self.conversations.get(session_id, "")
                payload = _build_payload(message, conversation_id)
                headers = _build_headers()
                endpoint = f"{DIFY_BASE_URL}/workflows/run"

                result, elapsed_time = await loop.run_in_executor(
                    None,
                    partial(_call_workflow_api, payload, headers, endpoint),
                )

                if result:
                    self.conversations[session_id] = result.get("conversation_id", conversation_id)
                    message_text = _extract_message(result)
                    res_data = {
                        "status": "success",
                        "response": message_text or "No text message",
                        "elapsed_time": elapsed_time,
                    }
                else:
                    res_data = {"status": "error", "message": "Workflow execution failed"}

                await websocket.send(json.dumps(res_data, ensure_ascii=False))

        except websockets.exceptions.ConnectionClosedError:
            print("[-] Client disconnected unexpectedly.")
        finally:
            self.clients.discard(websocket)
            self.conversations.pop(session_id, None)
            print(f"[+] Session terminated: {session_id}")

    async def push_loop(self, status_context: dict, interval_seconds: float = 5.0):
        if not DIFY_STATE_ENDPOINT:
            print("[*] DIFY_STATE_ENDPOINT 未設定のため push_loop は無効です。")
            return

        while True:
            loop = asyncio.get_running_loop()
            message_text = await loop.run_in_executor(
                None, _monitor_agent_status, status_context
            )

            if message_text:
                try:
                    parsed_message = json.loads(message_text)
                except (json.JSONDecodeError, TypeError):
                    parsed_message = message_text

                data = {"type": "periodic_update", "message": parsed_message}

                if self.clients:
                    json_message = json.dumps(data, ensure_ascii=False)
                    websockets.broadcast(self.clients, json_message)

            await asyncio.sleep(interval_seconds)

    async def start(self):
        status_context = {"is_monitoring": True}
        asyncio.create_task(self.push_loop(status_context, interval_seconds=5.0))

        async with websockets.serve(
                self.handler,
                self.host,
                self.port,
                ping_interval=20,
                ping_timeout=20
        ):
            print(f"[+] WebSocket Server running on ws://{self.host}:{self.port}")
            await asyncio.Future()


if __name__ == "__main__":
    server = DifyWSServer(host="0.0.0.0", port=WEBSOCKET_PORT)
    try:
        asyncio.run(server.start())
    except KeyboardInterrupt:
        print("\n[+] Exited by user.")