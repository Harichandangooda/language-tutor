from __future__ import annotations

from typing import Any

from backend.app.schemas.lesson import (
    AssessmentContent,
    DialogueLine,
    LearnContent,
    LessonCard,
    LessonPackage,
    ListeningContent,
    MCQItem,
    PracticeContent,
    PracticeItem,
    QAItem,
    ReadingContent,
    SpeakingContent,
    TranslatableText,
    VocabularyItem,
    WordGloss,
    WritingContent,
)


class TemplateLessonBuilder:
    def build_lesson(self, lesson_blueprint: dict[str, Any]) -> LessonPackage:
        focus = str(lesson_blueprint.get("scenario") or lesson_blueprint.get("objective_hint") or "basic German")
        grammar_focus = str(lesson_blueprint.get("grammar_focus") or "simple present")
        vocabulary_focus = [str(item) for item in lesson_blueprint.get("vocabulary_focus", []) if item][:4]
        while len(vocabulary_focus) < 4:
            vocabulary_focus.append(["Hallo", "Danke", "ich", "bin"][len(vocabulary_focus)])

        card = LessonCard(
            lesson_id="",
            title=str(lesson_blueprint.get("title_hint") or "German Practice"),
            objective=str(lesson_blueprint.get("objective_hint") or f"Practice German around {focus}."),
            image_prompt=f"Friendly illustrated German learning card about {focus}",
        )

        learn = LearnContent(
            intro=self._tt(
                f"In this lesson, you will practise German for {focus}.",
                f"In this lesson, you will practice German for {focus}.",
            ),
            grammar_tip=self._tt(
                f"Use {grammar_focus} to make short, clear sentences.",
                f"Use {grammar_focus} to make short, clear sentences.",
            ),
            coaching_tip="Say the sentence aloud once before answering so the structure feels natural.",
            vocabulary=[
                VocabularyItem(
                    word=word,
                    meaning=self._meaning_for(word),
                    example=self._example_for(word, focus),
                )
                for word in vocabulary_focus
            ],
            dialogue=[
                DialogueLine(speaker="Anna", line=self._tt("Hallo!", "Hello!")),
                DialogueLine(
                    speaker="Ben",
                    line=self._tt("Ich heisse Ben.", "My name is Ben."),
                ),
                DialogueLine(
                    speaker="Anna",
                    line=self._tt("Ich komme aus Berlin.", "I come from Berlin."),
                ),
                DialogueLine(
                    speaker="Ben",
                    line=self._tt("Danke, das ist interessant.", "Thank you, that is interesting."),
                ),
            ],
        )

        practice = PracticeContent(
            intro=self._tt(
                "Use the words and sentence pattern you just learned.",
                "Use the words and sentence pattern you just learned.",
            ),
            items=[
                PracticeItem(
                    prompt=self._tt("Fill in the blank: Ich ___ Maria.", "Fill in the blank: I ___ Maria."),
                    answer=self._tt("heisse", "am called"),
                    hint="Use the verb for introducing your name.",
                ),
                PracticeItem(
                    prompt=self._tt(
                        f"Complete the sentence: {vocabulary_focus[0]}! Ich bin neu hier.",
                        f"Complete the sentence: {self._meaning_for(vocabulary_focus[0])}! I am new here.",
                    ),
                    answer=self._tt(vocabulary_focus[0], self._meaning_for(vocabulary_focus[0])),
                    hint="Use the greeting you just learned.",
                ),
                PracticeItem(
                    prompt=self._tt(
                        "Write the key phrase for saying where you come from.",
                        "Write the key phrase for saying where you come from.",
                    ),
                    answer=self._tt("Ich komme aus London.", "I come from London."),
                    hint="Start with 'Ich komme aus ...'",
                ),
            ],
        )

        reading = ReadingContent(
            passage=self._tt(
                "Hallo! Ich heisse Lara. Ich komme aus Wien. Ich lerne heute Deutsch.",
                "Hello! My name is Lara. I come from Vienna. I am learning German today.",
            ),
            questions=[
                QAItem(
                    question=self._tt("Wie heisst die Person?", "What is the person's name?"),
                    answer=self._tt("Sie heisst Lara.", "Her name is Lara."),
                ),
                QAItem(
                    question=self._tt("Woher kommt Lara?", "Where does Lara come from?"),
                    answer=self._tt("Sie kommt aus Wien.", "She comes from Vienna."),
                ),
            ],
        )

        listening = ListeningContent(
            audio_script=self._tt(
                "Guten Tag. Ich bin Tom. Ich komme aus Hamburg und ich lerne Deutsch.",
                "Good day. I am Tom. I come from Hamburg and I am learning German.",
            ),
            questions=[
                QAItem(
                    question=self._tt("Wie heisst der Sprecher?", "What is the speaker's name?"),
                    answer=self._tt("Er heisst Tom.", "His name is Tom."),
                ),
                QAItem(
                    question=self._tt("Woher kommt Tom?", "Where does Tom come from?"),
                    answer=self._tt("Er kommt aus Hamburg.", "He comes from Hamburg."),
                ),
            ],
        )

        writing = WritingContent(
            prompt=self._tt(
                "Schreibe 2 Saetze und stelle dich kurz vor.",
                "Write 2 sentences and introduce yourself briefly.",
            ),
            expected_keywords=[
                self._tt("Ich heisse", "My name is"),
                self._tt("Ich komme aus", "I come from"),
            ],
        )

        speaking = SpeakingContent(
            prompt=self._tt(
                "Sprich 2 kurze Saetze: dein Name und woher du kommst.",
                "Say 2 short sentences: your name and where you come from.",
            ),
            expected_phrases=[
                self._tt("Ich bin", "I am"),
                self._tt("Ich komme aus", "I come from"),
            ],
        )

        return LessonPackage(
            card=card,
            learn=learn,
            practice=practice,
            reading=reading,
            listening=listening,
            writing=writing,
            speaking=speaking,
            assessment=None,
        )

    def build_assessment(self, lesson_blueprint: dict[str, Any], lesson_core: dict[str, Any]) -> AssessmentContent:
        vocab = [str(item) for item in lesson_blueprint.get("vocabulary_focus", []) if item][:4]
        main_word = vocab[0] if vocab else "Hallo"
        return AssessmentContent(
            reading_questions=[
                QAItem(
                    question=self._tt("Wie begruesst die Person den Leser?", "How does the person greet the reader?"),
                    answer=self._tt(main_word, self._meaning_for(main_word)),
                ),
                QAItem(
                    question=self._tt("Welche Information gibt die Person ueber sich?", "What information does the person give about themselves?"),
                    answer=self._tt("Sie sagt ihren Namen und Herkunftsort.", "They say their name and place of origin."),
                ),
            ],
            listening_questions=[
                QAItem(
                    question=self._tt("Was sagt der Sprecher zuerst?", "What does the speaker say first?"),
                    answer=self._tt("Eine Begruessung.", "A greeting."),
                ),
                QAItem(
                    question=self._tt("Welche Stadt wird genannt?", "Which city is mentioned?"),
                    answer=self._tt("Hamburg.", "Hamburg."),
                ),
            ],
            writing_prompt=self._tt(
                "Schreibe 3 kurze Saetze ueber dich mit Name und Herkunft.",
                "Write 3 short sentences about yourself with your name and origin.",
            ),
            speaking_prompt=self._tt(
                "Stelle dich muendlich in 3 kurzen Saetzen vor.",
                "Introduce yourself orally in 3 short sentences.",
            ),
            questions=[
                MCQItem(
                    question=self._tt("Was bedeutet 'Hallo'?", "What does 'Hallo' mean?"),
                    options=["Hello", "Goodbye", "Please", "Thanks"],
                    correct_answer="Hello",
                ),
                MCQItem(
                    question=self._tt("Welche Phrase nennt deinen Namen?", "Which phrase states your name?"),
                    options=["Ich heisse", "Ich komme", "Ich lerne", "Ich trinke"],
                    correct_answer="Ich heisse",
                ),
                MCQItem(
                    question=self._tt("Welche Phrase nennt deine Herkunft?", "Which phrase states where you come from?"),
                    options=["Ich komme aus", "Ich bin heute", "Ich habe", "Ich moechte"],
                    correct_answer="Ich komme aus",
                ),
                MCQItem(
                    question=self._tt("Was bedeutet 'Danke'?", "What does 'Danke' mean?"),
                    options=["Thanks", "Sorry", "Maybe", "Morning"],
                    correct_answer="Thanks",
                ),
                MCQItem(
                    question=self._tt("Welche Antwort passt zu einer Begruessung?", "Which answer fits a greeting?"),
                    options=["Hallo!", "Gute Nacht", "Bis spaeter", "Nein"],
                    correct_answer="Hallo!",
                ),
            ],
        )

    def _example_for(self, word: str, focus: str) -> TranslatableText:
        lowered = word.lower()
        if "hallo" in lowered:
            return self._tt("Hallo, ich bin neu hier.", "Hello, I am new here.")
        if "danke" in lowered:
            return self._tt("Danke fuer deine Hilfe.", "Thank you for your help.")
        if "komme" in lowered:
            return self._tt("Ich komme aus Berlin.", "I come from Berlin.")
        if "heisse" in lowered:
            return self._tt("Ich heisse Nina.", "My name is Nina.")
        return self._tt(f"Ich benutze {word} im Unterricht.", f"I use {word} in class.")

    def _meaning_for(self, word: str) -> str:
        lookup = {
            "Hallo": "Hello",
            "Danke": "Thanks",
            "Ich heisse": "My name is",
            "Ich komme aus": "I come from",
            "ich": "I",
            "bin": "am",
            "mohte": "would like",
            "moechte": "would like",
        }
        return lookup.get(word, word)

    def _tt(self, german: str, english: str) -> TranslatableText:
        return TranslatableText(
            text=german,
            english_translation=english,
            word_glosses=self._glosses(german, english),
        )

    def _glosses(self, german: str, english: str) -> list[WordGloss]:
        lookup = {
            "hallo": "hello",
            "ich": "I",
            "heisse": "am called",
            "bin": "am",
            "komme": "come",
            "aus": "from",
            "danke": "thanks",
            "deutsch": "German",
            "lerne": "learn",
            "guten": "good",
            "tag": "day",
            "wie": "what/how",
            "woher": "from where",
            "schreibe": "write",
            "sprich": "speak",
        }
        words = []
        for raw in german.replace(".", "").replace(",", "").replace("!", "").replace("?", "").split():
            normalized = raw.strip()
            if not normalized:
                continue
            words.append(WordGloss(word=normalized, meaning=lookup.get(normalized.lower(), english.split()[0] if english else normalized)))
        unique: list[WordGloss] = []
        seen: set[str] = set()
        for item in words:
            key = item.word.lower()
            if key in seen:
                continue
            seen.add(key)
            unique.append(item)
        return unique[:6]
