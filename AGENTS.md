# Global Agent Constraints

This file defines the foundational mandates and constraints for all agents operating within this codebase. These instructions take precedence over general defaults.

## Core Principles
- **Security First:** Never log, print, or commit secrets, API keys, or sensitive credentials. Protect `.env` files and system configuration folders.
- **Surgical Changes:** Minimize side effects by applying the most targeted changes possible.
- **Verification:** Every change must be verified through automated tests or manual validation before being considered complete.

## Engineering Standards
- **Python Style:** Adhere to PEP 8. Use type hints for all function signatures.
- **Dependencies:** Use `uv` for managing dependencies. Verify if a library is already in `pyproject.toml` and `uv.lock` before suggesting or adding new ones. Use `uv add <package>` to add dependencies.
- **Documentation:** Update docstrings for any modified functions or classes using the Google style guide.

## Environment & Tools
- **Environment Management:** Use `mise` for managing tool versions and environment variables. Use `uv` for Python environment and package management.
- **Python Execution:** Always run Python scripts and commands within the `.venv` virtual environment managed by `uv`. Ensure the environment is synchronized by running `uv sync` if dependencies change.

## Workspace Specifics
- The core chatbot logic resides in the `my_chatbot/` directory.
- `agent_engine_app.py` is the main entry point for the API.
- Always check `.env` for local environment configuration but never commit it.
