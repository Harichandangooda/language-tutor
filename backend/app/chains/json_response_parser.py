from __future__ import annotations

import json
from typing import Any, Type

from pydantic import BaseModel, ValidationError


class JsonResponseParseError(ValueError):
    pass


class JsonResponseValidationError(ValueError):
    pass


def parse_model_response(response: Any, schema: Type[BaseModel]) -> BaseModel:
    text = response_to_text(response)
    return parse_model_text(text, schema)


def parse_model_text(text: str, schema: Type[BaseModel]) -> BaseModel:
    payload = _extract_json_payload(text)
    try:
        data = json.loads(payload)
    except json.JSONDecodeError as exc:
        snippet = payload[max(0, exc.pos - 120) : min(len(payload), exc.pos + 120)]
        raise JsonResponseParseError(f"Model did not return valid JSON: {exc}. Near: {snippet}") from exc
    try:
        return schema.model_validate(data)
    except ValidationError as exc:
        raise JsonResponseValidationError(f"Model returned JSON that did not match the schema: {exc}") from exc


def response_to_text(response: Any) -> str:
    content = getattr(response, "content", response)
    if isinstance(content, str):
        return content.strip()
    if isinstance(content, list):
        chunks: list[str] = []
        for item in content:
            if isinstance(item, str):
                chunks.append(item)
            elif isinstance(item, dict):
                if "text" in item:
                    chunks.append(str(item["text"]))
                elif item.get("type") == "text" and "content" in item:
                    chunks.append(str(item["content"]))
                else:
                    chunks.append(str(item))
            else:
                chunks.append(str(item))
        return "\n".join(part for part in chunks if part).strip()
    return str(content).strip()


def _extract_json_payload(text: str) -> str:
    if not text:
        raise JsonResponseParseError("Model returned an empty response")
    stripped = text.strip()
    if stripped.startswith("```"):
        lines = stripped.splitlines()
        if lines and lines[0].startswith("```"):
            lines = lines[1:]
        if lines and lines[-1].startswith("```"):
            lines = lines[:-1]
        stripped = "\n".join(lines).strip()

    start = stripped.find("{")
    end = stripped.rfind("}")
    if start == -1 or end == -1 or end <= start:
        raise JsonResponseParseError("Model response did not contain a JSON object")
    return stripped[start : end + 1]
