import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../services/api_client.dart';

class AppController extends ChangeNotifier {
  AppController({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  LoginResult? session;
  List<LessonFeedItemModel> lessons = const [];
  ProgressSummaryModel? progress;
  ProfileSummaryModel? profile;
  List<FlashcardModel> flashcards = const [];
  String? activeLessonId;
  bool isReviewMode = false;
  String writingDraft = '';
  String speakingDraft = '';
  int selectedLevel = 1;
  String selectedLevelName = 'Newbie';

  bool isBusy = false;
  String? errorMessage;
  String loadingTitle = 'Preparing your lesson plan';
  String loadingMessage = 'Checking your profile, loading today\'s lesson, and setting up the next learning path.';

  Future<void> login(String email, String password) async {
    isBusy = true;
    errorMessage = null;
    notifyListeners();

    try {
      session = await _apiClient.login(email: email, password: password);
    } catch (error) {
      errorMessage = error.toString();
      rethrow;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> bootstrap() async {
    final userId = session?.userId;
    if (userId == null) {
      throw Exception('No logged in user');
    }

    isBusy = true;
    errorMessage = null;
    _setLoadingState(
      title: 'Checking your profile',
      message: 'Loading your account, progress history, and current level setup.',
    );
    notifyListeners();

    try {
      final overviewResults = await Future.wait<dynamic>([
        _apiClient.fetchProgress(userId),
        _apiClient.fetchProfile(userId),
        _apiClient.fetchFlashcards(userId),
      ]);
      progress = overviewResults[0] as ProgressSummaryModel;
      profile = overviewResults[1] as ProfileSummaryModel;
      flashcards = overviewResults[2] as List<FlashcardModel>;
      _setLoadingState(
        title: 'Generating lesson cards',
        message: 'Preparing the next lesson pack and caching the core teaching flow.',
      );
      lessons = await _apiClient.fetchLessons(userId);
      if (profile != null) {
        selectedLevel = profile!.currentLevelValue;
        selectedLevelName = profile!.currentLevelName;
      }
      if (lessons.isEmpty) {
        activeLessonId = null;
      } else if (activeLessonId == null || lessons.every((item) => item.lessonId != activeLessonId)) {
        activeLessonId = _defaultLessonId();
        isReviewMode = false;
      }
      if (activeLessonId != null) {
        _setLoadingState(
          title: 'Preparing practice',
          message: 'Warming up the first lesson so reading, listening, writing, and speaking open faster.',
        );
        await Future.wait<dynamic>([
          fetchLearn(),
          fetchPractice(),
          fetchReading(),
          fetchListening(),
          fetchWriting(),
          fetchSpeaking(),
        ]);
        _setLoadingState(
          title: 'Building assessment',
          message: 'Creating the final lesson quiz separately so the first screens load sooner.',
        );
        await fetchAssessment();
      }
    } catch (error) {
      errorMessage = error.toString();
      rethrow;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  void _setLoadingState({
    required String title,
    required String message,
  }) {
    loadingTitle = title;
    loadingMessage = message;
    notifyListeners();
  }

  Future<void> setPlacementLevel(int level) async {
    final userId = session?.userId;
    if (userId == null) {
      throw Exception('No logged in user');
    }

    isBusy = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await _apiClient.setPlacement(userId: userId, level: level);
      selectedLevel = result.currentLevel;
      selectedLevelName = result.currentLevelName;
    } catch (error) {
      errorMessage = error.toString();
      rethrow;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  void selectLesson(String lessonId) {
    isReviewMode = false;
    activeLessonId = lessonId;
    writingDraft = '';
    speakingDraft = '';
    notifyListeners();
  }

  void retryLesson(String lessonId) {
    isReviewMode = true;
    activeLessonId = lessonId;
    writingDraft = '';
    speakingDraft = '';
    notifyListeners();
  }

  void updateWritingDraft(String value) {
    writingDraft = value;
  }

  void updateSpeakingDraft(String value) {
    speakingDraft = value;
  }

  Future<void> refreshAppData() async {
    if (session == null) {
      return;
    }
    await bootstrap();
  }

  Future<ReadingContentModel> fetchReading() async {
    return _apiClient.fetchReading(_requireActiveLessonId());
  }

  Future<LearnContentModel> fetchLearn() async {
    return _apiClient.fetchLearn(_requireActiveLessonId());
  }

  Future<PracticeContentModel> fetchPractice() async {
    return _apiClient.fetchPractice(_requireActiveLessonId());
  }

  Future<ListeningContentModel> fetchListening() async {
    return _apiClient.fetchListening(_requireActiveLessonId());
  }

  Future<WritingContentModel> fetchWriting() async {
    return _apiClient.fetchWriting(_requireActiveLessonId());
  }

  Future<SpeakingContentModel> fetchSpeaking() async {
    return _apiClient.fetchSpeaking(_requireActiveLessonId());
  }

  Future<AssessmentContentModel> fetchAssessment() async {
    return _apiClient.fetchAssessment(_requireActiveLessonId());
  }

  Future<AssessmentResultModel> submitAssessment({
    required List<String> readingAnswers,
    required List<String> listeningAnswers,
    required String writingResponse,
    required String speakingTranscript,
    required List<String> selectedAnswers,
  }) async {
    final userId = session?.userId;
    if (userId == null) {
      throw Exception('No logged in user');
    }

    final result = await _apiClient.submitAssessment(
      lessonId: _requireActiveLessonId(),
      userId: userId,
      readingAnswers: readingAnswers,
      listeningAnswers: listeningAnswers,
      writingResponse: writingResponse.isEmpty ? writingDraft : writingResponse,
      speakingTranscript: speakingTranscript.isEmpty ? speakingDraft : speakingTranscript,
      selectedAnswers: selectedAnswers,
    );
    await refreshAppData();
    return result;
  }

  String _requireActiveLessonId() {
    final lessonId = activeLessonId;
    if (lessonId == null) {
      throw Exception('No lesson selected');
    }
    return lessonId;
  }

  String? _defaultLessonId() {
    for (final lesson in lessons) {
      if (lesson.status != 'completed') {
        return lesson.lessonId;
      }
    }
    return lessons.first.lessonId;
  }
}

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    if (scope == null || scope.notifier == null) {
      throw Exception('AppScope not found');
    }
    return scope.notifier!;
  }
}
