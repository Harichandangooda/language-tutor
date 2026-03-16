import 'package:flutter/material.dart';

import '../../state/app_controller.dart';
import '../../widgets/lesson_shell.dart';

class SpeakingPage extends StatefulWidget {
  const SpeakingPage({super.key});

  @override
  State<SpeakingPage> createState() => _SpeakingPageState();
}

class _SpeakingPageState extends State<SpeakingPage> {
  final TextEditingController _transcriptController = TextEditingController();

  @override
  void dispose() {
    _transcriptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);

    return LessonShell(
      title: 'Speaking',
      subtitle: 'Speaking prompts and phrase targets come from the backend lesson content.',
      stepLabel: 'Step 4 of 5',
      progress: 0.8,
      accentColor: const Color(0xFF7C3AED),
      previousRoute: '/lesson/writing',
      nextRoute: '/lesson/assessment',
      body: FutureBuilder(
        future: controller.fetchSpeaking(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) {
              return _ErrorCard(message: '${snapshot.error}');
            }
            return const Center(child: CircularProgressIndicator());
          }

          final speaking = snapshot.data!;
          return Column(
            children: [
              LessonCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Speaking prompt',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF112032),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.mic_rounded,
                        size: 40,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      speaking.prompt,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.8,
                        color: Color(0xFF334155),
                      ),
                    ),
                    if (speaking.expectedPhrases.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: speaking.expectedPhrases
                            .map(
                              (phrase) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F3FF),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  phrase,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF5B21B6),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 18),
                    TextField(
                      controller: _transcriptController,
                      onChanged: controller.updateSpeakingDraft,
                      minLines: 3,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Type what you would say in the mic...',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
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
