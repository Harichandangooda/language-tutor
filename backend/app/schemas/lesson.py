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
    image_url: Optional[str] = None
    image_prompt: Optional[str] = None
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


class WordGloss(StrictModel):
    word: str
    meaning: str


class TranslatableText(StrictModel):
    text: str
    english_translation: str
    word_glosses: List[WordGloss]


class QAItem(StrictModel):
    question: TranslatableText
    answer: TranslatableText


class MCQItem(StrictModel):
    question: TranslatableText
    options: List[str]
    correct_answer: str


class VocabularyItem(StrictModel):
    word: str
    meaning: str
    example: TranslatableText


class DialogueLine(StrictModel):
    speaker: str
    line: TranslatableText


class PracticeItem(StrictModel):
    prompt: TranslatableText
    answer: TranslatableText
    hint: str


class LearnContent(StrictModel):
    intro: TranslatableText
    grammar_tip: TranslatableText
    coaching_tip: str
    vocabulary: List[VocabularyItem]
    dialogue: List[DialogueLine]


class PracticeContent(StrictModel):
    intro: TranslatableText
    items: List[PracticeItem]


class ReadingContent(StrictModel):
    passage: TranslatableText
    questions: List[QAItem]


class ListeningContent(StrictModel):
    audio_script: TranslatableText
    questions: List[QAItem]


class WritingContent(StrictModel):
    prompt: TranslatableText
    expected_keywords: List[TranslatableText]


class SpeakingContent(StrictModel):
    prompt: TranslatableText
    expected_phrases: List[TranslatableText]


class AssessmentContent(StrictModel):
    reading_questions: List[QAItem]
    listening_questions: List[QAItem]
    writing_prompt: TranslatableText
    speaking_prompt: TranslatableText
    questions: List[MCQItem]


class LessonPackage(StrictModel):
    card: LessonCard
    learn: LearnContent
    practice: PracticeContent
    reading: ReadingContent
    listening: ListeningContent
    writing: WritingContent
    speaking: SpeakingContent
    assessment: AssessmentContent | None = None


class LessonStartResponse(StrictModel):
    lesson_id: str
    card: LessonCard
    status: str
