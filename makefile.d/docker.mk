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
	@if [ -f "dify/docker/docker-compose.yaml" ]; then \
		docker compose -f ./dify/docker/docker-compose.yaml up -d; \
	fi; \
	\
	@if [ -f "ollama/docker-compose.yaml" ]; then \
		docker compose -f ./ollama/docker-compose.yaml up -d; \
	fi; \
	\
	@if [ -f "crawl/docker-compose.yaml" ]; then \
		docker compose -f ./crawl/docker-compose.yaml up -d; \
	fi

.PHONY: docker-down
docker-down:
	@if [ -f "dify/docker/docker-compose.yaml" ]; then \
		docker compose -f ./dify/docker/docker-compose.yaml down; \
	fi; \
	\
	@if [ -f "dify/docker/docker-compose.yaml" ]; then \
		docker compose -f ./docker-compose.yaml down; \
	fi; \
	\
	@if [ -f "crawl/docker-compose.yaml" ]; then \
		docker compose -f ./crawl/docker-compose.yaml down; \
	fi

