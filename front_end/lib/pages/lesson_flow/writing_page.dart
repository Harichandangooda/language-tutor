import 'package:flutter/material.dart';

import '../../state/app_controller.dart';
import '../../widgets/lesson_shell.dart';

class WritingPage extends StatefulWidget {
  const WritingPage({super.key});

  @override
  State<WritingPage> createState() => _WritingPageState();
}

class _WritingPageState extends State<WritingPage> {
  final TextEditingController _responseController = TextEditingController();

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);

    return LessonShell(
      title: 'Writing',
      subtitle: 'Writing prompts and keywords now come from the backend lesson package.',
      stepLabel: 'Step 3 of 5',
      progress: 0.6,
      accentColor: const Color(0xFF2563EB),
      previousRoute: '/lesson/listening',
      nextRoute: '/lesson/speaking',
      body: FutureBuilder(
        future: controller.fetchWriting(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) {
              return _ErrorCard(message: '${snapshot.error}');
            }
            return const Center(child: CircularProgressIndicator());
          }

          final writing = snapshot.data!;
          return Column(
            children: [
              LessonCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Writing prompt',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF112032),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      writing.prompt,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.7,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (writing.expectedKeywords.isNotEmpty) ...[
                      const Text(
                        'Expected keywords',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF112032),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: writing.expectedKeywords
                            .map(
                              (word) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDBEAFE),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  word,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1D4ED8),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 18),
                    ],
                    TextField(
                      controller: _responseController,
                      onChanged: controller.updateWritingDraft,
                      minLines: 4,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Type your German response here...',
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
