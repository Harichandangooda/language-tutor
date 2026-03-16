import 'package:flutter/material.dart';

import 'pages/dashboard_page.dart';
import 'pages/doubt_chat_page.dart';
import 'pages/flashcards_page.dart';
import 'pages/lesson_flow/assessment_page.dart';
import 'pages/lesson_flow/learn_page.dart';
import 'pages/lesson_flow/listening_page.dart';
import 'pages/lesson_flow/practice_page.dart';
import 'pages/lesson_flow/reading_page.dart';
import 'pages/lesson_flow/speaking_page.dart';
import 'pages/lesson_flow/writing_page.dart';
import 'pages/level_selector_page.dart';
import 'pages/loading_page.dart';
import 'pages/prev_lesson_flow/prev_listening_page.dart';
import 'pages/prev_lesson_flow/prev_reading_page.dart';
import 'pages/prev_lesson_flow/prev_speaking_page.dart';
import 'pages/prev_lesson_flow/prev_writing_page.dart';
import 'pages/prev_lesson_flow/previous_lesson_menu_page.dart';
import 'pages/sign_in_page.dart';
import 'state/app_controller.dart';

void main() {
  runApp(
    AppScope(
      controller: AppController(),
      child: const LingoLearnApp(),
    ),
  );
}

class LingoLearnApp extends StatelessWidget {
  const LingoLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    const base = Color(0xFF112032);
    const accent = Color(0xFFD97706);
    const surface = Color(0xFFF6F4EE);

    return MaterialApp(
      title: 'LingoLearn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: surface,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          primary: accent,
          secondary: const Color(0xFF0F766E),
          surface: surface,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: base,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: base,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: base,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            height: 1.55,
            color: Color(0xFF334155),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Color(0xFF526071),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: accent, width: 1.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 22),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: base,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            side: const BorderSide(color: Color(0xFFD0D7E2)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
      initialRoute: '/sign_in',
      routes: {
        '/sign_in': (context) => const SignInPage(),
        '/level_selector': (context) => const LevelSelectorPage(),
        '/loading': (context) => const LoadingPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/doubts': (context) => const DoubtChatPage(),
        '/flashcards': (context) => const FlashcardsPage(),
        '/lesson/learn': (context) => const LearnPage(),
        '/lesson/practice': (context) => const PracticePage(),
        '/lesson/reading': (context) => const ReadingPage(),
        '/lesson/listening': (context) => const ListeningPage(),
        '/lesson/writing': (context) => const WritingPage(),
        '/lesson/speaking': (context) => const SpeakingPage(),
        '/lesson/assessment': (context) => const AssessmentPage(),
        '/prev_lesson': (context) => const PreviousLessonMenuPage(),
        '/prev_lesson/reading': (context) => const PrevReadingPage(),
        '/prev_lesson/listening': (context) => const PrevListeningPage(),
        '/prev_lesson/speaking': (context) => const PrevSpeakingPage(),
        '/prev_lesson/writing': (context) => const PrevWritingPage(),
      },
    );
  }
}
