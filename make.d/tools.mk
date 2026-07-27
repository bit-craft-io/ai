-include make.d/.env
export
SHELL := /bin/bash

# ========================================
# menu
# ----------------------------------------
TASKS += \
	windows-setup \
	mic-spk-enable \
	mic-spk-disable
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
	$(VENV_PYTHON) $(__TOOLS_ROOT)/mic-ops/setup.py

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
	@$(VENV_PYTHON) $(__TOOLS_ROOT)/mic-ops/mic_on.py

.PHONY: mic-off
mic-off:
	@$(VENV_PYTHON) $(__TOOLS_ROOT)/mic-ops/mic_off.py

# スピーカーの制御
.PHONY: spk-on
spk-on:
	@$(VENV_PYTHON) $(__TOOLS_ROOT)/mic-ops/spk_on.py

.PHONY: spk-off
spk-off:
	@$(VENV_PYTHON) $(__TOOLS_ROOT)/mic-ops/spk_off.py
