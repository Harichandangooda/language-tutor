from __future__ import annotations

from typing import Any, Dict, List
from pydantic import BaseModel, Field


class Answer(BaseModel):
    question_id: str
    answer: str


class AssessmentSubmission(BaseModel):
    user_id: str
    reading_answers: List[Answer] = Field(default_factory=list)
    listening_answers: List[Answer] = Field(default_factory=list)
    writing_response: str = ""
    speaking_transcript: str = ""
    assessment_answers: List[Answer] = Field(default_factory=list)


class AssessmentMetrics(BaseModel):
    reading_score: float
    listening_score: float
    writing_score: float
    speaking_score: float
    assessment_score: float
    weak_words: List[str] = Field(default_factory=list)
    grammar_errors: List[str] = Field(default_factory=list)


class AssessmentEvaluation(BaseModel):
    strengths: List[str] = Field(default_factory=list)
    weaknesses: List[str] = Field(default_factory=list)
    flashcard_words: List[str] = Field(default_factory=list)
    next_focus: str


class AssessmentResult(BaseModel):
    lesson_completed: bool
    strengths: List[str]
    weaknesses: List[str]
    new_flashcards: List[str]
    next_focus: str
    chapter_complete: bool = False
    chapter_average: float | None = None
    level_outcome: str | None = None
    current_level: int | None = None
    current_level_name: str | None = None
    metrics: Dict[str, Any]
