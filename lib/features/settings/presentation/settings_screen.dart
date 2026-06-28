import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(title: const Text('Notifications'), value: true, onChanged: (_){}),
          ListTile(title: const Text('Language'), subtitle: const Text('English'), onTap: (){}),
          ListTile(title: const Text('Clear Local Chats'), onTap: (){}),
          ListTile(title: const Text('Sync with Cloud'), onTap: (){}),
        ],
      ),
    );
  }
}
