import 'package:flutter/material.dart';

class LessonCardData {
  const LessonCardData({
    required this.dayLabel,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.xp,
    required this.color,
    this.isToday = false,
  });

  final String dayLabel;
  final String title;
  final String subtitle;
  final String duration;
  final String xp;
  final Color color;
  final bool isToday;
}

const List<LessonCardData> lessonFeed = [
  LessonCardData(
    dayLabel: 'Today',
    title: 'Meeting New People',
    subtitle: 'Greetings, introductions, and confidence in first conversations.',
    duration: '18 min',
    xp: '50 XP',
    color: Color(0xFF1E3A5F),
    isToday: true,
  ),
  LessonCardData(
    dayLabel: 'Yesterday',
    title: 'Cafe Conversations',
    subtitle: 'Ordering politely, asking for recommendations, and paying.',
    duration: '15 min',
    xp: '42 XP',
    color: Color(0xFF2B6CB0),
  ),
  LessonCardData(
    dayLabel: 'Friday',
    title: 'Around The City',
    subtitle: 'Directions, landmarks, and useful travel phrases.',
    duration: '16 min',
    xp: '40 XP',
    color: Color(0xFF2C7A7B),
  ),
  LessonCardData(
    dayLabel: 'Thursday',
    title: 'Daily Routines',
    subtitle: 'Present tense verbs and everyday sentence structure.',
    duration: '14 min',
    xp: '38 XP',
    color: Color(0xFF805AD5),
  ),
];

const List<String> flashcards = [
  'Hola - Hello',
  'Buenos dias - Good morning',
  'Mucho gusto - Nice to meet you',
  'Como te llamas? - What is your name?',
  'Me llamo Ana - My name is Ana',
  'Gracias - Thank you',
  'Por favor - Please',
  'Hasta luego - See you later',
];

const String readingMarkdown = '''
Meeting New People

When you meet someone for the first time, start with a warm greeting and a short introduction.

Useful phrases

- Hola means "hello".
- Me llamo Ana means "my name is Ana".
- Mucho gusto means "nice to meet you".

Short example

Ana: Hola, me llamo Ana.
Luis: Hola Ana, mucho gusto.

Keep your tone friendly and your sentences short. In this lesson, the focus is clarity before complexity.
''';

const String writingMarkdown = '''
Writing Focus

In Spanish, introductions often use the structure:

Me llamo + name

Grammar pattern

- Me points back to the speaker.
- Llamo comes from the verb llamarse.

Build your own sentence

1. Start with Hola.
2. Add me llamo.
3. End with your name.

Example: Hola, me llamo Ana.
''';

const String speakingPrompt = '''
Say this phrase clearly and slowly:

"Hola, me llamo Ana. Mucho gusto."

Focus on rhythm, not speed. Keep your pronunciation clean and confident.
''';

const String listeningTranscript = '''
Hola, me llamo Ana. Vivo en Madrid y trabajo en una pequena libreria.
Mucho gusto. Me encanta conocer gente nueva y hablar sobre libros.
''';
