from backend.app.chains.lesson_chain import LessonChain
from backend.app.llm.model_factory import get_chat_model


class LessonGenerator:
    def __init__(self):
        model = get_chat_model()
        self.lesson_chain = LessonChain(model)

    def generate(self, user_id: str, learner_state: dict | None, lesson_blueprint: dict):
        cold_start = not learner_state or learner_state.get("lesson_history", {}).get("lessons_completed", 0) == 0

        return self.lesson_chain.generate(
            user_id=user_id,
            learner_state=learner_state,
            cold_start=cold_start,
            lesson_blueprint=lesson_blueprint,
        )
