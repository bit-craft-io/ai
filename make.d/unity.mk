-include make.d/.env
export
SHELL := /bin/bash

# ========================================
# menu
# ----------------------------------------
TASKS += \
	unity-backup\
	unity-backup-size \
	unity-restore
# ========================================
# command
# ----------------------------------------
UNITY_PROJECT_DIR := $(__UNITY_PROJECT_DIR)
UNITY_BACKUP_DIR  := $(__UNITY_BACKUP_DIR)

.PHONY: unity-backup
unity-backup:
	@echo "--------------------------------------------------------------------------------"
	@echo "Unity project backup dry-run"
	@echo "--------------------------------------------------------------------------------"
	bash tools/unity/unity-backup.sh
	@read -p "This will copy Unity project to backup. Continue? [y/N]: " ans; \
	if [ "$$ans" != "y" ] && [ "$$ans" != "yes" ]; then \
	   echo "Cancelled."; \
	   exit 0; \
	fi; \
	bash tools/unity/unity-backup.sh --apply
	@echo "--------------------------------------------------------------------------------"
	@echo -e "$(CLR_GREEN) [OK] Successfully!$(CLR_RESET)"
	@echo "--------------------------------------------------------------------------------"

.PHONY: unity-restore
unity-restore:
	@echo "--------------------------------------------------------------------------------"
	@echo "Unity project restore dry-run"
	@echo "--------------------------------------------------------------------------------"
	bash tools/unity/unity-restore.sh
	@read -p "This will overwrite Unity project from backup. Continue? [y/N]: " ans; \
	if [ "$$ans" != "y" ] && [ "$$ans" != "yes" ]; then \
	   echo "Cancelled."; \
	   exit 0; \
	fi; \
	bash tools/unity/unity-restore.sh --apply
	@echo "--------------------------------------------------------------------------------"
	@echo -e "$(CLR_GREEN) [OK] Successfully!$(CLR_RESET)"
	@echo "--------------------------------------------------------------------------------"

.PHONY: unity-backup-size
unity-backup-size:
	@echo "--------------------------------------------------------------------------------"
	@echo "Unity backup size"
	@echo "--------------------------------------------------------------------------------"
	@if [ -d "$(UNITY_BACKUP_DIR)" ]; then \
		du -sh "$(UNITY_BACKUP_DIR)"; \
	else \
		echo "Backup directory ($(UNITY_BACKUP_DIR)) does not exist."; \
	fi