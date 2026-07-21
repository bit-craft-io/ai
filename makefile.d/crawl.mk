-include makefile.d/.env
export
SHELL := /bin/bash

# ========================================
# crawl ルートパス
# ----------------------------------------
__CRAWL_ROOT := docker/crawl

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
	@if [ ! -d "$(__CRAWL_ROOT)" ]; then \
		echo "repository clone crawl"; \
		git clone --branch v2.11.0 --depth 1 https://github.com/firecrawl/firecrawl $(__CRAWL_ROOT); \
		yes | rm -r $(__CRAWL_ROOT)/.github; \
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
	if [ -f "$(__CRAWL_ROOT)/docker-compose.yaml" ]; then \
		docker compose -f $(__CRAWL_ROOT)/docker-compose.yaml down -v; \
	fi; \
	sudo rm -rf $(__CRAWL_ROOT)