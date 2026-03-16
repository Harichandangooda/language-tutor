from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, Dict

from backend.app.services.evaluator_service import EvaluatorService
from backend.app.services.level_progression import build_progression_state, level_name
from backend.app.services.metrics_processor import MetricsProcessor


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
            "long_feedback": evaluation.get("long_feedback", ""),
            "what_went_well": evaluation.get("what_went_well", []),
            "what_to_improve": evaluation.get("what_to_improve", []),
            "correct_answers": self._build_correct_answers(lesson),
            "chapter_complete": chapter_result["chapter_complete"],
            "chapter_average": chapter_result["chapter_average"],
            "level_average": chapter_result["level_average"],
            "level_outcome": chapter_result["level_outcome"],
            "current_level": chapter_result["current_level"],
            "current_level_name": chapter_result["current_level_name"],
            "metrics": metrics,
        }

    def _build_reset_focus_profile(
        self,
        user_id: str,
        level: int,
    ) -> Dict[str, Any]:
        attempts = self.attempts_repo.list_by_user(user_id)
        if not attempts:
            return {}

        relevant_attempts = []
        for attempt in attempts:
            lesson = self.lessons_repo.get(attempt["lesson_id"])
            if lesson is None:
                continue
            if int(lesson.get("level") or 0) != level:
                continue
            relevant_attempts.append(attempt)

        if not relevant_attempts:
            relevant_attempts = attempts[:5]

        weak_topics: list[str] = []
        weak_words: list[str] = []
        skill_scores = {
            "reading": [],
            "listening": [],
            "writing": [],
            "speaking": [],
        }

        for attempt in relevant_attempts[:8]:
            evaluation = attempt.get("evaluation", {})
            metrics = attempt.get("metrics", {})
            weak_topics.extend(evaluation.get("weaknesses", []))
            weak_topics.extend(evaluation.get("what_to_improve", []))
            weak_words.extend(evaluation.get("flashcard_words", []))
            skill_scores["reading"].append(float(metrics.get("reading_score", 0.0)))
            skill_scores["listening"].append(float(metrics.get("listening_score", 0.0)))
            skill_scores["writing"].append(float(metrics.get("writing_score", 0.0)))
            skill_scores["speaking"].append(float(metrics.get("speaking_score", 0.0)))

        ranked_skills = sorted(
            (
                (skill, sum(scores) / len(scores))
                for skill, scores in skill_scores.items()
                if scores
            ),
            key=lambda item: item[1],
        )
        weakest_skills = [item[0] for item in ranked_skills[:2]]
        grammar_focus = ", ".join(list(dict.fromkeys(weak_topics))[:2])
        if not grammar_focus:
            grammar_focus = "sentence building and practical response control"

        focus_override = "practical German conversation and writing reinforcement"
        if weakest_skills:
            focus_override = (
                "practical German reinforcement for "
                + " and ".join(weakest_skills)
            )

        return {
            "focus_override": focus_override,
            "grammar_focus": grammar_focus,
            "weak_topics": list(dict.fromkeys(item for item in weak_topics if item))[:5],
            "weak_words": list(dict.fromkeys(item for item in weak_words if item))[:6],
            "weakest_skills": weakest_skills,
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

    def _build_correct_answers(self, lesson: Dict[str, Any]) -> Dict[str, Any]:
        assessment = lesson.get("lesson_package", {}).get("assessment", {})
        return {
            "reading_answers": [
                item.get("answer", {}).get("text", "")
                for item in assessment.get("reading_questions", [])
            ],
            "listening_answers": [
                item.get("answer", {}).get("text", "")
                for item in assessment.get("listening_questions", [])
            ],
            "mcq_answers": [
                item.get("correct_answer", "")
                for item in assessment.get("questions", [])
            ],
        }

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
                "level_average": None,
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
                "level_average": None,
                "level_outcome": None,
                "current_level": current_level,
                "current_level_name": level_name(current_level),
            }

        chapter_average = round(
            sum(float(attempt["metrics"].get("assessment_score", 0.0)) * 100 for attempt in attempts) / len(attempts),
            1,
        )

        chapter_history = [
            item
            for item in list(progression.get("chapter_history", []))
            if not (int(item.get("chapter", 0)) == current_chapter and int(item.get("level", 0)) == current_level)
        ]
        chapter_history.append(
            {
                "chapter": current_chapter,
                "level": current_level,
                "level_name": level_name(current_level),
                "score": chapter_average,
                "status": "completed",
                "result": "completed",
            }
        )

        level_average = round(
            sum(float(item.get("score", 0.0)) for item in chapter_history) / len(chapter_history),
            1,
        ) if chapter_history else 0.0

        promotion_threshold = float(progression.get("overall_threshold", 80.0))
        relegation_threshold = float(progression.get("relegation_threshold", 50.0))
        outcome = "reset"
        next_level = current_level

        if level_average >= promotion_threshold:
            if current_level >= 5:
                outcome = "mastered"
            else:
                outcome = "promoted"
                next_level = current_level + 1
        elif level_average < relegation_threshold:
            if current_level > 1:
                outcome = "relegated"
                next_level = current_level - 1
            else:
                outcome = "reset"

        chapter_history[-1]["result"] = outcome

        level_attempt_history = list(progression.get("level_attempt_history", []))
        level_attempt_history.append(
            {
                "level": current_level,
                "level_name": level_name(current_level),
                "chapter_average": chapter_average,
                "level_average": level_average,
                "result": outcome,
                "cycle": int(progression.get("content_cycle", 1)),
            }
        )

        if outcome == "promoted":
            new_progression = build_progression_state(next_level)
        elif outcome == "relegated":
            new_progression = build_progression_state(next_level)
        elif outcome == "reset":
            new_progression = build_progression_state(current_level)
            new_progression["content_cycle"] = int(progression.get("content_cycle", 1)) + 1
            new_progression["active_lesson_count"] = 5
            new_progression["reset_focus_profile"] = self._build_reset_focus_profile(
                user_id=user_id,
                level=current_level,
            )
        else:
            new_progression = dict(progression)
            new_progression["chapter_history"] = chapter_history

        new_progression["last_chapter_average"] = chapter_average
        new_progression["last_level_average"] = level_average
        new_progression["last_completed_chapter_history"] = chapter_history
        new_progression["last_result"] = outcome
        new_progression["level_attempt_history"] = level_attempt_history

        self.learner_state_repo.patch(
            user_id,
            {
                "language_profile": {
                    "current_level": build_progression_state(next_level)["current_level_cefr"]
                    if outcome in {"promoted", "relegated"}
                    else learner_state.get("language_profile", {}).get("current_level", "A1"),
                },
                "progression": new_progression,
            },
        )

        self.lessons_repo.delete_by_user(user_id)

        return {
            "chapter_complete": True,
            "chapter_average": chapter_average,
            "level_average": level_average,
            "level_outcome": outcome,
            "current_level": new_progression.get("current_level", current_level),
            "current_level_name": new_progression.get("current_level_name", level_name(current_level)),
        }
