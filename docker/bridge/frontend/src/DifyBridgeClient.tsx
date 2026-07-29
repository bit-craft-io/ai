import { useState, useRef, useCallback, useEffect } from "react";

/**
 * Dify WebSocket Bridge Client
 * 対象サーバ: DifyWSServer (websockets, /workflows/run 中継)
 *
 * プロトコル(サーバ実装準拠):
 *   送信: 生テキスト(JSON化しない) — websocket.send(text)
 *   受信(応答):        { status: "success" | "error", response?: string, message?: string, elapsed_time?: number }
 *   受信(push, 5秒毎): { type: "periodic_update", message: unknown }
 */

type ConnectionState = "disconnected" | "connecting" | "connected" | "error";

interface AckResponse {
  status?: "success" | "error";
  response?: string;
  message?: string;
  elapsed_time?: number;
}

interface PushUpdate {
  type: "periodic_update";
  message: unknown;
}

type InboundMessage = AckResponse | PushUpdate;

interface LogEntry {
  id: string;
  kind: "sent" | "recv_success" | "recv_error" | "push" | "system";
  timestamp: string;
  text: string;
  meta?: string;
}

const genId = () => Math.random().toString(36).slice(2, 10);

const nowLabel = () =>
  new Date().toLocaleTimeString("ja-JP", { hour12: false }) +
  "." +
  String(new Date().getMilliseconds()).padStart(3, "0");

function isPushUpdate(m: InboundMessage): m is PushUpdate {
  return (m as PushUpdate).type === "periodic_update";
}

export default function DifyBridgeClient() {
  const [url, setUrl] = useState("ws://localhost:8765");
  const [state, setState] = useState<ConnectionState>("disconnected");
  const [message, setMessage] = useState("");
  const [logs, setLogs] = useState<LogEntry[]>([]);
  const [autoScroll, setAutoScroll] = useState(true);
  const [pending, setPending] = useState(false);

  const wsRef = useRef<WebSocket | null>(null);
  const logEndRef = useRef<HTMLDivElement | null>(null);

  const pushLog = useCallback((entry: Omit<LogEntry, "id" | "timestamp">) => {
    setLogs((prev) => [...prev, { ...entry, id: genId(), timestamp: nowLabel() }]);
  }, []);

  useEffect(() => {
    if (autoScroll) logEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [logs, autoScroll]);

  useEffect(() => {
    return () => {
      wsRef.current?.close();
    };
  }, []);

  const connect = useCallback(() => {
    if (wsRef.current) wsRef.current.close();
    setState("connecting");
    pushLog({ kind: "system", text: `接続開始: ${url}` });

    let socket: WebSocket;
    try {
      socket = new WebSocket(url);
    } catch (e) {
      setState("error");
      pushLog({ kind: "system", text: `接続失敗: ${(e as Error).message}` });
      return;
    }

    socket.onopen = () => {
      setState("connected");
      pushLog({ kind: "system", text: "接続確立" });
    };

    socket.onmessage = (event) => {
      let parsed: InboundMessage | null = null;
      try {
        parsed = JSON.parse(event.data);
      } catch {
        pushLog({ kind: "recv_error", text: String(event.data), meta: "JSON解析失敗" });
        return;
      }

      if (parsed && isPushUpdate(parsed)) {
        const body =
          typeof parsed.message === "string"
            ? parsed.message
            : JSON.stringify(parsed.message, null, 2);
        pushLog({ kind: "push", text: body, meta: "periodic_update" });
        return;
      }

      const ack = parsed as AckResponse;
      setPending(false);
      if (ack.status === "success") {
        pushLog({
          kind: "recv_success",
          text: ack.response ?? "(応答本文なし)",
          meta:
            ack.elapsed_time !== undefined
              ? `elapsed: ${ack.elapsed_time.toFixed(2)}s`
              : undefined,
        });
      } else {
        pushLog({
          kind: "recv_error",
          text: ack.message ?? "(エラー詳細なし)",
          meta: `status: ${ack.status ?? "unknown"}`,
        });
      }
    };

    socket.onerror = () => {
      setState("error");
      pushLog({ kind: "system", text: "接続エラー発生" });
    };

    socket.onclose = (event) => {
      setState("disconnected");
      pushLog({
        kind: "system",
        text: `切断 (code=${event.code}${event.reason ? `, reason=${event.reason}` : ""})`,
      });
    };

    wsRef.current = socket;
  }, [url, pushLog]);

  const disconnect = useCallback(() => {
    wsRef.current?.close(1000, "manual disconnect");
  }, []);

  const sendMessage = useCallback(() => {
    if (!wsRef.current || state !== "connected" || message.trim().length === 0) return;
    wsRef.current.send(message);
    pushLog({ kind: "sent", text: message });
    setPending(true);
    setMessage("");
  }, [state, message, pushLog]);

  const handleKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === "Enter" && (e.metaKey || e.ctrlKey)) {
      e.preventDefault();
      sendMessage();
    }
  };

  const clearLogs = () => setLogs([]);

  const stateColor: Record<ConnectionState, string> = {
    disconnected: "#6b7280",
    connecting: "#d97706",
    connected: "#16a34a",
    error: "#dc2626",
  };
  const stateLabel: Record<ConnectionState, string> = {
    disconnected: "未接続",
    connecting: "接続中",
    connected: "接続済み",
    error: "エラー",
  };

  return (
    <div
      style={{
        fontFamily: "'JetBrains Mono', 'SFMono-Regular', Consolas, monospace",
        background: "#0d1117",
        color: "#c9d1d9",
        minHeight: "100vh",
        padding: "24px",
        boxSizing: "border-box",
      }}
    >
      <div style={{ maxWidth: 900, margin: "0 auto" }}>
        <header
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            marginBottom: 20,
          }}
        >
          <h1 style={{ fontSize: 16, fontWeight: 600, letterSpacing: 1, margin: 0, color: "#e6edf3" }}>
            DIFY WS BRIDGE
          </h1>
          <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
            <span
              style={{
                width: 8,
                height: 8,
                borderRadius: "50%",
                background: stateColor[state],
                display: "inline-block",
              }}
            />
            <span style={{ fontSize: 12, color: "#8b949e" }}>{stateLabel[state]}</span>
          </div>
        </header>

        <section style={{ display: "flex", gap: 8, marginBottom: 16 }}>
          <input
            value={url}
            onChange={(e) => setUrl(e.target.value)}
            disabled={state === "connected" || state === "connecting"}
            placeholder="ws://localhost:8765"
            style={inputStyle({ flex: 1 })}
          />
          {state === "connected" || state === "connecting" ? (
            <button onClick={disconnect} style={btnStyle("#dc2626")}>
              切断
            </button>
          ) : (
            <button onClick={connect} style={btnStyle("#238636")}>
              接続
            </button>
          )}
        </section>

        <section
          style={{
            background: "#161b22",
            border: "1px solid #30363d",
            borderRadius: 6,
            padding: 16,
            marginBottom: 16,
          }}
        >
          <textarea
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            onKeyDown={handleKeyDown}
            rows={4}
            placeholder="Difyへ送るメッセージ (Cmd/Ctrl+Enterで送信)"
            style={{ ...inputStyle({ width: "100%" }), resize: "vertical", fontFamily: "inherit" }}
          />
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginTop: 10 }}>
            <span style={{ fontSize: 12, color: pending ? "#d97706" : "#484f58" }}>
              {pending ? "応答待ち…" : ""}
            </span>
            <button
              onClick={sendMessage}
              disabled={state !== "connected" || message.trim().length === 0}
              style={btnStyle(state === "connected" ? "#1f6feb" : "#30363d")}
            >
              送信
            </button>
          </div>
        </section>

        <section>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 8 }}>
            <span style={{ fontSize: 12, color: "#8b949e" }}>LOG ({logs.length})</span>
            <div style={{ display: "flex", gap: 12, alignItems: "center" }}>
              <label style={{ fontSize: 12, color: "#8b949e", display: "flex", alignItems: "center", gap: 4 }}>
                <input type="checkbox" checked={autoScroll} onChange={(e) => setAutoScroll(e.target.checked)} />
                自動スクロール
              </label>
              <button onClick={clearLogs} style={{ ...btnStyle("#21262d"), padding: "4px 10px", fontSize: 12 }}>
                クリア
              </button>
            </div>
          </div>

          <div
            style={{
              background: "#010409",
              border: "1px solid #30363d",
              borderRadius: 6,
              height: 400,
              overflowY: "auto",
              padding: 12,
              fontSize: 12,
              lineHeight: 1.5,
            }}
          >
            {logs.length === 0 && <div style={{ color: "#484f58" }}>ログなし</div>}
            {logs.map((log) => (
              <div key={log.id} style={{ marginBottom: 10 }}>
                <div style={{ color: "#484f58" }}>
                  [{log.timestamp}] <span style={{ color: kindColor(log.kind) }}>{kindLabel(log.kind)}</span>
                  {log.meta && <span style={{ color: "#6e7681" }}> ({log.meta})</span>}
                </div>
                <pre
                  style={{
                    margin: "2px 0 0 0",
                    whiteSpace: "pre-wrap",
                    wordBreak: "break-all",
                    color: log.kind === "recv_error" ? "#f85149" : "#c9d1d9",
                  }}
                >
                  {log.text}
                </pre>
              </div>
            ))}
            <div ref={logEndRef} />
          </div>
        </section>
      </div>
    </div>
  );
}

function kindLabel(k: LogEntry["kind"]) {
  switch (k) {
    case "sent":
      return "SENT";
    case "recv_success":
      return "RECV";
    case "recv_error":
      return "ERROR";
    case "push":
      return "PUSH";
    default:
      return "SYS";
  }
}

function kindColor(k: LogEntry["kind"]) {
  switch (k) {
    case "sent":
      return "#58a6ff";
    case "recv_success":
      return "#3fb950";
    case "recv_error":
      return "#f85149";
    case "push":
      return "#a371f7";
    default:
      return "#8b949e";
  }
}

function inputStyle(extra: React.CSSProperties = {}): React.CSSProperties {
  return {
    background: "#0d1117",
    border: "1px solid #30363d",
    borderRadius: 4,
    color: "#c9d1d9",
    padding: "8px 10px",
    fontSize: 13,
    fontFamily: "inherit",
    outline: "none",
    boxSizing: "border-box",
    ...extra,
  };
}

function btnStyle(bg: string): React.CSSProperties {
  return {
    background: bg,
    color: "#fff",
    border: "none",
    borderRadius: 4,
    padding: "8px 16px",
    fontSize: 13,
    cursor: "pointer",
    fontFamily: "inherit",
  };
}
