import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../state/app_controller.dart';
import '../../widgets/lesson_shell.dart';

class WritingPage extends StatefulWidget {
  const WritingPage({super.key});

  @override
  State<WritingPage> createState() => _WritingPageState();
}

class _WritingPageState extends State<WritingPage> {
  final TextEditingController _responseController = TextEditingController();
  bool _submitted = false;
  int _matchedKeywords = 0;

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
      subtitle: 'This is writing practice. Submit here, review feedback, and retry without changing your score.',
      stepLabel: 'Step 5 of 7',
      progress: 0.72,
      accentColor: const Color(0xFF2563EB),
      previousRoute: '/lesson/listening',
      nextRoute: '/lesson/speaking',
      nextEnabled: _submitted,
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
                      writing.prompt.text,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.7,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TranslationRevealCard(
                      text: writing.prompt,
                      accentColor: const Color(0xFF2563EB),
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
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDBEAFE),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  word.text,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1D4ED8),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      for (final keyword in writing.expectedKeywords) ...[
                        TranslationRevealCard(
                          text: keyword,
                          accentColor: const Color(0xFF2563EB),
                        ),
                        const SizedBox(height: 10),
                      ],
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
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _submitted = true;
                                _matchedKeywords = _matchCount(
                                  _responseController.text,
                                  writing.expectedKeywords,
                                );
                              });
                            },
                            child: const Text('Submit writing practice'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _responseController.clear();
                              controller.updateWritingDraft('');
                              setState(() {
                                _submitted = false;
                                _matchedKeywords = 0;
                              });
                            },
                            child: const Text('Retry writing'),
                          ),
                        ),
                      ],
                    ),
                    if (_submitted) ...[
                      const SizedBox(height: 14),
                      Text(
                        'You used $_matchedKeywords of ${writing.expectedKeywords.length} target phrases.',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
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

  int _matchCount(String response, List<TranslatableTextModel> expected) {
    final lowered = response.toLowerCase();
    return expected.where((item) => lowered.contains(item.text.toLowerCase())).length;
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
