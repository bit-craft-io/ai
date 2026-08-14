#!/bin/bash
# unity-backup.sh
# Sドライブ(Windows)上の Unity プロジェクトから
# リポジトリ内のバックアップディレクトリへ丸ごとコピーする。
#
# 使い方:
#   bash unity-backup.sh              # dry-run(設定表示のみ)
#   bash unity-backup.sh --apply       # バックアップ実行

set -euo pipefail

UNITY_PROJECT_DIR="${UNITY_PROJECT_DIR:-/mnt/s/risuna}"
UNITY_BACKUP_DIR="${UNITY_BACKUP_DIR:-client/unity/backup}"

APPLY=false
if [[ "${1:-}" == "--apply" ]]; then
  APPLY=true
fi

echo "=== Unity Backup Settings ==="
echo "  Source: ${UNITY_PROJECT_DIR}"
echo "  Target: ${UNITY_BACKUP_DIR}"
echo "============================="

if [[ ! -d "${UNITY_PROJECT_DIR}/Assets" ]]; then
  echo "Error: ${UNITY_PROJECT_DIR} is not a valid Unity project." >&2
  exit 1
fi

if [[ "$APPLY" == false ]]; then
  echo ""
  echo "Dry-run mode. Re-run with --apply to execute backup."
  exit 0
fi

echo ""
echo "=== Cleaning old backup ==="
rm -rf "$UNITY_BACKUP_DIR"
mkdir -p "$UNITY_BACKUP_DIR"

echo ""
echo "=== Copying project files ==="
cp -r "${UNITY_PROJECT_DIR}/Assets" "${UNITY_BACKUP_DIR}/"
cp -r "${UNITY_PROJECT_DIR}/ProjectSettings" "${UNITY_BACKUP_DIR}/"

mkdir -p "${UNITY_BACKUP_DIR}/Packages"
cp "${UNITY_PROJECT_DIR}/Packages/manifest.json" "${UNITY_BACKUP_DIR}/Packages/"
cp "${UNITY_PROJECT_DIR}/Packages/packages-lock.json" "${UNITY_BACKUP_DIR}/Packages/" 2>/dev/null || true

# 不要なフォント元素材の削除
find "${UNITY_BACKUP_DIR}/Assets" -type f \( -name "*.ttc" -o -name "*.otf" -o -name "*.ttf" \) -delete

echo ""
echo "Completed"