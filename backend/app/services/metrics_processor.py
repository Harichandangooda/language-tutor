from __future__ import annotations

from typing import Any, Dict


class MetricsProcessor:
    def compute(self, submission: Dict[str, Any], lesson: Dict[str, Any]) -> Dict[str, Any]:
        reading_score = 0.8 if submission.get("reading_answers") else 0.0
        listening_score = 0.7 if submission.get("listening_answers") else 0.0

        writing_text = submission.get("writing_response", "").strip().lower()
        speaking_text = submission.get("speaking_transcript", "").strip().lower()

        writing_score = 0.6 if writing_text else 0.0
        speaking_score = 0.5 if speaking_text else 0.0
        assessment_score = 0.75 if submission.get("assessment_answers") else 0.0

        grammar_errors = []
        weak_words = []

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