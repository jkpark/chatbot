import os
from typing import Callable

from google.adk.agents import Agent
from google.adk.models import Gemini

from app import prompt
from app.retrievers import create_search_tool


def build_care_framework_agent(
    model_factory: Callable[[], Gemini], project_id: str
) -> Agent:
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

    return Agent(
        name="care_framework_agent",
        model=model_factory(),
        instruction=prompt.SYSTEM_PROMPT,
        tools=[vertex_search_tool],
    )
