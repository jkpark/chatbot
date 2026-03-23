# chatbot

A chatbot built with [Google Agent Development Kit (ADK)](https://google.github.io/adk-docs/get-started/python/).

## Setup

### 1. Install dependencies

```bash
pip install -r requirements.txt
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

**API server:**

```bash
adk api_server
```

## Deployment

### Deploy to Vertex AI Agent Engine via Developer Connect

The `deploy.py` script deploys the chatbot to [Vertex AI Agent Engine](https://cloud.google.com/vertex-ai/docs/agent-engine/overview) using [Developer Connect](https://cloud.google.com/developer-connect/docs/overview), which fetches the source code directly from this Git repository.

#### Prerequisites

1. **Link the repository to Developer Connect** (one-time setup):
   Follow the [Developer Connect setup guide](https://cloud.google.com/developer-connect/docs/connect-repo) to connect this repository to Google Cloud. The connection used is:
   ```
   projects/chatbot-test-490711/locations/asia-northeast3/connections/chatbot-connection
   ```

2. **Find your `gitRepositoryLink` ID**:
   ```bash
   gcloud developer-connect connections git-repository-links list \
     --connection=chatbot-connection \
     --location=asia-northeast3 \
     --project=chatbot-test-490711
   ```
   Copy the link ID from the output.

3. **Update `.env`**: Add the copied ID to your `.env` file:
   `YOUR_REPOSITORY_LINK_ID=your-link-id`

#### Run the deployment script

```bash
gcloud auth application-default login
python deploy.py
```

The script will print the resource name of the created Agent Engine instance on success.
