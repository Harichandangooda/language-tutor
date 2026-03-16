import 'package:flutter/material.dart';

import '../state/app_controller.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController(
    text: 'hari@example.com',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: 'demo123',
  );
  bool _obscurePassword = true;

  Future<void> _signIn() async {
    FocusScope.of(context).unfocus();
    final controller = AppScope.of(context);
    try {
      await controller.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) {
        return;
      }
      Navigator.pushReplacementNamed(context, '/level_selector');
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.errorMessage ?? 'Login failed')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF112032), Color(0xFF19314C), Color(0xFF2D5B8A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE2B6),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.language_rounded,
                        color: Color(0xFF112032),
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LingoLearn',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Speak with structure, context, and confidence.',
                            style: TextStyle(
                              color: Color(0xFFD6DEE8),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 44),
                const Text(
                  'Your lessons, practice flow, and progress all in one place.',
                  style: TextStyle(
                    fontSize: 34,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'The login flow stays minimal, then the app takes you directly into today\'s learning sequence.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.65,
                    color: Color(0xFFD6DEE8),
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Welcome back',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF112032),
                              ),
                            ),
                          ),
                          _StatusChip(label: 'Demo ready'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Use the seeded demo account for the hackathon flow.',
                        style: TextStyle(
                          height: 1.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text('Email'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'Enter your email',
                          prefixIcon: Icon(Icons.mail_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text('Password'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: Color(0xFFD97706),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Demo credentials are prefilled so you can move straight into the product flow.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isBusy ? null : _signIn,
                          child: Text(controller.isBusy ? 'Logging in...' : 'Login'),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF92400E),
        ),
      ),
    );
  }
}
