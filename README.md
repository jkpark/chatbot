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
