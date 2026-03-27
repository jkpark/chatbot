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
```
### 3. Run the chatbot

**Interactive CLI:**

```bash
adk run my_chatbot
```

**Web UI (browser-based dev interface):**

```bash
adk web
```

Then open `http://localhost:8000` in your browser.

## Running Tests

For running tests and evaluation, install the extra dependencies:

```bash
uv sync --dev
```

Then the tests and evaluation can be run from the `academic-research` directory using
the `pytest` module:

```bash
uv run pytest tests
uv run pytest eval
```

`tests` runs the agent on a sample request, and makes sure that every component
is functional. `eval` is a demonstration of how to evaluate the agent, using the
`AgentEvaluator` in ADK. It sends a couple requests to the agent and expects
that the agent's responses match a pre-defined response reasonablly well.


## Deployment

The chatbot can be deployed to Vertex AI Agent Engine using the following
commands:

```bash
uv sync --group deployment
uv run deployment/deploy.py --create
```

When the deployment finishes, it will print a line like this:

```
Created remote agent: projects/<PROJECT_NUMBER>/locations/<PROJECT_LOCATION>/reasoningEngines/<AGENT_ENGINE_ID>
```

If you forgot the AGENT_ENGINE_ID, you can list existing agents using:

```bash
uv run deployment/deploy.py --list
```