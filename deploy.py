#!/usr/bin/env python3
"""Deployment script to deploy the chatbot to Vertex AI Agent Engine via Developer Connect.

Usage:
    python deploy.py

Before running this script:
1. Set GIT_REPOSITORY_LINK to the full Developer Connect gitRepositoryLink resource name.
   Format: projects/{project}/locations/{location}/connections/{connection}/gitRepositoryLinks/{link_id}
   You can find the link ID by running:
     gcloud developer-connect repository-links list \
       --connection=chatbot-connection \
       --location=asia-northeast3 \
       --project=chatbot-test-490711

2. Authenticate with Google Cloud:
     gcloud auth application-default login

3. Install dependencies:
     pip install -r requirements.txt
"""

import os

import vertexai
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# ── Configuration ──────────────────────────────────────────────────────────────

PROJECT = os.getenv("GOOGLE_CLOUD_PROJECT", "chatbot-test-490711")
LOCATION = os.getenv("GOOGLE_CLOUD_LOCATION", "asia-northeast3")

# Developer Connect Git Repository Link resource name.
# Connection path: projects/chatbot-test-490711/locations/asia-northeast3/connections/chatbot-connection
# Replace {YOUR_REPOSITORY_LINK_ID} with the actual gitRepositoryLink ID from Developer Connect.
GIT_REPOSITORY_LINK = (
    "projects/chatbot-test-490711/locations/asia-northeast3"
    "/connections/chatbot-connection"
    "/gitRepositoryLinks/{YOUR_REPOSITORY_LINK_ID}"
)

# The Git revision to deploy (branch name, tag, or commit SHA).
REVISION = "main"

# The display name for the Agent Engine instance.
DISPLAY_NAME = os.getenv("AGENT_ENGINE_DISPLAY_NAME", "my-chatbot")

# ── Deploy ─────────────────────────────────────────────────────────────────────


def main() -> None:
    if "{YOUR_REPOSITORY_LINK_ID}" in GIT_REPOSITORY_LINK:
        raise ValueError(
            "Please set GIT_REPOSITORY_LINK to the full Developer Connect "
            "gitRepositoryLink resource name before running this script.\n"
            "Run the following command to find the link ID:\n"
            "  gcloud developer-connect repository-links list \\\n"
            "    --connection=chatbot-connection \\\n"
            "    --location=asia-northeast3 \\\n"
            "    --project=chatbot-test-490711"
        )

    print(f"Initializing Vertex AI (project={PROJECT}, location={LOCATION})...")
    client = vertexai.Client(project=PROJECT, location=LOCATION)

    print(f"Deploying '{DISPLAY_NAME}' via Developer Connect...")
    print(f"  git_repository_link : {GIT_REPOSITORY_LINK}")
    print(f"  revision            : {REVISION}")

    agent_engine = client.agent_engines.create(
        config={
            "display_name": DISPLAY_NAME,
            "developer_connect_source": {
                "config": {
                    "git_repository_link": GIT_REPOSITORY_LINK,
                    "dir": ".",
                    "revision": REVISION,
                }
            },
            "entrypoint_module": "agent_engine_app",
            "entrypoint_object": "adk_app",
            "requirements_file": "requirements.txt",
            "agent_framework": "google-adk",
            "env_vars": {
                "GOOGLE_GENAI_USE_VERTEXAI": "1",
                "GOOGLE_CLOUD_PROJECT": PROJECT,
                "GOOGLE_CLOUD_LOCATION": LOCATION,
            },
        }
    )

    print(f"✅ Agent Engine created: {agent_engine.api_resource.name}")


if __name__ == "__main__":
    main()
