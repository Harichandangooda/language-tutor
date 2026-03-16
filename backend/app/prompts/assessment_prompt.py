from langchain_core.prompts import ChatPromptTemplate


assessment_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            (
                "You are an adaptive CEFR-aligned language tutor. "
                "Generate only the final assessment for a German lesson. "
                "The assessment must match the already prepared lesson content, "
                "but use slightly different wording so it tests transfer instead of memorization. "
                "Return only structured output."
            ),
        ),
        (
            "human",
            (
                "Generate the assessment for this lesson.\n\n"
                "learner_state: {learner_state}\n\n"
                "lesson_blueprint: {lesson_blueprint}\n\n"
                "lesson_core: {lesson_core}\n\n"
                "Constraints:\n"
                "- Target language: German\n"
                "- Native language: English\n"
                "- Use the same topic, grammar focus, and vocabulary focus as the lesson core\n"
                "- Keep the questions slightly different from the guided practice\n"
                "- Every German learner-facing question must include English translation and word_glosses\n"
                "- Include 2 reading assessment questions, 2 listening assessment questions, 1 writing assessment prompt, 1 speaking assessment prompt, and exactly 5 MCQ questions\n"
            ),
        ),
    ]
)
