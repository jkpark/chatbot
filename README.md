# chatbot

A chatbot built with [Google Agent Development Kit (ADK)](https://google.github.io/adk-docs/get-started/python/).

## Project Structure

```
chatbot/
├── app/         # Core agent code
│   ├── agent.py               # Main agent logic
│   ├── fast_api_app.py        # FastAPI Backend server
│   └── app_utils/             # App utilities and helpers
├── tests/                     # Unit, integration, and load tests
├── AGENTS.md                  # AI-assisted development guide
├── Makefile                   # Development commands
└── pyproject.toml             # Project dependencies
```

## Prerequisites

We recommend using [mise-en-place (mise)](https://mise.jdx.dev/) to manage your development environment. This project includes a `mise.toml` file to automatically install the required versions of Python, `uv`, and `gcloud`.

### Using mise (Recommended)

1. Install [mise](https://mise.jdx.dev/getting-started.html).
2. Run:
   ```bash
   mise install
   ```

### Manual Installation

If you prefer to install the requirements manually, ensure you have the following:

- **Python (3.12+)**: [Install Python](https://www.python.org/downloads/)
- **uv**: [Install uv](https://docs.astral.sh/uv/getting-started/installation/)
- **Google Cloud SDK (gcloud)**: [Install gcloud](https://cloud.google.com/sdk/docs/install)

## Setup

### 1. Install dependencies

```bash
make install
```

### 2. Configure Vertex AI credentials

The chatbot uses [Vertex AI](https://cloud.google.com/vertex-ai). Update `.env` with your Google Cloud project details:

```
GOOGLE_GENAI_USE_VERTEXAI=1
GOOGLE_CLOUD_PROJECT=your-project-id
GOOGLE_CLOUD_LOCATION=your-region
```

Make sure you are authenticated with Google Cloud:

```bash
gcloud auth application-default login
gcloud auth application-default set-quota-project $GOOGLE_CLOUD_PROJECT
```

```bash
gcloud services enable run.googleapis.com cloudbuild.googleapis.com artifactregistry.googleapis.com storage.googleapis.com discoveryengine.googleapis.com aiplatform.googleapis.com --project "$GOOGLE_CLOUD_PROJECT"
```


get service account

```bash
gcloud projects get-iam-policy $GOOGLE_CLOUD_PROJECT --flatten="bindings[].members" --format="table(bindings.role, bindings.members)"
```

set `$SERVICE_ACCOUNT`

```bash
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member="serviceAccount:$SERVICE_ACCOUNT" --role="roles/storage.objectViewer"
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT--member="serviceAccount:$SERVICE_ACCOUNT" --role="roles/artifactregistry.reader"
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member="serviceAccount:$SERVICE_ACCOUNT"--role="roles/logging.logWriter"
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member="serviceAccount:$SERVICE_ACCOUNT" --role="roles/aiplatform.user"
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member="serviceAccount:$SERVICE_ACCOUNT" --role="roles/discoveryengine.user"
```


## Quick Start

Install required packages and launch the local development environment:

```bash
make install && make playground
```

## Commands

| Command              | Description                                                                                 |
| -------------------- | ------------------------------------------------------------------------------------------- |
| `make install`       | Install dependencies using uv                                                               |
| `make playground`    | Launch local development environment                                                        |
| `make lint`          | Run code quality checks                                                                     |
| `make test`          | Run unit and integration tests                                                              |
| `make deploy`        | Deploy agent to Cloud Run                                                                   |
| `make local-backend` | Launch local development server with hot-reload                                             |
| `make data-ingestion`| Run data ingestion pipeline                                                                 |

For full command options and usage, refer to the [Makefile](Makefile).

## 🛠️ Project Management

| Command | What It Does |
|---------|--------------|
| `uvx agent-starter-pack enhance` | Add CI/CD pipelines and Terraform infrastructure |
| `uvx agent-starter-pack setup-cicd` | One-command setup of entire CI/CD pipeline + infrastructure |
| `uvx agent-starter-pack upgrade` | Auto-upgrade to latest version while preserving customizations |
| `uvx agent-starter-pack extract` | Extract minimal, shareable version of your agent |

---

## Development

Edit your agent logic in `app/agent.py` and test with `make playground` - it auto-reloads on save.
See the [development guide](https://googlecloudplatform.github.io/agent-starter-pack/guide/development-guide) for the full workflow.

## Deployment

```bash
gcloud config set project <your-project-id>
make deploy
```

To add CI/CD and Terraform, run `uvx agent-starter-pack enhance`.
To set up your production infrastructure, run `uvx agent-starter-pack setup-cicd`.
See the [deployment guide](https://googlecloudplatform.github.io/agent-starter-pack/guide/deployment) for details.

## Observability

Built-in telemetry exports to Cloud Trace, BigQuery, and Cloud Logging.
See the [observability guide](https://googlecloudplatform.github.io/agent-starter-pack/guide/observability) for queries and dashboards.
