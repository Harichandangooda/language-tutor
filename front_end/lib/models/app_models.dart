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
      level: json['level'] as int?,
      chapter: json['chapter'] as int?,
      isToday: json['is_today'] as bool,
    );
  }
}

class QuestionAnswerModel {
  const QuestionAnswerModel({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

  factory QuestionAnswerModel.fromJson(Map<String, dynamic> json) {
    return QuestionAnswerModel(
      question: json['question'] as String,
      answer: (json['answer'] ?? '') as String,
    );
  }
}

class ReadingContentModel {
  const ReadingContentModel({
    required this.passage,
    required this.questions,
  });

  final String passage;
  final List<QuestionAnswerModel> questions;

  factory ReadingContentModel.fromJson(Map<String, dynamic> json) {
    return ReadingContentModel(
      passage: json['passage'] as String,
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

  final String audioScript;
  final List<QuestionAnswerModel> questions;

  factory ListeningContentModel.fromJson(Map<String, dynamic> json) {
    return ListeningContentModel(
      audioScript: json['audio_script'] as String,
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

  final String prompt;
  final List<String> expectedKeywords;

  factory WritingContentModel.fromJson(Map<String, dynamic> json) {
    return WritingContentModel(
      prompt: json['prompt'] as String,
      expectedKeywords: List<String>.from(json['expected_keywords'] as List<dynamic>? ?? const []),
    );
  }
}

class SpeakingContentModel {
  const SpeakingContentModel({
    required this.prompt,
    required this.expectedPhrases,
  });

  final String prompt;
  final List<String> expectedPhrases;

  factory SpeakingContentModel.fromJson(Map<String, dynamic> json) {
    return SpeakingContentModel(
      prompt: json['prompt'] as String,
      expectedPhrases: List<String>.from(json['expected_phrases'] as List<dynamic>? ?? const []),
    );
  }
}

class AssessmentQuestionModel {
  const AssessmentQuestionModel({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  final String question;
  final List<String> options;
  final String correctAnswer;

  factory AssessmentQuestionModel.fromJson(Map<String, dynamic> json) {
    return AssessmentQuestionModel(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List<dynamic>? ?? const []),
      correctAnswer: json['correct_answer'] as String,
    );
  }
}

class AssessmentContentModel {
  const AssessmentContentModel({required this.questions});

  final List<AssessmentQuestionModel> questions;

  factory AssessmentContentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentContentModel(
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
  });

  final String lessonId;
  final int slot;
  final String title;
  final String status;
  final double? score;
  final String focus;
  final String summary;

  factory ProgressLessonModel.fromJson(Map<String, dynamic> json) {
    return ProgressLessonModel(
      lessonId: json['lesson_id'] as String,
      slot: json['slot'] as int,
      title: json['title'] as String,
      status: json['status'] as String,
      score: (json['score'] as num?)?.toDouble(),
      focus: json['focus'] as String,
      summary: json['summary'] as String,
    );
  }
}

class ProgressSummaryModel {
  const ProgressSummaryModel({
    required this.overallScore,
    required this.strengths,
    required this.weakTopics,
    required this.currentLevel,
    required this.currentLevelName,
    required this.currentChapter,
    required this.chapterHistory,
    required this.lessons,
  });

  final double overallScore;
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
    required this.promotionThreshold,
    required this.mastered,
    required this.nextFocus,
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
  final double promotionThreshold;
  final bool mastered;
  final String nextFocus;

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
      promotionThreshold: (json['promotion_threshold'] as num).toDouble(),
      mastered: (json['mastered'] ?? false) as bool,
      nextFocus: json['next_focus'] as String,
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
    required this.levelOutcome,
    required this.currentLevel,
    required this.currentLevelName,
    required this.nextFocus,
  });

  final bool lessonCompleted;
  final bool chapterComplete;
  final double? chapterAverage;
  final String? levelOutcome;
  final int? currentLevel;
  final String? currentLevelName;
  final String nextFocus;

  factory AssessmentResultModel.fromJson(Map<String, dynamic> json) {
    return AssessmentResultModel(
      lessonCompleted: json['lesson_completed'] as bool? ?? false,
      chapterComplete: json['chapter_complete'] as bool? ?? false,
      chapterAverage: (json['chapter_average'] as num?)?.toDouble(),
      levelOutcome: json['level_outcome'] as String?,
      currentLevel: json['current_level'] as int?,
      currentLevelName: json['current_level_name'] as String?,
      nextFocus: (json['next_focus'] ?? '') as String,
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
