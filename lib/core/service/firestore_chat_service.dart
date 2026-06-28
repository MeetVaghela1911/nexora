import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../local_storage/hive/chat_models.dart';

/// Service for syncing chat data with Firestore cloud storage
class FirestoreChatService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreChatService(this._firestore, this._auth);

  /// Get the current user ID
  String? get _userId {
    final user = _auth.currentUser;
    if (user == null) {
      print('[FirestoreChat] ⚠️ No current user found');
      return null;
    }
    return user.uid;
  }

  /// Get the user's chats collection path
  String? get _chatsCollectionPath {
    final userId = _userId;
    if (userId == null) return null;
    return 'users/$userId/chats';
  }

  /// Get the messages subcollection path for a chat
  String? _messagesCollectionPath(String chatId) {
    final userId = _userId;
    if (userId == null) return null;
    return 'users/$userId/chats/$chatId/messages';
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _userId != null;

  /// Create or update a chat in Firestore
  Future<void> createOrUpdateChat(Chat chat) async {
    if (!isAuthenticated) {
      print('[FirestoreChat] ❌ User not authenticated, skipping sync');
      print('[FirestoreChat] Current user: ${_auth.currentUser?.uid ?? "null"}');
      return;
    }

    final userId = _userId;
    final path = _chatsCollectionPath;
    
    if (userId == null || path == null) {
      print('[FirestoreChat] ❌ Cannot sync: userId or path is null');
      print('[FirestoreChat] User ID: $userId');
      print('[FirestoreChat] Path: $path');
      return;
    }
    
    print('[FirestoreChat] 🔄 Syncing chat to Firestore...');
    print('[FirestoreChat] User ID: $userId');
    print('[FirestoreChat] Collection path: $path');
    print('[FirestoreChat] Chat ID: ${chat.id}');
    print('[FirestoreChat] Chat title: ${chat.title}');

    try {
      final chatData = {
        'id': chat.id,
        'title': chat.title,
        'createdAt': Timestamp.fromDate(chat.createdAt),
        'updatedAt': Timestamp.fromDate(chat.updatedAt),
        'modelUsed': chat.modelUsed,
      };
      
      print('[FirestoreChat] Chat data: $chatData');
      
      await _firestore
          .collection(path)
          .doc(chat.id)
          .set(chatData, SetOptions(merge: true));

      print('[FirestoreChat] ✅ Successfully synced chat: ${chat.id} - "${chat.title}"');
    }
    catch (e, stackTrace) {
      print('[FirestoreChat] ❌ Error syncing chat ${chat.id}: $e');
      print('[FirestoreChat] Stack trace: $stackTrace');
      print('[FirestoreChat] Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  /// Delete a chat from Firestore
  Future<void> deleteChat(String chatId) async {
    if (!isAuthenticated) {
      print('[FirestoreChat] User not authenticated, skipping delete');
      return;
    }

    final messagesPath = _messagesCollectionPath(chatId);
    final chatsPath = _chatsCollectionPath;
    
    if (messagesPath == null || chatsPath == null) {
      print('[FirestoreChat] ❌ Cannot delete: paths are null');
      return;
    }

    try {
      // Delete all messages first
      final messagesSnapshot = await _firestore
          .collection(messagesPath)
          .get();

      final batch = _firestore.batch();
      for (var doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete the chat document
      batch.delete(
        _firestore.collection(chatsPath).doc(chatId),
      );

      await batch.commit();
      print('[FirestoreChat] ✅ Deleted chat: $chatId');
    } catch (e) {
      print('[FirestoreChat] ❌ Error deleting chat $chatId: $e');
      rethrow;
    }
  }

  /// Add or update a message in Firestore
  Future<void> addOrUpdateMessage(ChatMessage message) async {
    if (!isAuthenticated) {
      print('[FirestoreChat] ❌ User not authenticated, skipping sync');
      print('[FirestoreChat] Current user: ${_auth.currentUser?.uid ?? "null"}');
      return;
    }

    final userId = _userId;
    final path = _messagesCollectionPath(message.chatId);
    
    if (userId == null || path == null) {
      print('[FirestoreChat] ❌ Cannot sync: userId or path is null');
      print('[FirestoreChat] User ID: $userId');
      print('[FirestoreChat] Path: $path');
      return;
    }
    
    print('[FirestoreChat] 🔄 Syncing message to Firestore...');
    print('[FirestoreChat] User ID: $userId');
    print('[FirestoreChat] Messages path: $path');
    print('[FirestoreChat] Message ID: ${message.id}');
    print('[FirestoreChat] Chat ID: ${message.chatId}');
    print('[FirestoreChat] Role: ${message.role}');

    try {
      final messageData = {
        'id': message.id,
        'chatId': message.chatId,
        'role': message.role,
        'content': message.content,
        'timestamp': Timestamp.fromDate(message.timestamp),
        'isThinking': message.isThinking,
      };
      
      print('[FirestoreChat] Message data length: ${message.content.length} chars');
      
      await _firestore
          .collection(path)
          .doc(message.id)
          .set(messageData, SetOptions(merge: true));

      print(
        '[FirestoreChat] ✅ Successfully synced message: ${message.id} (${message.role})',
      );
    } catch (e, stackTrace) {
      print('[FirestoreChat] ❌ Error syncing message ${message.id}: $e');
      print('[FirestoreChat] Stack trace: $stackTrace');
      print('[FirestoreChat] Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  /// Get all chats from Firestore for the current user
  Future<List<Chat>> getAllChats() async {
    if (!isAuthenticated) {
      print('[FirestoreChat] User not authenticated');
      return [];
    }

    final path = _chatsCollectionPath;
    if (path == null) {
      print('[FirestoreChat] ❌ Cannot get chats: path is null');
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection(path)
          .orderBy('updatedAt', descending: true)
          .get();

      final chats = snapshot.docs.map((doc) {
        final data = doc.data();
        return Chat(
          id: data['id'] as String,
          title: data['title'] as String,
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          updatedAt: (data['updatedAt'] as Timestamp).toDate(),
          modelUsed: data['modelUsed'] as String?,
        );
      }).toList();

      print('[FirestoreChat] ✅ Loaded ${chats.length} chats from cloud');
      return chats;
    } catch (e) {
      print('[FirestoreChat] ❌ Error loading chats: $e');
      return [];
    }
  }

  /// Get all messages for a specific chat from Firestore
  Future<List<ChatMessage>> getMessagesForChat(String chatId) async {
    if (!isAuthenticated) {
      print('[FirestoreChat] User not authenticated');
      return [];
    }

    final path = _messagesCollectionPath(chatId);
    if (path == null) {
      print('[FirestoreChat] ❌ Cannot get messages: path is null');
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection(path)
          .orderBy('timestamp', descending: false)
          .get();

      final messages = snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatMessage(
          id: data['id'] as String,
          chatId: data['chatId'] as String,
          role: data['role'] as String,
          content: data['content'] as String,
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          isThinking: data['isThinking'] as bool? ?? false,
        );
      }).toList();

      print(
        '[FirestoreChat] ✅ Loaded ${messages.length} messages for chat: $chatId',
      );
      return messages;
    } catch (e) {
      print('[FirestoreChat] ❌ Error loading messages: $e');
      return [];
    }
  }

  /// Sync all local chats to Firestore
  Future<void> syncAllChatsToCloud(List<Chat> localChats) async {
    if (!isAuthenticated) {
      print('[FirestoreChat] User not authenticated, skipping sync');
      return;
    }

    final path = _chatsCollectionPath;
    if (path == null) {
      print('[FirestoreChat] ❌ Cannot sync chats: path is null');
      return;
    }

    try {
      print('[FirestoreChat] 🔄 Starting sync of ${localChats.length} chats...');
      final batch = _firestore.batch();

      for (var chat in localChats) {
        final chatRef = _firestore
            .collection(path)
            .doc(chat.id);

        batch.set(chatRef, {
          'id': chat.id,
          'title': chat.title,
          'createdAt': Timestamp.fromDate(chat.createdAt),
          'updatedAt': Timestamp.fromDate(chat.updatedAt),
          'modelUsed': chat.modelUsed,
        }, SetOptions(merge: true));
      }

      await batch.commit();
      print('[FirestoreChat] ✅ Synced ${localChats.length} chats to cloud');
    } catch (e) {
      print('[FirestoreChat] ❌ Error syncing chats to cloud: $e');
      rethrow;
    }
  }

  /// Sync all messages for a chat to Firestore
  Future<void> syncMessagesToCloud(
    String chatId,
    List<ChatMessage> messages,
  ) async {
    if (!isAuthenticated) {
      print('[FirestoreChat] User not authenticated, skipping sync');
      return;
    }

    final path = _messagesCollectionPath(chatId);
    if (path == null) {
      print('[FirestoreChat] ❌ Cannot sync messages: path is null');
      return;
    }

    try {
      print(
        '[FirestoreChat] 🔄 Starting sync of ${messages.length} messages for chat: $chatId',
      );
      final batch = _firestore.batch();

      for (var message in messages) {
        final messageRef = _firestore
            .collection(path)
            .doc(message.id);

        batch.set(messageRef, {
          'id': message.id,
          'chatId': message.chatId,
          'role': message.role,
          'content': message.content,
          'timestamp': Timestamp.fromDate(message.timestamp),
          'isThinking': message.isThinking,
        }, SetOptions(merge: true));
      }

      await batch.commit();
      print(
        '[FirestoreChat] ✅ Synced ${messages.length} messages to cloud for chat: $chatId',
      );
    } catch (e) {
      print('[FirestoreChat] ❌ Error syncing messages to cloud: $e');
      rethrow;
    }
  }

  /// Download all chats from Firestore and return them
  /// This is useful for syncing cloud data to local storage
  Future<List<Chat>> downloadAllChats() async {
    return await getAllChats();
  }

  /// Download all messages for a chat from Firestore
  Future<List<ChatMessage>> downloadMessagesForChat(String chatId) async {
    return await getMessagesForChat(chatId);
  }

  /// Stream of chats for real-time updates
  Stream<List<Chat>> watchChats() {
    if (!isAuthenticated) {
      return Stream.value([]);
    }

    final path = _chatsCollectionPath;
    if (path == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(path)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Chat(
          id: data['id'] as String,
          title: data['title'] as String,
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          updatedAt: (data['updatedAt'] as Timestamp).toDate(),
          modelUsed: data['modelUsed'] as String?,
        );
      }).toList();
    });
  }

  /// Stream of messages for a specific chat (real-time updates)
  Stream<List<ChatMessage>> watchMessages(String chatId) {
    if (!isAuthenticated) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_messagesCollectionPath(chatId) ?? '')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatMessage(
          id: data['id'] as String,
          chatId: data['chatId'] as String,
          role: data['role'] as String,
          content: data['content'] as String,
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          isThinking: data['isThinking'] as bool? ?? false,
        );
      }).toList();
    });
  }
}

