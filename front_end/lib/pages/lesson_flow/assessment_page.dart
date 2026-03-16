import 'package:flutter/material.dart';

class AssessmentPage extends StatelessWidget {
  const AssessmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Question Area
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Question 1 of 5',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber, // Using amber to match theme
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Translate this sentence:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '"Me llamo Ana."',
                      style: TextStyle(
                        fontSize: 22,
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Mock Input Options
                    _buildOption(context, 'My name is Ana.', isSelected: true),
                    const SizedBox(height: 12),
                    _buildOption(context, 'I live in Ana.'),
                    const SizedBox(height: 12),
                    _buildOption(context, 'Hello Ana.'),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  // Finish and go back to dashboard
                  Navigator.popUntil(context, ModalRoute.withName('/dashboard'));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Differentiate primary success action
                  foregroundColor: Colors.white,
                ),
                child: const Text('Verify & Finish'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, String text, {bool isSelected = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.2) : Colors.white,
        border: Border.all(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.black87 : Colors.black54,
        ),
      ),
    );
  }
}
