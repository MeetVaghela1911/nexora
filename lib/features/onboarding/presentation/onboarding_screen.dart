import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/app_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            const Text('Your AI Companion', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Chat with multiple models, keep your history, and sync to the cloud.'),
            const Spacer(),
            FilledButton(onPressed: () => context.go(AppRoutes.login), child: const Text('Login')),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: () => context.go(AppRoutes.signup), child: const Text('Sign Up')),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
