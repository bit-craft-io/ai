#!/usr/bin/env bash
set -euo pipefail

APPLY=false
if [ "${1:-}" == "--apply" ]; then
  APPLY=true
fi

DOC_COUNT=$(docker compose -f "$DIFY_COMPOSE_FILE" exec -T "$DIFY_DB_CONTAINER" \
  psql -U "$DIFY_DB_USER" -d "$DIFY_DB_NAME" -t -A -c "SELECT count(*) FROM documents;")

echo "documents count: $DOC_COUNT"

if [ "$DOC_COUNT" -ne 0 ]; then
  echo "[ABORT] documents table is not empty (${DOC_COUNT} rows)."
  echo "        website_files may still be referenced. Skipping deletion."
  exit 1
fi

TARGET_DIR="${DIFY_VOLUMES_DIR}/app/storage/website_files"

if [ ! -d "$TARGET_DIR" ]; then
  echo "[SKIP] ${TARGET_DIR} does not exist."
  exit 0
fi

FILE_COUNT=$(find "$TARGET_DIR" -type f | wc -l)
DIR_SIZE=$(du -sh "$TARGET_DIR" | cut -f1)

echo "target: $TARGET_DIR"
echo "files : $FILE_COUNT"
echo "size  : $DIR_SIZE"

if [ "$APPLY" = true ]; then
  echo "[APPLY] removing files under $TARGET_DIR ..."
  find "$TARGET_DIR" -mindepth 1 -delete
  echo "[DONE]"
else
  echo "[DRY-RUN] no files deleted. Re-run with --apply to delete."
fi