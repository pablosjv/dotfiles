##@ Usage

.PHONY: help
help: ## show help message
	@awk 'BEGIN {FS = ":.*##"; printf "\033[36m\033[0m"} /^[$$()% a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Formatting

.PHONY: fmt
fmt: fmt-sh fmt-py fmt-json ## format all files (shell, python, json)

.PHONY: fmt-sh
fmt-sh: ## format shell scripts
	@shfmt --version
	@find . -type f -name "*.sh" -not -path "./dotbot/*" -not -path "./.venv/*" -print0 | xargs -0 shfmt -i 4 -w
	@find . -type f -name "*.zsh" -not -path "./dotbot/*" -not -path "./.venv/*" -print0 | xargs -0 shfmt -i 4 -w -ln zsh

.PHONY: fmt-py
fmt-py: ## format python files
	@uv run ruff format .

.PHONY: fmt-json
fmt-json: ## format and sort json files
	@biome check --write

##@ Linting

.PHONY: lint
lint: lint-py ## lint all files (python)

.PHONY: lint-py
lint-py: ## lint python files
	@uv run ruff check .

##@ Testing

.PHONY: test
test: ## run python tests
	@uv run pytest

##@ Development

.PHONY: check
check: fmt lint test ## run all checks (fmt, lint, test)

.PHONY: pre-commit
pre-commit: check ## run pre-commit flow (fmt, lint, test)
