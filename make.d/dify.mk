-include make.d/.env
export
SHELL := /bin/bash

# ========================================
# menu
# ----------------------------------------
TASKS += \
	dify-git-pull \
	dify-git-dell \
	dify-docker-up \
	dify-docker-down \
	dify-backup \
	dify-backup-list \
	dify-backup-clean \
	dify-restore
# ========================================
# command
# ----------------------------------------
.PHONY: dify-git-pull
dify-git-pull:
	@if [ ! -d "$(__DOCKER_ROOT_DIFY)" ]; then \
		echo "repository clone dify"; \
		git clone --branch 1.15.0 --depth 1 https://github.com/langgenius/dify.git $(__DOCKER_ROOT_DIFY); \
		yes | rm -r $(__DOCKER_ROOT_DIFY)/.git; \
		yes | rm -r $(__DOCKER_ROOT_DIFY)/.gemini; \
		yes | rm -r $(__DOCKER_ROOT_DIFY)/.github; \
		echo "make .env from .env.example"; \
		cp $(__DOCKER_ROOT_DIFY)/docker/.env.example $(__DOCKER_ROOT_DIFY)/docker/.env; \
		echo "make .env from .env.example with custom project name"; \
		echo "COMPOSE_PROJECT_NAME=dify" >> $(__DOCKER_ROOT_DIFY)/docker/.env; \
#		echo "SECRET_KEY=$(__DIFY_SECRET_KEY)" >> $(__DOCKER_ROOT_DIFY)/docker/.env; \
	else \
		echo "exist dify make skip"; \
	fi

.PHONY: dify-git-dell
dify-git-dell:
	@# ユーザーに実行確認を求める
	@read -p "Are you sure you want to delete dify? [y/N]: " ans; \
	if [ "$$ans" != "y" ] && [ "$$ans" != "yes" ]; then \
		echo "Cancelled."; \
		exit 0; \
	fi; \
	sudo rm -rf $(__DOCKER_ROOT_DIFY)

# ========================================
# Dify バックアップ / リストア
# ----------------------------------------
# ディレクトリ構成:
#   backup/                最新バックアップの実体（git管理対象）
#   backup/history/<TS>/   世代ごとの履歴（git対象外）
#   backup/latest          history内最新へのsymlink（git対象外）
# ----------------------------------------
BACKUP_ROOT     := $(__DIFY_BACKUP_ROOT)
HISTORY_ROOT    := $(BACKUP_ROOT)/history
TIMESTAMP       := $(shell date +%Y%m%d_%H%M%S)
BACKUP_DIR      := $(HISTORY_ROOT)/$(TIMESTAMP)
LATEST_LINK     := $(BACKUP_ROOT)/latest
GIT_BACKUP_DIR  := $(BACKUP_ROOT)
DB_NAME_PLUGIN  := dify_plugin

# ========================================
# Dify バックアップ
# ----------------------------------------
.PHONY: dify-backup
dify-backup:
	mkdir -p $(BACKUP_DIR)

	docker compose -f $(__DIFY_COMPOSE_FILE) exec $(__DIFY_DB_CONTAINER) pg_dump -U $(__DIFY_DB_USER) -d $(__DIFY_DB_NAME) > $(BACKUP_DIR)/dify_db.sql
	docker compose -f $(__DIFY_COMPOSE_FILE) exec $(__DIFY_DB_CONTAINER) pg_dump -U $(__DIFY_DB_USER) -d $(DB_NAME_PLUGIN) > $(BACKUP_DIR)/dify_plugin_db.sql

	docker compose -f $(__DIFY_COMPOSE_FILE) stop weaviate plugin_daemon
	sudo tar -czf $(BACKUP_DIR)/weaviate_data.tar.gz -C $(__DIFY_VOLUMES_DIR) weaviate
	sudo tar -czf $(BACKUP_DIR)/storage_data.tar.gz -C $(__DIFY_VOLUMES_DIR) app/storage
	# plugin_daemonは実行環境(cwd)を除外し、.difypkg本体等の軽量データのみ保存
	# cwdはdaemon起動時に自動再構築されるため保存不要（検証済み）
	sudo tar -czf $(BACKUP_DIR)/plugin_files.tar.gz \
		-C $(__DIFY_VOLUMES_DIR)/plugin_daemon plugin plugin_packages assets
	docker compose -f $(__DIFY_COMPOSE_FILE) start weaviate plugin_daemon

	sudo chown $(shell whoami):$(shell whoami) $(BACKUP_DIR)/*

	@rm -f $(LATEST_LINK)
	@ln -s history/$(TIMESTAMP) $(LATEST_LINK)

	# git管理対象のbackup/直下へ実ファイルとしてコピー（最新版のみ保持）
	@cp $(BACKUP_DIR)/*.sql $(BACKUP_DIR)/*.tar.gz $(GIT_BACKUP_DIR)/

	@echo "=========================================="
	@echo " backup done: $(BACKUP_DIR)"
	@echo " git-tracked copy -> $(GIT_BACKUP_DIR)/"
	@echo " (latest -> $(LATEST_LINK))"
	@echo "=========================================="

# ========================================
# Dify リストア
# 使い方:
#   make dify-restore                      # git管理対象(backup/直下)から復元
#   make dify-restore DIR=backup/latest     # ローカル最新から復元
#   make dify-restore DIR=backup/history/20260715_161500  # 世代指定
# ----------------------------------------
DIR ?= $(BACKUP_ROOT)
.PHONY: dify-restore
dify-restore:
	@test -f $(DIR)/dify_db.sql || (echo "[ERROR] backup not found: $(DIR)"; exit 1)

	docker compose -f $(__DIFY_COMPOSE_FILE) down
	docker compose -f $(__DIFY_COMPOSE_FILE) up -d db_postgres

	@echo "waiting for postgres..."
	@until docker compose -f $(__DIFY_COMPOSE_FILE) exec $(__DIFY_DB_CONTAINER) pg_isready -U $(__DIFY_DB_USER) > /dev/null 2>&1; do sleep 1; done

	docker compose -f $(__DIFY_COMPOSE_FILE) exec $(__DIFY_DB_CONTAINER) psql -U $(__DIFY_DB_USER) -c "DROP DATABASE IF EXISTS $(__DIFY_DB_NAME);"
	docker compose -f $(__DIFY_COMPOSE_FILE) exec $(__DIFY_DB_CONTAINER) psql -U $(__DIFY_DB_USER) -c "CREATE DATABASE $(__DIFY_DB_NAME);"
	@echo "restoring dify_db..."
	@cat $(DIR)/dify_db.sql | docker compose -f $(__DIFY_COMPOSE_FILE) exec -T $(__DIFY_DB_CONTAINER) psql -U $(__DIFY_DB_USER) -d $(__DIFY_DB_NAME) > /dev/null

	docker compose -f $(__DIFY_COMPOSE_FILE) exec $(__DIFY_DB_CONTAINER) psql -U $(__DIFY_DB_USER) -c "DROP DATABASE IF EXISTS $(DB_NAME_PLUGIN);"
	docker compose -f $(__DIFY_COMPOSE_FILE) exec $(__DIFY_DB_CONTAINER) psql -U $(__DIFY_DB_USER) -c "CREATE DATABASE $(DB_NAME_PLUGIN);"
	@echo "restoring dify_plugin..."
	@cat $(DIR)/dify_plugin_db.sql | docker compose -f $(__DIFY_COMPOSE_FILE) exec -T $(__DIFY_DB_CONTAINER) psql -U $(__DIFY_DB_USER) -d $(DB_NAME_PLUGIN) > /dev/null

	sudo tar -xzf $(DIR)/weaviate_data.tar.gz -C $(__DIFY_VOLUMES_DIR)
	sudo tar -xzf $(DIR)/storage_data.tar.gz -C $(__DIFY_VOLUMES_DIR)

	# plugin本体を配置。cwdはdaemon起動時に自動再構築される
	mkdir -p $(__DIFY_VOLUMES_DIR)/plugin_daemon
	sudo tar -xzf $(DIR)/plugin_files.tar.gz -C $(__DIFY_VOLUMES_DIR)/plugin_daemon

	docker compose -f $(__DIFY_COMPOSE_FILE) down
	docker compose -f $(__DIFY_COMPOSE_FILE) up -d

	@echo "=========================================="
	@echo " restore done from: $(DIR)"
	@echo " plugin_daemonのcwd自動再構築を待つ(数十秒〜)"
	@echo "=========================================="

# ========================================
# 補助
# ----------------------------------------
.PHONY: dify-backup-list
dify-backup-list:
	@ls -1 $(HISTORY_ROOT)/ 2>/dev/null || echo "no history backups"

# 7日以上前の世代を削除（history配下のみ、backup/直下とlatestは維持）
.PHONY: dify-backup-clean
dify-backup-clean:
	find $(HISTORY_ROOT)/ -maxdepth 1 -type d -mtime +7 -exec rm -rf {} \;
	@echo "[OK] old history backups (>7days) removed"