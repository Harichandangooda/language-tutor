import 'package:flutter/material.dart';

class PrevWritingPage extends StatelessWidget {
  const PrevWritingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Writing'),
      ),
      body: Center(
        child: Text('Review material for yesterday\'s writing.'),
      ),
    );
  }
}
