from langchain_core.prompts import ChatPromptTemplate


lesson_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            (
                "You are an adaptive CEFR-aligned language tutor. "
                "Generate exactly one beginner-friendly lesson package. "
                "The lesson must include: "
                "card, learn, practice, reading, listening, writing, speaking, and assessment. "
                "Keep the content simple, clear, and educational. "
                "Use the learner context provided. "
                "If learner_state is empty or cold_start is true, generate a diagnostic baseline lesson. "
                "Prefer short passages, short prompts, and simple vocabulary. "
                "Return valid JSON only. Do not add markdown fences or commentary."
            ),
        ),
        (
            "human",
            (
                "Generate the demo lesson.\n\n"
                "user_id: {user_id}\n"
                "cold_start: {cold_start}\n"
                "learner_state: {learner_state}\n\n"
                "lesson_blueprint: {lesson_blueprint}\n\n"
                "Constraints:\n"
                "- Target language: German\n"
                "- Native language: English\n"
                "- Default CEFR level for cold start: A1 unless lesson_blueprint says otherwise\n"
                "- Use the lesson_blueprint as the source of truth for the topic, scenario, grammar focus, and vocabulary focus\n"
                "- If lesson_blueprint includes reset_focus_profile, bias the new lesson toward those weak skills and weak topics without repeating the exact same wording\n"
                "- Keep the title, objective, and learning tasks aligned with the blueprint\n"
                "- If lesson_blueprint.defer_assessment is true, set assessment to null and focus on generating the teaching and practice content first\n"
                "- Include a card title and objective\n"
                "- Include a simple image_prompt for the lesson card\n"
                "- Learn must explicitly teach the vocabulary and grammar before any testing\n"
                "- Learn must include intro, grammar_tip, coaching_tip, 4 vocabulary items, and 4 short dialogue lines\n"
                "- Practice must include intro and 3 short guided items with answer and hint\n"
                "- Every German sentence or phrase shown to the learner must include an English translation and word_glosses\n"
                "- word_glosses should be short German-to-English mappings for the important words in the phrase\n"
                "- Reading should contain a short passage and 2 questions\n"
                "- Listening should contain a short audio_script and 1-2 questions\n"
                "- Writing should contain one prompt and expected_keywords\n"
                "- Speaking should contain one prompt and expected_phrases\n"
                "- If assessment is included, it should contain 2 reading assessment questions, 2 listening assessment questions, 1 writing assessment prompt, 1 speaking assessment prompt, and 5 MCQ questions\n"
                "- All learner-facing lesson content should be about German for beginner English speakers\n"
                "- Return a single valid JSON object matching the lesson schema\n"
            ),
        ),
    ]
)
