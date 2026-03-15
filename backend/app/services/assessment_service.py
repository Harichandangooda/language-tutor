from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, Dict

from backend.app.services.metrics_processor import MetricsProcessor
from backend.app.services.evaluator_service import EvaluatorService


class LessonNotFoundError(Exception):
    pass


class InvalidSubmissionError(Exception):
    pass


class AssessmentService:
    def __init__(
        self,
        lessons_repo,
        learner_state_repo,
        attempts_repo,
        flashcards_repo,
    ):
        self.lessons_repo = lessons_repo
        self.learner_state_repo = learner_state_repo
        self.attempts_repo = attempts_repo
        self.flashcards_repo = flashcards_repo
        self.metrics_processor = MetricsProcessor()
        self.evaluator_service = EvaluatorService()

    def submit_assessment(self, lesson_id: str, submission) -> Dict[str, Any]:
        lesson = self.lessons_repo.get(lesson_id)
        if not lesson:
            raise LessonNotFoundError(f"Lesson '{lesson_id}' not found")

        user_id = submission.user_id
        if lesson["user_id"] != user_id:
            raise InvalidSubmissionError("This lesson does not belong to the submitted user")

        if lesson.get("status") == "completed":
            raise InvalidSubmissionError("This lesson has already been completed")

        submission_dict = submission.model_dump()

        if not self._has_any_answers(submission_dict):
            raise InvalidSubmissionError("Assessment submission is empty")

        learner_state = self.learner_state_repo.get_or_create(user_id)

        metrics = self.metrics_processor.compute(
            submission=submission_dict,
            lesson=lesson,
        )

        evaluation = self.evaluator_service.evaluate(
            learner_state=learner_state,
            lesson=lesson,
            metrics=metrics,
        )

        attempt_id = f"attempt_{lesson_id}_{datetime.now(timezone.utc).strftime('%Y%m%d%H%M%S')}"

        self.attempts_repo.create_attempt(
            attempt_id=attempt_id,
            lesson_id=lesson_id,
            user_id=user_id,
            submission=submission_dict,
            metrics=metrics,
            evaluation=evaluation,
        )

        flashcards = self._build_flashcards(evaluation["flashcard_words"])
        if flashcards:
            self.flashcards_repo.add_cards(user_id, flashcards)

        learner_patch = {
            "recent_performance": {
                "last_lesson_score": metrics["assessment_score"],
                "reading_score": metrics["reading_score"],
                "listening_score": metrics["listening_score"],
                "writing_score": metrics["writing_score"],
                "speaking_score": metrics["speaking_score"],
            },
            "grammar": {
                "weak_topics": evaluation["weaknesses"],
            },
            "vocabulary": {
                "review_words": evaluation["flashcard_words"],
            },
            "next_lesson_focus": {
                "topic": evaluation["next_focus"],
                "grammar": evaluation["next_focus"],
                "difficulty": learner_state.get("language_profile", {}).get("current_level", "A1"),
            },
            "lesson_history": {
                "lessons_completed": learner_state.get("lesson_history", {}).get("lessons_completed", 0) + 1,
                "last_lesson_id": lesson_id,
                "last_lesson_date": datetime.now(timezone.utc).date().isoformat(),
            },
            "updated_at": datetime.now(timezone.utc).isoformat(),
        }

        self.learner_state_repo.patch(user_id, learner_patch)
        self.lessons_repo.mark_completed(lesson_id)

        return {
            "lesson_completed": True,
            "strengths": evaluation["strengths"],
            "weaknesses": evaluation["weaknesses"],
            "new_flashcards": evaluation["flashcard_words"],
            "next_focus": evaluation["next_focus"],
            "metrics": metrics,
        }

    def _has_any_answers(self, submission_dict: Dict[str, Any]) -> bool:
        return any(
            [
                bool(submission_dict.get("reading_answers")),
                bool(submission_dict.get("listening_answers")),
                bool(submission_dict.get("writing_response", "").strip()),
                bool(submission_dict.get("speaking_transcript", "").strip()),
                bool(submission_dict.get("assessment_answers")),
            ]
        )

    def _build_flashcards(self, words: list[str]) -> list[dict[str, str]]:
        cards = []
        for word in words:
            cards.append(
                {
                    "word": word,
                    "meaning": f"Meaning of {word}",
                    "example": f"Example sentence using {word}",
                    "status": "learning",
                }
            )
        return cards