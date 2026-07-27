#!/bin/bash
# dify-cache-check.sh
# Dify plugin_daemon の plugin_packages キャッシュから、
# DB(dify_plugin)上どの *_installations テーブルにも紐付いてない
# 孤児 .difypkg を検出・削除する。
#
# 呼び出しはMakefile経由を想定、以下の環境変数を利用:
#   DIFY_COMPOSE_FILE   (例: docker/dify/docker/docker-compose.yaml)
#   DIFY_DB_CONTAINER   (例: db_postgres)
#   DIFY_DB_USER        (例: postgres)
#   DIFY_DB_NAME_PLUGIN (例: dify_plugin)
#   DIFY_VOLUMES_DIR    (例: docker/dify/docker/volumes)
#
# 使い方:
#   bash dify-cache-check.sh              # dry-run(一覧表示のみ)
#   bash dify-cache-check.sh --apply       # 実削除

set -euo pipefail

: "${DIFY_COMPOSE_FILE:?DIFY_COMPOSE_FILE is not set}"
: "${DIFY_DB_CONTAINER:?DIFY_DB_CONTAINER is not set}"
: "${DIFY_DB_USER:?DIFY_DB_USER is not set}"
: "${DIFY_DB_NAME_PLUGIN:?DIFY_DB_NAME_PLUGIN is not set}"
: "${DIFY_VOLUMES_DIR:?DIFY_VOLUMES_DIR is not set}"

PKG_DIR="${DIFY_VOLUMES_DIR}/plugin_daemon/plugin_packages"

APPLY=false
if [[ "${1:-}" == "--apply" ]]; then
  APPLY=true
fi

echo "=== In-use identifiers (DB *_installations) ==="
USED=$(docker compose -f "$DIFY_COMPOSE_FILE" exec -T "$DIFY_DB_CONTAINER" \
  psql -U "$DIFY_DB_USER" -d "$DIFY_DB_NAME_PLUGIN" -t -A -c "
    SELECT plugin_unique_identifier FROM tool_installations
    UNION SELECT plugin_unique_identifier FROM ai_model_installations
    UNION SELECT plugin_unique_identifier FROM datasource_installations
    UNION SELECT plugin_unique_identifier FROM agent_strategy_installations
    UNION SELECT plugin_unique_identifier FROM trigger_installations
  ")
echo "$USED"
echo "================================================="

ORPHANS=()
while IFS= read -r f; do
  rel="${f#"$PKG_DIR"/}"
  if ! grep -qF "$rel" <<< "$USED"; then
    ORPHANS+=("$f")
  fi
done < <(find "$PKG_DIR" -type f)

if [[ ${#ORPHANS[@]} -eq 0 ]]; then
  echo "No orphaned files found."
  exit 0
fi

echo ""
echo "=== Orphaned files (${#ORPHANS[@]}) ==="
for f in "${ORPHANS[@]}"; do
  echo "  $f"
done

if [[ "$APPLY" == false ]]; then
  echo ""
  echo "Dry-run mode. Re-run with --apply to delete:"
  echo "  make dify-cache-clear"
  exit 0
fi

echo ""
echo "=== Deleting ==="
for f in "${ORPHANS[@]}"; do
  sudo rm -fv "$f"
done

# Also remove now-empty provider directories (e.g. watercrawl/)
find "$PKG_DIR" -mindepth 1 -maxdepth 1 -type d -empty -exec rmdir {} \;

echo "Completed"