from typing import Callable

from google.adk.agents import Agent
from google.adk.models import Gemini


def build_general_agent(model_factory: Callable[[], Gemini]) -> Agent:
    return Agent(
        name="general_agent",
        model=model_factory(),
        instruction=(
            "You are a helpful general-purpose assistant. "
            "Handle normal conversation, writing, and reasoning tasks that do not "
            "require data store retrieval."
        ),
    )
