import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../state/app_controller.dart';
import '../../widgets/lesson_shell.dart';

class ListeningPage extends StatefulWidget {
  const ListeningPage({super.key});

  @override
  State<ListeningPage> createState() => _ListeningPageState();
}

class _ListeningPageState extends State<ListeningPage> {
  final List<TextEditingController> _controllers = [];
  bool _submitted = false;
  int _correctCount = 0;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);

    return LessonShell(
      title: 'Listening',
      subtitle: 'This is listening practice. Submit and retry here without affecting your score.',
      stepLabel: 'Step 4 of 7',
      progress: 0.57,
      accentColor: const Color(0xFF0F766E),
      previousRoute: '/lesson/reading',
      nextRoute: '/lesson/writing',
      nextEnabled: _submitted,
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
          _syncControllers(listening.questions.length);
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
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
                            ),
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
                      listening.audioScript.text,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.7,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TranslationRevealCard(
                      text: listening.audioScript,
                      accentColor: const Color(0xFF0F766E),
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
                      for (var i = 0; i < listening.questions.length; i++) ...[
                        Text(
                          listening.questions[i].question.text,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        TranslationRevealCard(
                          text: listening.questions[i].question,
                          accentColor: const Color(0xFF0F766E),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _controllers[i],
                          minLines: 2,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Type your answer in German...',
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                        if (_submitted) ...[
                          const SizedBox(height: 10),
                          Text('Expected answer: ${listening.questions[i].answer.text}'),
                          const SizedBox(height: 10),
                          TranslationRevealCard(
                            text: listening.questions[i].answer,
                            accentColor: const Color(0xFF166534),
                          ),
                        ],
                        const SizedBox(height: 14),
                      ],
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _submitted = true;
                                _correctCount = _score(listening.questions);
                              });
                            },
                            child: const Text('Submit listening practice'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _retry,
                            child: const Text('Retry listening'),
                          ),
                        ),
                      ],
                    ),
                    if (_submitted) ...[
                      const SizedBox(height: 12),
                      Text(
                        'You got $_correctCount of ${listening.questions.length} listening answers right.',
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

  void _syncControllers(int count) {
    while (_controllers.length < count) {
      _controllers.add(TextEditingController());
    }
  }

  int _score(List<QuestionAnswerModel> questions) {
    var correct = 0;
    for (var i = 0; i < questions.length; i++) {
      if (_isCorrect(_controllers[i].text, questions[i].answer.text)) {
        correct++;
      }
    }
    return correct;
  }

  bool _isCorrect(String value, String expected) {
    final normalizedValue = value.trim().toLowerCase();
    final normalizedExpected = expected.trim().toLowerCase();
    return normalizedValue.isNotEmpty &&
        (normalizedValue == normalizedExpected || normalizedValue.contains(normalizedExpected));
  }

  void _retry() {
    for (final controller in _controllers) {
      controller.clear();
    }
    setState(() {
      _submitted = false;
      _correctCount = 0;
    });
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
