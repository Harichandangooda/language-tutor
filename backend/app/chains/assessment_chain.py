from typing import Any, Dict

from backend.app.chains.json_response_parser import (
    JsonResponseParseError,
    JsonResponseValidationError,
    parse_model_response,
    parse_model_text,
    response_to_text,
)
from backend.app.prompts.assessment_prompt import assessment_prompt
from backend.app.schemas.lesson import AssessmentContent


class AssessmentChain:
    def __init__(self, model):
        self.model = model
        self.chain = assessment_prompt | self.model
        self.structured_chain = None
        if self.model.__class__.__name__ == "ChatBedrockConverse":
            self.structured_chain = assessment_prompt | self.model.with_structured_output(
                AssessmentContent,
                method="json_schema",
                include_raw=True,
            )

    def generate(
        self,
        learner_state: Dict[str, Any] | None,
        lesson_blueprint: Dict[str, Any],
        lesson_core: Dict[str, Any],
    ) -> AssessmentContent:
        payload = {
            "learner_state": learner_state or {},
            "lesson_blueprint": lesson_blueprint,
            "lesson_core": lesson_core,
        }
        if self.structured_chain is not None:
            structured = self.structured_chain.invoke(payload)
            parsed = structured.get("parsed") if isinstance(structured, dict) else None
            if parsed is not None:
                return parsed
            raw_response = structured.get("raw") if isinstance(structured, dict) else structured
            response = raw_response
        else:
            response = self.chain.invoke(payload)
        try:
            return parse_model_response(response, AssessmentContent)
        except (JsonResponseParseError, JsonResponseValidationError) as exc:
            raw_text = response_to_text(response)
            repaired = self._repair_json(raw_text, AssessmentContent, str(exc))
            try:
                return parse_model_text(repaired, AssessmentContent)
            except (JsonResponseParseError, JsonResponseValidationError) as repair_exc:
                tightened = self._repair_json(repaired, AssessmentContent, str(repair_exc))
                return parse_model_text(tightened, AssessmentContent)

    def _repair_json(self, raw_text: str, schema: type[AssessmentContent], failure_reason: str) -> str:
        response = self.model.invoke(
            [
                (
                    "system",
                    "You repair malformed JSON. "
                    "Return one valid JSON object only. "
                    "Do not explain anything. "
                    "Do not change the meaning of fields. "
                    "Use standard JSON with double quotes. "
                    "Ensure every required schema field is present. "
                    "Only fix JSON syntax and schema mismatches so it matches the provided schema.",
                ),
                (
                    "human",
                    f"Previous parsing failure:\n{failure_reason}\n\n"
                    f"Schema:\n{schema.model_json_schema()}\n\n"
                    "Repair this payload so it becomes one valid JSON object.\n\n"
                    f"Malformed JSON:\n{raw_text}",
                ),
            ]
        )
        return response_to_text(response)
