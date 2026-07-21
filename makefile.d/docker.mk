-include makefile.d/.env
export
SHELL := /bin/bash

# ========================================
# menu
# ----------------------------------------
TASKS += \
	docker-up \
	docker-down

# ========================================
# docker
# ----------------------------------------
.PHONY: docker-up
docker-up:
	@docker network inspect sandbox >/dev/null 2>&1 || docker network create sandbox || true

	@if [ -f "$(__DIFY_ROOT)/docker/docker-compose.yaml" ]; then \
		docker compose \
			-p dify \
			-f $(__DIFY_ROOT)/docker/docker-compose.yaml \
			-f docker/override.d/dify/docker-compose.override.yaml \
			up -d; \
	fi

	@if [ -f "$(__CRAWL_ROOT)/docker-compose.yaml" ]; then \
		docker compose \
			-p crawl \
			-f $(__CRAWL_ROOT)/docker-compose.yaml \
			-f docker/override.d/crawl/docker-compose.override.yaml \
			up -d; \
	fi

	@if [ -f "$(__OLLAMA_ROOT)/docker-compose.yaml" ]; then \
		docker compose \
			-p ollama \
			-f $(__OLLAMA_ROOT)/docker-compose.yaml \
			-f docker/override.d/ollama/docker-compose.override.yaml \
			up -d; \
	fi

	@if [ -f "$(__VOICEVOX_ROOT)/docker-compose.yaml" ]; then \
		docker compose \
			-p voicevox \
			-f $(__VOICEVOX_ROOT)/docker-compose.yaml \
			-f docker/override.d/voicevox/docker-compose.override.yaml \
			up -d; \
	fi

.PHONY: docker-down
docker-down:
	@docker network rm sandbox 2>/dev/null || true
	@if [ -f "dify/docker/docker-compose.yaml" ]; then \
		docker compose -f ./dify/docker/docker-compose.yaml down; \
	fi
	@if [ -f "crawl/docker-compose.yaml" ]; then \
  		docker compose -f ./crawl/docker-compose.yaml down; \
  	fi
	@if [ -f "ollama/docker-compose.yaml" ]; then \
		docker compose -f ./ollama/docker-compose.yaml down; \
	fi
	@if [ -f "voicevox/docker-compose.yaml" ]; then \
		docker compose -f ./voicevox/docker-compose.yaml down; \
	fi
