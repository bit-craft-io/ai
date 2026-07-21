SHELL := /bin/bash
.DEFAULT_GOAL := menu

# ========================================
# include
# ----------------------------------------
-include .env
include makefile.d/wsl.mk
include makefile.d/docker.mk
include makefile.d/dify.mk
include makefile.d/crawl.mk
include makefile.d/python.mk
# ========================================
# menu
# ----------------------------------------
TASKS += \
	docker-up \
	docker-down
# ========================================
# command
# ----------------------------------------
.PHONY: menu
menu:
	@# Ctrl+C (SIGINT) が押されたら綺麗に終了させる
	@trap 'echo ""; exit 0' INT; \
	\
	# 1. 親 Makefile から include 行を記述順に抜き出し、拡張子を除去してグループ名にする \
	MENU_GROUPS=$$(awk '/^include makefile\.d\// {print $$2}' Makefile | xargs -n1 basename | sed 's/\.mk$$//' | awk '!visited[$$0]++'); \
	if [ -z "$$MENU_GROUPS" ]; then echo "No .mk files included in Makefile"; exit 1; fi; \
	\
	echo "--- Select Group ---"; \
	echo " 1) _exit"; \
	\
	i=2; \
	for g in $$MENU_GROUPS; do \
		printf "%2d) %s\n" $$i "$$g"; \
		i=$$(($$i + 1)); \
	done; \
	\
	read -p "??: " g_num; \
	if [ "$$g_num" -eq 1 ] 2>/dev/null; then echo "Exit"; exit 0; fi; \
	\
	idx=$$(($$g_num - 1)); \
	#selected_g=$$(echo "$$MENU_GROUPS" | sed -n "$${idx}p"); \
	selected_g=$$(echo "$$MENU_GROUPS" | sed -n "$${idx}p" 2>/dev/null); \
	if [ -z "$$selected_g" ]; then \
		echo "Invalid group"; \
		exit 0; \
	fi; \
	\
	echo "--- Select Task [$$selected_g] ---"; \
	echo " 1) _back"; \
	\
	# 2. 選択されたファイルの中のターゲットを記述順にそのまま抽出 \
	SUB_TASKS=$$(awk -F: '/^[a-zA-Z0-9_-]+:/ {print $$1}' makefile.d/$$selected_g.mk | grep -v '^\.' | awk '!visited[$$0]++'); \
	\
	i=2; \
	for st in $$SUB_TASKS; do \
		printf "%2d) %s\n" $$i "$$st"; \
		i=$$(($$i + 1)); \
	done; \
	\
	read -p "??: " t_num; \
	if [ "$$t_num" -eq 1 ] 2>/dev/null; then exec make --no-print-directory menu; fi; \
	\
	t_idx=$$(($$t_num - 1)); \
	#selected_t=$$(echo "$$SUB_TASKS" | sed -n "$${t_idx}p"); \
	selected_t=$$(echo "$$SUB_TASKS" | sed -n "$${t_idx}p" 2>/dev/null); \
	if [ -n "$$selected_t" ]; then \
		# 【重要】一切のリダイレクトやパイプを通さず生で実行し、警告自体は MAKEFLAGS で抑制する \
		MAKEFLAGS="--no-print-directory" make $$selected_t; \
	else \
		echo "Invalid task"; \
		exit 0; \
	fi

# ========================================
# docker
# ----------------------------------------
.PHONY: docker-up
docker-up:
	@docker network inspect sandbox >/dev/null 2>&1 || docker network create sandbox
	@if [ -f "dify/docker/docker-compose.yaml" ]; then \
		docker compose -p dify -f dify/docker/docker-compose.yaml -f override.d/dify/docker-compose.override.yaml up -d; \
	fi
	@if [ -f "crawl/docker-compose.yaml" ]; then \
		docker compose -p crawl -f crawl/docker-compose.yaml -f override.d/crawl/docker-compose.override.yaml up -d; \
	fi
	@if [ -f "ollama/docker-compose.yaml" ]; then \
		docker compose -p ollama -f ollama/docker-compose.yaml -f override.d/ollama/docker-compose.override.yaml up -d; \
	fi
	@if [ -f "voicevox/docker-compose.yaml" ]; then \
		docker compose -p voicevox -f voicevox/docker-compose.yaml -f override.d/voicevox/docker-compose.override.yaml up -d; \
	fi

.PHONY: docker-down
docker-down:
	@if [ -f "dify/docker/docker-compose.yaml" ]; then \
		docker compose -f ./dify/docker/docker-compose.yaml down; \
	fi
	@if [ -f "ollama/docker-compose.yaml" ]; then \
		docker compose -f ./ollama/docker-compose.yaml down; \
	fi
	@if [ -f "crawl/docker-compose.yaml" ]; then \
		docker compose -f ./crawl/docker-compose.yaml down; \
	fi

.DEFAULT:
	@echo "[WARN] target '$@' unknown"