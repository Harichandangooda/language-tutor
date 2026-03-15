import os


def get_chat_model():
    api_key = os.getenv("OPENAI_API_KEY")

    provider = os.getenv("LLM_PROVIDER", "openai").lower()

    if provider == "openai":
        from langchain_openai import ChatOpenAI

        model_name = os.getenv("OPENAI_MODEL", "gpt-4.1-mini")
        return ChatOpenAI(
            model=model_name,
            temperature=0.3,
        )

    raise ValueError(f"Unsupported LLM_PROVIDER: {provider}")