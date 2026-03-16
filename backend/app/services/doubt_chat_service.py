from __future__ import annotations

import logging

from backend.app.llm.model_factory import get_chat_model
from backend.app.services.level_progression import build_progression_state


class DoubtChatError(Exception):
    pass


logger = logging.getLogger(__name__)


class DoubtChatService:
    def __init__(self, users_repo, learner_state_repo):
        self.users_repo = users_repo
        self.learner_state_repo = learner_state_repo
        self.model = get_chat_model()

    def answer_doubt(self, user_id: str, message: str) -> str:
        if not user_id or not user_id.strip():
            raise DoubtChatError("user_id is required")
        if not message or not message.strip():
            raise DoubtChatError("message is required")

        user = self.users_repo.get(user_id)
        if user is None:
            raise DoubtChatError(f"User '{user_id}' not found")

        learner_state = self.learner_state_repo.get_or_create(user_id)
        progression = learner_state.get("progression", build_progression_state(1))
        level_name = progression.get("current_level_name", "Newbie")
        cefr = learner_state.get("language_profile", {}).get("current_level", "A1")

        try:
            response = self.model.invoke(
                [
                    (
                        "system",
                        "You are a helpful German language doubt-clearing tutor for English-speaking learners. "
                        "Answer only questions related to German language learning, grammar, vocabulary, pronunciation, translation, sentence structure, and usage. "
                        "Keep answers practical, concise, and beginner-friendly unless the learner question clearly needs more depth. "
                        "If helpful, include short German examples with English translations. "
                        "If the user asks something unrelated to German learning, politely steer them back to German study help.",
                    ),
                    (
                        "human",
                        f"Learner level: {level_name} ({cefr})\n"
                        f"Native language: {user.get('native_language', 'English')}\n"
                        f"Target language: {user.get('target_language', 'German')}\n\n"
                        f"Doubt: {message.strip()}",
                    ),
                ]
            )
            answer = self._extract_answer_text(response)
            if answer:
                return answer
        except Exception as exc:
            logger.warning("Nova doubt-chat request failed: %s", exc, exc_info=True)

        return self._fallback_answer(message, level_name, cefr)

    def _extract_answer_text(self, response) -> str:
        content = getattr(response, "content", "")
        if isinstance(content, str):
            return content.strip()
        if isinstance(content, list):
            chunks: list[str] = []
            for item in content:
                if isinstance(item, str):
                    chunks.append(item)
                elif isinstance(item, dict):
                    text = item.get("text")
                    if text:
                        chunks.append(str(text))
                else:
                    chunks.append(str(item))
            return " ".join(part.strip() for part in chunks if str(part).strip()).strip()
        return str(content).strip()

    def _fallback_answer(self, message: str, level_name: str, cefr: str) -> str:
        lowered = message.lower().strip()

        if "kennen" in lowered and "wissen" in lowered:
            return (
                "Use `kennen` for people, places, or things you are familiar with. "
                "Use `wissen` for facts or information you know. "
                "Example: `Ich kenne Anna.` means `I know Anna.` "
                "`Ich weiss die Antwort.` means `I know the answer.`"
            )

        if "weil" in lowered:
            return (
                "`Weil` means `because`. In a `weil` clause, the conjugated verb usually goes to the end. "
                "Example: `Ich lerne Deutsch, weil ich in Berlin arbeite.` "
                "English: `I am learning German because I work in Berlin.`"
            )

        if "der" in lowered or "die" in lowered or "das" in lowered or "article" in lowered:
            return (
                "`der`, `die`, and `das` are German definite articles. "
                "They depend on grammatical gender: `der` masculine, `die` feminine, `das` neuter. "
                "You usually need to learn the noun together with its article."
            )

        if "word order" in lowered or "verb" in lowered:
            return (
                "In a basic German main sentence, the conjugated verb is usually in position 2. "
                "Example: `Ich lerne heute Deutsch.` "
                "If you start with a time word, the verb still stays second: `Heute lerne ich Deutsch.`"
            )

        if "akkusativ" in lowered or "accusative" in lowered:
            return (
                "Akkusativ is often used for the direct object, the thing directly affected by the verb. "
                "Example: `Ich sehe den Mann.` Here `den Mann` is in the accusative case."
            )

        if "dativ" in lowered:
            return (
                "Dativ is often used for the indirect object or after certain verbs and prepositions. "
                "Example: `Ich gebe dem Kind ein Buch.` Here `dem Kind` is dative."
            )

        if "pronunciation" in lowered or "speak" in lowered:
            return (
                f"For your current level ({level_name}, {cefr}), focus on short clear German sentences first. "
                "Say the sentence slowly, stress the main content words, and repeat it once with natural rhythm."
            )

        return (
            f"I could not reach the Nova tutor just now, but I can still help with common German study questions for "
            f"{level_name} ({cefr}). Ask about word order, cases, articles, `weil`, `kennen` vs `wissen`, or sentence correction."
        )
