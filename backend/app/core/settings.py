from __future__ import annotations

import os
from dataclasses import dataclass

from dotenv import load_dotenv


class SettingsError(Exception):
    pass


@dataclass(frozen=True)
class AppSettings:
    llm_provider: str
    openai_model: str
    openai_api_key: str | None
    aws_region: str | None
    aws_profile: str | None
    bedrock_model_id: str | None

    @property
    def has_openai_key(self) -> bool:
        return bool(self.openai_api_key and self.openai_api_key.strip())

    @property
    def has_bedrock_config(self) -> bool:
        return bool(
            self.aws_region and self.aws_region.strip() and self.bedrock_model_id and self.bedrock_model_id.strip()
        )


def get_settings() -> AppSettings:
    load_dotenv(override=True)
    return AppSettings(
        llm_provider=os.getenv("LLM_PROVIDER", "openai").strip().lower(),
        openai_model=os.getenv("OPENAI_MODEL", "gpt-4.1-mini").strip(),
        openai_api_key=os.getenv("OPENAI_API_KEY"),
        aws_region=os.getenv("AWS_REGION"),
        aws_profile=os.getenv("AWS_PROFILE"),
        bedrock_model_id=os.getenv("BEDROCK_MODEL_ID"),
    )


def validate_settings() -> AppSettings:
    settings = get_settings()

    if settings.llm_provider not in {"openai", "bedrock", "nova"}:
        raise SettingsError(
            f"Unsupported LLM_PROVIDER '{settings.llm_provider}'. Supported values are 'openai', 'bedrock', and 'nova'."
        )

    if settings.llm_provider == "openai":
        if not settings.has_openai_key:
            raise SettingsError(
                "OPENAI_API_KEY is missing. OpenAI lesson generation requires a valid OpenAI API key in .env."
            )

        invalid_markers = ("your_key", "replace", "paste", "placeholder", "{", "}")
        normalized_key = settings.openai_api_key.strip().lower() if settings.openai_api_key else ""
        if any(marker in normalized_key for marker in invalid_markers):
            raise SettingsError(
                "OPENAI_API_KEY appears to be a placeholder value. Replace it with a real OpenAI API key in .env."
            )

        if not settings.openai_model:
            raise SettingsError("OPENAI_MODEL is missing. Set it in .env before starting the backend.")

    if settings.llm_provider in {"bedrock", "nova"}:
        if not settings.has_bedrock_config:
            raise SettingsError(
                "AWS_REGION and BEDROCK_MODEL_ID are required in .env for Amazon Nova / Bedrock."
            )

    return settings
