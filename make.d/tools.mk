-include make.d/.env
export
SHELL := /bin/bash

# ========================================
# menu
# ----------------------------------------
TASKS += \
	windows-setup \
	mic-spk-enable \
	mic-spk-disable \
	dify-cache-clear-dry \
	dify-cache-clear \
	nvidia-smi
# ========================================
# command
# ----------------------------------------
ifndef ROOT_MK_INCLUDED
    ROOT_MK_INCLUDED := 1
	ROOT_DIR := $(shell pwd)
    export VENV_PYTHON := $(ROOT_DIR)/.venv/bin/python3
    export VENV_PIP    := $(ROOT_DIR)/.venv/bin/pip
endif

.PHONY: windows-setup
windows-setup:
	$(VENV_PYTHON) tools/win-ops/setup.py

.PHONY: mic-spk-enable
mic-spk-enable:
	@$(MAKE) --no-print-directory mic-on
	@$(MAKE) --no-print-directory spk-on
	@echo "completed!"

.PHONY: mic-spk-disable
mic-spk-disable:
	@$(MAKE) --no-print-directory mic-off
	@$(MAKE) --no-print-directory spk-off
	@echo "completed!"

# マイクの制御
.PHONY: mic-on
mic-on:
	@$(VENV_PYTHON) tools/win-ops/mic_on.py

.PHONY: mic-off
mic-off:
	@$(VENV_PYTHON) $(__TOOLS_ROOT)/win-ops/mic_off.py

# スピーカーの制御
.PHONY: spk-on
spk-on:
	@$(VENV_PYTHON) $(__TOOLS_ROOT)/win-ops/spk_on.py

.PHONY: spk-off
spk-off:
	@$(VENV_PYTHON) $(__TOOLS_ROOT)/win-ops/spk_off.py

.PHONY: dify-cache-clear-dry
dify-cache-clear-dry:
	DIFY_COMPOSE_FILE=$(__DIFY_COMPOSE_FILE) \
	DIFY_DB_CONTAINER=$(__DIFY_DB_CONTAINER) \
	DIFY_DB_USER=$(__DIFY_DB_USER) \
	DIFY_DB_NAME_PLUGIN=$(__DIFY_DB_NAME_PLUGIN) \
	DIFY_VOLUMES_DIR=$(__DIFY_VOLUMES_DIR) \
	bash $(__TOOLS_ROOT)/dify-cache-check.sh

.PHONY: dify-cache-clear
dify-cache-clear:
	@read -p "This will permanently delete orphaned plugin cache files. Continue? [y/N]: " ans; \
	if [ "$$ans" != "y" ] && [ "$$ans" != "yes" ]; then \
	   echo "Cancelled."; \
	   exit 0; \
	fi; \
	DIFY_COMPOSE_FILE=$(__DIFY_COMPOSE_FILE) \
	DIFY_DB_CONTAINER=$(__DIFY_DB_CONTAINER) \
	DIFY_DB_USER=$(__DIFY_DB_USER) \
	DIFY_DB_NAME_PLUGIN=$(__DIFY_DB_NAME_PLUGIN) \
	DIFY_VOLUMES_DIR=$(__DIFY_VOLUMES_DIR) \
	bash $(__TOOLS_ROOT)/dify-cache-check.sh --apply
