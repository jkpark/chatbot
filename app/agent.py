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

from app.agents import build_care_framework_agent, build_general_agent

LLM_LOCATION = os.environ.get("GOOGLE_CLOUD_LOCATION", "global")
LOCATION = os.environ.get("LOCATION", "asia-northeast3")
LLM = "gemini-3-flash-preview"

credentials, project_id = google.auth.default()
os.environ["GOOGLE_CLOUD_PROJECT"] = project_id
os.environ["GOOGLE_CLOUD_LOCATION"] = LLM_LOCATION
os.environ["GOOGLE_GENAI_USE_VERTEXAI"] = "True"

vertexai.init(project=project_id, location=LOCATION)

def _build_model() -> Gemini:
    return Gemini(
        model="gemini-2.5-flash",
        retry_options=types.HttpRetryOptions(attempts=3),
    )


care_framework_agent = build_care_framework_agent(
    _build_model, project_id
)


general_agent = build_general_agent(_build_model)


root_agent = Agent(
    name="root_agent",
    model=_build_model(),
    instruction=(
        "당신은 데이터플랫폼 부서 전용 루트 라우팅 에이전트입니다. "
        "직접 답변하지 말고 요청 성격에 따라 아래 규칙으로 반드시 위임하세요. "
        "사용자가 CARE Framework(정의, 구조, 운영 모델, 재사용 로직, 거버넌스, 온보딩, "
        "스펙/정책/근거 확인)를 묻는 경우 care_framework_agent로 위임합니다. "
        "사용자가 일상적인 대화, 일반 설명, 가벼운 문장 작성/정리 요청을 하는 경우 general_agent로 위임합니다. "
        "요청이 모호하면 한 문장으로 짧게 의도를 확인한 뒤 가장 가까운 에이전트로 위임합니다."
    ),
    sub_agents=[care_framework_agent, general_agent],
)

app = App(
    root_agent=root_agent,
    name="app",
)
