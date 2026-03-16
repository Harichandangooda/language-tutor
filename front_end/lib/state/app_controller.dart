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
  String writingDraft = '';
  String speakingDraft = '';
  int selectedLevel = 1;
  String selectedLevelName = 'Newbie';

  bool isBusy = false;
  String? errorMessage;

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
    notifyListeners();

    try {
      final results = await Future.wait<dynamic>([
        _apiClient.fetchLessons(userId),
        _apiClient.fetchProgress(userId),
        _apiClient.fetchProfile(userId),
        _apiClient.fetchFlashcards(userId),
      ]);
      lessons = results[0] as List<LessonFeedItemModel>;
      progress = results[1] as ProgressSummaryModel;
      profile = results[2] as ProfileSummaryModel;
      flashcards = results[3] as List<FlashcardModel>;
      if (profile != null) {
        selectedLevel = profile!.currentLevelValue;
        selectedLevelName = profile!.currentLevelName;
      }
      if (lessons.isEmpty) {
        activeLessonId = null;
      } else if (activeLessonId == null || lessons.every((item) => item.lessonId != activeLessonId)) {
        activeLessonId = lessons.first.lessonId;
      }
    } catch (error) {
      errorMessage = error.toString();
      rethrow;
    } finally {
      isBusy = false;
      notifyListeners();
    }
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
    required String selectedAnswer,
    required String writingResponse,
    required String speakingTranscript,
  }) async {
    final userId = session?.userId;
    if (userId == null) {
      throw Exception('No logged in user');
    }

    final result = await _apiClient.submitAssessment(
      lessonId: _requireActiveLessonId(),
      userId: userId,
      selectedAnswer: selectedAnswer,
      writingResponse: writingResponse.isEmpty ? writingDraft : writingResponse,
      speakingTranscript: speakingTranscript.isEmpty ? speakingDraft : speakingTranscript,
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
