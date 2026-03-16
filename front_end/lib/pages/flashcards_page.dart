import 'dart:math';

import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../state/app_controller.dart';

class FlashcardsPage extends StatelessWidget {
  const FlashcardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = AppScope.of(context).flashcards;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F4EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F4EE),
        title: const Text('Flashcards'),
      ),
      body: cards.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.78,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return _FlipCard(card: cards[index]);
              },
            ),
    );
  }
}

class _FlipCard extends StatefulWidget {
  const _FlipCard({required this.card});

  final FlashcardModel card;

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final showBack = _animation.value > 0.5;
          final rotation = _animation.value * pi;

          return Transform(
            transform: Matrix4.rotationY(rotation)..setEntry(3, 2, 0.001),
            alignment: Alignment.center,
            child: showBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(pi),
                    child: _CardFace(
                      title: widget.card.meaning,
                      subtitle: widget.card.example,
                      dark: true,
                    ),
                  )
                : _CardFace(
                    title: widget.card.word,
                    subtitle: widget.card.status,
                    dark: false,
                  ),
          );
        },
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.title,
    required this.subtitle,
    required this.dark,
  });

  final String title;
  final String subtitle;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: dark
            ? const LinearGradient(
                colors: [Color(0xFF112032), Color(0xFF234D74)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: dark ? null : Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120E1A29),
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: dark
                  ? Colors.white.withValues(alpha: 0.14)
                  : const Color(0xFFFFF1DA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              color: dark ? Colors.white : const Color(0xFFD97706),
              size: 20,
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: dark ? 18 : 24,
              fontWeight: FontWeight.w800,
              color: dark ? Colors.white : const Color(0xFF112032),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(
              color: dark
                  ? Colors.white.withValues(alpha: 0.72)
                  : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
