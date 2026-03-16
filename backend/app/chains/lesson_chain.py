from typing import Any, Dict

from backend.app.prompts.lesson_prompt import lesson_prompt
from backend.app.schemas.lesson import LessonPackage


class LessonChain:
    def __init__(self, model):
        self.model = model
        self.chain = lesson_prompt | self.model.with_structured_output(LessonPackage)

    def generate(
        self,
        user_id: str,
        learner_state: Dict[str, Any] | None,
        cold_start: bool,
        lesson_blueprint: Dict[str, Any],
    ) -> LessonPackage:
        return self.chain.invoke(
            {
                "user_id": user_id,
                "cold_start": cold_start,
                "learner_state": learner_state or {},
                "lesson_blueprint": {**lesson_blueprint, "defer_assessment": True},
            }
        )
