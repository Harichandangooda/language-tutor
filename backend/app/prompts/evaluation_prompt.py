from langchain_core.prompts import ChatPromptTemplate


evaluation_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            (
                "You are an encouraging German language tutor for beginner English speakers. "
                "Given lesson content, learner state, submission, and computed metrics, produce a concise assessment evaluation. "
                "Focus on actionable strengths, weaknesses, 3-5 flashcard words, and one next focus area. "
                "Return only structured output."
            ),
        ),
        (
            "human",
            (
                "learner_state: {learner_state}\n\n"
                "lesson: {lesson}\n\n"
                "submission: {submission}\n\n"
                "metrics: {metrics}\n\n"
                "Constraints:\n"
                "- Assume target language is German.\n"
                "- Keep feedback short and demo-friendly.\n"
                "- Flashcard words should be useful beginner German words from the lesson or learner output.\n"
                "- next_focus should be a short phrase.\n"
            ),
        ),
    ]
)
