import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../state/app_controller.dart';
import '../../widgets/lesson_shell.dart';

class SpeakingPage extends StatefulWidget {
  const SpeakingPage({super.key});

  @override
  State<SpeakingPage> createState() => _SpeakingPageState();
}

class _SpeakingPageState extends State<SpeakingPage> {
  final TextEditingController _transcriptController = TextEditingController();
  bool _submitted = false;
  int _matchedPhrases = 0;
  int _expectedPhraseCount = 0;

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
      subtitle: 'This is speaking practice. Retry here as much as you want before the final assessment.',
      stepLabel: 'Step 6 of 7',
      progress: 0.86,
      accentColor: const Color(0xFF7C3AED),
      previousRoute: '/lesson/writing',
      nextRoute: '/lesson/assessment',
      nextEnabled: _submitted && _expectedPhraseCount > 0 && _matchedPhrases == _expectedPhraseCount,
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
          _expectedPhraseCount = speaking.expectedPhrases.length;
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
                      speaking.prompt.text,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.8,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TranslationRevealCard(
                      text: speaking.prompt,
                      accentColor: const Color(0xFF7C3AED),
                    ),
                    if (speaking.expectedPhrases.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: speaking.expectedPhrases
                            .map(
                              (phrase) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F3FF),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  phrase.text,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF5B21B6),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      for (final phrase in speaking.expectedPhrases) ...[
                        TranslationRevealCard(
                          text: phrase,
                          accentColor: const Color(0xFF7C3AED),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
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
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _submitted = true;
                                _matchedPhrases = _matchCount(
                                  _transcriptController.text,
                                  speaking.expectedPhrases,
                                );
                              });
                            },
                            child: const Text('Submit speaking practice'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _transcriptController.clear();
                              controller.updateSpeakingDraft('');
                              setState(() {
                                _submitted = false;
                                _matchedPhrases = 0;
                              });
                            },
                            child: const Text('Retry speaking'),
                          ),
                        ),
                      ],
                    ),
                    if (_submitted) ...[
                      const SizedBox(height: 14),
                      Text(
                        'You used $_matchedPhrases of ${speaking.expectedPhrases.length} target phrases.',
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
