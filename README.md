<style>pre {margin: 6px !important;padding: 6px 8px !important;}</style>
## 概要
- AIエージェント開発・検証のための学習用リポジトリ
### 準備
- direnv（ディレクトリ毎に環境変数を自動設定）
```
sudo apt update
sudo apt install direnv
```
```
echo "# add \$(date +'%Y.%m.%d') direnv" >> ~/.bashrc
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
echo 'export DIRENV_LOG_FORMAT=""' >> ~/.bashrc
```
```
source ~/.bashrc
direnv version
```
```
# .envrc のあるディレクトリでコマンドを実行
direnv allow
```
- python3 をインストール
```
sudo apt update
sudo apt install python3 python3-pip python3-venv
dpkg -l | grep python3-venv
```
```
cd /var/www/bc.ai
python3 -m venv .venv
source .venv/bin/activate
```
- source .venv/bin/activate を自動化
```
cd /var/www/bc.ai
echo "# add \$(date +'%Y.%m.%d') direnv" >> .envrc
echo 'source .venv/bin/activate' >> ~/.envrc

direnv allow
```
- Git LFS 導入
```
cd /var/www/bc.ai
sudo apt update
sudo apt install git-lfs

git lfs install
git lfs version

git lfs track "backup/*.tar.gz"
git add .gitattributes
```
### 各種コマンド
- コンテナ作成
```
make menu
make dify-pull
make dify-up
```
- コンテナ削除
```
make dify-clean
```
