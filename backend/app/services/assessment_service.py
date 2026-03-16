from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, Dict

from backend.app.services.metrics_processor import MetricsProcessor
from backend.app.services.evaluator_service import EvaluatorService
from backend.app.services.level_progression import build_progression_state, level_name


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
            submission=submission_dict,
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

        chapter_result = self._handle_chapter_completion(
            user_id=user_id,
            lesson=lesson,
            learner_state=self.learner_state_repo.get_or_create(user_id),
        )

        return {
            "lesson_completed": True,
            "strengths": evaluation["strengths"],
            "weaknesses": evaluation["weaknesses"],
            "new_flashcards": evaluation["flashcard_words"],
            "next_focus": evaluation["next_focus"],
            "chapter_complete": chapter_result["chapter_complete"],
            "chapter_average": chapter_result["chapter_average"],
            "level_outcome": chapter_result["level_outcome"],
            "current_level": chapter_result["current_level"],
            "current_level_name": chapter_result["current_level_name"],
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

    def _handle_chapter_completion(
        self,
        user_id: str,
        lesson: Dict[str, Any],
        learner_state: Dict[str, Any],
    ) -> Dict[str, Any]:
        progression = learner_state.get("progression", build_progression_state(1))
        current_level = int(progression.get("current_level", 1))
        current_chapter = int(progression.get("current_chapter", 5))

        chapter_lessons = [
            item
            for item in self.lessons_repo.list_by_user(user_id)
            if item.get("level") == current_level and item.get("chapter") == current_chapter
        ]
        if not chapter_lessons or any(item.get("status") != "completed" for item in chapter_lessons):
            return {
                "chapter_complete": False,
                "chapter_average": None,
                "level_outcome": None,
                "current_level": current_level,
                "current_level_name": level_name(current_level),
            }

        attempts = []
        for item in chapter_lessons:
            attempt = self.attempts_repo.get_latest_by_lesson(item["lesson_id"])
            if attempt is not None:
                attempts.append(attempt)

        if not attempts:
            return {
                "chapter_complete": False,
                "chapter_average": None,
                "level_outcome": None,
                "current_level": current_level,
                "current_level_name": level_name(current_level),
            }

        chapter_average = round(
            sum(float(attempt["metrics"].get("assessment_score", 0.0)) * 100 for attempt in attempts) / len(attempts),
            1,
        )
        threshold = float(progression.get("promotion_threshold", 60.0))
        outcome = "retry"
        next_level = current_level

        if chapter_average >= threshold:
            if current_level >= 5:
                outcome = "mastered"
            else:
                outcome = "promoted"
                next_level = current_level + 1

        chapter_history = list(progression.get("chapter_history", []))
        chapter_history.append(
            {
                "chapter": current_chapter,
                "level": current_level,
                "level_name": level_name(current_level),
                "score": chapter_average,
                "status": "completed",
                "result": outcome,
            }
        )

        if outcome == "promoted":
            new_progression = build_progression_state(next_level)
            new_progression["last_chapter_average"] = chapter_average
            new_progression["last_result"] = outcome
        elif outcome == "mastered":
            new_progression = dict(progression)
            new_progression["last_chapter_average"] = chapter_average
            new_progression["last_result"] = outcome
            new_progression["chapter_history"] = chapter_history
        else:
            new_progression = dict(progression)
            new_progression["last_chapter_average"] = chapter_average
            new_progression["last_result"] = outcome
            new_progression["chapter_history"] = chapter_history

        self.learner_state_repo.patch(
            user_id,
            {
                "language_profile": {
                    "current_level": build_progression_state(next_level)["current_level_cefr"]
                    if outcome == "promoted"
                    else learner_state.get("language_profile", {}).get("current_level", "A1"),
                },
                "progression": new_progression,
            },
        )

        self.lessons_repo.delete_by_user(user_id)

        return {
            "chapter_complete": True,
            "chapter_average": chapter_average,
            "level_outcome": outcome,
            "current_level": new_progression.get("current_level", current_level),
            "current_level_name": new_progression.get("current_level_name", level_name(current_level)),
        }
