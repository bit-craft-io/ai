#!/bin/bash
# unity-restore.sh
# リポジトリ内のバックアップディレクトリから
# Sドライブ(Windows)上の Unity プロジェクトへ丸ごと復元コピーする。
#
# 使い方:
#   bash unity-restore.sh             # dry-run(設定表示のみ)
#   bash unity-restore.sh --apply      # 復元実行

set -euo pipefail

UNITY_PROJECT_DIR="${UNITY_PROJECT_DIR:-/mnt/s/risuna}"
UNITY_BACKUP_DIR="${UNITY_BACKUP_DIR:-client/unity/backup}"

APPLY=false
if [[ "${1:-}" == "--apply" ]]; then
  APPLY=true
fi

echo "=== Unity Restore Settings ==="
echo "  Source: ${UNITY_BACKUP_DIR}"
echo "  Target: ${UNITY_PROJECT_DIR}"
echo "=============================="

if [[ ! -d "${UNITY_BACKUP_DIR}/Assets" ]]; then
  echo "Error: Backup directory ${UNITY_BACKUP_DIR} not found." >&2
  exit 1
fi

if [[ ! -d "${UNITY_PROJECT_DIR}/Assets" ]]; then
  echo "Error: ${UNITY_PROJECT_DIR} is not a valid Unity project. Create it via Unity Hub first." >&2
  exit 1
fi

if [[ "$APPLY" == false ]]; then
  echo ""
  echo "Dry-run mode. Re-run with --apply to execute restore."
  exit 0
fi

echo ""
echo "=== Restoring project files (Overwriting) ==="
rsync -a --info=progress2 "${UNITY_BACKUP_DIR}/Assets" "${UNITY_PROJECT_DIR}/"
rsync -a --info=progress2 "${UNITY_BACKUP_DIR}/ProjectSettings" "${UNITY_PROJECT_DIR}/"
rsync -a --info=progress2 "${UNITY_BACKUP_DIR}/Packages" "${UNITY_PROJECT_DIR}/"

# LastSceneManagerSetup.txt の復元（存在する場合のみ）
if [[ -f "${UNITY_BACKUP_DIR}/Library/LastSceneManagerSetup.txt" ]]; then
  mkdir -p "${UNITY_PROJECT_DIR}/Library"
  rsync -a "${UNITY_BACKUP_DIR}/Library/LastSceneManagerSetup.txt" "${UNITY_PROJECT_DIR}/Library/"
fi

echo ""
echo "Completed"
