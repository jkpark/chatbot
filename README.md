# chatbot

A chatbot built with [Google Agent Development Kit (ADK)](https://google.github.io/adk-docs/get-started/python/).

## Setup

### 1. Install dependencies

```bash
pip install -r requirements.txt
```

### 2. Configure API key

Copy `.env` to `.env.local` and set your Gemini API key:

```bash
cp .env .env.local
```

Edit `.env.local` and replace `your_api_key_here` with your actual [Google AI Studio](https://aistudio.google.com/apikey) API key:

```
GOOGLE_GENAI_USE_VERTEXAI=FALSE
GOOGLE_API_KEY=your_api_key_here
```

> **Note:** `.env.local` is listed in `.gitignore` and will not be committed to version control.

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
