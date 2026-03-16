import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../state/app_controller.dart';
import '../../widgets/lesson_shell.dart';

class LearnPage extends StatelessWidget {
  const LearnPage({super.key});

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
      title: 'Learn',
      subtitle: lesson?.objective ?? 'Learn the vocabulary and structure before the checks begin.',
      stepLabel: 'Step 1 of 7',
      progress: 0.14,
      accentColor: const Color(0xFFD97706),
      nextRoute: '/lesson/practice',
      nextLabel: 'Start practice',
      body: FutureBuilder(
        future: controller.fetchLearn(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) {
              return _ErrorCard(message: '${snapshot.error}');
            }
            return const Center(child: CircularProgressIndicator());
          }

          final learn = snapshot.data!;
          return Column(
            children: [
              LessonCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson?.title ?? 'Lesson focus',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF112032),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      learn.intro.text,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.7,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TranslationRevealCard(
                      text: learn.intro,
                      accentColor: const Color(0xFFD97706),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              LessonCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Must-know words',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF112032),
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final item in learn.vocabulary) ...[
                      _VocabTile(item: item),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              LessonCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Grammar shortcut',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF112032),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(learn.grammarTip.text),
                    const SizedBox(height: 14),
                    TranslationRevealCard(
                      text: learn.grammarTip,
                      accentColor: const Color(0xFFD97706),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3C4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        learn.coachingTip,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              LessonCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mini dialogue',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF112032),
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final line in learn.dialogue) ...[
                      _DialogueBubble(line: line),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _VocabTile extends StatelessWidget {
  const _VocabTile({required this.item});

  final VocabularyItemModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7E0), Color(0xFFFFE6B7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.word,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF112032),
            ),
          ),
          const SizedBox(height: 6),
          Text(item.meaning),
          const SizedBox(height: 8),
          Text(
            item.example.text,
            style: const TextStyle(
              color: Color(0xFF7C2D12),
            ),
          ),
          const SizedBox(height: 12),
          TranslationRevealCard(
            text: item.example,
            accentColor: const Color(0xFFB45309),
          ),
        ],
      ),
    );
  }
}

class _DialogueBubble extends StatelessWidget {
  const _DialogueBubble({required this.line});

  final DialogueLineModel line;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Color(0xFF334155),
              ),
              children: [
                TextSpan(
                  text: '${line.speaker}: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF112032),
                  ),
                ),
                TextSpan(text: line.line.text),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TranslationRevealCard(
            text: line.line,
            accentColor: const Color(0xFF0F766E),
          ),
        ],
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
