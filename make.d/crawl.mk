-include make.d/.env
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
	@if [ ! -d "$(__DOCKER_ROOT_CRAWL)" ]; then \
		echo "repository clone crawl"; \
		git clone --branch v2.11.0 --depth 1 https://github.com/firecrawl/firecrawl $(__DOCKER_ROOT_CRAWL); \
		yes | rm -r $(__DOCKER_ROOT_CRAWL)/.github; \
		echo "make .env from .env.example"; \
		cp $(__DOCKER_ROOT_DIFY)/docker/.env.example $(__DOCKER_ROOT_DIFY)/docker/.env; \
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
	sudo rm -rf $(__DOCKER_ROOT_CRAWL)