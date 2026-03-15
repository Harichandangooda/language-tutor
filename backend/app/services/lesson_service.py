import uuid

from backend.app.services.lesson_generator import LessonGenerator


class LessonNotFoundError(Exception):
    pass


class InvalidLessonRequestError(Exception):
    pass


class LessonService:
    def __init__(self, learner_state_repo, lessons_repo):
        self.learner_state_repo = learner_state_repo
        self.lessons_repo = lessons_repo
        self.lesson_generator = LessonGenerator()

    def start_lesson(self, user_id: str):
        if not user_id or not user_id.strip():
            raise InvalidLessonRequestError("user_id is required to start a lesson")

        learner_state = self.learner_state_repo.get_or_create(user_id)

        lesson_package = self.lesson_generator.generate(
            user_id=user_id,
            learner_state=learner_state,
        )

        lesson_id = f"lesson_{uuid.uuid4().hex[:8]}"
        lesson_package.card.lesson_id = lesson_id

        lesson_package_dict = lesson_package.model_dump()

        self.lessons_repo.create_lesson(
            lesson_id=lesson_id,
            user_id=user_id,
            lesson_package=lesson_package_dict,
        )

        return {
            "lesson_id": lesson_id,
            "card": lesson_package_dict["card"],
            "status": "ready",
        }

    def get_card(self, lesson_id: str):
        card = self.lessons_repo.get_card(lesson_id)
        if not card:
            raise LessonNotFoundError(f"Lesson card not found for lesson_id='{lesson_id}'")
        return card

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
        assessment = self.lessons_repo.get_section(lesson_id, "assessment")
        if not assessment:
            raise LessonNotFoundError(f"Assessment content not found for lesson_id='{lesson_id}'")
        return assessment