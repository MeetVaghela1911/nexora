import 'package:flutter/material.dart';

class EmptyErrorScreen extends StatelessWidget {
  const EmptyErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isError = ModalRoute.of(context)?.settings.arguments == 'error';
    return Scaffold(
      appBar: AppBar(title: Text(isError ? 'Error' : 'Nothing here')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isError ? Icons.error_outline : Icons.inbox, size: 64),
            const SizedBox(height: 16),
            Text(isError ? 'Something went wrong' : 'No content yet'),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => Navigator.of(context).maybePop(), child: const Text('Go Back')),
          ],
        ),
      ),
    );
  }
}
