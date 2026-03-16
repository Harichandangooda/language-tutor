from typing import Any, Dict

from backend.app.prompts.assessment_prompt import assessment_prompt
from backend.app.schemas.lesson import AssessmentContent


class AssessmentChain:
    def __init__(self, model):
        self.model = model
        self.chain = assessment_prompt | self.model.with_structured_output(AssessmentContent)

    def generate(
        self,
        learner_state: Dict[str, Any] | None,
        lesson_blueprint: Dict[str, Any],
        lesson_core: Dict[str, Any],
    ) -> AssessmentContent:
        return self.chain.invoke(
            {
                "learner_state": learner_state or {},
                "lesson_blueprint": lesson_blueprint,
                "lesson_core": lesson_core,
            }
        )
