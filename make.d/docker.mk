-include make.d/.env
export
SHELL := /bin/bash

# ========================================
# menu
# ----------------------------------------
TASKS += \
	docker-up \
	docker-down \
	docker-clean

# ========================================
# command
# ----------------------------------------
# サービス定義: 名称/パス（区切りを半角スペースに変更）
SERVICES := \
    dify docker/dify/docker/docker-compose.yaml \
    crawl docker/crawl/docker-compose.yaml \
    ollama docker/ollama/docker-compose.yaml \
    voicevox docker/voicevox/docker-compose.yaml

.PHONY: docker-up
docker-up:
	@docker network inspect sandbox >/dev/null 2>&1 || docker network create sandbox || true
	@set -- $(SERVICES); \
	while [ $$# -gt 0 ]; do \
	   p="$$1"; f="$$2"; shift 2; \
	   o="docker/override.d/$$p/docker-compose.override.yaml"; \
	   if [ -f "$$f" ]; then \
	      cmd="docker compose -p $$p --env-file make.d/.env -f $$f"; \
	      [ -f "$$o" ] && cmd="$$cmd -f $$o"; \
	      $$cmd up -d; \
	   fi; \
	done

.PHONY: docker-down
docker-down:
	@docker network rm sandbox 2>/dev/null || true
	@set -- $(SERVICES); \
	while [ $$# -gt 0 ]; do \
	   p="$$1"; f="$$2"; shift 2; \
	   if [ -f "$$f" ]; then \
	      docker compose -p $$p --env-file make.d/.env -f $$f down; \
	   fi; \
	done

.PHONY: docker-clean
docker-clean:
	@read -p "docker compose down -v [y/N]: " ans; \
	if [ "$$ans" != "y" ] && [ "$$ans" != "yes" ]; then \
	   echo "Cancelled."; \
	   exit 0; \
	fi; \
	docker network rm sandbox 2>/dev/null || true; \
	set -- $(SERVICES); \
	while [ $$# -gt 0 ]; do \
	   p="$$1"; f="$$2"; shift 2; \
	   if [ -f "$$f" ]; then \
	      docker compose -p $$p --env-file make.d/.env -f $$f down -v; \
	   fi; \
	done