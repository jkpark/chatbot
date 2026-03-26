
# ==============================================================================
# Installation & Setup
# ==============================================================================

# Install dependencies using uv package manager
install:
	@command -v uv >/dev/null 2>&1 || { echo "uv is not installed. Installing uv..."; curl -LsSf https://astral.sh/uv/0.8.13/install.sh | sh; source $HOME/.local/bin/env; }
	uv sync

# ==============================================================================
# Playground Targets
# ==============================================================================

# Launch local dev playground
playground:
	@echo "==============================================================================="
	@echo "| 🚀 Starting your agent playground...                                        |"
	@echo "|                                                                             |"
	@echo "| 💡 Try asking: How to save a pandas dataframe to CSV?                       |"
	@echo "|                                                                             |"
	@echo "| 🔍 IMPORTANT: Select the 'app' folder to interact with your agent.          |"
	@echo "==============================================================================="
	uv run adk web . --port 8501 --reload_agents

# ==============================================================================
# Local Development Commands
# ==============================================================================

# Launch local development server with hot-reload
# Usage: make local-backend [PORT=8000] - Specify PORT for parallel scenario testing
local-backend:
	uv run uvicorn app.fast_api_app:app --host localhost --port $(or $(PORT),8000) --reload

# ==============================================================================
# Backend Deployment Targets
# ==============================================================================

# Deploy the agent remotely
# Usage: make deploy [IAP=true] [PORT=8080] - Set IAP=true to enable Identity-Aware Proxy, PORT to specify container port
deploy:
	export $$(grep -v '^#' .env | xargs) && \
	IMAGE_URL=$$(make image_path) && \
	gcloud beta run deploy hdp-chatbot \
		--image "$$IMAGE_URL" \
		--memory "4Gi" \
		--project $${GOOGLE_CLOUD_PROJECT} \
		--region "$${GOOGLE_CLOUD_LOCATION}" \
		--no-allow-unauthenticated \
		--no-cpu-throttling \
		--labels "created-by=adk" \
		--update-build-env-vars "AGENT_VERSION=$(shell awk -F'"' '/^version = / {print $$2}' pyproject.toml || echo '0.0.0')" \
		--env-vars-file .env \
		$(if $(IAP),--iap) \
		$(if $(PORT),--port=$(PORT))

# Alias for 'make deploy' for backward compatibility
backend: deploy

# 저장소 이름과 이미지 이름 변수 설정
REPO_NAME ?= hdp
IMAGE_NAME ?= hdp-chatbot

.PHONY: image_path deploy

image_path:
	@export $$(grep -v '^#' .env | xargs) && \
	if ! gcloud artifacts repositories describe $(REPO_NAME) --location="$${GOOGLE_CLOUD_LOCATION}" --project="$${GOOGLE_CLOUD_PROJECT}" > /dev/null 2>&1; then \
		echo "Repository $(REPO_NAME) does not exist. Creating..." >&2; \
		gcloud artifacts repositories create $(REPO_NAME) \
			--repository-format=docker \
			--location="$${GOOGLE_CLOUD_LOCATION}" \
			--project="$${GOOGLE_CLOUD_PROJECT}" \
			--description="Docker repository for $(IMAGE_NAME)" >&2; \
	fi; \
	echo "$${GOOGLE_CLOUD_LOCATION}-docker.pkg.dev/$${GOOGLE_CLOUD_PROJECT}/$(REPO_NAME)/$(IMAGE_NAME):latest"




# ==============================================================================
# Data Ingestion (Vertex AI Search)
# ==============================================================================








# Set up Vertex AI Search datastore (GCS bucket, data connector, search engine)
setup-datastore:
	PROJECT_ID=$$(gcloud config get-value project) && \
	(cd deployment/terraform/dev && terraform init && \
	terraform apply --var-file vars/env.tfvars --var dev_project_id=$$PROJECT_ID --auto-approve \
		-target=google_discovery_engine_search_engine.search_engine_dev)

# Upload sample data and trigger initial sync
data-ingestion:
	PROJECT_ID=$$(gcloud config get-value project) && \
	DATA_STORE_REGION=$$(grep 'data_store_region' deployment/terraform/dev/vars/env.tfvars | sed 's/.*= *"//;s/".*//') && \
	gcloud storage cp knowledges/* gs://$$PROJECT_ID-ragbot-docs/ && \
	uv run deployment/terraform/scripts/start_connector_run.py $$PROJECT_ID $$DATA_STORE_REGION ragbot-collection --wait

# Trigger an on-demand sync for the GCS Data Connector
sync-data:
	PROJECT_ID=$$(gcloud config get-value project) && \
	DATA_STORE_REGION=$$(grep 'data_store_region' deployment/terraform/dev/vars/env.tfvars | sed 's/.*= *"//;s/".*//') && \
	uv run deployment/terraform/scripts/start_connector_run.py $$PROJECT_ID $$DATA_STORE_REGION ragbot-collection --wait

# ==============================================================================
# Testing & Code Quality
# ==============================================================================

# Run unit and integration tests
test:
	uv sync --dev
	uv run pytest tests/unit && uv run pytest tests/integration

# ==============================================================================
# Agent Evaluation
# ==============================================================================

# Run agent evaluation using ADK eval
# Usage: make eval [EVALSET=tests/eval/evalsets/basic.evalset.json] [EVAL_CONFIG=tests/eval/eval_config.json]
eval:
	@echo "==============================================================================="
	@echo "| Running Agent Evaluation                                                    |"
	@echo "==============================================================================="
	uv sync --dev --extra eval
	uv run adk eval ./app $${EVALSET:-tests/eval/evalsets/basic.evalset.json} \
		$(if $(EVAL_CONFIG),--config_file_path=$(EVAL_CONFIG),$(if $(wildcard tests/eval/eval_config.json),--config_file_path=tests/eval/eval_config.json,))

# Run evaluation with all evalsets
eval-all:
	@echo "==============================================================================="
	@echo "| Running All Evalsets                                                        |"
	@echo "==============================================================================="
	@for evalset in tests/eval/evalsets/*.evalset.json; do \
		echo ""; \
		echo "▶ Running: $$evalset"; \
		$(MAKE) eval EVALSET=$$evalset || exit 1; \
	done
	@echo ""
	@echo "✅ All evalsets completed"

# Run code quality checks (codespell, ruff, ty)
lint:
	uv sync --dev --extra lint
	uv run codespell
	uv run ruff check . --diff
	uv run ruff format . --check --diff
	uv run ty check .