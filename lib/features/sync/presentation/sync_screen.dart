import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../core/local_storage/hive/chat_storage_service.dart';
import '../../../core/service/firestore_chat_service.dart';
import '../../../core/service/firestore_debug_helper.dart';
import '../../../core/utility/MyInstanc.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  bool _isSyncing = false;
  String _syncStatus = '';
  int _localChatCount = 0;
  int _cloudChatCount = 0;

  @override
  void initState() {
    super.initState();
    _loadChatCounts();
  }

  Future<void> _loadChatCounts() async {
    // Load local chat count
    final localChats = ChatStorageService.getAllChats();
    setState(() {
      _localChatCount = localChats.length;
    });

    // Load cloud chat count if authenticated
    try {
      final firestoreService = getIt<FirestoreChatService>();
      if (firestoreService.isAuthenticated) {
        final cloudChats = await firestoreService.getAllChats();
        setState(() {
          _cloudChatCount = cloudChats.length;
        });
      }
    } catch (e) {
      // Service not available or not authenticated
    }
  }

  Future<void> _syncNow() async {
    setState(() {
      _isSyncing = true;
      _syncStatus = 'Syncing...';
    });

    try {
      await ChatStorageService.syncBidirectional();
      setState(() {
        _syncStatus = 'Sync completed successfully!';
      });
      await _loadChatCounts();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sync completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _syncStatus = 'Sync failed: $e';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  Future<void> _restoreFromCloud() async {
    setState(() {
      _isSyncing = true;
      _syncStatus = 'Restoring from cloud...';
    });

    try {
      await ChatStorageService.syncFromCloud();
      setState(() {
        _syncStatus = 'Restore completed successfully!';
      });
      await _loadChatCounts();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restored from cloud successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _syncStatus = 'Restore failed: $e';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  Future<void> _uploadToCloud() async {
    setState(() {
      _isSyncing = true;
      _syncStatus = 'Uploading to cloud...';
    });

    try {
      await ChatStorageService.syncAllToCloud();
      setState(() {
        _syncStatus = 'Upload completed successfully!';
      });
      await _loadChatCounts();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uploaded to cloud successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _syncStatus = 'Upload failed: $e';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = () {
      try {
        return getIt<FirestoreChatService>().isAuthenticated;
      } catch (e) {
        return false;
      }
    }();

    return Scaffold(
      appBar: AppBar(title: const Text('Cloud Sync')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isAuthenticated)
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Please sign in to use cloud sync',
                          style: TextStyle(color: Colors.orange.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.storage),
                title: const Text('Local Chats'),
                subtitle: Text('$_localChatCount conversations'),
                trailing: const Icon(Icons.check_circle_outline),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.cloud),
                title: const Text('Cloud Chats'),
                subtitle: Text(
                  isAuthenticated
                      ? '$_cloudChatCount conversations'
                      : 'Sign in required',
                ),
                trailing: Icon(
                  isAuthenticated ? Icons.cloud_done : Icons.cloud_off,
                ),
              ),
            ),
            if (_syncStatus.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                color: _syncStatus.contains('failed')
                    ? Colors.red.shade50
                    : Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      if (_isSyncing)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Icon(
                          _syncStatus.contains('failed')
                              ? Icons.error_outline
                              : Icons.check_circle_outline,
                          color: _syncStatus.contains('failed')
                              ? Colors.red
                              : Colors.green,
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _syncStatus,
                          style: TextStyle(
                            color: _syncStatus.contains('failed')
                                ? Colors.red.shade700
                                : Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isSyncing || !isAuthenticated ? null : _syncNow,
              icon: _isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.sync),
              label: const Text('Sync Now (Bidirectional)'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _isSyncing || !isAuthenticated ? null : _uploadToCloud,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Upload to Cloud'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _isSyncing || !isAuthenticated ? null : _restoreFromCloud,
                    icon: const Icon(Icons.cloud_download),
                    label: const Text('Restore from Cloud'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                await FirestoreDebugHelper.checkFirestoreSetup();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Check console for debug information'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              icon: const Icon(Icons.bug_report),
              label: const Text('Debug Firestore Setup'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                await FirestoreDebugHelper.testWriteToFirestore();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Check console for test results'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              icon: const Icon(Icons.science),
              label: const Text('Test Firestore Write'),
            ),
            const SizedBox(height: 16),
            Text(
              'Note: Sync operations will merge local and cloud data. '
              'Newer data takes precedence in case of conflicts.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
