from pydantic import BaseModel, ConfigDict
from typing import List, Optional


class StrictModel(BaseModel):
    model_config = ConfigDict(extra="forbid")


class LessonStartRequest(StrictModel):
    user_id: str


class LessonFeedItem(StrictModel):
    lesson_id: str
    slot: int
    slug: str
    day_label: str
    title: str
    objective: str
    status: str
    level: int | None = None
    chapter: int | None = None
    is_today: bool


class LessonFeedResponse(StrictModel):
    user_id: str
    lessons: List[LessonFeedItem]


class LessonCard(StrictModel):
    lesson_id: str
    title: str
    objective: str
    image_url: Optional[str] = None
    image_prompt: Optional[str] = None


class QAItem(StrictModel):
    question: str
    answer: str


class MCQItem(StrictModel):
    question: str
    options: List[str]
    correct_answer: str


class ReadingContent(StrictModel):
    passage: str
    questions: List[QAItem]


class ListeningContent(StrictModel):
    audio_script: str
    questions: List[QAItem]


class WritingContent(StrictModel):
    prompt: str
    expected_keywords: List[str]


class SpeakingContent(StrictModel):
    prompt: str
    expected_phrases: List[str]


class AssessmentContent(StrictModel):
    questions: List[MCQItem]


class LessonPackage(StrictModel):
    card: LessonCard
    reading: ReadingContent
    listening: ListeningContent
    writing: WritingContent
    speaking: SpeakingContent
    assessment: AssessmentContent


class LessonStartResponse(StrictModel):
    lesson_id: str
    card: LessonCard
    status: str
