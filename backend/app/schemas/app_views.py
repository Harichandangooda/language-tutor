from __future__ import annotations

from typing import List

from pydantic import BaseModel


class ProgressLessonItem(BaseModel):
    lesson_id: str
    slot: int
    title: str
    status: str
    score: float | None = None
    focus: str
    summary: str


class ChapterProgressItem(BaseModel):
    chapter: int
    level: int
    level_name: str
    score: float
    status: str
    result: str


class ProgressSummaryResponse(BaseModel):
    user_id: str
    overall_score: float
    strengths: List[str]
    weak_topics: List[str]
    current_level: int
    current_level_name: str
    current_chapter: int
    chapter_history: List[ChapterProgressItem]
    lessons: List[ProgressLessonItem]


class ProfileSummaryResponse(BaseModel):
    user_id: str
    name: str
    email: str
    native_language: str
    target_language: str
    current_level_value: int
    current_level_name: str
    current_level: str
    lessons_completed: int
    total_lessons: int
    streak_label: str
    current_chapter: int
    promotion_threshold: float
    mastered: bool
    next_focus: str


class FlashcardItem(BaseModel):
    word: str
    meaning: str
    example: str
    status: str


class FlashcardListResponse(BaseModel):
    user_id: str
    cards: List[FlashcardItem]


class LevelSelectionRequest(BaseModel):
    user_id: str
    level: int


class LevelSelectionResponse(BaseModel):
    user_id: str
    current_level: int
    current_level_name: str
    current_chapter: int
    message: str
