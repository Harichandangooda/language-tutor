import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/app_models.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000';
      default:
        return 'http://127.0.0.1:8000';
    }
  }

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _post(
      '/auth/login',
      {'email': email, 'password': password},
    );
    return LoginResult.fromJson(response);
  }

  Future<LevelPlacementResult> setPlacement({
    required String userId,
    required int level,
  }) async {
    final response = await _post(
      '/app/placement',
      {'user_id': userId, 'level': level},
    );
    return LevelPlacementResult.fromJson(response);
  }

  Future<List<LessonFeedItemModel>> fetchLessons(String userId) async {
    final response = await _get('/lessons?user_id=$userId');
    return (response['lessons'] as List<dynamic>)
        .map((item) => LessonFeedItemModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ProgressSummaryModel> fetchProgress(String userId) async {
    final response = await _get('/app/progress?user_id=$userId');
    return ProgressSummaryModel.fromJson(response);
  }

  Future<ProfileSummaryModel> fetchProfile(String userId) async {
    final response = await _get('/app/profile?user_id=$userId');
    return ProfileSummaryModel.fromJson(response);
  }

  Future<List<FlashcardModel>> fetchFlashcards(String userId) async {
    final response = await _get('/app/flashcards?user_id=$userId');
    return (response['cards'] as List<dynamic>)
        .map((item) => FlashcardModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<String> askDoubt({
    required String userId,
    required String message,
  }) async {
    final response = await _post(
      '/app/doubt-chat',
      {
        'user_id': userId,
        'message': message,
      },
    );
    return (response['answer'] ?? '') as String;
  }

  Future<ReadingContentModel> fetchReading(String lessonId) async {
    final response = await _get('/lessons/$lessonId/reading');
    return ReadingContentModel.fromJson(response);
  }

  Future<LearnContentModel> fetchLearn(String lessonId) async {
    final response = await _get('/lessons/$lessonId/learn');
    return LearnContentModel.fromJson(response);
  }

  Future<PracticeContentModel> fetchPractice(String lessonId) async {
    final response = await _get('/lessons/$lessonId/practice');
    return PracticeContentModel.fromJson(response);
  }

  Future<ListeningContentModel> fetchListening(String lessonId) async {
    final response = await _get('/lessons/$lessonId/listening');
    return ListeningContentModel.fromJson(response);
  }

  Future<WritingContentModel> fetchWriting(String lessonId) async {
    final response = await _get('/lessons/$lessonId/writing');
    return WritingContentModel.fromJson(response);
  }

  Future<SpeakingContentModel> fetchSpeaking(String lessonId) async {
    final response = await _get('/lessons/$lessonId/speaking');
    return SpeakingContentModel.fromJson(response);
  }

  Future<AssessmentContentModel> fetchAssessment(String lessonId) async {
    final response = await _get('/lessons/$lessonId/assessment');
    return AssessmentContentModel.fromJson(response);
  }

  Future<AssessmentResultModel> submitAssessment({
    required String lessonId,
    required String userId,
    required List<String> readingAnswers,
    required List<String> listeningAnswers,
    required String writingResponse,
    required String speakingTranscript,
    required List<String> selectedAnswers,
  }) async {
    final response = await _post(
      '/lessons/$lessonId/submit-assessment',
      {
        'user_id': userId,
        'reading_answers': List.generate(
          readingAnswers.length,
          (index) => {'question_id': 'reading_${index + 1}', 'answer': readingAnswers[index]},
        ),
        'listening_answers': List.generate(
          listeningAnswers.length,
          (index) => {'question_id': 'listening_${index + 1}', 'answer': listeningAnswers[index]},
        ),
        'writing_response': writingResponse,
        'speaking_transcript': speakingTranscript,
        'assessment_answers': List.generate(
          selectedAnswers.length,
          (index) => {'question_id': 'assessment_${index + 1}', 'answer': selectedAnswers[index]},
        ),
      },
    );
    return AssessmentResultModel.fromJson(response);
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final response = await _client.get(
      Uri.parse('$baseUrl$path'),
      headers: const {'Content-Type': 'application/json'},
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.post(
      Uri.parse('$baseUrl$path'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['detail'] ?? 'Request failed with ${response.statusCode}');
    }
    return body;
  }
}
