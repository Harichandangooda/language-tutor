from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class LevelDefinition:
    value: int
    name: str
    cefr: str
    focus: str
    grammar_focus: str
    vocabulary_focus: list[str]


LEVEL_DEFINITIONS: dict[int, LevelDefinition] = {
    1: LevelDefinition(
        value=1,
        name="Newbie",
        cefr="A1",
        focus="basic greetings and identity",
        grammar_focus="simple present, ich bin, ich heisse",
        vocabulary_focus=["Hallo", "Ich heisse", "Ich komme aus", "Danke"],
    ),
    2: LevelDefinition(
        value=2,
        name="Beginner",
        cefr="A2",
        focus="daily routines and simple requests",
        grammar_focus="present tense verbs, polite requests",
        vocabulary_focus=["moechte", "Fruehstueck", "arbeiten", "heute"],
    ),
    3: LevelDefinition(
        value=3,
        name="Intermediate",
        cefr="B1",
        focus="opinions, comparisons, and past experiences",
        grammar_focus="weil clauses, modal verbs, Perfekt review",
        vocabulary_focus=["meiner Meinung nach", "gestern", "interessant", "vergleich"],
    ),
    4: LevelDefinition(
        value=4,
        name="Advanced",
        cefr="B2",
        focus="formal communication and nuanced explanations",
        grammar_focus="subordinate clauses, connectors, formal register",
        vocabulary_focus=["allerdings", "obwohl", "vereinbaren", "ausserdem"],
    ),
    5: LevelDefinition(
        value=5,
        name="Expert",
        cefr="C1",
        focus="abstract discussion and professional fluency",
        grammar_focus="precision, persuasion, advanced connectors",
        vocabulary_focus=["darueber hinaus", "einerseits", "andererseits", "Standpunkt"],
    ),
}


def level_name(level: int) -> str:
    return LEVEL_DEFINITIONS[level].name


def level_cefr(level: int) -> str:
    return LEVEL_DEFINITIONS[level].cefr


def build_demo_lessons(level: int, chapter: int) -> list[dict[str, object]]:
    definition = LEVEL_DEFINITIONS[level]
    chapter_label = f"Chapter {chapter}"
    return [
        {
            "slot": 1,
            "slug": f"level-{level}-chapter-{chapter}-lesson-1",
            "day_label": chapter_label,
            "title_hint": f"{definition.name} Chapter {chapter}: Warm-up Reading",
            "objective_hint": f"Read and understand German around {definition.focus}.",
            "scenario": f"{definition.name} learner working through chapter {chapter} with a focus on {definition.focus}.",
            "grammar_focus": definition.grammar_focus,
            "vocabulary_focus": definition.vocabulary_focus,
            "difficulty": definition.cefr,
        },
        {
            "slot": 2,
            "slug": f"level-{level}-chapter-{chapter}-lesson-2",
            "day_label": chapter_label,
            "title_hint": f"{definition.name} Chapter {chapter}: Conversation Builder",
            "objective_hint": f"Listen and respond naturally in German about {definition.focus}.",
            "scenario": f"Conversation-focused practice for chapter {chapter} around {definition.focus}.",
            "grammar_focus": definition.grammar_focus,
            "vocabulary_focus": definition.vocabulary_focus,
            "difficulty": definition.cefr,
        },
        {
            "slot": 3,
            "slug": f"level-{level}-chapter-{chapter}-lesson-3",
            "day_label": chapter_label,
            "title_hint": f"{definition.name} Chapter {chapter}: Chapter Checkpoint",
            "objective_hint": f"Apply chapter {chapter} German in reading, writing, and speaking.",
            "scenario": f"Checkpoint lesson for chapter {chapter} that tests {definition.focus}.",
            "grammar_focus": definition.grammar_focus,
            "vocabulary_focus": definition.vocabulary_focus,
            "difficulty": definition.cefr,
        },
    ]


def seeded_chapter_history(level: int) -> list[dict[str, object]]:
    definition = LEVEL_DEFINITIONS[level]
    seeded_scores = [82.0, 84.0, 86.0, 88.0]
    history = []
    for chapter, score in enumerate(seeded_scores, start=1):
        history.append(
            {
                "chapter": chapter,
                "level": level,
                "level_name": definition.name,
                "score": score,
                "status": "completed",
                "result": "completed",
            }
        )
    return history


def build_progression_state(level: int) -> dict[str, object]:
    definition = LEVEL_DEFINITIONS[level]
    return {
        "selected_level": level,
        "current_level": level,
        "current_level_name": definition.name,
        "current_level_cefr": definition.cefr,
        "current_chapter": 5,
        "completed_chapters": [1, 2, 3, 4],
        "promotion_threshold": 60.0,
        "chapter_history": seeded_chapter_history(level),
        "last_chapter_average": None,
        "last_result": "in_progress",
    }
