
# ==============================================================================
# Global Variables
# ==============================================================================

SERVICE_NAME:=hdp-chatbot
REPO_NAME ?= hdp
IMAGE_NAME ?= hdp-chatbot

# Extract environment variables for Makefile use
include .env
export $(shell sed 's/=.*//' .env)

# Define IMAGE_URL globally
TAG := latest
IMAGE_URL := $(GOOGLE_CLOUD_LOCATION)-docker.pkg.dev/$(GOOGLE_CLOUD_PROJECT)/$(REPO_NAME)/$(IMAGE_NAME):$(TAG)

.PHONY: install playground local-backend release deploy backend setup-datastore data-ingestion sync-data test eval eval-all lint

# ==============================================================================
# Installation & Setup
# ==============================================================================

# Install dependencies using uv package manager
install:
	@command -v uv >/dev/null 2>&1 && uv sync

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
# Backend Release
# ==============================================================================

release:
	@if ! gcloud artifacts repositories describe $(REPO_NAME) --location="$(GOOGLE_CLOUD_LOCATION)" --project="$(GOOGLE_CLOUD_PROJECT)" > /dev/null 2>&1; then \
		echo "Repository $(REPO_NAME) does not exist. Creating..." >&2; \
		gcloud artifacts repositories create $(REPO_NAME) \
			--repository-format=docker \
			--location="$(GOOGLE_CLOUD_LOCATION)" \
			--project="$(GOOGLE_CLOUD_PROJECT)" \
			--description="Docker repository for $(IMAGE_NAME)" >&2; \
	fi; \
	echo "$(IMAGE_URL)"

	@echo "Ensuring Cloud Build storage bucket exists..." && \
	if ! gcloud storage buckets describe gs://$(GOOGLE_CLOUD_PROJECT)-$(SERVICE_NAME) > /dev/null 2>&1; then \
		gcloud storage buckets create gs://$(GOOGLE_CLOUD_PROJECT)-$(SERVICE_NAME) --project="$(GOOGLE_CLOUD_PROJECT)" --location="$(GOOGLE_CLOUD_LOCATION)"; \
	fi && \
	echo "Building and pushing image via Cloud Build..." && \
	gcloud builds submit --tag "$(IMAGE_URL)" \
		.

# ==============================================================================
# Backend Deployment Targets
# ==============================================================================

# Deploy the agent remotely
# Usage: make deploy [IAP=true] [PORT=8080] - Set IAP=true to enable Identity-Aware Proxy, PORT to specify container port
deploy:
	@gcloud beta run deploy "$(SERVICE_NAME)" \
		--image "$(IMAGE_URL)" \
		--memory "4Gi" \
		--project $(GOOGLE_CLOUD_PROJECT) \
		--region "$(GOOGLE_CLOUD_LOCATION)" \
		--no-allow-unauthenticated \
		--labels "created-by=adk" \
		--update-env-vars "AGENT_VERSION=$(awk -F'"' '/^version = / {print $$2}' pyproject.toml || echo '0.0.0')" \
		$(if $(IAP),--iap) \
		$(if $(PORT),--port=$(PORT))

# Alias for 'make deploy' for backward compatibility
backend: deploy

# ==============================================================================
# Data Ingestion (Vertex AI Search)
# ==============================================================================


# Set up Vertex AI Search datastore (GCS bucket, data connector, search engine)
setup-datastore:
# 	PROJECT_ID=$$(gcloud config get-value project) && \
# 	(cd deployment/terraform/dev && terraform init && \
# 	terraform apply --var-file vars/env.tfvars --var dev_project_id=$$PROJECT_ID --auto-approve \
# 		-target=google_discovery_engine_search_engine.search_engine_dev)
	uv run deployment/terraform/scripts/setup_data_connector.py $$PROJECT_ID $$DATA_STORE_REGION $$COLLECTION_ID \
	$$SERVICE_NAME gs://$$PROJECT_ID-$$SERVICE_NAME/knowledges/ --refresh-interval 86400s --data-schema content

# Upload knowledges data and trigger initial sync
data-ingestion:
# 	PROJECT_ID=$$(gcloud config get-value project) && \
# 	DATA_STORE_REGION=$$(grep 'data_store_region' deployment/terraform/dev/vars/env.tfvars | sed 's/.*= *"//;s/".*//') &&
	gcloud storage cp knowledges/* gs://$$PROJECT_ID-$$SERVICE_NAME/knowledges/ && \
	uv run deployment/terraform/scripts/start_connector_run.py $$PROJECT_ID $$DATA_STORE_REGION $$SERVICE_NAME-collection --wait

# Trigger an on-demand sync for the GCS Data Connector
sync-data:
# 	PROJECT_ID=$$(gcloud config get-value project) && \
# 	DATA_STORE_REGION=$$(grep 'data_store_region' deployment/terraform/dev/vars/env.tfvar | sed 's/.*= *"//;s/".*//') &&
	uv run deployment/terraform/scripts/start_connector_run.py $$PROJECT_ID $$DATA_STORE_REGION $$SERVICE_NAME-collection --wait

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