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

    raise ValueError(f"Unsupported LLM_PROVIDER: {provider}")
