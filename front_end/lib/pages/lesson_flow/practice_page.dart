import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../state/app_controller.dart';
import '../../widgets/lesson_shell.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
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
      title: 'Practice',
      subtitle: 'Try the taught material first. This page is unscored and can be retried until you get it right.',
      stepLabel: 'Step 2 of 7',
      progress: 0.28,
      accentColor: const Color(0xFFEA580C),
      previousRoute: '/lesson/learn',
      nextRoute: '/lesson/reading',
      nextLabel: 'Go to reading',
      nextEnabled: _submitted,
      body: FutureBuilder(
        future: controller.fetchPractice(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) {
              return _ErrorCard(message: '${snapshot.error}');
            }
            return const Center(child: CircularProgressIndicator());
          }

          final practice = snapshot.data!;
          _syncControllers(practice.items.length);
          return Column(
            children: [
              LessonCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Guided practice',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF112032),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(practice.intro.text),
                    const SizedBox(height: 14),
                    TranslationRevealCard(
                      text: practice.intro,
                      accentColor: const Color(0xFFEA580C),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _submitted = true;
                                _correctCount = _score(practice.items);
                              });
                            },
                            child: const Text('Submit practice'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _retry,
                            child: const Text('Retry practice'),
                          ),
                        ),
                      ],
                    ),
                    if (_submitted) ...[
                      const SizedBox(height: 14),
                      Text(
                        'You got $_correctCount of ${practice.items.length} correct.',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: _correctCount == practice.items.length && practice.items.isNotEmpty
                              ? const Color(0xFF166534)
                              : const Color(0xFF9A3412),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              for (var i = 0; i < practice.items.length; i++) ...[
                _PracticeItemCard(
                  index: i,
                  item: practice.items[i],
                  controller: _controllers[i],
                  showAnswer: _submitted,
                  isCorrect: _submitted && _isCorrect(_controllers[i].text, practice.items[i].answer.text),
                ),
                const SizedBox(height: 16),
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

  int _score(List<PracticeItemModel> items) {
    var correct = 0;
    for (var i = 0; i < items.length; i++) {
      if (_isCorrect(_controllers[i].text, items[i].answer.text)) {
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

class _PracticeItemCard extends StatelessWidget {
  const _PracticeItemCard({
    required this.index,
    required this.item,
    required this.controller,
    required this.showAnswer,
    required this.isCorrect,
  });

  final int index;
  final PracticeItemModel item;
  final TextEditingController controller;
  final bool showAnswer;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    return LessonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEDD5),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Practice ${index + 1}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF9A3412),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            item.prompt.text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF112032),
            ),
          ),
          const SizedBox(height: 12),
          TranslationRevealCard(
            text: item.prompt,
            accentColor: const Color(0xFFEA580C),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              'Hint: ${item.hint}',
              style: const TextStyle(
                color: Color(0xFF475569),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Write your answer in German...',
              filled: true,
              fillColor: const Color(0xFFFFFBF5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          if (showAnswer) ...[
            const SizedBox(height: 14),
            Text(
              isCorrect ? 'Correct' : 'Not quite',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isCorrect ? const Color(0xFF166534) : const Color(0xFFB91C1C),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Model answer: ${item.answer.text}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF166534),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TranslationRevealCard(
                    text: item.answer,
                    accentColor: const Color(0xFF166534),
                  ),
                ],
              ),
            ),
          ],
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
