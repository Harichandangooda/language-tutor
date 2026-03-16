import 'package:flutter/material.dart';

class PrevReadingPage extends StatelessWidget {
  const PrevReadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Reading'),
      ),
      body: Center(
        child: Text('Review material for yesterday\'s reading.'),
      ),
    );
  }
}
