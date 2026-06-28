import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../core/service/firestore_chat_service.dart';

/// Widget that displays the current sync status (cloud or local)
class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestoreService = _getFirestoreService();
    final isAuthenticated = firestoreService?.isAuthenticated ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAuthenticated
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAuthenticated
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAuthenticated ? Icons.cloud_done : Icons.storage,
            size: 14,
            color: isAuthenticated ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            isAuthenticated ? 'Cloud Sync' : 'Local Only',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isAuthenticated ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  FirestoreChatService? _getFirestoreService() {
    try {
      return GetIt.instance<FirestoreChatService>();
    } catch (e) {
      return null;
    }
  }
}

/// Compact version for app bar
class SyncStatusBadge extends StatelessWidget {
  const SyncStatusBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestoreService = _getFirestoreService();
    final isAuthenticated = firestoreService?.isAuthenticated ?? false;

    return Tooltip(
      message: isAuthenticated
          ? 'Syncing with cloud storage'
          : 'Using local storage only',
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isAuthenticated
              ? Colors.green.withOpacity(0.15)
              : Colors.grey.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isAuthenticated ? Icons.cloud_done : Icons.storage,
          size: 16,
          color: isAuthenticated ? Colors.green : Colors.grey,
        ),
      ),
    );
  }

  FirestoreChatService? _getFirestoreService() {
    try {
      return GetIt.instance<FirestoreChatService>();
    } catch (e) {
      return null;
    }
  }
}

/// Detailed sync status card for settings/sync screen
class SyncStatusCard extends StatelessWidget {
  final VoidCallback? onSyncNow;

  const SyncStatusCard({Key? key, this.onSyncNow}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestoreService = _getFirestoreService();
    final isAuthenticated = firestoreService?.isAuthenticated ?? false;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isAuthenticated ? Icons.cloud_done : Icons.cloud_off,
                  color: isAuthenticated ? Colors.green : Colors.orange,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAuthenticated
                            ? 'Cloud Sync Active'
                            : 'Local Storage Only',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAuthenticated
                            ? 'Your chats are syncing with cloud storage'
                            : 'Sign in to sync chats across devices',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isAuthenticated && onSyncNow != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onSyncNow,
                  icon: const Icon(Icons.sync, size: 18),
                  label: const Text('Sync Now'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  FirestoreChatService? _getFirestoreService() {
    try {
      return GetIt.instance<FirestoreChatService>();
    } catch (e) {
      return null;
    }
  }
}
