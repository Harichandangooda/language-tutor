import 'package:flutter/material.dart';

import '../state/app_controller.dart';

class LevelSelectorPage extends StatefulWidget {
  const LevelSelectorPage({super.key});

  @override
  State<LevelSelectorPage> createState() => _LevelSelectorPageState();
}

class _LevelSelectorPageState extends State<LevelSelectorPage> {
  double _level = 1;

  static const Map<int, String> _levelNames = {
    1: 'Newbie',
    2: 'Beginner',
    3: 'Intermediate',
    4: 'Advanced',
    5: 'Expert',
  };

  Future<void> _continue() async {
    final controller = AppScope.of(context);
    try {
      await controller.setPlacementLevel(_level.round());
      if (!mounted) {
        return;
      }
      Navigator.pushReplacementNamed(context, '/loading');
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.errorMessage ?? 'Unable to set level')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final current = _level.round();

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF112032), Color(0xFF1E3A5F), Color(0xFFD97706)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Text(
                  'How would you rate your German?',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'For the demo, this resets Hari to chapter 5 of the selected level and generates three fresh lessons for that level.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Level $current',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD97706),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _levelNames[current]!,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF112032),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Slider(
                        value: _level,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: _levelNames[current],
                        onChanged: (value) {
                          setState(() {
                            _level = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _levelNames.entries
                            .map(
                              (entry) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: entry.key == current
                                      ? const Color(0xFFFFE2B6)
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '${entry.key}. ${entry.value}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: entry.key == current
                                        ? const Color(0xFF92400E)
                                        : const Color(0xFF475569),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isBusy ? null : _continue,
                          child: Text(
                            controller.isBusy
                                ? 'Setting level...'
                                : 'Let\'s start!',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
