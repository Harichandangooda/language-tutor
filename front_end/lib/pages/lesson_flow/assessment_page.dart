import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../state/app_controller.dart';
import '../../widgets/lesson_shell.dart';

class AssessmentPage extends StatefulWidget {
  const AssessmentPage({super.key});

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  final List<TextEditingController> _readingControllers = [];
  final List<TextEditingController> _listeningControllers = [];
  final TextEditingController _writingController = TextEditingController();
  final TextEditingController _speakingController = TextEditingController();
  final Map<int, int> _selectedOptions = {};
  bool isSubmitting = false;

  @override
  void dispose() {
    for (final controller in _readingControllers) {
      controller.dispose();
    }
    for (final controller in _listeningControllers) {
      controller.dispose();
    }
    _writingController.dispose();
    _speakingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);

    return LessonShell(
      title: 'Assessment',
      subtitle: controller.isReviewMode
          ? 'This retry uses the same lesson questions. Your official score stays locked.'
          : 'This final step is scored. It checks reading, listening, writing, speaking, and five quiz questions from the same lesson theme.',
      stepLabel: 'Step 7 of 7',
      progress: 1,
      accentColor: const Color(0xFF059669),
      previousRoute: '/lesson/speaking',
      nextLabel: isSubmitting ? 'Verifying...' : (controller.isReviewMode ? 'Finish review' : 'Submit assessment'),
      onNext: isSubmitting
          ? null
          : () async {
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              final assessment = await controller.fetchAssessment();
              if (!context.mounted) {
                return;
              }
              setState(() {
                isSubmitting = true;
              });
              try {
                if (controller.isReviewMode) {
                  await _showReviewDialog(
                    context: context,
                    controller: controller,
                    assessment: assessment,
                  );
                } else {
                  final result = await controller.submitAssessment(
                    readingAnswers: _readingControllers.map((item) => item.text).toList(),
                    listeningAnswers: _listeningControllers.map((item) => item.text).toList(),
                    writingResponse: _writingController.text,
                    speakingTranscript: _speakingController.text,
                    selectedAnswers: List.generate(
                      assessment.questions.length,
                      (index) => _selectedOptions[index] == null
                          ? ''
                          : assessment.questions[index].options[_selectedOptions[index]!],
                    ),
                  );
                  if (!context.mounted) {
                    return;
                  }
                  await _showScoredResultDialog(context: context, result: result);
                }
                if (!context.mounted) {
                  return;
                }
                final activeLessonId = controller.activeLessonId;
                if (activeLessonId != null) {
                  controller.selectLesson(activeLessonId);
                }
                navigator.pushNamedAndRemoveUntil('/dashboard', (route) => false);
              } catch (error) {
                if (!context.mounted) {
                  return;
                }
                messenger.showSnackBar(SnackBar(content: Text('$error')));
              } finally {
                if (mounted) {
                  setState(() {
                    isSubmitting = false;
                  });
                }
              }
            },
      body: FutureBuilder<AssessmentContentModel>(
        future: controller.fetchAssessment(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) {
              return _ErrorCard(message: '${snapshot.error}');
            }
            return const Center(child: CircularProgressIndicator());
          }

          final assessment = snapshot.data!;
          _syncControllers(_readingControllers, assessment.readingQuestions.length);
          _syncControllers(_listeningControllers, assessment.listeningQuestions.length);

          return Column(
            children: [
              _SectionCard(
                title: 'Reading assessment',
                children: [
                  for (var i = 0; i < assessment.readingQuestions.length; i++) ...[
                    _OpenQuestion(
                      prompt: assessment.readingQuestions[i].question.text,
                      controller: _readingControllers[i],
                    ),
                    const SizedBox(height: 10),
                    TranslationRevealCard(
                      text: assessment.readingQuestions[i].question,
                      accentColor: const Color(0xFF059669),
                    ),
                    const SizedBox(height: 14),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Listening assessment',
                children: [
                  for (var i = 0; i < assessment.listeningQuestions.length; i++) ...[
                    _OpenQuestion(
                      prompt: assessment.listeningQuestions[i].question.text,
                      controller: _listeningControllers[i],
                    ),
                    const SizedBox(height: 10),
                    TranslationRevealCard(
                      text: assessment.listeningQuestions[i].question,
                      accentColor: const Color(0xFF059669),
                    ),
                    const SizedBox(height: 14),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Writing assessment',
                children: [
                  Text(assessment.writingPrompt.text),
                  const SizedBox(height: 10),
                  TranslationRevealCard(
                    text: assessment.writingPrompt,
                    accentColor: const Color(0xFF059669),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _writingController,
                    minLines: 4,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Write your final German answer...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Speaking assessment',
                children: [
                  Text(assessment.speakingPrompt.text),
                  const SizedBox(height: 10),
                  TranslationRevealCard(
                    text: assessment.speakingPrompt,
                    accentColor: const Color(0xFF059669),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _speakingController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Type what you would say aloud...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Quiz',
                children: [
                  for (var q = 0; q < assessment.questions.length; q++) ...[
                    Text(
                      '${q + 1}. ${assessment.questions[q].question.text}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF112032),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TranslationRevealCard(
                      text: assessment.questions[q].question,
                      accentColor: const Color(0xFF059669),
                    ),
                    const SizedBox(height: 10),
                    for (var i = 0; i < assessment.questions[q].options.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _AssessmentOption(
                          label: assessment.questions[q].options[i],
                          selected: _selectedOptions[q] == i,
                          onTap: () {
                            setState(() {
                              _selectedOptions[q] = i;
                            });
                          },
                        ),
                      ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showScoredResultDialog({
    required BuildContext context,
    required AssessmentResultModel result,
  }) {
    final title = switch (result.levelOutcome) {
      'promoted' => 'Promoted!',
      'mastered' => 'Mastered!',
      'relegated' => 'Moved down',
      _ => 'Assessment complete',
    };
    final message = switch (result.levelOutcome) {
      'promoted' => 'Your combined level score is ${result.levelAverage?.toStringAsFixed(1) ?? ''}% and you unlocked Level ${result.currentLevel}: ${result.currentLevelName}.',
      'mastered' => 'Your combined level score is ${result.levelAverage?.toStringAsFixed(1) ?? ''}% and you mastered the Expert level.',
      'relegated' => 'Your combined level score is ${result.levelAverage?.toStringAsFixed(1) ?? ''}%. You were moved to Level ${result.currentLevel}: ${result.currentLevelName} for reinforcement.',
      _ => 'Your combined level score is ${result.levelAverage?.toStringAsFixed(1) ?? ''}%. The score is locked, and a fresh retry set has been generated on the same level.',
    };
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message),
                const SizedBox(height: 14),
                Text(
                  result.longFeedback,
                  style: const TextStyle(height: 1.5),
                ),
                if (result.whatWentWell.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Text('What went well', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  for (final item in result.whatWentWell) Text('- $item'),
                ],
                if (result.whatToImprove.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Text('What to improve', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  for (final item in result.whatToImprove) Text('- $item'),
                ],
                const SizedBox(height: 14),
                const Text('Correct answers', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('Reading: ${(result.correctAnswers['reading_answers'] as List?)?.join(', ') ?? ''}'),
                Text('Listening: ${(result.correctAnswers['listening_answers'] as List?)?.join(', ') ?? ''}'),
                Text('Quiz: ${(result.correctAnswers['mcq_answers'] as List?)?.join(', ') ?? ''}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showReviewDialog({
    required BuildContext context,
    required AppController controller,
    required AssessmentContentModel assessment,
  }) {
    final readingCorrect = _countOpenMatches(
      _readingControllers.map((item) => item.text).toList(),
      assessment.readingQuestions.map((item) => item.answer.text).toList(),
    );
    final listeningCorrect = _countOpenMatches(
      _listeningControllers.map((item) => item.text).toList(),
      assessment.listeningQuestions.map((item) => item.answer.text).toList(),
    );
    final quizCorrect = _countQuizMatches(assessment);
    final priorFeedback = _priorFeedback(controller);

    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Review complete'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'This retry uses the same lesson questions. Your official score stays locked, so this run is only for reinforcement.',
                ),
                const SizedBox(height: 14),
                Text('Reading matches: $readingCorrect / ${assessment.readingQuestions.length}'),
                Text('Listening matches: $listeningCorrect / ${assessment.listeningQuestions.length}'),
                Text('Quiz matches: $quizCorrect / ${assessment.questions.length}'),
                if (priorFeedback.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Text('Saved coaching notes', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(priorFeedback),
                ],
                const SizedBox(height: 14),
                const Text('Correct answers', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('Reading: ${assessment.readingQuestions.map((item) => item.answer.text).join(', ')}'),
                Text('Listening: ${assessment.listeningQuestions.map((item) => item.answer.text).join(', ')}'),
                Text('Quiz: ${assessment.questions.map((item) => item.correctAnswer).join(', ')}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to dashboard'),
            ),
          ],
        );
      },
    );
  }

  int _countOpenMatches(List<String> userAnswers, List<String> correctAnswers) {
    var total = 0;
    final count = userAnswers.length < correctAnswers.length ? userAnswers.length : correctAnswers.length;
    for (var index = 0; index < count; index++) {
      if (_normalize(userAnswers[index]) == _normalize(correctAnswers[index])) {
        total += 1;
      }
    }
    return total;
  }

  int _countQuizMatches(AssessmentContentModel assessment) {
    var total = 0;
    for (var index = 0; index < assessment.questions.length; index++) {
      final selectedIndex = _selectedOptions[index];
      if (selectedIndex == null) {
        continue;
      }
      final selected = assessment.questions[index].options[selectedIndex];
      if (_normalize(selected) == _normalize(assessment.questions[index].correctAnswer)) {
        total += 1;
      }
    }
    return total;
  }

  String _priorFeedback(AppController controller) {
    final activeLessonId = controller.activeLessonId;
    if (activeLessonId == null) {
      return '';
    }
    for (final lesson in controller.progress?.lessons ?? const <ProgressLessonModel>[]) {
      if (lesson.lessonId == activeLessonId) {
        return lesson.longFeedback.isNotEmpty ? lesson.longFeedback : lesson.summary;
      }
    }
    return '';
  }

  String _normalize(String value) {
    return value.trim().toLowerCase();
  }

  void _syncControllers(List<TextEditingController> controllers, int count) {
    while (controllers.length < count) {
      controllers.add(TextEditingController());
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LessonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF112032),
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _OpenQuestion extends StatelessWidget {
  const _OpenQuestion({
    required this.prompt,
    required this.controller,
  });

  final String prompt;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          prompt,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF112032),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          minLines: 2,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Answer in German...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ],
    );
  }
}

class _AssessmentOption extends StatelessWidget {
  const _AssessmentOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFD1FAE5) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF112032),
                ),
              ),
            ),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: selected ? const Color(0xFF059669) : const Color(0xFF94A3B8),
            ),
          ],
        ),
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
