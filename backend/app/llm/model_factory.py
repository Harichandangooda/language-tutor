from backend.app.core.settings import get_settings


def get_chat_model():
    settings = get_settings()
    provider = settings.llm_provider

    if provider == "openai":
        from langchain_openai import ChatOpenAI

        return ChatOpenAI(
            api_key=settings.openai_api_key,
            model=settings.openai_model,
            temperature=0.3,
        )

    if provider in {"bedrock", "nova"}:
        from langchain_aws import ChatBedrockConverse

        kwargs = {
            "model": settings.bedrock_model_id,
            "region_name": settings.aws_region,
            "temperature": 0.3,
        }
        if settings.aws_profile and settings.aws_profile.strip():
            kwargs["credentials_profile_name"] = settings.aws_profile.strip()

        return ChatBedrockConverse(**kwargs)

    raise ValueError(f"Unsupported LLM_PROVIDER: {provider}")
