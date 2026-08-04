SHELL := /bin/bash
.DEFAULT_GOAL := menu

# ========================================
# include
# ----------------------------------------
include make.d/_common.mk
include make.d/wsl.mk
include make.d/docker.mk
include make.d/dify.mk
include make.d/crawl.mk
include make.d/python.mk
include make.d/tools.mk
# ========================================
# command
# ----------------------------------------
.PHONY: menu
menu:
	@trap 'echo ""; exit 0' INT; \
	\
	MENU_GROUPS=$$(awk '/^include make\.d\// {print $$2}' Makefile | xargs -n1 basename | sed 's/\.mk$$//' | awk '!visited[$$0]++'); \
	if [ -z "$$MENU_GROUPS" ]; then echo "No .mk files included in Makefile"; exit 1; fi; \
	\
	echo "--- Select Group ---"; \
	echo " 1) _exit"; \
	\
	i=2; \
	for g in $$MENU_GROUPS; do \
	   printf "%2d) %s\n" $$i "$$g"; \
	   i=$$(($$i + 1)); \
	done; \
	\
	read -p "??: " g_num; \
	if [ "$$g_num" -eq 1 ] 2>/dev/null; then echo "Exit"; exit 0; fi; \
	\
	idx=$$(($$g_num - 1)); \
	selected_g=$$(echo "$$MENU_GROUPS" | sed -n "$${idx}p" 2>/dev/null); \
	if [ -z "$$selected_g" ]; then \
	   echo "Invalid group"; \
	   exit 0; \
	fi; \
	\
	echo "--- Select Task [$$selected_g] ---"; \
	echo " 1) _back"; \
	\
	# 2. TASKS += のブロックからタスク名を抽出 \
	SUB_TASKS=$$(awk '/TASKS *\+=/,/[^\\]$$/' make.d/$$selected_g.mk | sed -e 's/TASKS *+=//' -e 's/\\//g' | tr -s ' \t\n' '\n' | grep -v '^$$' | awk '!visited[$$0]++'); \
	\
	i=2; \
	for st in $$SUB_TASKS; do \
	   printf "%2d) %s\n" $$i "$$st"; \
	   i=$$(($$i + 1)); \
	done; \
	\
	read -p "??: " t_num; \
	if [ "$$t_num" -eq 1 ] 2>/dev/null; then exec make --no-print-directory menu; fi; \
	\
	t_idx=$$(($$t_num - 1)); \
	selected_t=$$(echo "$$SUB_TASKS" | sed -n "$${t_idx}p" 2>/dev/null); \
	if [ -n "$$selected_t" ]; then \
	   MAKEFLAGS="--no-print-directory" make $$selected_t; \
	else \
	   echo "Invalid task"; \
	   exit 0; \
	fi

.DEFAULT:
	@echo "[WARN] target '$@' unknown"