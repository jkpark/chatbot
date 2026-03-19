from google.adk.agents import Agent

root_agent = Agent(
    name="my_chatbot",
    model="gemini-2.5-flash",
    description="A helpful chatbot assistant.",
    instruction="You are a helpful assistant. Answer user questions clearly and concisely.",
)
