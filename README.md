# Makefile Specification & Setup Guide for AI Agents

When setting up or standardizing a project's `Makefile`, follow this standard layout. It provides a consistent interface across tools, human developers, CI/CD pipelines, and AI coding agents.

---

## 1. Core Principles

1. **Package Management**: Use `uv` for Python environments and dependencies (`uv sync`, `uv run`, `uv tool install`).
2. **Quality Gates**: Standardize on `ruff` for linting/formatting and `pytest` for testing.
3. **Agent Skill Synchronization**: Always support deploying agent skills (`skills/<skill_name>/SKILL.md`) into standard AI assistant configuration directories.
4. **Predictable Target Contract**: Any developer or AI agent should be able to rely on standard targets:
   - `make setup`
   - `make test`
   - `make lint`
   - `make format`
   - `make all`
   - `make install`

---

## 2. Standard Target Contract

| Target | Purpose | Standard Implementation |
|---|---|---|
| `help` (default) | Self-documenting target list | Parses inline `##` comments |
| `setup` | Install project and dev dependencies | `uv sync --dev` |
| `install` | Install CLI binary globally + sync skills | `install-skill` prerequisite + `uv tool install --editable .` |
| `install-skill` | Deploy `SKILL.md` to agent skill directories | Copies `SKILL_SRC` to Claude, Copilot, Codex, and Gemini config paths |
| `lint` | Static analysis and style check | `uv run ruff check src/ tests/` |
| `lint-fix` | Automated fixes for lint rules | `uv run ruff check --fix src/ tests/` |
| `format` | Code formatter | `uv run ruff format src/ tests/` |
| `test` | Test runner | `uv run pytest tests/ -v` |
| `all` | Full verification gate | Prerequisite targets: `lint test` |
| `run` | Run the application / entrypoint | `uv run <project_name>` |
| `clean` | Remove caches and build artifacts | Removes `.venv`, `.pytest_cache`, `.ruff_cache`, dist, etc. |

---

## 3. Standard AI Skill Folders

When syncing project skills via `install-skill`, populate these directories:
- **Claude**: `$(HOME)/.claude/skills/$(SKILL_NAME)`
- **Copilot**: `$(HOME)/.copilot/skills/$(SKILL_NAME)`
- **Codex**: `$(HOME)/.codex/skills/$(SKILL_NAME)`
- **Gemini / Antigravity**: `$(HOME)/.gemini/config/skills/$(SKILL_NAME)`

---

## 4. Instructions for Agents When Scaffolding a New Project

1. Copy [templates/Makefile.template](templates/Makefile.template) to `Makefile` in the project root.
2. Replace `PROJECT_NAME` with the repository or package identifier.
3. Update `SRC_DIR` and `TESTS_DIR` if the project uses a custom layout.
4. If the tool is a CLI that requires shell wrapper functions or environment setup, echo those in the `install` target.
5. If the project maintains a skill in `skills/<project>/SKILL.md`, verify `SKILL_SRC` points to it.
6. Run `make help` and `make setup` to verify syntax and functionality.
