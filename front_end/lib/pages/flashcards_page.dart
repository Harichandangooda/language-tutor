import 'package:flutter/material.dart';
import 'dart:math';

class FlashcardsPage extends StatelessWidget {
  const FlashcardsPage({super.key});

  final List<Map<String, String>> flashcards = const [
    {'word': 'Hola', 'context': 'Hello (used to greet someone)'},
    {'word': 'Adiós', 'context': 'Goodbye (used when leaving)'},
    {'word': 'Por favor', 'context': 'Please (polite request)'},
    {'word': 'Gracias', 'context': 'Thank you (expressing gratitude)'},
    {'word': 'Sí', 'context': 'Yes (agreement)'},
    {'word': 'No', 'context': 'No (disagreement)'},
    {'word': 'Buenos días', 'context': 'Good morning'},
    {'word': 'Buenas noches', 'context': 'Good night'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flash Cards'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.8,
            ),
            itemCount: flashcards.length,
            itemBuilder: (context, index) {
              return FlipCard(
                front: flashcards[index]['word']!,
                back: flashcards[index]['context']!,
              );
            },
          ),
        ),
      ),
    );
  }
}

class FlipCard extends StatefulWidget {
  final String front;
  final String back;

  const FlipCard({super.key, required this.front, required this.back});

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final isUnder = _animation.value > 0.5;
          final value = _animation.value * pi;
          
          return Transform(
            transform: Matrix4.rotationY(value)..setEntry(3, 2, 0.001),
            alignment: Alignment.center,
            child: isUnder
                ? Transform(
                    transform: Matrix4.rotationY(pi),
                    alignment: Alignment.center,
                    child: _buildCard(widget.back, true),
                  )
                : _buildCard(widget.front, false),
          );
        },
      ),
    );
  }

  Widget _buildCard(String text, bool isBack) {
    return Container(
      decoration: BoxDecoration(
        color: isBack ? Theme.of(context).primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.5),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isBack ? 16 : 24,
            fontWeight: isBack ? FontWeight.w500 : FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
