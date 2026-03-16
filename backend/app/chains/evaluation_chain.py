from typing import Any, Dict

from backend.app.prompts.evaluation_prompt import evaluation_prompt
from backend.app.schemas.assessment import AssessmentEvaluation


class EvaluationChain:
    def __init__(self, model):
        self.chain = evaluation_prompt | model.with_structured_output(AssessmentEvaluation)

    def evaluate(
        self,
        learner_state: Dict[str, Any],
        lesson: Dict[str, Any],
        submission: Dict[str, Any],
        metrics: Dict[str, Any],
    ) -> AssessmentEvaluation:
        return self.chain.invoke(
            {
                "learner_state": learner_state,
                "lesson": lesson,
                "submission": submission,
                "metrics": metrics,
            }
        )
