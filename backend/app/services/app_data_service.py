from __future__ import annotations

from typing import Any

from backend.app.services.level_progression import (
    LEVEL_DEFINITIONS,
    build_progression_state,
    level_cefr,
    level_name,
)


class AppDataRequestError(Exception):
    pass


class AppDataService:
    def __init__(
        self,
        users_repo,
        learner_state_repo,
        lessons_repo,
        attempts_repo,
        flashcards_repo,
        lesson_service,
    ):
        self.users_repo = users_repo
        self.learner_state_repo = learner_state_repo
        self.lessons_repo = lessons_repo
        self.attempts_repo = attempts_repo
        self.flashcards_repo = flashcards_repo
        self.lesson_service = lesson_service

    def set_level(self, user_id: str, level: int) -> dict[str, Any]:
        user = self._get_user(user_id)
        if level not in LEVEL_DEFINITIONS:
            raise AppDataRequestError("level must be between 1 and 5")

        progression = build_progression_state(level)
        self.lessons_repo.delete_by_user(user_id)
        self.attempts_repo.delete_by_user(user_id)
        self.flashcards_repo.delete_by_user(user_id)

        self.learner_state_repo.patch(
            user_id,
            {
                "language_profile": {
                    "current_level": level_cefr(level),
                    "target_language": user.get("target_language", "German"),
                    "native_language": user.get("native_language", "English"),
                },
                "recent_performance": {
                    "last_lesson_score": 0.0,
                    "reading_score": 0.0,
                    "listening_score": 0.0,
                    "writing_score": 0.0,
                    "speaking_score": 0.0,
                },
                "lesson_history": {
                    "lessons_completed": 0,
                    "last_lesson_id": None,
                    "last_lesson_date": None,
                },
                "next_lesson_focus": {
                    "topic": LEVEL_DEFINITIONS[level].focus,
                    "grammar": LEVEL_DEFINITIONS[level].grammar_focus,
                    "difficulty": level_cefr(level),
                },
                "progression": progression,
            },
        )
        self.lesson_service.preload_lessons(user_id)

        return {
            "user_id": user_id,
            "current_level": level,
            "current_level_name": level_name(level),
            "current_chapter": 5,
            "message": f"Demo set to level {level}: {level_name(level)}",
        }

    def get_progress_summary(self, user_id: str) -> dict[str, Any]:
        user = self._get_user(user_id)
        lesson_feed = self.lesson_service.list_lessons(user_id)["lessons"]
        learner_state = self.learner_state_repo.get_or_create(user_id)
        progression = learner_state.get("progression", build_progression_state(1))
        active_lesson_count = int(progression.get("active_lesson_count", 3))

        lessons = []
        strengths: list[str] = []
        weak_topics = learner_state.get("grammar", {}).get("weak_topics", []) or []

        for lesson in lesson_feed:
            attempt = self.attempts_repo.get_latest_by_lesson(lesson["lesson_id"])
            if attempt is not None:
                metrics = attempt["metrics"]
                evaluation = attempt["evaluation"]
                score = round(float(metrics.get("assessment_score", 0.0)) * 100, 1)
                focus = evaluation.get("next_focus", "Continue with the next demo lesson")
                summary = self._attempt_summary(lesson["title"], score, evaluation)
                long_feedback = evaluation.get("long_feedback", summary)
                what_went_well = evaluation.get("what_went_well", evaluation.get("strengths", []))
                what_to_improve = evaluation.get("what_to_improve", evaluation.get("weaknesses", []))
                strengths.extend(evaluation.get("strengths", []))
                weak_topics.extend(evaluation.get("weaknesses", []))
            else:
                score = None
                current_level = int(progression.get("current_level", 1))
                focus = LEVEL_DEFINITIONS[current_level].grammar_focus
                summary = (
                    f"{lesson['title']} is still pending. Finish all {active_lesson_count} lessons in this live chapter set to lock your level score."
                )
                long_feedback = summary
                what_went_well = []
                what_to_improve = []

            lessons.append(
                {
                    "lesson_id": lesson["lesson_id"],
                    "slot": lesson["slot"],
                    "title": lesson["title"],
                    "status": lesson["status"],
                    "score": score,
                    "focus": focus,
                    "summary": summary,
                    "long_feedback": long_feedback,
                    "what_went_well": what_went_well,
                    "what_to_improve": what_to_improve,
                }
            )

        chapter_history = progression.get("last_completed_chapter_history") or progression.get("chapter_history", [])
        overall_score = round(
            sum(float(item.get("score", 0.0)) for item in chapter_history) / len(chapter_history),
            1,
        ) if chapter_history else 0.0
        overall_threshold = float(progression.get("overall_threshold", 80.0))

        return {
            "user_id": user["user_id"],
            "overall_score": overall_score,
            "overall_threshold": overall_threshold,
            "meets_overall_threshold": overall_score >= overall_threshold,
            "strengths": self._unique_or_default(strengths, ["reading comprehension", "lesson consistency"]),
            "weak_topics": self._unique_or_default(
                weak_topics,
                ["verb placement", "listening recall"],
            ),
            "current_level": progression.get("current_level", 1),
            "current_level_name": progression.get("current_level_name", level_name(1)),
            "current_chapter": progression.get("current_chapter", 5),
            "chapter_history": chapter_history,
            "lessons": lessons,
        }

    def get_profile_summary(self, user_id: str) -> dict[str, Any]:
        user = self._get_user(user_id)
        learner_state = self.learner_state_repo.get_or_create(user_id)
        lesson_feed = self.lesson_service.list_lessons(user_id)["lessons"]
        progression = learner_state.get("progression", build_progression_state(1))

        lessons_completed = learner_state.get("lesson_history", {}).get("lessons_completed", 0)
        current_level = int(progression.get("current_level", 1))
        reset_focus_profile = progression.get("reset_focus_profile", {}) or {}
        next_focus = (
            reset_focus_profile.get("focus_override")
            or learner_state.get("next_lesson_focus", {}).get("topic")
            or LEVEL_DEFINITIONS[current_level].focus
        )

        return {
            "user_id": user["user_id"],
            "name": user["name"],
            "email": user["email"],
            "native_language": user.get("native_language", "English"),
            "target_language": user.get("target_language", "German"),
            "current_level_value": progression.get("current_level", 1),
            "current_level_name": progression.get("current_level_name", level_name(1)),
            "current_level": learner_state.get("language_profile", {}).get("current_level", "A1"),
            "lessons_completed": lessons_completed,
            "total_lessons": len(lesson_feed),
            "streak_label": "3-day demo streak",
            "current_chapter": progression.get("current_chapter", 5),
            "chapter_promotion_threshold": float(
                progression.get(
                    "chapter_promotion_threshold",
                    progression.get("promotion_threshold", 60.0),
                )
            ),
            "overall_threshold": float(progression.get("overall_threshold", 80.0)),
            "mastered": progression.get("last_result") == "mastered",
            "next_focus": next_focus,
            "long_feedback": "",
            "what_went_well": [],
            "what_to_improve": list(reset_focus_profile.get("weak_topics", [])),
            "correct_answers": {},
        }

    def get_flashcards(self, user_id: str) -> dict[str, Any]:
        self._get_user(user_id)
        cards = self.flashcards_repo.list_by_user(user_id)
        if not cards:
            cards = self._seed_flashcards_from_progression(
                self.learner_state_repo.get_or_create(user_id).get("progression", build_progression_state(1)),
            )

        return {
            "user_id": user_id,
            "cards": [
                {
                    "word": card["word"],
                    "meaning": card["meaning"],
                    "example": card["example"],
                    "status": card.get("status", "learning"),
                }
                for card in cards
            ],
        }

    def _get_user(self, user_id: str) -> dict[str, Any]:
        if not user_id or not user_id.strip():
            raise AppDataRequestError("user_id is required")

        user = self.users_repo.get(user_id)
        if user is None:
            raise AppDataRequestError(f"User '{user_id}' not found")
        return user

    def _attempt_summary(self, lesson_title: str, score: float, evaluation: dict[str, Any]) -> str:
        strengths = evaluation.get("strengths", [])
        weaknesses = evaluation.get("weaknesses", [])
        if strengths:
            return (
                f"{lesson_title} scored {score:.1f}. Strongest area: {strengths[0]}. "
                f"Next improvement area: {weaknesses[0] if weaknesses else 'keep practicing output'}."
            )
        return f"{lesson_title} scored {score:.1f}. Continue practicing to unlock stronger feedback."

    def _seed_flashcards_from_progression(self, progression: dict[str, Any]) -> list[dict[str, str]]:
        level = int(progression.get("current_level", 1))
        definition = LEVEL_DEFINITIONS[level]
        cards: list[dict[str, str]] = []
        for word in definition.vocabulary_focus[:6]:
            cards.append(
                {
                    "word": word,
                    "meaning": f"{definition.name} level German word",
                    "example": f"Use '{word}' while practicing {definition.focus}.",
                    "status": "learning",
                }
            )
        return cards

    def _unique_or_default(self, values: list[str], default: list[str]) -> list[str]:
        unique = list(dict.fromkeys(item for item in values if item))
        return unique or default
