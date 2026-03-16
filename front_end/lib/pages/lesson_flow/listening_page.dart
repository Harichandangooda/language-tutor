import 'package:flutter/material.dart';

import '../../state/app_controller.dart';
import '../../widgets/lesson_shell.dart';

class ListeningPage extends StatelessWidget {
  const ListeningPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);

    return LessonShell(
      title: 'Listening',
      subtitle: 'Audio script and prompts now come from the selected backend lesson.',
      stepLabel: 'Step 2 of 5',
      progress: 0.4,
      accentColor: const Color(0xFF0F766E),
      previousRoute: '/lesson/reading',
      nextRoute: '/lesson/writing',
      body: FutureBuilder(
        future: controller.fetchListening(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) {
              return _ErrorCard(message: '${snapshot.error}');
            }
            return const Center(child: CircularProgressIndicator());
          }

          final listening = snapshot.data!;
          return Column(
            children: [
              LessonCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dialogue playback',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF112032),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0F766E),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 52,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: const LinearProgressIndicator(
                              value: 0.38,
                              minHeight: 10,
                              backgroundColor: Color(0xFFD1FAE5),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF0F766E),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('00:48'),
                              Text('02:05'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Transcript',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF112032),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      listening.audioScript,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.7,
                        color: Color(0xFF334155),
                      ),
                    ),
                    if (listening.questions.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      const Text(
                        'Questions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF112032),
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final question in listening.questions) ...[
                        Text(
                          question.question,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(question.answer),
                        const SizedBox(height: 12),
                      ],
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
