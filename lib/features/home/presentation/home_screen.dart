import 'package:flutter/material.dart';

import '../../../core/utility/navigation_helper.dart';
import '../../../routes/app_router.dart';
import '../../chat/presentation/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    NavigationHelper.executePendingCallbacks(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat'),
        actions: [
          IconButton(
            tooltip: 'Models',
            onPressed: () =>
                NavigationHelper.navigateTo(context, AppRoutes.models),
            icon: const Icon(Icons.layers),
          ),
        ],
      ),
      drawer: const _LeftDrawer(),
      body: const ChatScreen(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: start new chat
        },
        child: const Icon(Icons.add_comment),
      ),
    );
  }
}

class _LeftDrawer extends StatelessWidget {
  const _LeftDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: const Text('User Name'),
              subtitle: const Text('user@email.com'),
              trailing: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () =>
                    NavigationHelper.navigateTo(context, AppRoutes.settings),
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: 6,
                itemBuilder: (c, i) => ListTile(
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: Text('Chat #$i'),
                  subtitle: const Text('Last message preview...'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: open specific chat
                  },
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              onTap: () =>
                  NavigationHelper.navigateTo(context, AppRoutes.history),
            ),
            ListTile(
              leading: const Icon(Icons.cloud_sync),
              title: const Text('Cloud Sync'),
              onTap: () => NavigationHelper.navigateTo(context, AppRoutes.sync),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () =>
                  NavigationHelper.navigateTo(context, AppRoutes.profile),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
