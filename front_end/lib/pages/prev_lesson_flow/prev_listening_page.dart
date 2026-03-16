import 'package:flutter/material.dart';

class PrevListeningPage extends StatelessWidget {
  const PrevListeningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Listening'),
      ),
      body: Center(
        child: Text('Review material for yesterday\'s listening.'),
      ),
    );
  }
}
