using System.Collections;
using UnityEngine;
using NativeWebSocket;
using System.Text;
using Network.Response;
using TMPro;
using UnityEngine.UI;

public class WebSockClient : MonoBehaviour
{
    [SerializeField] private WebSockStreamPlayer streamPlayer;
    [SerializeField] private InputField inputField;
    [SerializeField] private Text readField;
    [SerializeField] private Button btnRequest;
    [SerializeField] private Text answerText;
    [SerializeField] private FocalPointSwitcher focalPointSwitcher;
    
    private WebSocket _ws;

    async void Start()
    {
        btnRequest?.onClick.AddListener(SendInputText);
        
        // まずインスタンスを生成
        _ws = new WebSocket("ws://localhost:8765");
        // websocket = new WebSocket("ws://172.28.123.72:8765");

        // イベントハンドラを登録
        _ws.OnOpen += () =>
        {
            Debug.Log("[WS] Connected to Python server!");
            // 初回送信はスタミナが減るのでやめておく
            // SendText("Hello from Unity!");
        };

        _ws.OnError += (e) => { Debug.LogError($"[WS] Error: {e}"); };

        _ws.OnClose += (e) => { Debug.Log("[WS] Connection closed."); };

        _ws.OnMessage += (bytes) =>
        {
            // 送られてきたデータが「テキスト（JSON）」か「バイナリ（音声）」かを判別
            string response = Encoding.UTF8.GetString(bytes);
            Debug.Log($"Received: {response}");

            if (response.StartsWith("{") && response.EndsWith("}"))
            {
                try
                {
                    var obj = JsonUtility.FromJson<ResChat>(response);
                    if (!string.IsNullOrEmpty(obj.text)) // フィールド名要確認
                    {
                        answerText.text = obj.text;
                        focalPointSwitcher.Enable();
                    }
                }
                catch (System.Exception e)
                {
                    Debug.LogError($"JSONパース失敗: {e.Message}");
                }

                return;
            }

            // --- ここからは「音声WAVデータ(bytes)」の処理 ---
            if (streamPlayer == null) return;

            // JSONでなければ「音声WAVデータ(bytes)」として処理してCubeへ流す！
            AudioClip clip = WebSockWavLoader.ToAudioClip(bytes); // WAV変換
            if (clip != null)
            {
                streamPlayer.EnqueueAudio(clip);
            }

            // focalPointSwitcher.Disable()
            StartCoroutine(FocalPointSwitcherDisable());
        };

        // サーバーへ接続開始
        await _ws.Connect();
    }

    void Update()
    {
#if !UNITY_WEBGL || UNITY_EDITOR
        if (_ws != null)
        {
            _ws.DispatchMessageQueue();
        }
#endif
    }

    public async void SendInputText()
    {
        // if (inputField == null) return;
        //
        // string message = inputField.text; // 「New Text」に入力された文字を取得
        
        if (readField == null) return;

        // TODO dummy
        readField.text = "最近の事でなくて良いので、人物や歴史、国について雑学を１つ教えて";
        string message = readField.text;

        if (string.IsNullOrEmpty(message))
        {
            Debug.LogWarning("message is null or empty!");
            return;
        }

        if (_ws != null && _ws.State == WebSocketState.Open)
        {
            await _ws.SendText(message);
        }
    }

    private async void OnApplicationQuit()
    {
        if (_ws != null)
        {
            await _ws.Close();
        }
        
        btnRequest.onClick.RemoveListener(SendInputText);
    }
    
    private IEnumerator FocalPointSwitcherDisable()
    {
        // 少し待って再生開始を確実に検知（キュー投入直後のフレーム対策）
        yield return new WaitForSeconds(0.1f);

        // 再生中＆キューがある間待機
        while (streamPlayer.IsPlaying)
        {
            yield return null;
        }
        
        yield return new WaitForSeconds(1.0f);
        focalPointSwitcher?.Disable();
    }
}