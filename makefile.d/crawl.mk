-include makefile.d/.env
export
SHELL := /bin/bash

# ========================================
# menu
# ----------------------------------------
TASKS += \
	crawl-git-pull \
	crawl-git-dell \
	crawl-docker-up \
	crawl-docker-down
# ========================================
# command
# ----------------------------------------
.PHONY: crawl-git-pull
crawl-git-pull:
	@if [ ! -d "crawl" ]; then \
		echo "repository clone crawl"; \
		git clone --branch v2.11.0 --depth 1 https://github.com/firecrawl/firecrawl crawl; \
		yes | rm -r crawl/.github; \
	else \
		echo "exist crawl make skip"; \
	fi

.PHONY: crawl-git-dell
crawl-git-dell:
	@# ユーザーに実行確認を求める
	@read -p "Are you sure you want to delete crawl? [y/N]: " ans; \
	if [ "$$ans" != "y" ] && [ "$$ans" != "yes" ]; then \
		echo "Cancelled."; \
		exit 0; \
	fi; \
	if [ -f "crawl/docker-compose.yaml" ]; then \
		docker compose -f ./crawl/docker-compose.yaml down -v; \
	fi; \
	sudo rm -rf ./crawl

#.PHONY: crawl-docker-up
#crawl-docker-up:
#	@if [ -f "crawl/docker-compose.yaml" ]; then \
#		docker compose -f ./crawl/docker-compose.yaml up -d; \
#	fi
#
#.PHONY: crawl-docker-down
#crawl-docker-down:
#	@if [ -f "crawl/docker-compose.yaml" ]; then \
#		docker compose -f ./crawl/docker-compose.yaml down; \
#	fi
