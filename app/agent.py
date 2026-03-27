# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os
from dotenv import load_dotenv

load_dotenv()

import google
import vertexai
from google.adk.agents import Agent
from google.adk.apps import App
from google.adk.models import Gemini
from google.genai import types

from app.retrievers import create_search_tool

from . import prompt

LLM_LOCATION = os.environ.get("GOOGLE_CLOUD_LOCATION", "global")
LOCATION = os.environ.get("LOCATION", "asia-northeast3")
LLM = "gemini-3-flash-preview"

credentials, project_id = google.auth.default()
os.environ["GOOGLE_CLOUD_PROJECT"] = project_id
os.environ["GOOGLE_CLOUD_LOCATION"] = LLM_LOCATION
os.environ["GOOGLE_GENAI_USE_VERTEXAI"] = "True"

vertexai.init(project=project_id, location=LOCATION)


collection_id = os.getenv("COLLECTION_ID", "default_collection")
data_store_region = os.getenv("DATA_STORE_REGION", "global")
data_store_id = os.getenv(
    "DATA_STORE_ID", "default-collection_documents"
)
data_store_path = (
    f"projects/{project_id}/locations/{data_store_region}"
    f"/collections/{collection_id}/dataStores/{data_store_id}"
)


# For debugging: print the path to verify it's correct
print(f"DEBUG: Attempting to connect to Data Store: {data_store_path}")

vertex_search_tool = create_search_tool(data_store_path)


root_agent = Agent(
    name="root_agent",
    model=Gemini(
        model="gemini-2.5-flash",
        retry_options=types.HttpRetryOptions(attempts=3),
    ),
    instruction=prompt.SYSTEM_PROMPT,
    tools=[vertex_search_tool],
)

app = App(
    root_agent=root_agent,
    name="app",
)
