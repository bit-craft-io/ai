-include make.d/.env
export
SHELL := /bin/bash

# ========================================
# menu
# ----------------------------------------
TASKS += \
	docker-up \
	docker-down \
	docker-purge
# ========================================
# command
# ----------------------------------------
DIFY_COMPOSE     := $(__DOCKER_ROOT_DIFY)/docker-compose.yaml
CRAWL_COMPOSE    := $(__DOCKER_ROOT_CRAWL)/docker-compose.yaml
OLLAMA_COMPOSE   := $(__DOCKER_ROOT_OLLAMA)/docker-compose.yaml
VOICEVOX_COMPOSE := $(__DOCKER_ROOT_VOICEVOX)/docker-compose.yaml
BRIDGE_COMPOSE   := $(__DOCKER_ROOT_BRIDGE)/docker-compose.yaml
COMMON_ENV       := make.d/.env

# $(1)=project name $(2)=root dir $(3)=compose file $(4)=action(up -d / down)
define compose_action
	@if [ -f "$(3)" ]; then \
		cmd="docker compose -p $(1) --env-file $(COMMON_ENV)"; \
		[ -f "$(2)/.env" ] && \
			cmd="$$cmd --env-file $(2)/.env"; \
		cmd="$$cmd -f $(3)"; \
		[ -f "docker/override.d/$(1)/docker-compose.override.yaml" ] && \
			cmd="$$cmd -f docker/override.d/$(1)/docker-compose.override.yaml"; \
		[ "$(__DEV_CONTAINER)" = "true" ] && \
			[ -f "docker/override.d/$(1)/docker-compose.dev.yaml" ] && \
			cmd="$$cmd -f docker/override.d/$(1)/docker-compose.dev.yaml"; \
		$$cmd $(4); \
	fi
endef

.PHONY: docker-rebuild
docker-rebuild:
	# select
	#   .env: __DEV_CONTAINER=false
	#   .env: __DEV_CONTAINER=true
	# execute
	#   make docker-rebuild SERVICE=bridge
	@docker network inspect sandbox >/dev/null 2>&1 \
		&& echo "network sandbox already exists" \
		|| (docker network create sandbox >/dev/null && echo "network sandbox created")
	@if [ -z "$(SERVICE)" ]; then \
		echo "Error: SERVICE parameter is required. (e.g. make docker-rebuild SERVICE=bridge)"; \
		exit 1; \
	fi
	$(eval SERVICE_UPPER := $(shell echo $(SERVICE) | tr 'a-z' 'A-Z'))
	$(call compose_action,$(SERVICE),$(__DOCKER_ROOT_$(SERVICE_UPPER)),$($(SERVICE_UPPER)_COMPOSE),up -d --build --force-recreate)

.PHONY: docker-restart
docker-restart:
	# select
	#   .env: __DEV_CONTAINER=false
	#   .env: __DEV_CONTAINER=true
	# execute
	#   make docker-restart SERVICE=bridge
	@if [ -z "$(SERVICE)" ]; then \
	   echo "Error: SERVICE parameter is required. (e.g. make docker-restart SERVICE=bridge)"; \
	   exit 1; \
	fi
	$(eval SERVICE_UPPER := $(shell echo $(SERVICE) | tr 'a-z' 'A-Z'))
	$(call compose_action,$(SERVICE),$(__DOCKER_ROOT_$(SERVICE_UPPER)),$($(SERVICE_UPPER)_COMPOSE),restart)

.PHONY: docker-up
docker-up:
	@docker network inspect sandbox >/dev/null 2>&1 \
		&& echo "network sandbox already exists" \
		|| (docker network create sandbox >/dev/null && echo "network sandbox created")
	$(call compose_action,dify,$(__DOCKER_ROOT_DIFY),$(DIFY_COMPOSE),up -d)
	$(call compose_action,crawl,$(__DOCKER_ROOT_CRAWL),$(CRAWL_COMPOSE),up -d)
	$(call compose_action,ollama,$(__DOCKER_ROOT_OLLAMA),$(OLLAMA_COMPOSE),up -d)
	$(call compose_action,voicevox,$(__DOCKER_ROOT_VOICEVOX),$(VOICEVOX_COMPOSE),up -d)
	$(call compose_action,bridge,$(__DOCKER_ROOT_BRIDGE),$(BRIDGE_COMPOSE),up -d)

.PHONY: docker-down
docker-down:
	$(call compose_action,dify,$(__DOCKER_ROOT_DIFY),$(DIFY_COMPOSE),down)
	$(call compose_action,crawl,$(__DOCKER_ROOT_CRAWL),$(CRAWL_COMPOSE),down)
	$(call compose_action,ollama,$(__DOCKER_ROOT_OLLAMA),$(OLLAMA_COMPOSE),down)
	$(call compose_action,voicevox,$(__DOCKER_ROOT_VOICEVOX),$(VOICEVOX_COMPOSE),down)
	$(call compose_action,bridge,$(__DOCKER_ROOT_BRIDGE),$(BRIDGE_COMPOSE),down)
	@docker network inspect sandbox >/dev/null 2>&1 \
		&& (docker network rm sandbox >/dev/null && echo "network sandbox removed") \
		|| echo "network sandbox not found"

.PHONY: docker-purge
docker-purge:
	@read -p "docker compose down -v [y/N]: " ans; \
	if [ "$$ans" != "y" ] && [ "$$ans" != "yes" ]; then \
	   echo "Cancelled."; \
	   exit 0; \
	fi;
	$(call compose_action,dify,$(__DOCKER_ROOT_DIFY),$(DIFY_COMPOSE),down -v)
	$(call compose_action,crawl,$(__DOCKER_ROOT_CRAWL),$(CRAWL_COMPOSE),down -v)
	$(call compose_action,ollama,$(__DOCKER_ROOT_OLLAMA),$(OLLAMA_COMPOSE),down -v)
	$(call compose_action,voicevox,$(__DOCKER_ROOT_VOICEVOX),$(VOICEVOX_COMPOSE),down -v)
	$(call compose_action,bridge,$(__DOCKER_ROOT_BRIDGE),$(BRIDGE_COMPOSE),down -v)
	@docker network inspect sandbox >/dev/null 2>&1 \
		&& (docker network rm sandbox >/dev/null && echo "network sandbox removed") \
		|| echo "network sandbox not found"