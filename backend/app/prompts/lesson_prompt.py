from langchain_core.prompts import ChatPromptTemplate


lesson_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            (
                "You are an adaptive CEFR-aligned language tutor. "
                "Generate exactly one beginner-friendly lesson package. "
                "The lesson must include: "
                "card, reading, listening, writing, speaking, and assessment. "
                "Keep the content simple, clear, and educational. "
                "Use the learner context provided. "
                "If learner_state is empty or cold_start is true, generate a diagnostic baseline lesson. "
                "Prefer short passages, short prompts, and simple vocabulary. "
                "Return only structured output."
            ),
        ),
        (
            "human",
            (
                "Generate today's lesson.\n\n"
                "user_id: {user_id}\n"
                "cold_start: {cold_start}\n"
                "learner_state: {learner_state}\n\n"
                "Constraints:\n"
                "- Target language: German\n"
                "- Native language: English\n"
                "- Default CEFR level for cold start: A1\n"
                "- Include a card title and objective\n"
                "- Include a simple image_prompt for the lesson card\n"
                "- Reading should contain a short passage and 2 questions\n"
                "- Listening should contain a short audio_script and 1-2 questions\n"
                "- Writing should contain one prompt and expected_keywords\n"
                "- Speaking should contain one prompt and expected_phrases\n"
                "- Assessment should contain 2 questions\n"
            ),
        ),
    ]
)