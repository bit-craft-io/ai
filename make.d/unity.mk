-include make.d/.env
export
SHELL := /bin/bash

# ========================================
# menu
# ----------------------------------------
TASKS += \
	unity-backup \
	unity-backup-size \
	unity-restore \
	unity-init \
	unity-init-replace
# ========================================
# command
# ----------------------------------------
UNITY_PROJECT_DIR := $(__UNITY_PROJECT_DIR)
UNITY_BACKUP_DIR  := $(__UNITY_BACKUP_DIR)
UNITY_INIT_DIR    := $(__UNITY_INIT_DIR)

# ----------------------------------------
# common recipe (backup)
#   $(1) = target dir
#   $(2) = extra script args (e.g. --clean)
#   $(3) = label (for echo)
# ----------------------------------------
define unity_backup_action
	@echo "--------------------------------------------------------------------------------"
	@echo "Unity project backup dry-run $(3)(-> $(1))"
	@echo "--------------------------------------------------------------------------------"
	bash tools/unity/unity-backup.sh --dir "$(1)" $(2)
	@read -p "This will copy Unity project to backup. Continue? [y/N]: " ans; \
	if [ "$$ans" != "y" ] && [ "$$ans" != "yes" ]; then \
	   echo "Cancelled."; \
	   exit 0; \
	fi; \
	bash tools/unity/unity-backup.sh --dir "$(1)" $(2) --apply
	@echo "--------------------------------------------------------------------------------"
	@echo -e "$(CLR_GREEN) [OK] Successfully!$(CLR_RESET)"
	@echo "--------------------------------------------------------------------------------"
endef

# ----------------------------------------
# common recipe (restore)
#   $(1) = source dir
#   $(2) = label (for echo)
# ----------------------------------------
define unity_restore_action
	@echo "--------------------------------------------------------------------------------"
	@echo "Unity project restore dry-run $(2)(<- $(1))"
	@echo "--------------------------------------------------------------------------------"
	bash tools/unity/unity-restore.sh --dir "$(1)"
	@read -p "This will overwrite Unity project from backup. Continue? [y/N]: " ans; \
	if [ "$$ans" != "y" ] && [ "$$ans" != "yes" ]; then \
	   echo "Cancelled."; \
	   exit 0; \
	fi; \
	bash tools/unity/unity-restore.sh --dir "$(1)" --apply
	@echo "--------------------------------------------------------------------------------"
	@echo -e "$(CLR_GREEN) [OK] Successfully!$(CLR_RESET)"
	@echo "--------------------------------------------------------------------------------"
endef

.PHONY: unity-backup
unity-backup:
	$(call unity_backup_action,$(UNITY_BACKUP_DIR),,)

.PHONY: unity-init-replace
unity-init-replace:
	$(call unity_backup_action,$(UNITY_INIT_DIR),--clean,[CLEAN] )

.PHONY: unity-restore
unity-restore:
	$(call unity_restore_action,$(UNITY_BACKUP_DIR),)

.PHONY: unity-init
unity-init:
	$(call unity_restore_action,$(UNITY_INIT_DIR),[INIT] )

.PHONY: unity-backup-size
unity-backup-size:
	@echo "--------------------------------------------------------------------------------"
	@echo "Unity backup size"
	@echo "--------------------------------------------------------------------------------"
	@if [ -d "$(UNITY_BACKUP_DIR)" ]; then \
		echo "[backup] $(UNITY_BACKUP_DIR)"; \
		du -sh "$(UNITY_BACKUP_DIR)"; \
	else \
		echo "Backup directory ($(UNITY_BACKUP_DIR)) does not exist."; \
	fi
	@if [ -d "$(UNITY_INIT_DIR)" ]; then \
		echo "[init] $(UNITY_INIT_DIR)"; \
		du -sh "$(UNITY_INIT_DIR)"; \
	else \
		echo "Init directory ($(UNITY_INIT_DIR)) does not exist."; \
	fi