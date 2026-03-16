import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../state/app_controller.dart';
import '../../widgets/lesson_shell.dart';

class ReadingPage extends StatelessWidget {
  const ReadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    LessonFeedItemModel? lesson;
    for (final item in controller.lessons) {
      if (item.lessonId == controller.activeLessonId) {
        lesson = item;
        break;
      }
    }

    return LessonShell(
      title: 'Reading',
      subtitle: lesson?.objective ?? 'Reading content from the selected backend lesson.',
      stepLabel: 'Step 1 of 5',
      progress: 0.2,
      accentColor: const Color(0xFFD97706),
      nextRoute: '/lesson/listening',
      body: FutureBuilder(
        future: controller.fetchReading(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) {
              return _ErrorCard(message: '${snapshot.error}');
            }
            return const Center(child: CircularProgressIndicator());
          }

          final reading = snapshot.data!;
          return Column(
            children: [
              MarkdownSection(
                eyebrow: lesson?.dayLabel ?? 'Lesson',
                title: lesson?.title ?? 'Reading',
                body: reading.passage,
              ),
              if (reading.questions.isNotEmpty) ...[
                const SizedBox(height: 18),
                LessonCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Comprehension checks',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF112032),
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final question in reading.questions) ...[
                        Text(
                          question.question,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF112032),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(question.answer),
                        const SizedBox(height: 14),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return LessonCard(
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFFB91C1C)),
      ),
    );
  }
}
