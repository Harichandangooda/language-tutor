from backend.app.services.lesson_generator import LessonGenerator
from backend.app.services.level_progression import build_demo_lessons, build_progression_state


class LessonNotFoundError(Exception):
    pass


class InvalidLessonRequestError(Exception):
    pass


class LessonGenerationError(Exception):
    pass


class LessonService:
    def __init__(self, learner_state_repo, lessons_repo):
        self.learner_state_repo = learner_state_repo
        self.lessons_repo = lessons_repo
        self.lesson_generator = LessonGenerator()

    def list_lessons(self, user_id: str):
        if not user_id or not user_id.strip():
            raise InvalidLessonRequestError("user_id is required to list lessons")

        lessons = self._ensure_demo_lessons(user_id)
        return {
            "user_id": user_id,
            "lessons": [self._to_feed_item(lesson) for lesson in lessons],
        }

    def preload_lessons(self, user_id: str, warm_assessment: bool = False):
        lessons = self._ensure_demo_lessons(user_id)
        if warm_assessment and lessons:
            self._ensure_assessment(lessons[0]["lesson_id"])
        return {
            "user_id": user_id,
            "lessons_ready": len(lessons),
        }

    def start_lesson(self, user_id: str):
        if not user_id or not user_id.strip():
            raise InvalidLessonRequestError("user_id is required to start a lesson")

        lessons = self._ensure_demo_lessons(user_id)
        lesson = next((item for item in lessons if item.get("slot") == 1), lessons[0])

        return {
            "lesson_id": lesson["lesson_id"],
            "card": lesson["lesson_package"]["card"],
            "status": lesson["status"],
        }

    def get_card(self, lesson_id: str):
        card = self.lessons_repo.get_card(lesson_id)
        if not card:
            raise LessonNotFoundError(f"Lesson card not found for lesson_id='{lesson_id}'")
        return card

    def get_learn(self, lesson_id: str):
        learn = self.lessons_repo.get_section(lesson_id, "learn")
        if not learn:
            raise LessonNotFoundError(f"Learn content not found for lesson_id='{lesson_id}'")
        return learn

    def get_practice(self, lesson_id: str):
        practice = self.lessons_repo.get_section(lesson_id, "practice")
        if not practice:
            raise LessonNotFoundError(f"Practice content not found for lesson_id='{lesson_id}'")
        return practice

    def get_reading(self, lesson_id: str):
        reading = self.lessons_repo.get_section(lesson_id, "reading")
        if not reading:
            raise LessonNotFoundError(f"Reading content not found for lesson_id='{lesson_id}'")
        return reading

    def get_listening(self, lesson_id: str):
        listening = self.lessons_repo.get_section(lesson_id, "listening")
        if not listening:
            raise LessonNotFoundError(f"Listening content not found for lesson_id='{lesson_id}'")
        return listening

    def get_writing(self, lesson_id: str):
        writing = self.lessons_repo.get_section(lesson_id, "writing")
        if not writing:
            raise LessonNotFoundError(f"Writing content not found for lesson_id='{lesson_id}'")
        return writing

    def get_speaking(self, lesson_id: str):
        speaking = self.lessons_repo.get_section(lesson_id, "speaking")
        if not speaking:
            raise LessonNotFoundError(f"Speaking content not found for lesson_id='{lesson_id}'")
        return speaking

    def get_assessment(self, lesson_id: str):
        assessment = self._ensure_assessment(lesson_id)
        if not assessment:
            raise LessonNotFoundError(f"Assessment content not found for lesson_id='{lesson_id}'")
        return assessment

    def _ensure_demo_lessons(self, user_id: str):
        learner_state = self.learner_state_repo.get_or_create(user_id)
        progression = learner_state.get("progression", build_progression_state(1))
        current_level = int(progression.get("current_level", 1))
        current_chapter = int(progression.get("current_chapter", 5))
        lesson_count = int(progression.get("active_lesson_count", 3))
        content_cycle = int(progression.get("content_cycle", 1))
        blueprints = build_demo_lessons(
            current_level,
            current_chapter,
            lesson_count=lesson_count,
            cycle=content_cycle,
            focus_profile=progression.get("reset_focus_profile"),
        )

        for blueprint in blueprints:
            existing = self.lessons_repo.get_by_user_and_slot(user_id, int(blueprint["slot"]))
            if (
                existing is not None
                and existing.get("level") == current_level
                and existing.get("chapter") == current_chapter
                and int(existing.get("cycle", 1)) == content_cycle
            ):
                continue
            if existing is not None:
                self.lessons_repo.delete(existing["lesson_id"])

            lesson_id = (
                f"lesson_demo_{user_id}_l{current_level}_c{current_chapter}"
                f"_cycle{content_cycle}_{blueprint['slot']}"
            )
            try:
                lesson_package = self.lesson_generator.generate(
                    user_id=user_id,
                    learner_state=learner_state,
                    lesson_blueprint=blueprint,
                )
            except Exception as exc:
                raise LessonGenerationError(
                    f"Failed to generate demo lesson {blueprint['slot']} ({blueprint['slug']})"
                ) from exc
            lesson_package.card.lesson_id = lesson_id
            lesson_package_dict = lesson_package.model_dump()

            self.lessons_repo.create_lesson(
                lesson_id=lesson_id,
                user_id=user_id,
                lesson_package=lesson_package_dict,
                lesson_blueprint=blueprint,
                slot=int(blueprint["slot"]),
                slug=str(blueprint["slug"]),
                day_label=str(blueprint["day_label"]),
                level=current_level,
                chapter=current_chapter,
                cycle=content_cycle,
            )

        return self.lessons_repo.list_by_user(user_id)

    def _ensure_assessment(self, lesson_id: str):
        assessment = self.lessons_repo.get_section(lesson_id, "assessment")
        if assessment:
            return assessment

        lesson = self.lessons_repo.get(lesson_id)
        if not lesson:
            return None

        learner_state = self.learner_state_repo.get_or_create(lesson["user_id"])
        lesson_package = dict(lesson["lesson_package"])
        lesson_blueprint = dict(lesson.get("lesson_blueprint") or {})
        lesson_core = {key: value for key, value in lesson_package.items() if key != "assessment"}
        generated = self.lesson_generator.generate_assessment(
            learner_state=learner_state,
            lesson_blueprint=lesson_blueprint,
            lesson_core=lesson_core,
        )
        lesson_package["assessment"] = generated.model_dump()
        self.lessons_repo.update_lesson_package(lesson_id, lesson_package)
        return lesson_package["assessment"]

    def _to_feed_item(self, lesson: dict):
        card = lesson["lesson_package"]["card"]
        slot = lesson.get("slot", 999)
        return {
            "lesson_id": lesson["lesson_id"],
            "slot": slot,
            "slug": lesson.get("slug") or f"lesson-{slot}",
            "day_label": lesson.get("day_label") or f"Lesson {slot}",
            "title": card["title"],
            "objective": card["objective"],
            "status": lesson["status"],
            "image_url": card.get("image_url"),
            "image_prompt": card.get("image_prompt"),
            "level": lesson.get("level"),
            "chapter": lesson.get("chapter"),
            "is_today": slot == 1,
        }
