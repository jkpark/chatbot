import pytest
import os
from dotenv import load_dotenv

load_dotenv()

from my_chatbot.agent import root_agent
from google.adk.runners import Runner
from google.adk.sessions import InMemorySessionService
from google.genai import types

@pytest.mark.asyncio
async def test_root_agent_initialization():
    assert root_agent.name == "my_chatbot"
    assert root_agent.model == "gemini-2.5-flash"
    assert "helpful chatbot assistant" in root_agent.description

@pytest.mark.asyncio
async def test_root_agent_response():
    session_service = InMemorySessionService()
    runner = Runner(agent=root_agent, app_name="test_app", session_service=session_service, auto_create_session=True)
    
    events = []
    async for event in runner.run_async(
        user_id="test_user",
        session_id="test_session",
        new_message=types.Content(role="user", parts=[types.Part.from_text(text="Say hello!")])
    ):
        events.append(event)
    
    assert len(events) > 0
