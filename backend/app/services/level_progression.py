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


def build_demo_lessons(
    level: int,
    chapter: int,
    lesson_count: int = 3,
    cycle: int = 1,
    focus_profile: dict[str, object] | None = None,
) -> list[dict[str, object]]:
    definition = LEVEL_DEFINITIONS[level]
    chapter_label = f"Chapter {chapter}"
    focus_profile = focus_profile or {}
    weak_topics = [str(item) for item in focus_profile.get("weak_topics", []) if item]
    weak_words = [str(item) for item in focus_profile.get("weak_words", []) if item]
    weakest_skills = [str(item) for item in focus_profile.get("weakest_skills", []) if item]
    focus_override = str(focus_profile.get("focus_override") or "").strip()
    target_focus = focus_override or definition.focus
    target_grammar = str(focus_profile.get("grammar_focus") or definition.grammar_focus)
    target_vocabulary = weak_words[:4] or list(definition.vocabulary_focus)
    reset_hint = ""
    if cycle > 1 and (weak_topics or weakest_skills or weak_words):
        reset_hint = (
            " Retry focus: "
            f"skills={', '.join(weakest_skills) if weakest_skills else 'general output'}; "
            f"topics={', '.join(weak_topics) if weak_topics else target_grammar}; "
            f"words={', '.join(target_vocabulary)}."
        )

    templates = [
        (
            "Warm-up Reading",
            "Read and understand German around {focus}.",
            "{level_name} learner working through chapter {chapter} with a focus on {focus}.",
        ),
        (
            "Conversation Builder",
            "Listen and respond naturally in German about {focus}.",
            "Conversation-focused practice for chapter {chapter} around {focus}.",
        ),
        (
            "Chapter Checkpoint",
            "Apply chapter {chapter} German in reading, writing, and speaking.",
            "Checkpoint lesson for chapter {chapter} that tests {focus}.",
        ),
        (
            "Real-Life Response",
            "Use German in practical real-world responses tied to {focus}.",
            "Applied German lesson for chapter {chapter} centered on {focus}.",
        ),
        (
            "Confidence Builder",
            "Strengthen speaking and writing control around {focus}.",
            "Fresh retry lesson for chapter {chapter} with new examples about {focus}.",
        ),
    ]
    lessons: list[dict[str, object]] = []
    for slot in range(1, lesson_count + 1):
        title_suffix, objective_template, scenario_template = templates[(slot - 1) % len(templates)]
        cycle_suffix = "" if cycle == 1 else f"-cycle-{cycle}"
        lessons.append(
            {
                "slot": slot,
                "slug": f"level-{level}-chapter-{chapter}-lesson-{slot}{cycle_suffix}",
                "day_label": chapter_label,
                "title_hint": f"{definition.name} Chapter {chapter}: {title_suffix}",
                "objective_hint": objective_template.format(focus=target_focus, chapter=chapter),
                "scenario": scenario_template.format(
                    level_name=definition.name,
                    chapter=chapter,
                    focus=target_focus,
                )
                + reset_hint,
                "grammar_focus": target_grammar,
                "vocabulary_focus": target_vocabulary,
                "difficulty": definition.cefr,
                "cycle": cycle,
                "reset_focus_profile": focus_profile,
            }
        )
    return lessons


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
        "active_lesson_count": 3,
        "content_cycle": 1,
        "chapter_promotion_threshold": 60.0,
        "overall_threshold": 80.0,
        "relegation_threshold": 50.0,
        "chapter_history": seeded_chapter_history(level),
        "last_completed_chapter_history": [],
        "level_attempt_history": [],
        "last_chapter_average": None,
        "last_level_average": None,
        "last_result": "in_progress",
        "reset_focus_profile": {},
    }
