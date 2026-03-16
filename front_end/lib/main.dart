import 'package:flutter/material.dart';
import 'pages/sign_in_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/flashcards_page.dart';
import 'pages/lesson_flow/reading_page.dart';
import 'pages/lesson_flow/listening_page.dart';
import 'pages/lesson_flow/speaking_page.dart';
import 'pages/lesson_flow/assessment_page.dart';
import 'pages/lesson_flow/writing_page.dart';
import 'pages/prev_lesson_flow/previous_lesson_menu_page.dart';
import 'pages/prev_lesson_flow/prev_reading_page.dart';
import 'pages/prev_lesson_flow/prev_listening_page.dart';
import 'pages/prev_lesson_flow/prev_speaking_page.dart';
import 'pages/prev_lesson_flow/prev_writing_page.dart';

void main() {
  runApp(const LingoLearnApp());
}

class LingoLearnApp extends StatelessWidget {
  const LingoLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LingoLearn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFFF9E6), // Light yellow background
        primaryColor: const Color(0xFFFFB300), // Darker vibrant yellow
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFB300),
          primary: const Color(0xFFFFB300),
          secondary: const Color(0xFFF9A825), 
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFB300),
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFB300),
            foregroundColor: Colors.black87,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFFE57F)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFFB300), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFF9A825), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(8),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      initialRoute: '/sign_in',
      routes: {
        '/sign_in': (context) => const SignInPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/flashcards': (context) => const FlashcardsPage(),
        '/lesson/reading': (context) => const ReadingPage(),
        '/lesson/listening': (context) => const ListeningPage(),
        '/lesson/speaking': (context) => const SpeakingPage(),
        '/lesson/writing': (context) => const WritingPage(),
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
