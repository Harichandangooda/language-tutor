from __future__ import annotations

from typing import Any, Dict


class MetricsProcessor:
    def compute(self, submission: Dict[str, Any], lesson: Dict[str, Any]) -> Dict[str, Any]:
        lesson_package = lesson.get("lesson_package", {})
        reading_score = self._score_open_answers(
            provided_answers=submission.get("reading_answers", []),
            expected_items=lesson_package.get("assessment", {}).get("reading_questions", []),
        )
        listening_score = self._score_open_answers(
            provided_answers=submission.get("listening_answers", []),
            expected_items=lesson_package.get("assessment", {}).get("listening_questions", []),
        )

        writing_text = submission.get("writing_response", "").strip().lower()
        speaking_text = submission.get("speaking_transcript", "").strip().lower()
        assessment_score = self._score_assessment_answers(
            provided_answers=submission.get("assessment_answers", []),
            expected_items=lesson_package.get("assessment", {}).get("questions", []),
        )

        writing_score = self._score_keyword_match(
            text=writing_text,
            expected_keywords=lesson_package.get("writing", {}).get("expected_keywords", []),
        )
        speaking_score = self._score_keyword_match(
            text=speaking_text,
            expected_keywords=lesson_package.get("speaking", {}).get("expected_phrases", []),
        )

        grammar_errors = []
        weak_words = self._extract_missing_words(
            writing_text=writing_text,
            speaking_text=speaking_text,
            expected_keywords=lesson_package.get("writing", {}).get("expected_keywords", []),
            expected_phrases=lesson_package.get("speaking", {}).get("expected_phrases", []),
        )

        if "ich gehen" in writing_text:
            grammar_errors.append("verb conjugation")

        if "ich gehen" in speaking_text:
            grammar_errors.append("spoken verb conjugation")

        return {
            "reading_score": reading_score,
            "listening_score": listening_score,
            "writing_score": writing_score,
            "speaking_score": speaking_score,
            "assessment_score": assessment_score,
            "weak_words": weak_words,
            "grammar_errors": grammar_errors,
        }

    def _score_open_answers(
        self,
        provided_answers: list[Dict[str, str]],
        expected_items: list[Dict[str, str]],
    ) -> float:
        if not expected_items:
            return 0.0
        if not provided_answers:
            return 0.0

        answer_text = " ".join(item.get("answer", "").lower() for item in provided_answers)
        matches = 0
        for item in expected_items:
            answer = item.get("answer", {})
            expected_answer = self._extract_text(answer).lower()
            if expected_answer and expected_answer in answer_text:
                matches += 1
        return round(matches / len(expected_items), 2)

    def _score_assessment_answers(
        self,
        provided_answers: list[Dict[str, str]],
        expected_items: list[Dict[str, Any]],
    ) -> float:
        if not expected_items:
            return 0.0
        if not provided_answers:
            return 0.0

        provided_values = [item.get("answer", "").strip().lower() for item in provided_answers]
        correct = 0
        for expected in expected_items:
            if expected.get("correct_answer", "").strip().lower() in provided_values:
                correct += 1
        return round(correct / len(expected_items), 2)

    def _score_keyword_match(self, text: str, expected_keywords: list[str]) -> float:
        if not text:
            return 0.0
        if not expected_keywords:
            return 0.5

        lowered_keywords = [
            self._extract_text(keyword).lower()
            for keyword in expected_keywords
            if self._extract_text(keyword).strip()
        ]
        if not lowered_keywords:
            return 0.5

        matches = sum(1 for keyword in lowered_keywords if keyword in text)
        score = max(0.3, matches / len(lowered_keywords))
        return round(min(score, 1.0), 2)

    def _extract_missing_words(
        self,
        writing_text: str,
        speaking_text: str,
        expected_keywords: list[str],
        expected_phrases: list[str],
    ) -> list[str]:
        learner_text = f"{writing_text} {speaking_text}".strip()
        if not learner_text:
            return []

        weak_words: list[str] = []
        for item in [*expected_keywords, *expected_phrases]:
            raw_text = self._extract_text(item)
            lowered = raw_text.lower().strip()
            if lowered and lowered not in learner_text:
                weak_words.append(raw_text)
        return list(dict.fromkeys(weak_words))[:5]

    def _extract_text(self, item: Any) -> str:
        if isinstance(item, dict):
            return str(item.get("text", ""))
        return str(item)
