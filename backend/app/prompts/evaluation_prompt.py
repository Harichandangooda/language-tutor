from langchain_core.prompts import ChatPromptTemplate


evaluation_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            (
                "You are an encouraging German language tutor for beginner English speakers. "
                "Given lesson content, learner state, submission, and computed metrics, produce a detailed assessment evaluation. "
                "Focus on actionable strengths, weaknesses, 3-5 flashcard words, one next focus area, and a longer explanation of what the learner did well and what to improve. "
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
                "- Keep feedback readable but more detailed than a one-line summary.\n"
                "- Flashcard words should be useful beginner German words from the lesson or learner output.\n"
                "- next_focus should be a short phrase.\n"
                "- long_feedback should be a short paragraph.\n"
                "- what_went_well and what_to_improve should each contain 2-4 concrete bullets.\n"
            ),
        ),
    ]
)
