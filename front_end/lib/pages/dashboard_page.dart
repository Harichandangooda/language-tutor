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
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Doubt Clearance',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF112032),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'This stays as a frontend placeholder for now. The lesson, progress, profile, and flashcard flows are connected to the backend.',
                style: TextStyle(
                  height: 1.6,
                  color: Color(0xFF526071),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LessonsTab extends StatelessWidget {
  const _LessonsTab({required this.onDoubts});

  final VoidCallback onDoubts;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final lessons = controller.lessons;
    final today = lessons.isNotEmpty
        ? lessons.firstWhere(
            (item) => item.isToday,
            orElse: () => lessons.first,
          )
        : null;
    final previousLessons = lessons.where((item) => item.lessonId != today?.lessonId).toList();

    return RefreshIndicator(
      onRefresh: controller.refreshAppData,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
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
                                  ? 'Build fluency with three guided German lessons.'
                                  : 'Chapter ${controller.profile!.currentChapter}: finish the capstone and try to unlock the next level.',
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
                  const SizedBox(height: 18),
                  if (today != null) _TodayCard(lesson: today),
                  const SizedBox(height: 24),
                  const Text(
                    'Previous lessons',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF112032),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'The backend now owns exactly three demo lessons and this feed reflects them directly.',
                    style: TextStyle(height: 1.5),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverList.builder(
              itemCount: previousLessons.length,
              itemBuilder: (context, index) {
                final lesson = previousLessons[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _LessonListCard(lesson: lesson),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.lesson});

  final LessonFeedItemModel lesson;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);

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
                icon: Icons.check_circle_outline_rounded,
                label: lesson.status,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                controller.selectLesson(lesson.lessonId);
                Navigator.pushNamed(context, '/lesson/reading');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFE2B6),
                foregroundColor: const Color(0xFF112032),
              ),
              child: const Text('Start learning'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonListCard extends StatelessWidget {
  const _LessonListCard({required this.lesson});

  final LessonFeedItemModel lesson;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final colors = [
      const Color(0xFF2B6CB0),
      const Color(0xFF2C7A7B),
      const Color(0xFF805AD5),
    ];
    final color = colors[(lesson.slot - 1).clamp(0, colors.length - 1)];

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        controller.selectLesson(lesson.lessonId);
        Navigator.pushNamed(context, '/lesson/reading');
      },
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                lesson.status == 'completed' ? Icons.check_rounded : Icons.play_arrow_rounded,
                color: color,
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
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
            ),
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
          'Overall score: ${progress.overallScore.toStringAsFixed(1)}%',
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
          subtitle: 'Chapter ${profile.currentChapter} with ${profile.promotionThreshold.toStringAsFixed(0)}% needed to promote',
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
    required this.color,
    required this.focus,
  });

  final String title;
  final String? score;
  final String summary;
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
          Text(summary),
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
