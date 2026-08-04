-include make.d/.env
export
SHELL := /bin/bash

# ========================================
# menu
# ----------------------------------------
TASKS += \
	_setup_all
# ========================================
# command
# ----------------------------------------
.PHONY: _setup_all
_setup_all:
	@$(MAKE) wsl-tool-install
	@$(MAKE) wsl-git_lfs-setup
	@$(MAKE) wsl-ollama-model-pull
	@$(MAKE) python-install
	@$(MAKE) python-setup
	@$(MAKE) dify-git-pull
	@$(MAKE) crawl-git-pull
