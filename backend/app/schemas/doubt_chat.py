from pydantic import BaseModel, ConfigDict


class StrictModel(BaseModel):
    model_config = ConfigDict(extra="forbid")


class DoubtChatRequest(StrictModel):
    user_id: str
    message: str


class DoubtChatResponse(StrictModel):
    answer: str
