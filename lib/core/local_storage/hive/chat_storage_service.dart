// // import 'package:hive/hive.dart';
// // import 'package:nexora/core/local_storage/hive/chat_models.dart';
// // import 'package:uuid/uuid.dart';
// //
// // class ChatStorageService {
// //   static const String _chatsBox = 'chats_box';
// //   static const String _messagesBox = 'messages_box';
// //   static const String _currentChatKey = 'current_chat_id';
// //
// //   static final Uuid _uuid = Uuid();
// //
// //   static Future<void> init() async {
// //     await Hive.openBox<Chat>(_chatsBox);
// //     await Hive.openBox<ChatMessage>(_messagesBox);
// //   }
// //
// //   // Chat operations
// //   static Future<Chat> createNewChat({String? initialTitle, String? modelUsed}) async {
// //     final chatsBox = Hive.box<Chat>(_chatsBox);
// //     final messagesBox = Hive.box<ChatMessage>(_messagesBox);
// //
// //     final chatId = _uuid.v4();
// //     final now = DateTime.now();
// //
// //     final chat = Chat(
// //       id: chatId,
// //       title: initialTitle ?? 'New Chat',
// //       createdAt: now,
// //       updatedAt: now,
// //       modelUsed: modelUsed,
// //     );
// //
// //     await chatsBox.put(chatId, chat);
// //
// //     // Set as current chat
// //     await Hive.box('settings').put(_currentChatKey, chatId);
// //
// //     return chat;
// //   }
// //
// //   static Future<void> updateChatTitle(String chatId, String newTitle) async {
// //     final chatsBox = Hive.box<Chat>(_chatsBox);
// //     final chat = chatsBox.get(chatId);
// //
// //     if (chat != null) {
// //       chat.title = newTitle;
// //       chat.updatedAt = DateTime.now();
// //       await chat.save();
// //     }
// //   }
// //
// //   static Future<void> deleteChat(String chatId) async {
// //     final chatsBox = Hive.box<Chat>(_chatsBox);
// //     final messagesBox = Hive.box<ChatMessage>(_messagesBox);
// //
// //     // Delete all messages in this chat
// //     final messagesToDelete = messagesBox.values
// //         .where((message) => message.chatId == chatId)
// //         .map((message) => message.key)
// //         .toList();
// //
// //     await messagesBox.deleteAll(messagesToDelete);
// //
// //     // Delete the chat
// //     await chatsBox.delete(chatId);
// //
// //     // If this was the current chat, clear current chat
// //     final currentChatId = await getCurrentChatId();
// //     if (currentChatId == chatId) {
// //       await Hive.box('settings').delete(_currentChatKey);
// //     }
// //   }
// //
// //   static Future<String?> getCurrentChatId() async {
// //     return Hive.box('settings').get(_currentChatKey);
// //   }
// //
// //   static Future<void> setCurrentChatId(String chatId) async {
// //     await Hive.box('settings').put(_currentChatKey, chatId);
// //   }
// //
// //   static Chat? getCurrentChat() {
// //     final currentChatId = Hive.box('settings').get(_currentChatKey);
// //     if (currentChatId == null) return null;
// //
// //     final chatsBox = Hive.box<Chat>(_chatsBox);
// //     return chatsBox.get(currentChatId);
// //   }
// //
// //   // Message operations
// //   static Future<ChatMessage> addMessage({
// //     required String chatId,
// //     required String role,
// //     required String content,
// //     bool isThinking = false,
// //   }) async {
// //     final messagesBox = Hive.box<ChatMessage>(_messagesBox);
// //     final chatsBox = Hive.box<Chat>(_chatsBox);
// //
// //     final message = ChatMessage(
// //       id: _uuid.v4(),
// //       chatId: chatId,
// //       role: role,
// //       content: content,
// //       timestamp: DateTime.now(),
// //       isThinking: isThinking,
// //     );
// //
// //     await messagesBox.put(message.id, message);
// //
// //     // Update chat's updatedAt timestamp
// //     final chat = chatsBox.get(chatId);
// //     if (chat != null) {
// //       chat.updatedAt = DateTime.now();
// //
// //       // Auto-generate title from first user message if it's still "New Chat"
// //       if (chat.title == 'New Chat' && role == 'user') {
// //         chat.title = _generateTitleFromMessage(content);
// //       }
// //
// //       await chat.save();
// //     }
// //
// //     return message;
// //   }
// //
// //   static Future<void> updateMessageThinkingStatus(String messageId, bool isThinking) async {
// //     final messagesBox = Hive.box<ChatMessage>(_messagesBox);
// //     final message = messagesBox.get(messageId);
// //
// //     if (message != null) {
// //       // message.isThinking = isThinking;
// //       // await message.save();
// //     }
// //   }
// //
// //   static List<ChatMessage> getMessagesForChat(String chatId) {
// //     final messagesBox = Hive.box<ChatMessage>(_messagesBox);
// //
// //     return messagesBox.values
// //         .where((message) => message.chatId == chatId)
// //         .toList()
// //       ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
// //   }
// //
// //   // History operations
// //   static List<Chat> getAllChats() {
// //     final chatsBox = Hive.box<Chat>(_chatsBox);
// //
// //     return chatsBox.values.toList()
// //       ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
// //   }
// //
// //   static List<Chat> searchChats(String query) {
// //     final chatsBox = Hive.box<Chat>(_chatsBox);
// //     final messagesBox = Hive.box<ChatMessage>(_messagesBox);
// //
// //     final lowerQuery = query.toLowerCase();
// //
// //     return chatsBox.values.where((chat) {
// //       // Search in chat title
// //       if (chat.title.toLowerCase().contains(lowerQuery)) {
// //         return true;
// //       }
// //
// //       // Search in chat messages
// //       final chatMessages = messagesBox.values
// //           .where((message) => message.chatId == chat.id)
// //           .toList();
// //
// //       return chatMessages.any((message) =>
// //           message.content.toLowerCase().contains(lowerQuery));
// //     }).toList()
// //       ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
// //   }
// //
// //   static List<ChatMessage> searchInChat(String chatId, String query) {
// //     final messagesBox = Hive.box<ChatMessage>(_messagesBox);
// //     final lowerQuery = query.toLowerCase();
// //
// //     return messagesBox.values
// //         .where((message) =>
// //     message.chatId == chatId &&
// //         message.content.toLowerCase().contains(lowerQuery))
// //         .toList()
// //       ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
// //   }
// //
// //   // Helper methods
// //   static String _generateTitleFromMessage(String message) {
// //     final words = message.trim().split(' ');
// //     if (words.length <= 5) {
// //       return message;
// //     }
// //     return '${words.take(5).join(' ')}...';
// //   }
// //
// //   static Future<void> clearAllData() async {
// //     final chatsBox = Hive.box<Chat>(_chatsBox);
// //     final messagesBox = Hive.box<ChatMessage>(_messagesBox);
// //     final settingsBox = Hive.box('settings');
// //
// //     await chatsBox.clear();
// //     await messagesBox.clear();
// //     await settingsBox.clear();
// //   }
// //
// //   // Add this method to your ChatStorageService class
// //   static Future<void> updateMessageContent(String messageId, String newContent) async {
// //     final messagesBox = Hive.box<ChatMessage>(_messagesBox);
// //     final message = messagesBox.get(messageId);
// //
// //     if (message != null) {
// //       // Since ChatMessage fields are final, we need to replace the message
// //       final updatedMessage = ChatMessage(
// //         id: message.id,
// //         chatId: message.chatId,
// //         role: message.role,
// //         content: newContent,
// //         timestamp: message.timestamp,
// //         isThinking: message.isThinking,
// //       );
// //
// //       await messagesBox.put(messageId, updatedMessage);
// //     }
// //   }
// //
// //
// // }
// import 'package:hive/hive.dart';
// import 'package:nexora/core/local_storage/hive/chat_models.dart';
// import 'package:uuid/uuid.dart';

// class ChatStorageService {
//   static const String _chatsBox = 'chats_box';
//   static const String _messagesBox = 'messages_box';
//   static const String _settingsBox = 'settings_box'; // Changed to avoid conflicts
//   static const String _currentChatKey = 'current_chat_id';

//   static final Uuid _uuid = Uuid();

//   static bool _isInitialized = false;

//   static Future<void> init() async {
//     if (_isInitialized) return;

//     // Register adapters first
//     if (!Hive.isAdapterRegistered(0)) {
//       Hive.registerAdapter(ChatAdapter());
//     }
//     if (!Hive.isAdapterRegistered(1)) {
//       Hive.registerAdapter(ChatMessageAdapter());
//     }

//     // Open all boxes
//     await Hive.openBox<Chat>(_chatsBox);
//     await Hive.openBox<ChatMessage>(_messagesBox);
//     await Hive.openBox(_settingsBox); // Open settings box

//     _isInitialized = true;
//     print('Hive storage initialized successfully');
//   }

//   // Helper method to ensure initialization
//   static Future<void> _ensureInitialized() async {
//     if (!_isInitialized) {
//       await init();
//     }
//   }

//   // Chat operations
//   static Future<Chat> createNewChat({String? initialTitle, String? modelUsed}) async {
//     await _ensureInitialized();
//     final chatsBox = Hive.box<Chat>(_chatsBox);
//     final now = DateTime.now();

//     final chat = Chat(
//       id: _uuid.v4(),
//       title: initialTitle ?? 'New Chat',
//       createdAt: now,
//       updatedAt: now,
//       modelUsed: modelUsed,
//     );

//     await chatsBox.put(chat.id, chat);

//     // Set as current chat
//     await setCurrentChatId(chat.id);

//     return chat;
//   }

//   static Future<void> updateChatTitle(String chatId, String newTitle) async {
//     await _ensureInitialized();
//     final chatsBox = Hive.box<Chat>(_chatsBox);
//     final chat = chatsBox.get(chatId);

//     if (chat != null) {
//       chat.title = newTitle;
//       chat.updatedAt = DateTime.now();
//       await chatsBox.put(chatId, chat);
//     }
//   }

//   static Future<void> deleteChat(String chatId) async {
//     await _ensureInitialized();
//     final chatsBox = Hive.box<Chat>(_chatsBox);
//     final messagesBox = Hive.box<ChatMessage>(_messagesBox);

//     // Delete all messages in this chat
//     final messageKeys = messagesBox.values
//         .where((message) => message.chatId == chatId)
//         .map((message) => message.key)
//         .toList();

//     await messagesBox.deleteAll(messageKeys);

//     // Delete the chat
//     await chatsBox.delete(chatId);

//     // If this was the current chat, clear current chat
//     final currentChatId = await getCurrentChatId();
//     if (currentChatId == chatId) {
//       await Hive.box(_settingsBox).delete(_currentChatKey);
//     }
//   }

//   static Future<String?> getCurrentChatId() async {
//     await _ensureInitialized();
//     return Hive.box(_settingsBox).get(_currentChatKey);
//   }

//   static Future<void> setCurrentChatId(String chatId) async {
//     await _ensureInitialized();
//     await Hive.box(_settingsBox).put(_currentChatKey, chatId);
//   }

//   static Future<Chat?> getCurrentChat() async {
//     await _ensureInitialized();
//     final currentChatId = await getCurrentChatId();
//     if (currentChatId == null) return null;

//     final chatsBox = Hive.box<Chat>(_chatsBox);
//     return chatsBox.get(currentChatId);
//   }

//   // Message operations
//   static Future<ChatMessage> addMessage({
//     required String chatId,
//     required String role,
//     required String content,
//     bool isThinking = false,
//   }) async {
//     await _ensureInitialized();
//     final messagesBox = Hive.box<ChatMessage>(_messagesBox);
//     final chatsBox = Hive.box<Chat>(_chatsBox);

//     final message = ChatMessage(
//       id: _uuid.v4(),
//       chatId: chatId,
//       role: role,
//       content: content,
//       timestamp: DateTime.now(),
//       isThinking: isThinking,
//     );

//     await messagesBox.put(message.id, message);

//     // Update chat's updatedAt timestamp
//     final chat = chatsBox.get(chatId);
//     if (chat != null) {
//       chat.updatedAt = DateTime.now();

//       // Auto-generate title from first user message if it's still "New Chat"
//       if (chat.title == 'New Chat' && role == 'user') {
//         chat.title = _generateTitleFromMessage(content);
//       }

//       await chatsBox.put(chatId, chat);
//     }

//     return message;
//   }

//   static Future<void> updateMessageContent(String messageId, String newContent) async {
//     await _ensureInitialized();
//     final messagesBox = Hive.box<ChatMessage>(_messagesBox);
//     final message = messagesBox.get(messageId);

//     if (message != null) {
//       // Since ChatMessage fields are final, we need to replace the message
//       final updatedMessage = ChatMessage(
//         id: message.id,
//         chatId: message.chatId,
//         role: message.role,
//         content: newContent,
//         timestamp: message.timestamp,
//         isThinking: message.isThinking,
//       );

//       await messagesBox.put(messageId, updatedMessage);
//     }
//   }

//   static List<ChatMessage> getMessagesForChat(String chatId) {
//     // Note: This method doesn't await _ensureInitialized because it's synchronous
//     // Make sure init() is called before using this method
//     final messagesBox = Hive.box<ChatMessage>(_messagesBox);

//     return messagesBox.values
//         .where((message) => message.chatId == chatId)
//         .toList()
//       ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
//   }

//   // History operations
//   static List<Chat> getAllChats() {
//     // Note: This method doesn't await _ensureInitialized because it's synchronous
//     // Make sure init() is called before using this method
//     final chatsBox = Hive.box<Chat>(_chatsBox);

//     return chatsBox.values.toList()
//       ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
//   }

//   static List<Chat> searchChats(String query) {
//     final chatsBox = Hive.box<Chat>(_chatsBox);
//     final messagesBox = Hive.box<ChatMessage>(_messagesBox);

//     final lowerQuery = query.toLowerCase();

//     return chatsBox.values.where((chat) {
//       // Search in chat title
//       if (chat.title.toLowerCase().contains(lowerQuery)) {
//         return true;
//       }

//       // Search in chat messages
//       final chatMessages = messagesBox.values
//           .where((message) => message.chatId == chat.id)
//           .toList();

//       return chatMessages.any((message) =>
//           message.content.toLowerCase().contains(lowerQuery));
//     }).toList()
//       ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
//   }

//   // Helper methods
//   static String _generateTitleFromMessage(String message) {
//     final words = message.trim().split(' ');
//     if (words.length <= 5) {
//       return message;
//     }
//     return '${words.take(5).join(' ')}...';
//   }

//   static Future<void> clearAllData() async {
//     await _ensureInitialized();
//     final chatsBox = Hive.box<Chat>(_chatsBox);
//     final messagesBox = Hive.box<ChatMessage>(_messagesBox);
//     final settingsBox = Hive.box(_settingsBox);

//     await chatsBox.clear();
//     await messagesBox.clear();
//     await settingsBox.clear();
//   }

//   // Close all boxes (call when app closes)
//   static Future<void> close() async {
//     await Hive.close();
//     _isInitialized = false;
//   }
// }

import 'package:hive/hive.dart';
import 'package:nexora/core/local_storage/hive/chat_models.dart';
import 'package:uuid/uuid.dart';
import 'package:get_it/get_it.dart';
import '../../service/firestore_chat_service.dart';

class ChatStorageService {
  static const String _chatsBox = 'chats_box';
  static const String _messagesBox = 'messages_box';
  static const String _settingsBox = 'settings_box';
  static const String _currentChatKey = 'current_chat_id';

  static final Uuid _uuid = Uuid();
  static bool _isInitialized = false;

  // Logging configuration
  static bool _enableLogging = true;
  static const String _logPrefix = '[ChatStorage]';

  // Firestore sync service (optional, will be null if not available)
  static FirestoreChatService? get _firestoreService {
    try {
      return GetIt.instance<FirestoreChatService>();
    } catch (e) {
      return null;
    }
  }

  // Enable/disable cloud sync
  static bool _cloudSyncEnabled = true;
  static void enableCloudSync(bool enable) {
    _cloudSyncEnabled = enable;
    _log('Cloud sync ${enable ? 'enabled' : 'disabled'}');
  }

  static Future<void> init() async {
    if (_isInitialized) return;

    _log('Initializing Hive storage...');

    // Register adapters first
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ChatAdapter());
      _log('ChatAdapter registered');
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ChatMessageAdapter());
      _log('ChatMessageAdapter registered');
    }

    // Open all boxes
    await Hive.openBox<Chat>(_chatsBox);
    await Hive.openBox<ChatMessage>(_messagesBox);
    await Hive.openBox(_settingsBox);

    _isInitialized = true;
    _log('Hive storage initialized successfully');

    // Print initial data state
    await _printAllData();
  }

  // Helper method to ensure initialization
  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  // Logging helper methods
  static void _log(String message) {
    if (_enableLogging) {
      print('$_logPrefix $message');
    }
  }

  static void _logTransaction(
    String operation, {
    Map<String, dynamic>? details,
  }) {
    if (_enableLogging) {
      print('$_logPrefix 🔄 TRANSACTION: $operation');
      if (details != null) {
        details.forEach((key, value) {
          print('$_logPrefix   $key: $value');
        });
      }
      print('$_logPrefix ──────────────────────────');
    }
  }

  static Future<void> _printAllData() async {
    if (!_enableLogging) return;

    print('\n$_logPrefix 📊 CURRENT DATA STATE:');
    print('$_logPrefix ==========================');

    // Print all chats
    final chatsBox = Hive.box<Chat>(_chatsBox);
    final chats = chatsBox.values.toList();
    print('$_logPrefix CHATS (${chats.length}):');
    if (chats.isEmpty) {
      print('$_logPrefix   No chats found');
    } else {
      for (var chat in chats) {
        print(
          '$_logPrefix   - ${chat.id}: "${chat.title}" (${chat.modelUsed}) - Updated: ${chat.updatedAt}',
        );
      }
    }

    // Print all messages
    final messagesBox = Hive.box<ChatMessage>(_messagesBox);
    final messages = messagesBox.values.toList();
    print('$_logPrefix MESSAGES (${messages.length}):');
    if (messages.isEmpty) {
      print('$_logPrefix   No messages found');
    } else {
      for (var message in messages) {
        print(
          '$_logPrefix   - ${message.id}: [${message.role}] ${_truncateText(message.content)} (Chat: ${message.chatId})',
        );
      }
    }

    // Print current chat
    final currentChatId = await getCurrentChatId();
    print('$_logPrefix CURRENT CHAT ID: $currentChatId');

    // Print settings
    final settingsBox = Hive.box(_settingsBox);
    final settingsKeys = settingsBox.keys.toList();
    print('$_logPrefix SETTINGS (${settingsKeys.length}):');
    for (var key in settingsKeys) {
      print('$_logPrefix   - $key: ${settingsBox.get(key)}');
    }

    print('$_logPrefix ==========================\n');
  }

  static String _truncateText(String text, {int maxLength = 50}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Chat operations
  static Future<Chat> createNewChat({
    String? initialTitle,
    String? modelUsed,
  }) async {
    await _ensureInitialized();

    _logTransaction(
      'CREATE_NEW_CHAT',
      details: {'initialTitle': initialTitle, 'modelUsed': modelUsed},
    );

    final chatsBox = Hive.box<Chat>(_chatsBox);
    final now = DateTime.now();

    final chat = Chat(
      id: _uuid.v4(),
      title: initialTitle ?? 'New Chat',
      createdAt: now,
      updatedAt: now,
      modelUsed: modelUsed,
    );

    await chatsBox.put(chat.id, chat);
    _log('Created new chat: ${chat.id} - "${chat.title}"');

    // Sync to Firestore if enabled
    if (_cloudSyncEnabled && _firestoreService != null) {
      try {
        final isAuth = _firestoreService!.isAuthenticated;
        _log('🔄 Attempting to sync chat to cloud. Authenticated: $isAuth');
        if (isAuth) {
          await _firestoreService!.createOrUpdateChat(chat);
          _log('✅ Successfully synced chat to cloud: ${chat.id}');
        } else {
          _log('⚠️ User not authenticated, skipping cloud sync');
        }
      } catch (e, stackTrace) {
        _log('❌ Failed to sync chat to cloud: $e');
        _log('Stack trace: $stackTrace');
        // Don't rethrow - we want local save to succeed even if cloud fails
      }
    } else {
      if (!_cloudSyncEnabled) {
        _log('⚠️ Cloud sync is disabled');
      }
      if (_firestoreService == null) {
        _log('⚠️ Firestore service not available');
      }
    }

    // Set as current chat
    await setCurrentChatId(chat.id);

    await _printAllData();
    return chat;
  }

  static Future<void> updateChatTitle(String chatId, String newTitle) async {
    await _ensureInitialized();

    _logTransaction(
      'UPDATE_CHAT_TITLE',
      details: {
        'chatId': chatId,
        'oldTitle': Hive.box<Chat>(_chatsBox).get(chatId)?.title,
        'newTitle': newTitle,
      },
    );

    final chatsBox = Hive.box<Chat>(_chatsBox);
    final chat = chatsBox.get(chatId);

    if (chat != null) {
      final oldTitle = chat.title;
      chat.title = newTitle;
      chat.updatedAt = DateTime.now();
      await chatsBox.put(chatId, chat);
      _log('Updated chat title: "$oldTitle" → "$newTitle"');

      // Sync to Firestore if enabled
      if (_cloudSyncEnabled && _firestoreService != null) {
        try {
          final isAuth = _firestoreService!.isAuthenticated;
          _log(
            '🔄 Attempting to sync chat update to cloud. Authenticated: $isAuth',
          );
          if (isAuth) {
            await _firestoreService!.createOrUpdateChat(chat);
            _log('✅ Successfully synced chat update to cloud: $chatId');
          } else {
            _log('⚠️ User not authenticated, skipping cloud sync');
          }
        } catch (e, stackTrace) {
          _log('❌ Failed to sync chat update to cloud: $e');
          _log('Stack trace: $stackTrace');
        }
      }
    } else {
      _log('❌ Chat not found for update: $chatId');
    }

    await _printAllData();
  }

  static Future<void> deleteChat(String chatId) async {
    await _ensureInitialized();

    final chatsBox = Hive.box<Chat>(_chatsBox);
    final chat = chatsBox.get(chatId);

    _logTransaction(
      'DELETE_CHAT',
      details: {
        'chatId': chatId,
        'chatTitle': chat?.title,
        'messageCount': Hive.box<ChatMessage>(
          _messagesBox,
        ).values.where((m) => m.chatId == chatId).length,
      },
    );

    final messagesBox = Hive.box<ChatMessage>(_messagesBox);

    // Delete all messages in this chat
    final messageKeys = messagesBox.values
        .where((message) => message.chatId == chatId)
        .map((message) => message.key)
        .toList();

    await messagesBox.deleteAll(messageKeys);
    _log('Deleted ${messageKeys.length} messages for chat: $chatId');

    // Delete the chat
    await chatsBox.delete(chatId);
    _log('Deleted chat: $chatId');

    // Sync deletion to Firestore if enabled
    if (_cloudSyncEnabled && _firestoreService != null) {
      try {
        await _firestoreService!.deleteChat(chatId);
      } catch (e) {
        _log('⚠️ Failed to sync chat deletion to cloud: $e');
      }
    }

    // If this was the current chat, clear current chat
    final currentChatId = await getCurrentChatId();
    if (currentChatId == chatId) {
      await Hive.box(_settingsBox).delete(_currentChatKey);
      _log('Cleared current chat ID (was deleted)');
    }

    await _printAllData();
  }

  // static Future<String?> getCurrentChatId() async {
  //   await _ensureInitialized();
  //   final currentChatId = Hive.box(_settingsBox).get(_currentChatKey);
  //   _log('Retrieved current chat ID: $currentChatId');
  //   return currentChatId;
  // }
  static Future<String?> getCurrentChatId() async {
    await _ensureInitialized();
    final currentChatId = Hive.box(_settingsBox).get(_currentChatKey);

    // Return null if empty string (new chat pending) or null
    if (currentChatId == null || currentChatId == '') {
      _log('Retrieved current chat ID: null (no active chat)');
      return null;
    }

    _log('Retrieved current chat ID: $currentChatId');
    return currentChatId;
  }

  // static Future<void> setCurrentChatId(String chatId) async {
  //   await _ensureInitialized();
  //
  //   _logTransaction(
  //     'SET_CURRENT_CHAT',
  //     details: {
  //       'chatId': chatId,
  //       'chatTitle': Hive.box<Chat>(_chatsBox).get(chatId)?.title,
  //     },
  //   );
  //
  //   await Hive.box(_settingsBox).put(_currentChatKey, chatId);
  //   _log('Set current chat to: $chatId');
  //
  //   await _printAllData();
  // }
  static Future<void> setCurrentChatId(String chatId) async {
    await _ensureInitialized();

    _logTransaction(
      'SET_CURRENT_CHAT',
      details: {
        'chatId': chatId.isEmpty ? 'EMPTY (new chat pending)' : chatId,
        'chatTitle': chatId.isNotEmpty
            ? Hive.box<Chat>(_chatsBox).get(chatId)?.title
            : 'None',
      },
    );

    await Hive.box(_settingsBox).put(_currentChatKey, chatId);
    _log(
      'Set current chat to: ${chatId.isEmpty ? "EMPTY (new chat)" : chatId}',
    );

    await _printAllData();
  }

  static Future<Chat?> getCurrentChat() async {
    await _ensureInitialized();
    final currentChatId = await getCurrentChatId();
    final chat = currentChatId != null
        ? Hive.box<Chat>(_chatsBox).get(currentChatId)
        : null;
    _log('Retrieved current chat: ${chat?.title} ($currentChatId)');
    return chat;
  }

  // Message operations
  static Future<ChatMessage> addMessage({
    required String chatId,
    required String role,
    required String content,
    bool isThinking = false,
  }) async {
    await _ensureInitialized();

    _logTransaction(
      'ADD_MESSAGE',
      details: {
        'chatId': chatId,
        'role': role,
        'contentLength': content.length,
        'isThinking': isThinking,
        'chatTitle': Hive.box<Chat>(_chatsBox).get(chatId)?.title,
      },
    );

    final messagesBox = Hive.box<ChatMessage>(_messagesBox);
    final chatsBox = Hive.box<Chat>(_chatsBox);

    final message = ChatMessage(
      id: _uuid.v4(),
      chatId: chatId,
      role: role,
      content: content,
      timestamp: DateTime.now(),
      isThinking: isThinking,
    );

    await messagesBox.put(message.id, message);
    _log(
      'Added ${role.toUpperCase()} message (${message.id}): ${_truncateText(content)}',
    );

    // Update chat's updatedAt timestamp
    final chat = chatsBox.get(chatId);
    if (chat != null) {
      chat.updatedAt = DateTime.now();

      // Auto-generate title from first user message if it's still "New Chat"
      if (chat.title == 'New Chat' && role == 'user') {
        final newTitle = _generateTitleFromMessage(content);
        chat.title = newTitle;
        _log('Auto-generated chat title: "$newTitle"');
      }

      await chatsBox.put(chatId, chat);
      _log('Updated chat timestamp: $chatId');

      // Sync chat update to Firestore if enabled
      if (_cloudSyncEnabled && _firestoreService != null) {
        try {
          await _firestoreService!.createOrUpdateChat(chat);
        } catch (e) {
          _log('⚠️ Failed to sync chat update to cloud: $e');
        }
      }
    }

    // Sync message to Firestore if enabled
    if (_cloudSyncEnabled && _firestoreService != null) {
      try {
        final isAuth = _firestoreService!.isAuthenticated;
        _log('🔄 Attempting to sync message to cloud. Authenticated: $isAuth');
        if (isAuth) {
          await _firestoreService!.addOrUpdateMessage(message);
          _log('✅ Successfully synced message to cloud: ${message.id}');
        } else {
          _log('⚠️ User not authenticated, skipping cloud sync');
        }
      } catch (e, stackTrace) {
        _log('❌ Failed to sync message to cloud: $e');
        _log('Stack trace: $stackTrace');
      }
    }

    await _printAllData();
    return message;
  }

  static Future<void> updateMessageContent(
    String messageId,
    String newContent,
  ) async {
    await _ensureInitialized();

    final messagesBox = Hive.box<ChatMessage>(_messagesBox);
    final message = messagesBox.get(messageId);

    _logTransaction(
      'UPDATE_MESSAGE',
      details: {
        'messageId': messageId,
        'oldContent': message != null
            ? _truncateText(message.content)
            : 'NOT_FOUND',
        'newContent': _truncateText(newContent),
        'chatId': message?.chatId,
      },
    );

    if (message != null) {
      // Since ChatMessage fields are final, we need to replace the message
      final updatedMessage = ChatMessage(
        id: message.id,
        chatId: message.chatId,
        role: message.role,
        content: newContent,
        timestamp: message.timestamp,
        isThinking: message.isThinking,
      );

      await messagesBox.put(messageId, updatedMessage);
      _log('Updated message content: $messageId');

      // Sync message update to Firestore if enabled
      if (_cloudSyncEnabled && _firestoreService != null) {
        try {
          await _firestoreService!.addOrUpdateMessage(updatedMessage);
        } catch (e) {
          _log('⚠️ Failed to sync message update to cloud: $e');
        }
      }
    } else {
      _log('❌ Message not found for update: $messageId');
    }

    await _printAllData();
  }

  static Future<void> deleteMessage(String messageId) async {
    await _ensureInitialized();

    _logTransaction('DELETE_MESSAGE', details: {'messageId': messageId});

    final messagesBox = Hive.box<ChatMessage>(_messagesBox);
    final message = messagesBox.get(messageId);

    if (message != null) {
      await messagesBox.delete(messageId);
      _log('Deleted message: $messageId');

      // Sync deletion to Firestore if enabled
      if (_cloudSyncEnabled && _firestoreService != null) {
        try {
          // await _firestoreService!.deleteMessage(messageId);
        } catch (e) {
          // deleteMessage might not exist in FirestoreService yet, or might fail
          _log('⚠️ Failed to sync message deletion to cloud: $e');
        }
      }
    } else {
      _log('❌ Message not found for deletion: $messageId');
    }

    await _printAllData();
  }

  static List<ChatMessage> getMessagesForChat(String chatId) {
    _logTransaction(
      'GET_MESSAGES_FOR_CHAT',
      details: {
        'chatId': chatId,
        'chatTitle': Hive.box<Chat>(_chatsBox).get(chatId)?.title,
      },
    );

    final messagesBox = Hive.box<ChatMessage>(_messagesBox);

    final messages =
        messagesBox.values.where((message) => message.chatId == chatId).toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    _log('Retrieved ${messages.length} messages for chat: $chatId');
    return messages;
  }

  // History operations
  static List<Chat> getAllChats() {
    _logTransaction('GET_ALL_CHATS');

    final chatsBox = Hive.box<Chat>(_chatsBox);

    final chats = chatsBox.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    _log('Retrieved ${chats.length} chats');
    return chats;
  }

  static List<Chat> searchChats(String query) {
    _logTransaction('SEARCH_CHATS', details: {'query': query});

    final chatsBox = Hive.box<Chat>(_chatsBox);
    final messagesBox = Hive.box<ChatMessage>(_messagesBox);

    final lowerQuery = query.toLowerCase();

    final results = chatsBox.values.where((chat) {
      // Search in chat title
      if (chat.title.toLowerCase().contains(lowerQuery)) {
        return true;
      }

      // Search in chat messages
      final chatMessages = messagesBox.values
          .where((message) => message.chatId == chat.id)
          .toList();

      return chatMessages.any(
        (message) => message.content.toLowerCase().contains(lowerQuery),
      );
    }).toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    _log('Search found ${results.length} chats for query: "$query"');
    return results;
  }

  // Helper methods
  static String _generateTitleFromMessage(String message) {
    final words = message.trim().split(' ');
    if (words.length <= 5) {
      return message;
    }
    return '${words.take(5).join(' ')}...';
  }

  static Future<void> clearAllData() async {
    await _ensureInitialized();

    _logTransaction(
      'CLEAR_ALL_DATA',
      details: {
        'chatsCount': Hive.box<Chat>(_chatsBox).length,
        'messagesCount': Hive.box<ChatMessage>(_messagesBox).length,
        'settingsCount': Hive.box(_settingsBox).length,
      },
    );

    final chatsBox = Hive.box<Chat>(_chatsBox);
    final messagesBox = Hive.box<ChatMessage>(_messagesBox);
    final settingsBox = Hive.box(_settingsBox);

    await chatsBox.clear();
    await messagesBox.clear();
    await settingsBox.clear();

    _log('🗑️ Cleared all data: chats, messages, and settings');

    await _printAllData();
  }

  // Enable/disable logging
  static void enableLogging(bool enable) {
    _enableLogging = enable;
    _log('Logging ${enable ? 'enabled' : 'disabled'}');
  }

  // ==================== Firestore Cloud Sync Methods ====================

  /// Sync all local chats to Firestore cloud
  static Future<void> syncAllToCloud() async {
    if (_firestoreService == null || !_cloudSyncEnabled) {
      _log('⚠️ Cloud sync not available or disabled');
      return;
    }

    try {
      _log('🔄 Starting full sync to cloud...');
      await _ensureInitialized();

      // Get all local chats
      final localChats = getAllChats();
      _log('Found ${localChats.length} local chats to sync');

      // Sync all chats
      await _firestoreService!.syncAllChatsToCloud(localChats);

      // Sync messages for each chat
      final messagesBox = Hive.box<ChatMessage>(_messagesBox);
      for (var chat in localChats) {
        final chatMessages = messagesBox.values
            .where((m) => m.chatId == chat.id)
            .toList();
        if (chatMessages.isNotEmpty) {
          await _firestoreService!.syncMessagesToCloud(chat.id, chatMessages);
        }
      }

      _log('✅ Full sync to cloud completed');
    } catch (e) {
      _log('❌ Error during full sync to cloud: $e');
      rethrow;
    }
  }

  /// Download all chats from Firestore and merge with local storage
  static Future<void> syncFromCloud() async {
    if (_firestoreService == null || !_cloudSyncEnabled) {
      _log('⚠️ Cloud sync not available or disabled');
      return;
    }

    try {
      _log('🔄 Starting sync from cloud...');
      await _ensureInitialized();

      // Download all chats from cloud
      final cloudChats = await _firestoreService!.downloadAllChats();
      _log('Downloaded ${cloudChats.length} chats from cloud');

      final chatsBox = Hive.box<Chat>(_chatsBox);
      final messagesBox = Hive.box<ChatMessage>(_messagesBox);

      // Merge cloud chats with local (cloud takes precedence for conflicts)
      for (var cloudChat in cloudChats) {
        final localChat = chatsBox.get(cloudChat.id);

        // If cloud chat is newer or doesn't exist locally, use cloud version
        if (localChat == null ||
            cloudChat.updatedAt.isAfter(localChat.updatedAt)) {
          await chatsBox.put(cloudChat.id, cloudChat);
          _log('Merged chat from cloud: ${cloudChat.id}');

          // Download messages for this chat
          final cloudMessages = await _firestoreService!
              .downloadMessagesForChat(cloudChat.id);
          for (var cloudMessage in cloudMessages) {
            await messagesBox.put(cloudMessage.id, cloudMessage);
          }
          _log(
            'Downloaded ${cloudMessages.length} messages for chat: ${cloudChat.id}',
          );
        }
      }

      _log('✅ Sync from cloud completed');
      await _printAllData();
    } catch (e) {
      _log('❌ Error during sync from cloud: $e');
      rethrow;
    }
  }

  /// Two-way sync: upload local changes and download cloud changes
  static Future<void> syncBidirectional() async {
    if (_firestoreService == null || !_cloudSyncEnabled) {
      _log('⚠️ Cloud sync not available or disabled');
      return;
    }

    try {
      _log('🔄 Starting bidirectional sync...');

      // First, upload local changes to cloud
      await syncAllToCloud();

      // Then, download cloud changes (this will merge intelligently)
      await syncFromCloud();

      _log('✅ Bidirectional sync completed');
    } catch (e) {
      _log('❌ Error during bidirectional sync: $e');
      rethrow;
    }
  }

  /// Smart data loading based on authentication status
  /// - If user is logged in: Load from Firestore first, then sync to Hive
  /// - If user is NOT logged in: Load from Hive only
  static Future<List<Chat>> smartLoadChats() async {
    await _ensureInitialized();

    // Check if user is authenticated
    final isAuthenticated = _firestoreService?.isAuthenticated ?? false;

    if (isAuthenticated && _cloudSyncEnabled && _firestoreService != null) {
      _log('🔐 User is authenticated - loading from Firestore...');

      try {
        // Load from cloud
        final cloudChats = await _firestoreService!.downloadAllChats();
        _log('☁️ Downloaded ${cloudChats.length} chats from Firestore');

        if (cloudChats.isNotEmpty) {
          // Sync cloud data to local Hive
          final chatsBox = Hive.box<Chat>(_chatsBox);
          final messagesBox = Hive.box<ChatMessage>(_messagesBox);

          for (var cloudChat in cloudChats) {
            final localChat = chatsBox.get(cloudChat.id);

            // If cloud chat is newer or doesn't exist locally, use cloud version
            if (localChat == null ||
                cloudChat.updatedAt.isAfter(localChat.updatedAt)) {
              await chatsBox.put(cloudChat.id, cloudChat);
              _log('✅ Synced chat to local: ${cloudChat.id}');

              // Download messages for this chat
              try {
                final cloudMessages = await _firestoreService!
                    .downloadMessagesForChat(cloudChat.id);
                for (var cloudMessage in cloudMessages) {
                  await messagesBox.put(cloudMessage.id, cloudMessage);
                }
                _log(
                  '✅ Synced ${cloudMessages.length} messages for chat: ${cloudChat.id}',
                );
              } catch (e) {
                _log(
                  '⚠️ Failed to download messages for chat ${cloudChat.id}: $e',
                );
              }
            }
          }

          _log('✅ Cloud data synced to local storage');
        } else {
          _log('ℹ️ No cloud data found, using local data');
        }

        // Return merged local data (now includes cloud data)
        return getAllChats();
      } catch (e) {
        _log('❌ Failed to load from Firestore: $e');
        _log('⚠️ Falling back to local Hive data');

        // Fallback to local data if cloud fails
        return getAllChats();
      }
    } else {
      // User not authenticated - use local data only
      if (!isAuthenticated) {
        _log('👤 User not authenticated - loading from Hive only');
      } else if (!_cloudSyncEnabled) {
        _log('⚠️ Cloud sync disabled - loading from Hive only');
      } else {
        _log('⚠️ Firestore service unavailable - loading from Hive only');
      }

      return getAllChats();
    }
  }

  /// Smart load messages for a specific chat based on authentication
  static Future<List<ChatMessage>> smartLoadMessagesForChat(
    String chatId,
  ) async {
    await _ensureInitialized();

    final isAuthenticated = _firestoreService?.isAuthenticated ?? false;

    if (isAuthenticated && _cloudSyncEnabled && _firestoreService != null) {
      _log('🔐 User authenticated - checking Firestore for messages...');

      try {
        final cloudMessages = await _firestoreService!.downloadMessagesForChat(
          chatId,
        );

        if (cloudMessages.isNotEmpty) {
          _log('☁️ Downloaded ${cloudMessages.length} messages from Firestore');

          // Sync to local
          final messagesBox = Hive.box<ChatMessage>(_messagesBox);
          for (var cloudMessage in cloudMessages) {
            await messagesBox.put(cloudMessage.id, cloudMessage);
          }

          _log('✅ Messages synced to local storage');
        }

        // Return local data (now includes cloud data)
        return getMessagesForChat(chatId);
      } catch (e) {
        _log('❌ Failed to load messages from Firestore: $e');
        _log('⚠️ Falling back to local data');

        return getMessagesForChat(chatId);
      }
    } else {
      _log('👤 Loading messages from Hive only');
      return getMessagesForChat(chatId);
    }
  }

  // Close all boxes (call when app closes)
  static Future<void> close() async {
    _log('Closing Hive storage...');
    await Hive.close();
    _isInitialized = false;
    _log('Hive storage closed');
  }
}
