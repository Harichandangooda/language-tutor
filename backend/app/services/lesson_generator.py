from backend.app.chains.lesson_chain import LessonChain
from backend.app.chains.assessment_chain import AssessmentChain
from backend.app.llm.model_factory import get_chat_model
from backend.app.services.template_lesson_builder import TemplateLessonBuilder


class LessonGenerator:
    def __init__(self):
        model = get_chat_model()
        self.lesson_chain = LessonChain(model)
        self.assessment_chain = AssessmentChain(model)
        self.template_builder = TemplateLessonBuilder()

    def generate(self, user_id: str, learner_state: dict | None, lesson_blueprint: dict):
        cold_start = not learner_state or learner_state.get("lesson_history", {}).get("lessons_completed", 0) == 0

        try:
            return self.lesson_chain.generate(
                user_id=user_id,
                learner_state=learner_state,
                cold_start=cold_start,
                lesson_blueprint=lesson_blueprint,
            )
        except Exception:
            return self.template_builder.build_lesson(lesson_blueprint)

    def generate_assessment(self, learner_state: dict | None, lesson_blueprint: dict, lesson_core: dict):
        try:
            return self.assessment_chain.generate(
                learner_state=learner_state,
                lesson_blueprint=lesson_blueprint,
                lesson_core=lesson_core,
            )
        except Exception:
            return self.template_builder.build_assessment(lesson_blueprint, lesson_core)
