import 'package:flutter/material.dart';

class LessonShell extends StatelessWidget {
  const LessonShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.stepLabel,
    required this.progress,
    required this.accentColor,
    required this.body,
    this.previousRoute,
    this.nextRoute,
    this.nextLabel = 'Next',
    this.onNext,
  });

  final String title;
  final String subtitle;
  final String stepLabel;
  final double progress;
  final Color accentColor;
  final Widget body;
  final String? previousRoute;
  final String? nextRoute;
  final String nextLabel;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4EE),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _CircleAction(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.maybePop(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stepLabel,
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF112032),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color(0xFF546173),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFDAD5C8),
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFCF5),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: body,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Row(
                children: [
                  if (previousRoute != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          previousRoute!,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF112032),
                          side: const BorderSide(color: Color(0xFFCBD4E0)),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text('Prev'),
                      ),
                    ),
                  if (previousRoute != null) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onNext ??
                          () {
                            if (nextRoute != null) {
                              Navigator.pushReplacementNamed(context, nextRoute!);
                            }
                          },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(nextLabel),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120E1A29),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class MarkdownSection extends StatelessWidget {
  const MarkdownSection({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  final String eyebrow;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return LessonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow.toUpperCase(),
            style: const TextStyle(
              letterSpacing: 1.2,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFFB7791F),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF112032),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            body,
            style: const TextStyle(
              fontSize: 15,
              height: 1.8,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, required this.onTap});

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
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: const Color(0xFF112032),
          ),
        ),
      ),
    );
  }
}
