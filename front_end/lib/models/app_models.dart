class LoginResult {
  const LoginResult({
    required this.userId,
    required this.name,
    required this.email,
    required this.nativeLanguage,
    required this.targetLanguage,
    required this.demoMode,
  });

  final String userId;
  final String name;
  final String email;
  final String nativeLanguage;
  final String targetLanguage;
  final bool demoMode;

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      userId: json['user_id'] as String,
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      nativeLanguage: (json['native_language'] ?? 'English') as String,
      targetLanguage: (json['target_language'] ?? 'German') as String,
      demoMode: (json['demo_mode'] ?? true) as bool,
    );
  }
}

class LessonFeedItemModel {
  const LessonFeedItemModel({
    required this.lessonId,
    required this.slot,
    required this.slug,
    required this.dayLabel,
    required this.title,
    required this.objective,
    required this.status,
    required this.imageUrl,
    required this.imagePrompt,
    required this.level,
    required this.chapter,
    required this.isToday,
  });

  final String lessonId;
  final int slot;
  final String slug;
  final String dayLabel;
  final String title;
  final String objective;
  final String status;
  final String? imageUrl;
  final String? imagePrompt;
  final int? level;
  final int? chapter;
  final bool isToday;

  factory LessonFeedItemModel.fromJson(Map<String, dynamic> json) {
    return LessonFeedItemModel(
      lessonId: json['lesson_id'] as String,
      slot: json['slot'] as int,
      slug: json['slug'] as String,
      dayLabel: json['day_label'] as String,
      title: json['title'] as String,
      objective: json['objective'] as String,
      status: json['status'] as String,
      imageUrl: json['image_url'] as String?,
      imagePrompt: json['image_prompt'] as String?,
      level: json['level'] as int?,
      chapter: json['chapter'] as int?,
      isToday: json['is_today'] as bool,
    );
  }
}

class VocabularyItemModel {
  const VocabularyItemModel({
    required this.word,
    required this.meaning,
    required this.example,
  });

  final String word;
  final String meaning;
  final TranslatableTextModel example;

  factory VocabularyItemModel.fromJson(Map<String, dynamic> json) {
    return VocabularyItemModel(
      word: json['word'] as String,
      meaning: json['meaning'] as String,
      example: TranslatableTextModel.fromJson(json['example'] as Map<String, dynamic>),
    );
  }
}

class WordGlossModel {
  const WordGlossModel({
    required this.word,
    required this.meaning,
  });

  final String word;
  final String meaning;

  factory WordGlossModel.fromJson(Map<String, dynamic> json) {
    return WordGlossModel(
      word: json['word'] as String,
      meaning: json['meaning'] as String,
    );
  }
}

class TranslatableTextModel {
  const TranslatableTextModel({
    required this.text,
    required this.englishTranslation,
    required this.wordGlosses,
  });

  final String text;
  final String englishTranslation;
  final List<WordGlossModel> wordGlosses;

  factory TranslatableTextModel.fromJson(Map<String, dynamic> json) {
    return TranslatableTextModel(
      text: json['text'] as String,
      englishTranslation: json['english_translation'] as String,
      wordGlosses: (json['word_glosses'] as List<dynamic>? ?? [])
          .map((item) => WordGlossModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DialogueLineModel {
  const DialogueLineModel({
    required this.speaker,
    required this.line,
  });

  final String speaker;
  final TranslatableTextModel line;

  factory DialogueLineModel.fromJson(Map<String, dynamic> json) {
    return DialogueLineModel(
      speaker: json['speaker'] as String,
      line: TranslatableTextModel.fromJson(json['line'] as Map<String, dynamic>),
    );
  }
}

class LearnContentModel {
  const LearnContentModel({
    required this.intro,
    required this.grammarTip,
    required this.coachingTip,
    required this.vocabulary,
    required this.dialogue,
  });

  final TranslatableTextModel intro;
  final TranslatableTextModel grammarTip;
  final String coachingTip;
  final List<VocabularyItemModel> vocabulary;
  final List<DialogueLineModel> dialogue;

  factory LearnContentModel.fromJson(Map<String, dynamic> json) {
    return LearnContentModel(
      intro: TranslatableTextModel.fromJson(json['intro'] as Map<String, dynamic>),
      grammarTip: TranslatableTextModel.fromJson(json['grammar_tip'] as Map<String, dynamic>),
      coachingTip: json['coaching_tip'] as String,
      vocabulary: (json['vocabulary'] as List<dynamic>? ?? [])
          .map((item) => VocabularyItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      dialogue: (json['dialogue'] as List<dynamic>? ?? [])
          .map((item) => DialogueLineModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PracticeItemModel {
  const PracticeItemModel({
    required this.prompt,
    required this.answer,
    required this.hint,
  });

  final TranslatableTextModel prompt;
  final TranslatableTextModel answer;
  final String hint;

  factory PracticeItemModel.fromJson(Map<String, dynamic> json) {
    return PracticeItemModel(
      prompt: TranslatableTextModel.fromJson(json['prompt'] as Map<String, dynamic>),
      answer: TranslatableTextModel.fromJson(json['answer'] as Map<String, dynamic>),
      hint: json['hint'] as String,
    );
  }
}

class PracticeContentModel {
  const PracticeContentModel({
    required this.intro,
    required this.items,
  });

  final TranslatableTextModel intro;
  final List<PracticeItemModel> items;

  factory PracticeContentModel.fromJson(Map<String, dynamic> json) {
    return PracticeContentModel(
      intro: TranslatableTextModel.fromJson(json['intro'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => PracticeItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuestionAnswerModel {
  const QuestionAnswerModel({
    required this.question,
    required this.answer,
  });

  final TranslatableTextModel question;
  final TranslatableTextModel answer;

  factory QuestionAnswerModel.fromJson(Map<String, dynamic> json) {
    return QuestionAnswerModel(
      question: TranslatableTextModel.fromJson(json['question'] as Map<String, dynamic>),
      answer: TranslatableTextModel.fromJson(json['answer'] as Map<String, dynamic>),
    );
  }
}

class ReadingContentModel {
  const ReadingContentModel({
    required this.passage,
    required this.questions,
  });

  final TranslatableTextModel passage;
  final List<QuestionAnswerModel> questions;

  factory ReadingContentModel.fromJson(Map<String, dynamic> json) {
    return ReadingContentModel(
      passage: TranslatableTextModel.fromJson(json['passage'] as Map<String, dynamic>),
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((item) => QuestionAnswerModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ListeningContentModel {
  const ListeningContentModel({
    required this.audioScript,
    required this.questions,
  });

  final TranslatableTextModel audioScript;
  final List<QuestionAnswerModel> questions;

  factory ListeningContentModel.fromJson(Map<String, dynamic> json) {
    return ListeningContentModel(
      audioScript: TranslatableTextModel.fromJson(json['audio_script'] as Map<String, dynamic>),
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((item) => QuestionAnswerModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class WritingContentModel {
  const WritingContentModel({
    required this.prompt,
    required this.expectedKeywords,
  });

  final TranslatableTextModel prompt;
  final List<TranslatableTextModel> expectedKeywords;

  factory WritingContentModel.fromJson(Map<String, dynamic> json) {
    return WritingContentModel(
      prompt: TranslatableTextModel.fromJson(json['prompt'] as Map<String, dynamic>),
      expectedKeywords: (json['expected_keywords'] as List<dynamic>? ?? [])
          .map((item) => TranslatableTextModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SpeakingContentModel {
  const SpeakingContentModel({
    required this.prompt,
    required this.expectedPhrases,
  });

  final TranslatableTextModel prompt;
  final List<TranslatableTextModel> expectedPhrases;

  factory SpeakingContentModel.fromJson(Map<String, dynamic> json) {
    return SpeakingContentModel(
      prompt: TranslatableTextModel.fromJson(json['prompt'] as Map<String, dynamic>),
      expectedPhrases: (json['expected_phrases'] as List<dynamic>? ?? [])
          .map((item) => TranslatableTextModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AssessmentQuestionModel {
  const AssessmentQuestionModel({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  final TranslatableTextModel question;
  final List<String> options;
  final String correctAnswer;

  factory AssessmentQuestionModel.fromJson(Map<String, dynamic> json) {
    return AssessmentQuestionModel(
      question: TranslatableTextModel.fromJson(json['question'] as Map<String, dynamic>),
      options: List<String>.from(json['options'] as List<dynamic>? ?? const []),
      correctAnswer: json['correct_answer'] as String,
    );
  }
}

class AssessmentContentModel {
  const AssessmentContentModel({
    required this.readingQuestions,
    required this.listeningQuestions,
    required this.writingPrompt,
    required this.speakingPrompt,
    required this.questions,
  });

  final List<QuestionAnswerModel> readingQuestions;
  final List<QuestionAnswerModel> listeningQuestions;
  final TranslatableTextModel writingPrompt;
  final TranslatableTextModel speakingPrompt;
  final List<AssessmentQuestionModel> questions;

  factory AssessmentContentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentContentModel(
      readingQuestions: (json['reading_questions'] as List<dynamic>? ?? [])
          .map((item) => QuestionAnswerModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      listeningQuestions: (json['listening_questions'] as List<dynamic>? ?? [])
          .map((item) => QuestionAnswerModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      writingPrompt: TranslatableTextModel.fromJson(json['writing_prompt'] as Map<String, dynamic>),
      speakingPrompt: TranslatableTextModel.fromJson(json['speaking_prompt'] as Map<String, dynamic>),
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((item) => AssessmentQuestionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProgressLessonModel {
  const ProgressLessonModel({
    required this.lessonId,
    required this.slot,
    required this.title,
    required this.status,
    required this.score,
    required this.focus,
    required this.summary,
    required this.longFeedback,
    required this.whatWentWell,
    required this.whatToImprove,
  });

  final String lessonId;
  final int slot;
  final String title;
  final String status;
  final double? score;
  final String focus;
  final String summary;
  final String longFeedback;
  final List<String> whatWentWell;
  final List<String> whatToImprove;

  factory ProgressLessonModel.fromJson(Map<String, dynamic> json) {
    return ProgressLessonModel(
      lessonId: json['lesson_id'] as String,
      slot: json['slot'] as int,
      title: json['title'] as String,
      status: json['status'] as String,
      score: (json['score'] as num?)?.toDouble(),
      focus: json['focus'] as String,
      summary: json['summary'] as String,
      longFeedback: (json['long_feedback'] ?? '') as String,
      whatWentWell: List<String>.from(json['what_went_well'] as List<dynamic>? ?? const []),
      whatToImprove: List<String>.from(json['what_to_improve'] as List<dynamic>? ?? const []),
    );
  }
}

class ProgressSummaryModel {
  const ProgressSummaryModel({
    required this.overallScore,
    required this.overallThreshold,
    required this.meetsOverallThreshold,
    required this.strengths,
    required this.weakTopics,
    required this.currentLevel,
    required this.currentLevelName,
    required this.currentChapter,
    required this.chapterHistory,
    required this.lessons,
  });

  final double overallScore;
  final double overallThreshold;
  final bool meetsOverallThreshold;
  final List<String> strengths;
  final List<String> weakTopics;
  final int currentLevel;
  final String currentLevelName;
  final int currentChapter;
  final List<ChapterProgressModel> chapterHistory;
  final List<ProgressLessonModel> lessons;

  factory ProgressSummaryModel.fromJson(Map<String, dynamic> json) {
    return ProgressSummaryModel(
      overallScore: (json['overall_score'] as num).toDouble(),
      overallThreshold: (json['overall_threshold'] as num?)?.toDouble() ?? 80.0,
      meetsOverallThreshold: (json['meets_overall_threshold'] as bool?) ?? false,
      strengths: List<String>.from(json['strengths'] as List<dynamic>? ?? const []),
      weakTopics: List<String>.from(json['weak_topics'] as List<dynamic>? ?? const []),
      currentLevel: json['current_level'] as int,
      currentLevelName: json['current_level_name'] as String,
      currentChapter: json['current_chapter'] as int,
      chapterHistory: (json['chapter_history'] as List<dynamic>? ?? [])
          .map((item) => ChapterProgressModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      lessons: (json['lessons'] as List<dynamic>? ?? [])
          .map((item) => ProgressLessonModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ChapterProgressModel {
  const ChapterProgressModel({
    required this.chapter,
    required this.level,
    required this.levelName,
    required this.score,
    required this.status,
    required this.result,
  });

  final int chapter;
  final int level;
  final String levelName;
  final double score;
  final String status;
  final String result;

  factory ChapterProgressModel.fromJson(Map<String, dynamic> json) {
    return ChapterProgressModel(
      chapter: json['chapter'] as int,
      level: json['level'] as int,
      levelName: json['level_name'] as String,
      score: (json['score'] as num).toDouble(),
      status: json['status'] as String,
      result: json['result'] as String,
    );
  }
}

class ProfileSummaryModel {
  const ProfileSummaryModel({
    required this.name,
    required this.email,
    required this.nativeLanguage,
    required this.targetLanguage,
    required this.currentLevelValue,
    required this.currentLevelName,
    required this.currentLevel,
    required this.lessonsCompleted,
    required this.totalLessons,
    required this.streakLabel,
    required this.currentChapter,
    required this.chapterPromotionThreshold,
    required this.overallThreshold,
    required this.mastered,
    required this.nextFocus,
    required this.longFeedback,
    required this.whatWentWell,
    required this.whatToImprove,
    required this.correctAnswers,
  });

  final String name;
  final String email;
  final String nativeLanguage;
  final String targetLanguage;
  final int currentLevelValue;
  final String currentLevelName;
  final String currentLevel;
  final int lessonsCompleted;
  final int totalLessons;
  final String streakLabel;
  final int currentChapter;
  final double chapterPromotionThreshold;
  final double overallThreshold;
  final bool mastered;
  final String nextFocus;
  final String longFeedback;
  final List<String> whatWentWell;
  final List<String> whatToImprove;
  final Map<String, dynamic> correctAnswers;

  factory ProfileSummaryModel.fromJson(Map<String, dynamic> json) {
    return ProfileSummaryModel(
      name: json['name'] as String,
      email: json['email'] as String,
      nativeLanguage: json['native_language'] as String,
      targetLanguage: json['target_language'] as String,
      currentLevelValue: json['current_level_value'] as int,
      currentLevelName: json['current_level_name'] as String,
      currentLevel: json['current_level'] as String,
      lessonsCompleted: json['lessons_completed'] as int,
      totalLessons: json['total_lessons'] as int,
      streakLabel: json['streak_label'] as String,
      currentChapter: json['current_chapter'] as int,
      chapterPromotionThreshold: (json['chapter_promotion_threshold'] as num?)?.toDouble() ?? 60.0,
      overallThreshold: (json['overall_threshold'] as num?)?.toDouble() ?? 80.0,
      mastered: (json['mastered'] ?? false) as bool,
      nextFocus: json['next_focus'] as String,
      longFeedback: (json['long_feedback'] ?? '') as String,
      whatWentWell: List<String>.from(json['what_went_well'] as List<dynamic>? ?? const []),
      whatToImprove: List<String>.from(json['what_to_improve'] as List<dynamic>? ?? const []),
      correctAnswers: Map<String, dynamic>.from(json['correct_answers'] as Map? ?? const {}),
    );
  }
}

class FlashcardModel {
  const FlashcardModel({
    required this.word,
    required this.meaning,
    required this.example,
    required this.status,
  });

  final String word;
  final String meaning;
  final String example;
  final String status;

  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    return FlashcardModel(
      word: json['word'] as String,
      meaning: json['meaning'] as String,
      example: json['example'] as String,
      status: json['status'] as String,
    );
  }
}

class AssessmentResultModel {
  const AssessmentResultModel({
    required this.lessonCompleted,
    required this.chapterComplete,
    required this.chapterAverage,
    required this.levelAverage,
    required this.levelOutcome,
    required this.currentLevel,
    required this.currentLevelName,
    required this.nextFocus,
    required this.longFeedback,
    required this.whatWentWell,
    required this.whatToImprove,
    required this.correctAnswers,
  });

  final bool lessonCompleted;
  final bool chapterComplete;
  final double? chapterAverage;
  final double? levelAverage;
  final String? levelOutcome;
  final int? currentLevel;
  final String? currentLevelName;
  final String nextFocus;
  final String longFeedback;
  final List<String> whatWentWell;
  final List<String> whatToImprove;
  final Map<String, dynamic> correctAnswers;

  factory AssessmentResultModel.fromJson(Map<String, dynamic> json) {
    return AssessmentResultModel(
      lessonCompleted: json['lesson_completed'] as bool? ?? false,
      chapterComplete: json['chapter_complete'] as bool? ?? false,
      chapterAverage: (json['chapter_average'] as num?)?.toDouble(),
      levelAverage: (json['level_average'] as num?)?.toDouble(),
      levelOutcome: json['level_outcome'] as String?,
      currentLevel: json['current_level'] as int?,
      currentLevelName: json['current_level_name'] as String?,
      nextFocus: (json['next_focus'] ?? '') as String,
      longFeedback: (json['long_feedback'] ?? '') as String,
      whatWentWell: List<String>.from(json['what_went_well'] as List<dynamic>? ?? const []),
      whatToImprove: List<String>.from(json['what_to_improve'] as List<dynamic>? ?? const []),
      correctAnswers: Map<String, dynamic>.from(json['correct_answers'] as Map? ?? const {}),
    );
  }
}

class LevelPlacementResult {
  const LevelPlacementResult({
    required this.currentLevel,
    required this.currentLevelName,
    required this.currentChapter,
    required this.message,
  });

  final int currentLevel;
  final String currentLevelName;
  final int currentChapter;
  final String message;

  factory LevelPlacementResult.fromJson(Map<String, dynamic> json) {
    return LevelPlacementResult(
      currentLevel: json['current_level'] as int,
      currentLevelName: json['current_level_name'] as String,
      currentChapter: json['current_chapter'] as int,
      message: json['message'] as String,
    );
  }
}
