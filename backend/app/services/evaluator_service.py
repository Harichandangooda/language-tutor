from __future__ import annotations

from typing import Any, Dict, List


class EvaluatorService:
    def evaluate(
        self,
        learner_state: Dict[str, Any],
        lesson: Dict[str, Any],
        metrics: Dict[str, Any],
    ) -> Dict[str, Any]:
        strengths: List[str] = []
        weaknesses: List[str] = []
        flashcard_words: List[str] = []
        next_focus = "continue with beginner daily routine lessons"

        if metrics["reading_score"] >= 0.75:
            strengths.append("reading comprehension")

        if metrics["listening_score"] >= 0.65:
            strengths.append("listening comprehension")

        if metrics["writing_score"] < 0.7:
            weaknesses.append("writing")

        if metrics["speaking_score"] < 0.7:
            weaknesses.append("speaking")

        if metrics["grammar_errors"]:
            weaknesses.extend(metrics["grammar_errors"])
            next_focus = "present tense verb conjugation"

        lesson_package = lesson.get("lesson_package", {})
        card = lesson_package.get("card", {})
        title = card.get("title", "").lower()

        if "daily routine" in title:
            flashcard_words = ["gehen", "essen", "lernen"]

        return {
            "strengths": list(dict.fromkeys(strengths)),
            "weaknesses": list(dict.fromkeys(weaknesses)),
            "flashcard_words": flashcard_words,
            "next_focus": next_focus,
        }