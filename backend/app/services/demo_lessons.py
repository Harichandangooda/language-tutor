from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class DemoLessonBlueprint:
    slot: int
    slug: str
    day_label: str
    title_hint: str
    objective_hint: str
    scenario: str
    grammar_focus: str
    vocabulary_focus: list[str]
    difficulty: str = "A1"


DEMO_LESSONS: list[DemoLessonBlueprint] = [
    DemoLessonBlueprint(
        slot=1,
        slug="greetings-introductions",
        day_label="Today",
        title_hint="Greetings and Introductions",
        objective_hint="Introduce yourself in German and greet someone naturally.",
        scenario="Meeting someone for the first time at a community language meetup.",
        grammar_focus="ich heisse, ich komme aus, simple present statements",
        vocabulary_focus=["Hallo", "Ich heisse", "Freut mich", "Ich komme aus"],
    ),
    DemoLessonBlueprint(
        slot=2,
        slug="cafe-ordering",
        day_label="Yesterday",
        title_hint="At the Cafe",
        objective_hint="Order a drink and respond to simple follow-up questions.",
        scenario="Ordering coffee and cake at a quiet German cafe.",
        grammar_focus="ich moechte, polite requests, numbers and items",
        vocabulary_focus=["Ich moechte", "Kaffee", "Kuchen", "bitte"],
    ),
    DemoLessonBlueprint(
        slot=3,
        slug="city-directions",
        day_label="Friday",
        title_hint="Asking for Directions",
        objective_hint="Ask where a place is and understand a short reply.",
        scenario="Asking for the train station in a German city center.",
        grammar_focus="wo ist, links, rechts, geradeaus",
        vocabulary_focus=["Wo ist", "Bahnhof", "links", "rechts", "geradeaus"],
    ),
]
