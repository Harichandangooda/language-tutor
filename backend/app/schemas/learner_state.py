from pydantic import BaseModel
from typing import List, Dict

class SkillLevels(BaseModel):
    reading: float
    listening: float
    writing: float
    speaking: float


class VocabularyState(BaseModel):
    mastered_words: List[str]
    learning_words: List[str]
    review_words: List[str]


class LearnerState(BaseModel):
    user_id: str
    current_level: str
    skill_levels: SkillLevels
    vocabulary: VocabularyState
    weak_topics: List[str]
    lessons_completed: int


class LearnerStateUpdate(BaseModel):
    skill_updates: Dict[str, float]
    new_words: List[str]
    review_words: List[str]
    weak_topics: List[str]
    next_lesson_focus: Dict