import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../state/app_controller.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final screens = [
      _LessonsTab(onDoubts: _showDoubtSheet),
      const _ProgressTab(),
      const _ProfileTab(),
    ];

    return Scaffold(
      body: SafeArea(
        child: controller.lessons.isEmpty && controller.isBusy
            ? const Center(child: CircularProgressIndicator())
            : screens[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Lessons',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _showDoubtSheet() {
    Navigator.pushNamed(context, '/doubts');
  }
}

class _LessonsTab extends StatelessWidget {
  const _LessonsTab({required this.onDoubts});

  final VoidCallback onDoubts;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final lessons = controller.lessons;
    final active = _pickActiveLesson(lessons, controller.activeLessonId);
    final upcoming = lessons
        .where((item) => item.status != 'completed' && item.lessonId != active?.lessonId)
        .toList();
    final completed = lessons
        .where((item) => item.status == 'completed' && item.lessonId != active?.lessonId)
        .toList();

    return RefreshIndicator(
      onRefresh: controller.refreshAppData,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.profile == null
                                  ? 'Demo flow'
                                  : 'Level ${controller.profile!.currentLevelValue} - ${controller.profile!.currentLevelName}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFD97706),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.profile == null
                                  ? 'Build fluency with guided German lessons.'
                                  : 'Chapter ${controller.profile!.currentChapter}: work through the live lesson set in order.',
                              style: const TextStyle(
                                fontSize: 28,
                                height: 1.15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF112032),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _TopIconButton(
                        icon: Icons.forum_rounded,
                        onTap: onDoubts,
                      ),
                      const SizedBox(width: 10),
                      _TopIconButton(
                        icon: Icons.style_rounded,
                        onTap: () => Navigator.pushNamed(context, '/flashcards'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (active != null)
                    _HeroLessonCard(
                      lesson: active,
                      buttonLabel: active.status == 'completed' ? 'Retry lesson' : 'Start learning',
                      onPressed: () {
                        if (active.status == 'completed') {
                          controller.retryLesson(active.lessonId);
                        } else {
                          controller.selectLesson(active.lessonId);
                        }
                        Navigator.pushNamed(context, '/lesson/learn');
                      },
                    ),
                  if (upcoming.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Up next',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF112032),
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final lesson in upcoming) ...[
                      _LessonQueueCard(
                        lesson: lesson,
                        onTap: () {
                          controller.selectLesson(lesson.lessonId);
                          Navigator.pushNamed(context, '/lesson/learn');
                        },
                      ),
                      const SizedBox(height: 14),
                    ],
                  ],
                  if (completed.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Completed lessons',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF112032),
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final lesson in completed) ...[
                      _CompletedLessonCard(
                        lesson: lesson,
                        onRetry: () {
                          controller.retryLesson(lesson.lessonId);
                          Navigator.pushNamed(context, '/lesson/learn');
                        },
                      ),
                      const SizedBox(height: 14),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LessonFeedItemModel? _pickActiveLesson(List<LessonFeedItemModel> lessons, String? activeLessonId) {
    for (final lesson in lessons) {
      if (lesson.status != 'completed') {
        return lesson;
      }
    }
    if (activeLessonId != null) {
      for (final lesson in lessons) {
        if (lesson.lessonId == activeLessonId) {
          return lesson;
        }
      }
    }
    return lessons.isEmpty ? null : lessons.first;
  }
}

class _HeroLessonCard extends StatelessWidget {
  const _HeroLessonCard({
    required this.lesson,
    required this.buttonLabel,
    required this.onPressed,
  });

  final LessonFeedItemModel lesson;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF112032), Color(0xFF234D74)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${lesson.dayLabel} lesson',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            lesson.title,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            lesson.objective,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _MetricChip(
                icon: Icons.flag_rounded,
                label: 'Lesson ${lesson.slot}',
              ),
              const SizedBox(width: 10),
              _MetricChip(
                icon: lesson.status == 'completed'
                    ? Icons.replay_rounded
                    : Icons.play_circle_outline_rounded,
                label: lesson.status,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFE2B6),
                foregroundColor: const Color(0xFF112032),
              ),
              child: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonQueueCard extends StatelessWidget {
  const _LessonQueueCard({
    required this.lesson,
    required this.onTap,
  });

  final LessonFeedItemModel lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _LessonBaseCard(
      lesson: lesson,
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
      onTap: onTap,
    );
  }
}

class _CompletedLessonCard extends StatelessWidget {
  const _CompletedLessonCard({
    required this.lesson,
    required this.onRetry,
  });

  final LessonFeedItemModel lesson;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _LessonBaseCard(
      lesson: lesson,
      trailing: TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.replay_rounded),
        label: const Text('Retry'),
      ),
      onTap: onRetry,
    );
  }
}

class _LessonBaseCard extends StatelessWidget {
  const _LessonBaseCard({
    required this.lesson,
    required this.trailing,
    required this.onTap,
  });

  final LessonFeedItemModel lesson;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF2B6CB0),
      const Color(0xFF2C7A7B),
      const Color(0xFF805AD5),
      const Color(0xFFEA580C),
      const Color(0xFF0F766E),
    ];
    final gradientSets = [
      [const Color(0xFFFEF3C7), const Color(0xFFF59E0B)],
      [const Color(0xFFD1FAE5), const Color(0xFF10B981)],
      [const Color(0xFFE0E7FF), const Color(0xFF6366F1)],
      [const Color(0xFFFFEDD5), const Color(0xFFEA580C)],
      [const Color(0xFFCCFBF1), const Color(0xFF0F766E)],
    ];
    final icons = [
      Icons.auto_stories_rounded,
      Icons.record_voice_over_rounded,
      Icons.edit_note_rounded,
      Icons.map_rounded,
      Icons.track_changes_rounded,
    ];
    final index = (lesson.slot - 1).clamp(0, colors.length - 1);
    final color = colors[index];
    final gradient = gradientSets[index];
    final icon = icons[index];

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: Icon(
                  lesson.status == 'completed' ? Icons.check_rounded : icon,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.dayLabel,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lesson.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF112032),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lesson.objective,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _ProgressTab extends StatelessWidget {
  const _ProgressTab();

  @override
  Widget build(BuildContext context) {
    final progress = AppScope.of(context).progress;
    if (progress == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        const Text(
          'Progress',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Color(0xFF112032),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Overall score: ${progress.overallScore.toStringAsFixed(1)}% | combined target ${progress.overallThreshold.toStringAsFixed(0)}%',
        ),
        const SizedBox(height: 6),
        Text(
          progress.meetsOverallThreshold
              ? 'Combined progress is on track.'
              : 'Combined progress is below the overall target.',
          style: const TextStyle(color: Color(0xFF526071)),
        ),
        const SizedBox(height: 20),
        Text(
          'Current level: ${progress.currentLevelName}  |  Chapter ${progress.currentChapter}',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF112032),
          ),
        ),
        const SizedBox(height: 14),
        for (final chapter in progress.chapterHistory.take(5)) ...[
          _ChapterCard(chapter: chapter),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 14),
        for (final lesson in progress.lessons) ...[
          _InsightCard(
            title: lesson.title,
            score: lesson.score == null ? null : '${lesson.score!.toStringAsFixed(0)}%',
            summary: lesson.summary,
            longFeedback: lesson.longFeedback,
            whatWentWell: lesson.whatWentWell,
            whatToImprove: lesson.whatToImprove,
            color: const Color(0xFF0F766E),
            focus: lesson.focus,
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final profile = AppScope.of(context).profile;
    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF112032),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFFFFE2B6),
                child: Icon(
                  Icons.person_rounded,
                  color: Color(0xFF112032),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                profile.name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${profile.nativeLanguage} to ${profile.targetLanguage} learner',
                style: const TextStyle(color: Color(0xFFD6DEE8)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _ProfileTile(
          icon: Icons.flag_rounded,
          title: 'Current level',
          subtitle: 'Level ${profile.currentLevelValue} - ${profile.currentLevelName} (${profile.currentLevel})',
        ),
        _ProfileTile(
          icon: Icons.auto_graph_rounded,
          title: 'Current chapter',
          subtitle: 'Level decisions use the combined 5-chapter score: ${profile.overallThreshold.toStringAsFixed(0)}% to advance, below 50% to relegate.',
        ),
        _ProfileTile(
          icon: Icons.track_changes_rounded,
          title: 'Next focus',
          subtitle: profile.nextFocus,
        ),
      ],
    );
  }
}

class _ChapterCard extends StatelessWidget {
  const _ChapterCard({required this.chapter});

  final ChapterProgressModel chapter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1DA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.layers_rounded, color: Color(0xFFD97706)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${chapter.levelName} - Chapter ${chapter.chapter}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF112032),
                  ),
                ),
                const SizedBox(height: 4),
                Text('Score: ${chapter.score.toStringAsFixed(0)}%  |  ${chapter.result}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Icon(icon, color: const Color(0xFF112032)),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.title,
    required this.score,
    required this.summary,
    required this.longFeedback,
    required this.whatWentWell,
    required this.whatToImprove,
    required this.color,
    required this.focus,
  });

  final String title;
  final String? score;
  final String summary;
  final String longFeedback;
  final List<String> whatWentWell;
  final List<String> whatToImprove;
  final Color color;
  final String focus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF112032),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  score ?? 'Pending',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (score != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: double.parse(score!.replaceAll('%', '')) / 100,
                minHeight: 10,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          const SizedBox(height: 14),
          Text(longFeedback.isEmpty ? summary : longFeedback),
          if (whatWentWell.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'What went well',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF112032),
              ),
            ),
            const SizedBox(height: 6),
            for (final item in whatWentWell.take(3)) Text('- $item'),
          ],
          if (whatToImprove.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'What to improve',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF112032),
              ),
            ),
            const SizedBox(height: 6),
            for (final item in whatToImprove.take(3)) Text('- $item'),
          ],
          const SizedBox(height: 12),
          Text(
            'Focus: $focus',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1DA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFFD97706)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF112032),
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
