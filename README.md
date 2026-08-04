## 概要
- AIエージェント開発・検証のための学習用リポジトリ
### Make内容の説明
```
make
```
```
/
├── _common                               # 共通コマンド
│   └── _setup_all                        # 必要な環境構築処理を順番に実行
├── wsl                                   # WSL・Ollama環境の管理
│   ├── wsl-tool-install                  # 開発環境ツールのインストール
│   ├── wsl-git_lfs-setup                 # Git LFSの設定
│   ├── wsl-ollama-install                # Ollamaをインストール
│   ├── wsl-ollama-model-pull             # モデルをダウンロード
│   ├── wsl-ollama-model-list             # モデル一覧を表示
│   └── wsl-ollama-model-clean            # 未使用モデルを削除
│
├── docker                                # Docker環境の管理
│   ├── docker-up                         # コンテナを起動
│   ├── docker-down                       # コンテナを停止
│   └── docker-purge                      # コンテナ・イメージ等を削除
│
├── dify                                  # Dify環境の管理
│   ├── dify-git-pull                     # 最新ソースを取得
│   ├── dify-git-destroy                  # Git管理を初期化
│   ├── dify-cache-remove                 # キャッシュを削除
│   ├── dify-backup                       # バックアップを作成
│   ├── dify-backup-size                  # バックアップ容量を表示
│   ├── dify-backup-list                  # バックアップ一覧を表示
│   ├── dify-backup-prune                 # 古いバックアップを削除
│   └── dify-restore                      # バックアップを復元
│
├── crawl                                 # クローラー環境の管理
│   ├── crawl-git-pull                    # 最新ソースを取得
│   ├── crawl-git-del                     # Git管理を削除
│   ├── crawl-docker-up                   # クローラーを起動
│   └── crawl-docker-down                 # クローラーを停止
│
├── python                                # Python環境の構築
│   ├── python-install                    # Pythonをインストール
│   └── python-setup                      # Python環境を設定
│
└── tools                                 # 補助ツール
    ├── windows-setup                     # Windows初期設定
    ├── mic-spk-enable                    # マイク・スピーカーを有効化
    ├── mic-spk-disable                   # マイク・スピーカーを無効化
    └── nvidia-smi                        # GPU情報を表示
```
### コンテナを起動の準備
```
make
```
```
--- Select Group ---
> _common
--- Select Task [_common] ---
> _setup_all

実行内容:
- WSL環境構築
- Git LFS設定
- Ollamaモデル取得
- Python環境構築
- Dify取得
- Crawl取得
```
### コンテナを起動
```
make
```
```
--- Select Group ---
> docker
--- Select Task [_common] ---
> docker-up
```
### デモデータをリストア
```
--- Select Group ---
> dify
--- Select Task [_common] ---
> dify-restore
```
### コンテナにアクセス
- [Dify コンテナ](http://localhost)<br />
u: admin@localhost.com<br />
p: admin1234
- [WebSocket 通信確認](http://localhost:5173)<br />
