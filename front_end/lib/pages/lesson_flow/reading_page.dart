import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../state/app_controller.dart';
import '../../widgets/lesson_shell.dart';

class ReadingPage extends StatefulWidget {
  const ReadingPage({super.key});

  @override
  State<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
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
    LessonFeedItemModel? lesson;
    for (final item in controller.lessons) {
      if (item.lessonId == controller.activeLessonId) {
        lesson = item;
        break;
      }
    }

    return LessonShell(
      title: 'Reading',
      subtitle: lesson?.objective ?? 'Reading practice from the selected backend lesson.',
      stepLabel: 'Step 3 of 7',
      progress: 0.42,
      accentColor: const Color(0xFFD97706),
      previousRoute: '/lesson/practice',
      nextRoute: '/lesson/listening',
      nextEnabled: _submitted,
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
          _syncControllers(reading.questions.length);
          return Column(
            children: [
              MarkdownSection(
                eyebrow: lesson?.dayLabel ?? 'Lesson',
                title: lesson?.title ?? 'Reading',
                body: reading.passage.text,
                translation: reading.passage,
              ),
              if (reading.questions.isNotEmpty) ...[
                const SizedBox(height: 18),
                LessonCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Comprehension practice',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF112032),
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (var i = 0; i < reading.questions.length; i++) ...[
                        Text(
                          reading.questions[i].question.text,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF112032),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TranslationRevealCard(
                          text: reading.questions[i].question,
                          accentColor: const Color(0xFFD97706),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _controllers[i],
                          minLines: 2,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Type your answer in German...',
                            filled: true,
                            fillColor: const Color(0xFFFFFBF5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                        if (_submitted) ...[
                          const SizedBox(height: 10),
                          Text(
                            _isCorrect(_controllers[i].text, reading.questions[i].answer.text) ? 'Correct' : 'Review this one',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: _isCorrect(_controllers[i].text, reading.questions[i].answer.text)
                                  ? const Color(0xFF166534)
                                  : const Color(0xFFB91C1C),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Expected answer: ${reading.questions[i].answer.text}'),
                          const SizedBox(height: 10),
                          TranslationRevealCard(
                            text: reading.questions[i].answer,
                            accentColor: const Color(0xFF166534),
                          ),
                        ],
                        const SizedBox(height: 16),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _submitted = true;
                                  _correctCount = _score(reading.questions);
                                });
                              },
                              child: const Text('Submit reading practice'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _retry,
                              child: const Text('Retry reading'),
                            ),
                          ),
                        ],
                      ),
                      if (_submitted) ...[
                        const SizedBox(height: 12),
                        Text(
                          'You got $_correctCount of ${reading.questions.length} reading answers right.',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
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
