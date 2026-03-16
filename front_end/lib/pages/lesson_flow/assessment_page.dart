import 'package:flutter/material.dart';

import '../../state/app_controller.dart';
import '../../widgets/lesson_shell.dart';

class AssessmentPage extends StatefulWidget {
  const AssessmentPage({super.key});

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  int selectedIndex = 0;
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);

    return LessonShell(
      title: 'Assessment',
      subtitle:
          'The last step now reads backend questions and sends a real assessment payload back to the API.',
      stepLabel: 'Step 5 of 5',
      progress: 1,
      accentColor: const Color(0xFF059669),
      previousRoute: '/lesson/speaking',
      nextLabel: isSubmitting ? 'Verifying...' : 'Verify',
      onNext: isSubmitting
          ? null
          : () async {
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              final assessment = await controller.fetchAssessment();
              final selectedAnswer = assessment.questions.isNotEmpty &&
                      assessment.questions.first.options.length > selectedIndex
                  ? assessment.questions.first.options[selectedIndex]
                  : '';
              setState(() {
                isSubmitting = true;
              });
              try {
                final result = await controller.submitAssessment(
                  selectedAnswer: selectedAnswer,
                  writingResponse: controller.writingDraft,
                  speakingTranscript: controller.speakingDraft,
                );
                if (!context.mounted) {
                  return;
                }
                if (result.chapterComplete) {
                  await showDialog<void>(
                    context: context,
                    builder: (context) {
                      final title = switch (result.levelOutcome) {
                        'promoted' => 'Promoted!',
                        'mastered' => 'Mastered!',
                        _ => 'Try again',
                      };
                      final message = switch (result.levelOutcome) {
                        'promoted' => 'You scored ${result.chapterAverage?.toStringAsFixed(1) ?? ''}% and unlocked Level ${result.currentLevel}: ${result.currentLevelName}.',
                        'mastered' => 'You scored ${result.chapterAverage?.toStringAsFixed(1) ?? ''}% and mastered the Expert level.',
                        _ => 'You scored ${result.chapterAverage?.toStringAsFixed(1) ?? ''}%. Stay on this level and try the refreshed chapter 5 set.',
                      };
                      return AlertDialog(
                        title: Text(title),
                        content: Text(message),
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
                navigator.pushNamedAndRemoveUntil(
                  '/dashboard',
                  (route) => false,
                );
              } catch (error) {
                if (!context.mounted) {
                  return;
                }
                messenger.showSnackBar(
                  SnackBar(content: Text('$error')),
                );
              } finally {
                if (mounted) {
                  setState(() {
                    isSubmitting = false;
                  });
                }
              }
            },
      body: FutureBuilder(
        future: controller.fetchAssessment(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) {
              return _ErrorCard(message: '${snapshot.error}');
            }
            return const Center(child: CircularProgressIndicator());
          }

          final assessment = snapshot.data!;
          if (assessment.questions.isEmpty) {
            return const _ErrorCard(message: 'No assessment questions available.');
          }

          final question = assessment.questions.first;
          return Column(
            children: [
              LessonCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Question 1 of ${assessment.questions.length}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF047857),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Assessment check',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF112032),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      question.question,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 18),
                    for (var i = 0; i < question.options.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AssessmentOption(
                          label: question.options[i],
                          selected: i == selectedIndex,
                          onTap: () {
                            setState(() {
                              selectedIndex = i;
                            });
                          },
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
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
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
