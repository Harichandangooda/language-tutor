import 'package:flutter/material.dart';

class PrevSpeakingPage extends StatelessWidget {
  const PrevSpeakingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Speaking'),
      ),
      body: Center(
        child: Text('Review material for yesterday\'s speaking.'),
      ),
    );
  }
}
