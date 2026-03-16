from __future__ import annotations

from typing import Any, Dict, List

from backend.app.chains.evaluation_chain import EvaluationChain
from backend.app.llm.model_factory import get_chat_model


class EvaluatorService:
    def __init__(self):
        self._chain = None

    def evaluate(
        self,
        learner_state: Dict[str, Any],
        lesson: Dict[str, Any],
        submission: Dict[str, Any],
        metrics: Dict[str, Any],
    ) -> Dict[str, Any]:
        try:
            return self._evaluate_with_llm(
                learner_state=learner_state,
                lesson=lesson,
                submission=submission,
                metrics=metrics,
            )
        except Exception:
            return self._evaluate_with_fallback(
                learner_state=learner_state,
                lesson=lesson,
                metrics=metrics,
            )

    def _evaluate_with_llm(
        self,
        learner_state: Dict[str, Any],
        lesson: Dict[str, Any],
        submission: Dict[str, Any],
        metrics: Dict[str, Any],
    ) -> Dict[str, Any]:
        if self._chain is None:
            self._chain = EvaluationChain(get_chat_model())

        evaluation = self._chain.evaluate(
            learner_state=learner_state,
            lesson=lesson,
            submission=submission,
            metrics=metrics,
        )
        return evaluation.model_dump()

    def _evaluate_with_fallback(
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

        if metrics["weak_words"]:
            flashcard_words = metrics["weak_words"][:5]

        lesson_package = lesson.get("lesson_package", {})
        card = lesson_package.get("card", {})
        title = card.get("title", "").lower()

        if not flashcard_words and "daily routine" in title:
            flashcard_words = ["gehen", "essen", "lernen"]

        return {
            "strengths": list(dict.fromkeys(strengths)),
            "weaknesses": list(dict.fromkeys(weaknesses)),
            "flashcard_words": flashcard_words,
            "next_focus": next_focus,
            "long_feedback": (
                "You are building useful German communication skills. "
                f"Your strongest areas were {', '.join(strengths) if strengths else 'effort and completion'}. "
                f"The main areas to improve are {', '.join(weaknesses) if weaknesses else 'more precise output and recall'}."
            ),
            "what_went_well": list(dict.fromkeys(strengths))[:4],
            "what_to_improve": list(dict.fromkeys(weaknesses))[:4],
        }
