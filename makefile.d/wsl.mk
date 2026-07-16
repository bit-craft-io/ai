-include makefile.d/.env

SHELL := /bin/bash

# ========================================
# menu
# ----------------------------------------
TASKS += \
	wsl-init \
	wsl-setup \
	wsl-info \
	wsl-clean
# ========================================
# command
# ----------------------------------------
.PHONY: wsl-init
wsl-init:
	@echo "--- Install Ollama ---"
	@which ollama > /dev/null 2>&1 || (sudo apt-get install -y zstd && curl -fsSL https://ollama.com/install.sh | sh)
	sudo systemctl stop ollama 2>/dev/null || true
	sudo systemctl disable ollama 2>/dev/null || true

.PHONY: wsl-setup
wsl-setup:
	@echo "--- Pull LLM models ---"
	@pgrep ollama > /dev/null 2>&1 || (ollama serve &)
	sleep 3
	ollama pull $(__OLLAMA_MODEL)
	ollama list
	@pgrep ollama > /dev/null 2>&1 && pkill ollama || true

.PHONY: wsl-info
wsl-info:
	@echo "--- LLM models ---"
	@pgrep ollama > /dev/null 2>&1 || (ollama serve > /dev/null 2>&1 &)
	@sleep 3
	@ollama list
	@pgrep ollama > /dev/null 2>&1 && pkill ollama > /dev/null 2>&1 || true

.PHONY: wsl-clean
wsl-clean:
	@echo "--- Cleaning up Ollama processes ---"
	@pgrep ollama > /dev/null 2>&1 || (echo "Starting ollama for cleanup..."; ollama serve > /dev/null 2>&1 & sleep 2)

	@echo "--- Deleting all Ollama models EXCEPT $(__OLLAMA_MODEL) ---"
	@sudo chown -R $$(whoami):$$(whoami) /home/guest/.ollama 2>/dev/null || true
	@if which ollama > /dev/null 2>&1; then \
		echo "Fetching downloaded models..."; \
		for model in $$(ollama list | tail -n +2 | awk '{print $$1}'); do \
			if [ "$$model" = "$(__OLLAMA_MODEL)" ]; then \
				echo "Keeping target model: $$model (Skipped)"; \
			else \
				echo "Deleting unused model: $$model..."; \
				ollama rm $$model; \
			fi \
		done; \
		echo "Cleanup completed (Only $(__OLLAMA_MODEL) remains)."; \
	else \
		echo "Ollama is not installed."; \
	fi

	@echo "--- Stopping Ollama process ---"
	@pgrep ollama > /dev/null 2>&1 && pkill ollama || true
