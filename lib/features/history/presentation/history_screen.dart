import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History'),
        actions: [IconButton(onPressed: (){}, icon: const Icon(Icons.search))],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: 12,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) => ListTile(
          leading: const Icon(Icons.chat_outlined),
          title: Text('Conversation ${i+1}'),
          subtitle: const Text('Preview of the last message...'),
          trailing: const Icon(Icons.chevron_right),
          onTap: (){},
        ),
      ),
    );
  }
}
