.DEFAULT_GOAL := help
.PHONY: help setup install install-skill lint format lint-fix test all clean run

# ── Project Configuration ───────────────────────────────────────────────────
PROJECT_NAME ?= myproject
SKILL_NAME   ?= $(PROJECT_NAME)
SRC_DIR      ?= src
TESTS_DIR    ?= tests
SKILL_SRC    ?= skills/$(SKILL_NAME)/SKILL.md

# Agent skill directories across standard AI coding assistants
SKILL_DIRS := \
	$(HOME)/.claude/skills/$(SKILL_NAME) \
	$(HOME)/.copilot/skills/$(SKILL_NAME) \
	$(HOME)/.codex/skills/$(SKILL_NAME) \
	$(HOME)/.gemini/config/skills/$(SKILL_NAME)

# ── Help ─────────────────────────────────────────────────────────────────────
help: ## Show this help message with available targets
	@echo "Usage: make <target>"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

# ── Development environment ────────────────────────────────────────────────
setup: ## Create/sync local virtual environment with dev dependencies
	uv sync --dev

# ── Global CLI install (makes CLI tool available system-wide) ──────────────
install: install-skill ## Install project as an editable uv tool and deploy agent skills
	uv tool install --editable .
	@echo ""
	@echo "$(PROJECT_NAME) installed globally via uv tool."
	@# Optional: print shell helper functions or completion tips if applicable
	@# @echo "Add shell helpers to your ~/.zshrc or ~/.bashrc if needed."

# ── Install skill into global AI agent skill folders ───────────────────────
install-skill: ## Copy agent SKILL.md into global assistant skill folders
	@if [ -f "$(SKILL_SRC)" ]; then \
		for dir in $(SKILL_DIRS); do \
			mkdir -p "$$dir"; \
			cp "$(SKILL_SRC)" "$$dir/SKILL.md"; \
			echo "Skill installed: $$dir/SKILL.md"; \
		done; \
	else \
		echo "Skill source $(SKILL_SRC) not found; skipping skill installation."; \
	fi

# ── Code quality ───────────────────────────────────────────────────────────
lint: ## Check source code and tests with ruff
	uv run ruff check $(SRC_DIR)/ $(TESTS_DIR)/

lint-fix: ## Auto-fix lint issues where possible
	uv run ruff check --fix $(SRC_DIR)/ $(TESTS_DIR)/

format: ## Format code with ruff
	uv run ruff format $(SRC_DIR)/ $(TESTS_DIR)/

# ── Tests ──────────────────────────────────────────────────────────────────
test: ## Run test suite with pytest
	uv run pytest $(TESTS_DIR)/ -v

# ── CI gate ────────────────────────────────────────────────────────────────
all: lint test ## Run linting and test suite (standard CI gate)

# ── Run application ────────────────────────────────────────────────────────
run: ## Run project CLI / application
	uv run $(PROJECT_NAME)

# ── Cleanup ────────────────────────────────────────────────────────────────
clean: ## Remove build artifacts, virtualenvs, and test caches
	rm -rf dist/ .venv/ .ruff_cache/ .pytest_cache/ *.egg-info $(SRC_DIR)/*.egg-info
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
