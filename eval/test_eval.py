import pytest
import os
from dotenv import load_dotenv

load_dotenv()

from my_chatbot.agent import root_agent
from google.adk.runners import Runner
from google.adk.sessions import InMemorySessionService
from google.genai import types

@pytest.mark.asyncio
async def test_agent_evaluation():
    session_service = InMemorySessionService()
    runner = Runner(agent=root_agent, app_name="test_app", session_service=session_service, auto_create_session=True)
    
    events = []
    async for event in runner.run_async(
        user_id="test_user",
        session_id="test_session",
        new_message=types.Content(role="user", parts=[types.Part.from_text(text="What is the capital of France?")])
    ):
        events.append(event)
    
    response_text = "".join(
        [part.text for event in events if hasattr(event, "content") and event.content is not None and event.content.parts for part in event.content.parts if part.text]
    )
    
    assert "Paris" in response_text
