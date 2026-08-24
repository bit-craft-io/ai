#!/usr/bin/env bash
set -euo pipefail

APPLY=false
if [ "${1:-}" == "--apply" ]; then
  APPLY=true
fi

VECTOR_DIR="${DIFY_VOLUMES_DIR}/weaviate"
WEAVIATE_URL="${DIFY_WEAVIATE_URL:-http://localhost:18080}"

# .envに設定済みのAPIキーを、コンテナの環境変数から動的取得(Makefile側に二重管理しない)
WEAVIATE_API_KEY=$(docker compose -f "$DIFY_COMPOSE_FILE" exec -T "$DIFY_RAG_CONTAINER" \
  printenv AUTHENTICATION_APIKEY_ALLOWED_KEYS)

echo "--------------------------------------------------------------------------------"
echo "weaviate orphaned vector_index cleanup: dry-run"
echo "--------------------------------------------------------------------------------"

SCHEMA=$(curl -s -H "Authorization: Bearer ${WEAVIATE_API_KEY}" "${WEAVIATE_URL}/v1/schema" || true)

if [ -z "$SCHEMA" ]; then
  echo "[ABORT] Failed to fetch schema from weaviate (${WEAVIATE_URL}). Aborting for safety."
  exit 0
fi

LIVE_CLASSES=$(echo "$SCHEMA" | grep -o '"class":"[^"]*"' | sed 's/"class":"//;s/"//' | tr '[:upper:]' '[:lower:]')

echo "Live classes in schema:"
if [ -z "$LIVE_CLASSES" ]; then
  echo "  (none)"
else
  echo "$LIVE_CLASSES" | sed 's/^/  - /'
fi
echo ""

mapfile -t DIRS < <(find "$VECTOR_DIR" -maxdepth 1 -type d -name 'vector_index_*_node' -printf '%f\n' 2>/dev/null || true)

ORPHANS=()
for dir in "${DIRS[@]}"; do
  if ! echo "$LIVE_CLASSES" | grep -qx "$dir"; then
    ORPHANS+=("$dir")
  fi
done

echo "Disk directories: ${#DIRS[@]} found"
echo "Orphaned (not in schema): ${#ORPHANS[@]} found"
echo ""

if [ "${#ORPHANS[@]}" -eq 0 ]; then
  echo "[SKIP] No orphaned vector_index directories found. Nothing to do."
  exit 0
fi

for orphan in "${ORPHANS[@]}"; do
  size=$(du -sh "${VECTOR_DIR}/${orphan}" 2>/dev/null | cut -f1)
  echo "  [ORPHAN] ${orphan} (${size})"
done
echo "--------------------------------------------------------------------------------"

if [ "$APPLY" = false ]; then
  echo "[DRY-RUN] no directories deleted. Re-run with --apply to delete."
  exit 0
fi

read -p "This will permanently delete the above orphaned directories. Continue? [y/N]: " ans
if [ "$ans" != "y" ] && [ "$ans" != "yes" ]; then
  echo "Cancelled."
  exit 0
fi

echo "Stopping weaviate..."
docker compose -f "$DIFY_COMPOSE_FILE" stop weaviate

for orphan in "${ORPHANS[@]}"; do
  echo "Removing ${orphan}..."
  sudo rm -rf "${VECTOR_DIR:?}/${orphan}"
done

echo "Starting weaviate..."
docker compose -f "$DIFY_COMPOSE_FILE" up -d weaviate

echo "Waiting for weaviate to become ready..."
sleep 5
docker compose -f "$DIFY_COMPOSE_FILE" exec -T "$DIFY_RAG_CONTAINER" \
  curl -s "http://localhost:8080/v1/.well-known/ready" && echo " -> ready"

echo "--------------------------------------------------------------------------------"
echo "[OK] Weaviate orphaned vector_index cleanup Successfully!"
echo "--------------------------------------------------------------------------------"