// // import 'dart:async';
// // import 'package:bloc/bloc.dart';
// // import 'package:meta/meta.dart';
// //
// // import '../../../core/service/api_service/nvidia_api_service.dart';
// //
// // part 'chat_event.dart';
// // part 'chat_state.dart';
// //
// // class ChatBloc extends Bloc<ChatEvent, ChatState> {
// //   final NvidiaApiService _apiService;
// //
// //   ChatBloc(this._apiService) : super(ChatInitial()) {
// //     on<SendMessage>(_onSendMessage);
// //     on<ClearChat>(_onClearChat);
// //     on<LoadHistory>(_onLoadHistory);
// //   }
// //
// //   StreamSubscription<String>? _currentStream;
// //
// //   Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
// //     // Add user message immediately
// //     final currentMessages = state.messages;
// //     final newMessages = [
// //       ...currentMessages,
// //       ChatMessage(role: 'user', content: event.message, timestamp: DateTime.now()),
// //     ];
// //
// //     emit(ChatLoading(newMessages));
// //
// //     // Cancel any ongoing stream
// //     await _currentStream?.cancel();
// //
// //     try {
// //       final stream = await _apiService.streamCompletion(message: event.message);
// //
// //       // Start with empty AI message
// //       final aiMessage = ChatMessage(
// //         role: 'assistant',
// //         content: '',
// //         timestamp: DateTime.now(),
// //         isThinking: true,
// //       );
// //
// //       final messagesWithAI = [...newMessages, aiMessage];
// //       emit(ChatStreaming(messagesWithAI));
// //
// //       String fullContent = '';
// //
// //       _currentStream = stream.listen(
// //             (chunk) {
// //           fullContent += chunk;
// //           final updatedMessages = [...newMessages];
// //           updatedMessages.add(ChatMessage(
// //             role: 'assistant',
// //             content: fullContent,
// //             timestamp: DateTime.now(),
// //             isThinking: false,
// //           ));
// //           add(UpdateMessage(updatedMessages));
// //         },
// //         onDone: () {
// //           final completedMessages = [...newMessages];
// //           completedMessages.add(ChatMessage(
// //             role: 'assistant',
// //             content: fullContent,
// //             timestamp: DateTime.now(),
// //             isThinking: false,
// //           ));
// //           emit(ChatSuccess(completedMessages));
// //         },
// //         onError: (error) {
// //           final errorMessages = [...newMessages];
// //           errorMessages.add(ChatMessage(
// //             role: 'assistant',
// //             content: 'Error: $error',
// //             timestamp: DateTime.now(),
// //             isThinking: false,
// //           ));
// //           emit(ChatError(errorMessages, error.toString()));
// //         },
// //       );
// //     } catch (e) {
// //       final errorMessages = [...newMessages];
// //       errorMessages.add(ChatMessage(
// //         role: 'assistant',
// //         content: 'Error: $e',
// //         timestamp: DateTime.now(),
// //         isThinking: false,
// //       ));
// //       emit(ChatError(errorMessages, e.toString()));
// //     }
// //   }
// //
// //   void _onClearChat(ClearChat event, Emitter<ChatState> emit) {
// //     _currentStream?.cancel();
// //     emit(ChatInitial());
// //   }
// //
// //   void _onLoadHistory(LoadHistory event, Emitter<ChatState> emit) {
// //     // Implement history loading logic here
// //     emit(ChatSuccess(event.messages));
// //   }
// //
// //   @override
// //   Future<void> close() {
// //     _currentStream?.cancel();
// //     return super.close();
// //   }
// // }
//
// import 'dart:async';
// import 'package:bloc/bloc.dart';
// import 'package:meta/meta.dart';
//
// import '../../../core/local_storage/hive/chat_models.dart';
// import '../../../core/service/api_service/nvidia_api_service.dart';
//
// part 'chat_event.dart';
// part 'chat_state.dart';
//
// class ChatBloc extends Bloc<ChatEvent, ChatState> {
//   final NvidiaApiService _apiService;
//   StreamSubscription<String>? _currentStream;
//   final List<ChatMessage> _conversationHistory = [];
//   final int _maxHistoryLength = 20; // Keep last 20 messages
//
//   ChatBloc(this._apiService) : super(const ChatInitial()) {
//     on<SendMessage>(_onSendMessage);
//     on<ClearChat>(_onClearChat);
//     on<LoadHistory>(_onLoadHistory);
//     on<StreamMessageUpdate>(_onStreamMessageUpdate);
//   }
//
//   Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
//     // Cancel any existing stream
//     await _currentStream?.cancel();
//
//     // Add user message to conversation history
//     final userMessage = ChatMessage(
//         role: 'user',
//         content: event.message,
//         timestamp: DateTime.now()
//     );
//     _addToHistory(userMessage);
//
//     // Convert conversation history to API format
//     final apiMessages = _conversationHistory.map((msg) => {
//       'role': msg.role,
//       'content': msg.content
//     }).toList();
//
//     emit(ChatLoading([..._conversationHistory]));
//
//     try {
//       final stream = await _apiService.streamCompletion(messages: apiMessages);
//
//       // Create a controller to handle the stream updates safely
//       final streamController = StreamController<String>();
//       _currentStream = stream.listen(
//             (chunk) => streamController.add(chunk),
//         onError: (error) => streamController.addError(error),
//         onDone: () => streamController.close(),
//       );
//
//       // Start with empty AI message (temporary - not added to history yet)
//       String fullContent = '';
//       final temporaryAiMessage = ChatMessage(
//         role: 'assistant',
//         content: '',
//         timestamp: DateTime.now(),
//         isThinking: true,
//       );
//
//       final initialMessages = [..._conversationHistory, temporaryAiMessage];
//       emit(ChatStreaming(initialMessages));
//
//       // Use emit.forEach to handle stream updates safely
//       await emit.forEach<String>(
//         streamController.stream,
//         onData: (chunk) {
//           fullContent += chunk;
//           // Create updated messages list with streaming content
//           final updatedMessages = [..._conversationHistory];
//           updatedMessages.add(ChatMessage(
//             role: 'assistant',
//             content: fullContent,
//             timestamp: DateTime.now(),
//             isThinking: false,
//           ));
//           return ChatStreaming(updatedMessages);
//         },
//         onError: (error, stackTrace) {
//           final errorMessages = [..._conversationHistory];
//           errorMessages.add(ChatMessage(
//             role: 'assistant',
//             content: 'Error: $error',
//             timestamp: DateTime.now(),
//             isThinking: false,
//           ));
//           return ChatError(errorMessages, error.toString());
//         },
//       );
//
//       // Stream completed successfully - add AI response to permanent history
//       final aiMessage = ChatMessage(
//         role: 'assistant',
//         content: fullContent,
//         timestamp: DateTime.now(),
//         isThinking: false,
//       );
//       _addToHistory(aiMessage);
//
//       emit(ChatSuccess([..._conversationHistory]));
//
//     } catch (e) {
//       final errorMessages = [..._conversationHistory];
//       errorMessages.add(ChatMessage(
//         role: 'assistant',
//         content: 'Error: $e',
//         timestamp: DateTime.now(),
//         isThinking: false,
//       ));
//       emit(ChatError(errorMessages, e.toString()));
//     }
//   }
//
//   void _onStreamMessageUpdate(StreamMessageUpdate event, Emitter<ChatState> emit) {
//     emit(ChatStreaming(event.messages));
//   }
//
//   void _onClearChat(ClearChat event, Emitter<ChatState> emit) {
//     _currentStream?.cancel();
//     _conversationHistory.clear(); // Clear conversation history
//     emit(const ChatInitial());
//   }
//
//   void _onLoadHistory(LoadHistory event, Emitter<ChatState> emit) {
//     // Replace current history with loaded history
//     _conversationHistory.clear();
//     _conversationHistory.addAll(event.messages);
//     emit(ChatSuccess([..._conversationHistory]));
//   }
//
//   // Helper method to manage conversation history length
//   void _addToHistory(ChatMessage message) {
//     _conversationHistory.add(message);
//
//     // Trim history if too long (keep most recent messages)
//     if (_conversationHistory.length > _maxHistoryLength) {
//       final removeCount = _conversationHistory.length - _maxHistoryLength;
//       _conversationHistory.removeRange(0, removeCount);
//     }
//   }
//
//   // Optional: Get current conversation history
//   List<ChatMessage> get conversationHistory => [..._conversationHistory];
//
//   // Optional: Get conversation summary for debugging
//   String get conversationSummary {
//     return 'Conversation length: ${_conversationHistory.length} messages\n'
//         'Last message: ${_conversationHistory.isNotEmpty ? _conversationHistory.last.content.substring(0, 30) + '...' : 'None'}';
//   }
//
//   @override
//   Future<void> close() {
//     _currentStream?.cancel();
//     return super.close();
//   }
// }

///----------------------------------------------------------///
// import 'dart:async';
// import 'package:bloc/bloc.dart';
// import 'package:meta/meta.dart';
// import 'package:nexora/core/service/api_service/nvidia_api_service.dart';
// import 'package:nexora/core/local_storage/hive/chat_storage_service.dart';
// import 'package:nexora/core/local_storage/hive/chat_models.dart';
//
// part 'chat_event.dart';
// part 'chat_state.dart';
//
// class ChatBloc extends Bloc<ChatEvent, ChatState> {
//   final NvidiaApiService _apiService;
//   StreamSubscription<String>? _currentStream;
//   String? _currentThinkingMessageId;
//   String? _currentChatId;
//
//   ChatBloc(this._apiService) : super(const ChatInitial()) {
//     on<SendMessage>(_onSendMessage);
//     on<ClearChat>(_onClearChat);
//     on<LoadChatHistory>(_onLoadChatHistory);
//     on<LoadSpecificChat>(_onLoadSpecificChat);
//     on<CreateNewChat>(_onCreateNewChat);
//     on<SearchChats>(_onSearchChats);
//
//     // Load initial data when bloc is created
//     add(LoadChatHistory());
//   }
//
//   Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
//     try {
//       // Cancel any existing stream
//       await _currentStream?.cancel();
//
//       // Get or create current chat
//       _currentChatId = await ChatStorageService.getCurrentChatId();
//       if (_currentChatId == null) {
//         final newChat = await ChatStorageService.createNewChat();
//         _currentChatId = newChat.id;
//       }
//
//       // Add user message to storage
//       await ChatStorageService.addMessage(
//         chatId: _currentChatId!,
//         role: 'user',
//         content: event.message,
//       );
//
//       // Get updated messages and history
//       final messages = ChatStorageService.getMessagesForChat(_currentChatId!);
//       final history = ChatStorageService.getAllChats();
//
//       emit(ChatLoaded(messages, history, currentChatId: _currentChatId));
//
//       // Add thinking message
//       final thinkingMessage = await ChatStorageService.addMessage(
//         chatId: _currentChatId!,
//         role: 'assistant',
//         content: 'Thinking...',
//         isThinking: true,
//       );
//
//       _currentThinkingMessageId = thinkingMessage.id;
//
//       final updatedMessages = ChatStorageService.getMessagesForChat(_currentChatId!);
//       emit(ChatStreaming(updatedMessages, history, currentChatId: _currentChatId));
//
//       // Prepare conversation history for API
//       final apiMessages = _prepareConversationHistory(_currentChatId!);
//
//       // Stream AI response
//       final responseStream = await _apiService.streamCompletion(messages: apiMessages);
//
//       // Use a Completer to handle the stream completion
//       final completer = Completer<void>();
//       String accumulatedResponse = '';
//
//       _currentStream = responseStream.listen(
//             (chunk) {
//           if (!emit.isDone) {
//             accumulatedResponse += chunk;
//
//             final currentStoredMessages = ChatStorageService.getMessagesForChat(_currentChatId!);
//             final lastMessage = currentStoredMessages.isNotEmpty ? currentStoredMessages.last : null;
//
//             if (lastMessage != null && lastMessage.isThinking) {
//               // Replace thinking message with actual response
//               ChatStorageService.updateMessageContent(_currentThinkingMessageId!, accumulatedResponse);
//             } else {
//               // Update last message with new content
//               if (currentStoredMessages.isNotEmpty) {
//                 final lastMsg = currentStoredMessages.last;
//                 ChatStorageService.updateMessageContent(lastMsg.id, accumulatedResponse);
//               }
//             }
//
//             final updatedMessages = ChatStorageService.getMessagesForChat(_currentChatId!);
//             final updatedHistory = ChatStorageService.getAllChats();
//
//             emit(ChatStreaming(
//               updatedMessages,
//               updatedHistory,
//               currentChatId: _currentChatId,
//             ));
//           }
//         },
//         onError: (error) {
//           if (!emit.isDone) {
//             _handleError(emit, error.toString(), _currentChatId!);
//           }
//           completer.complete();
//         },
//         onDone: () {
//           if (!emit.isDone) {
//             _currentThinkingMessageId = null;
//             final messages = ChatStorageService.getMessagesForChat(_currentChatId!);
//             final history = ChatStorageService.getAllChats();
//             emit(ChatLoaded(messages, history, currentChatId: _currentChatId));
//           }
//           completer.complete();
//         },
//       );
//
//       // Wait for the stream to complete before finishing the event handler
//       await completer.future;
//
//     } catch (error) {
//       if (!emit.isDone) {
//         _handleError(emit, error.toString(), _currentChatId ?? await ChatStorageService.getCurrentChatId() ?? 'unknown');
//       }
//     }
//   }
//
//   Future<void> _onLoadChatHistory(LoadChatHistory event, Emitter<ChatState> emit) async {
//     try {
//       final history = ChatStorageService.getAllChats();
//       final currentChatId = await ChatStorageService.getCurrentChatId();
//
//       List<ChatMessage> messages = [];
//       if (currentChatId != null) {
//         messages = ChatStorageService.getMessagesForChat(currentChatId);
//       }
//
//       emit(ChatLoaded(
//         messages,
//         history,
//         currentChatId: currentChatId,
//       ));
//     } catch (error) {
//       if (!emit.isDone) {
//         _handleError(emit, error.toString(), await ChatStorageService.getCurrentChatId() ?? 'unknown');
//       }
//     }
//   }
//
//   Future<void> _onLoadSpecificChat(LoadSpecificChat event, Emitter<ChatState> emit) async {
//     try {
//       await ChatStorageService.setCurrentChatId(event.chatId);
//       final messages = ChatStorageService.getMessagesForChat(event.chatId);
//       final history = ChatStorageService.getAllChats();
//
//       emit(ChatLoaded(
//         messages,
//         history,
//         currentChatId: event.chatId,
//       ));
//     } catch (error) {
//       if (!emit.isDone) {
//         _handleError(emit, error.toString(), event.chatId);
//       }
//     }
//   }
//
//   Future<void> _onCreateNewChat(CreateNewChat event, Emitter<ChatState> emit) async {
//     try {
//       await _currentStream?.cancel();
//       final newChat = await ChatStorageService.createNewChat(modelUsed: event.modelUsed);
//       final history = ChatStorageService.getAllChats();
//
//       emit(ChatLoaded(
//         [],
//         history,
//         currentChatId: newChat.id,
//       ));
//     } catch (error) {
//       if (!emit.isDone) {
//         _handleError(emit, error.toString(), await ChatStorageService.getCurrentChatId() ?? 'unknown');
//       }
//     }
//   }
//
//   Future<void> _onClearChat(ClearChat event, Emitter<ChatState> emit) async {
//     try {
//       await _currentStream?.cancel();
//       final currentChatId = await ChatStorageService.getCurrentChatId();
//       if (currentChatId != null) {
//         await ChatStorageService.deleteChat(currentChatId);
//       }
//
//       final history = ChatStorageService.getAllChats();
//       emit(ChatLoaded([], history));
//     } catch (error) {
//       if (!emit.isDone) {
//         _handleError(emit, error.toString(), await ChatStorageService.getCurrentChatId() ?? 'unknown');
//       }
//     }
//   }
//
//   Future<void> _onSearchChats(SearchChats event, Emitter<ChatState> emit) async {
//     try {
//       final currentChatId = await ChatStorageService.getCurrentChatId();
//       List<ChatMessage> messages = [];
//       if (currentChatId != null) {
//         messages = ChatStorageService.getMessagesForChat(currentChatId);
//       }
//
//       final searchResults = ChatStorageService.searchChats(event.query);
//
//       emit(ChatLoaded(
//         messages,
//         searchResults,
//         currentChatId: currentChatId,
//       ));
//     } catch (error) {
//       if (!emit.isDone) {
//         _handleError(emit, error.toString(), await ChatStorageService.getCurrentChatId() ?? 'unknown');
//       }
//     }
//   }
//
//   // Helper methods
//   List<Map<String, String>> _prepareConversationHistory(String chatId) {
//     final messages = ChatStorageService.getMessagesForChat(chatId);
//     return messages.map((msg) => {
//       'role': msg.role,
//       'content': msg.content
//     }).toList();
//   }
//
//   void _handleError(Emitter<ChatState> emit, String error, String chatId) {
//     if (emit.isDone) return;
//
//     List<ChatMessage> messages = [];
//     if (chatId != 'unknown') {
//       messages = ChatStorageService.getMessagesForChat(chatId);
//     }
//     final history = ChatStorageService.getAllChats();
//
//     emit(ChatError(
//       messages,
//       history,
//       error,
//     ));
//   }
//
//   @override
//   Future<void> close() {
//     _currentStream?.cancel();
//     return super.close();
//   }
// }

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:nexora/core/service/api_service/nvidia_api_service.dart';
import 'package:nexora/core/local_storage/hive/chat_storage_service.dart';
import 'package:nexora/core/local_storage/hive/chat_models.dart';

import '../../../core/service/auth_service.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final NvidiaApiService _apiService;
  StreamSubscription<String>? _currentStream;
  String? _currentThinkingMessageId;
  String? _currentChatId;
  String? _pendingModelName; // Store model name for when chat is created
  final AuthService _authService;
  User? _currentUser;

  ChatBloc(this._apiService, {required AuthService authService})
    : _authService = authService,
      super(const ChatInitial()) {
    on<SendMessage>(_onSendMessage);
    on<ClearChat>(_onClearChat);
    on<LoadChatHistory>(_onLoadChatHistory);
    on<LoadSpecificChat>(_onLoadSpecificChat);
    on<CreateNewChat>(_onCreateNewChat);
    on<SearchChats>(_onSearchChats);
    on<LoadUserProfile>(_loadUserProfile);
    on<RegenerateResponse>(_regenrateResp);
    on<CreateFreshChat>(_onCreateFreshChat);

    // Load initial data when bloc is created
    add(LoadChatHistory());
    add(LoadUserProfile());
  }

  Future<void> _onCreateFreshChat(
    CreateFreshChat event,
    Emitter<ChatState> emit,
  ) async {
    print('init');
    try {
      await _currentStream?.cancel();

      // Clear current chat ID to indicate we're in "new chat" mode
      // But DON'T create the chat in storage yet
      await ChatStorageService.setCurrentChatId(
        '',
      ); // Empty string means "new chat pending"
      _pendingModelName = event.modelUsed; // Store model name for later
      _currentChatId = null;

      final history = ChatStorageService.getAllChats();

      // Emit empty messages state (new chat screen)
      // Immediately load history to show all saved chats in sidebar
      emit(
        ChatLoaded(
          messages: [],
          chatHistory: history,
          currentChatId: null,
          user: _currentUser,
        ),
      );
    } catch (error) {
      if (!emit.isDone) {
        await _handleError(emit, error.toString(), 'unknown');
      }
    }

    print('end of the ');
  }

  Future<void> _regenrateResp(
    RegenerateResponse event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _currentStream?.cancel();

      if (_currentChatId == null || _currentChatId!.isEmpty) {
        return;
      }

      var messages = ChatStorageService.getMessagesForChat(_currentChatId!);
      if (messages.isEmpty) return;

      // If the last message is from assistant, delete it to regenerate
      if (messages.last.role == 'assistant') {
        await ChatStorageService.deleteMessage(messages.last.id);
        messages = ChatStorageService.getMessagesForChat(_currentChatId!);
      }

      // Check if we have a user message to respond to
      if (messages.isEmpty || messages.last.role != 'user') {
        return;
      }

      final history = ChatStorageService.getAllChats();

      emit(
        ChatLoaded(
          messages: messages,
          chatHistory: history,
          currentChatId: _currentChatId,
          user: _currentUser,
        ),
      );

      // Add thinking message
      final thinkingMessage = await ChatStorageService.addMessage(
        chatId: _currentChatId!,
        role: 'assistant',
        content: 'Thinking...',
        isThinking: true,
      );

      _currentThinkingMessageId = thinkingMessage.id;

      final updatedMessages = ChatStorageService.getMessagesForChat(
        _currentChatId!,
      );
      emit(
        ChatStreaming(
          messages: updatedMessages,
          chatHistory: history,
          currentChatId: _currentChatId,
          user: _currentUser,
        ),
      );

      // Prepare conversation history for API
      final apiMessages = _prepareConversationHistory(_currentChatId!);

      // Stream AI response
      final responseStream = await _apiService.streamCompletion(
        messages: apiMessages,
      );

      final completer = Completer<void>();
      String accumulatedResponse = '';

      _currentStream = responseStream.listen(
        (chunk) {
          if (!emit.isDone) {
            accumulatedResponse += chunk;

            final currentMessages = List<ChatMessage>.from(state.messages);
            final index = currentMessages.indexWhere(
              (m) => m.id == _currentThinkingMessageId,
            );

            if (index != -1) {
              final oldMessage = currentMessages[index];
              currentMessages[index] = ChatMessage(
                id: oldMessage.id,
                chatId: oldMessage.chatId,
                role: oldMessage.role,
                content: accumulatedResponse,
                timestamp: oldMessage.timestamp,
                isThinking: false,
              );
            }

            emit(
              ChatStreaming(
                messages: currentMessages,
                chatHistory: state.chatHistory,
                currentChatId: _currentChatId,
                user: _currentUser,
              ),
            );
          }
        },
        onError: (error) async {
          if (!emit.isDone) {
            await _handleError(emit, error.toString(), _currentChatId!);
          }
          completer.complete();
        },
        onDone: () async {
          if (_currentThinkingMessageId != null && !emit.isDone) {
            try {
              await ChatStorageService.updateMessageContent(
                _currentThinkingMessageId!,
                accumulatedResponse,
              );
            } catch (e) {
              print('Error saving final message: \$e');
            }
          }

          if (!emit.isDone) {
            _currentThinkingMessageId = null;
            final messages = ChatStorageService.getMessagesForChat(
              _currentChatId!,
            );
            final history = ChatStorageService.getAllChats();
            emit(
              ChatLoaded(
                messages: messages,
                chatHistory: history,
                currentChatId: _currentChatId,
                user: _currentUser,
              ),
            );
          }
          completer.complete();
        },
      );

      await completer.future;
    } catch (error) {
      if (!emit.isDone) {
        await _handleError(emit, error.toString(), _currentChatId ?? 'unknown');
      }
    }
  }

  void _loadUserProfile(LoadUserProfile event, Emitter<ChatState> emit) {
    _currentUser = _authService.currentUser;

    // Emit current state type with updated user data
    emit(
      ChatUserProfile(
        user: _currentUser,
        messages: state.messages,
        chatHistory: state.chatHistory,
      ),
    );
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // Cancel any existing stream
      await _currentStream?.cancel();

      // Emit loading state immediately for UX feedback with Optimistic Update
      final optimisticUserMessage = ChatMessage(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        chatId: _currentChatId ?? 'temp_chat_id',
        role: 'user',
        content: event.message,
        timestamp: DateTime.now(),
      );

      final optimisticMessages = [...state.messages, optimisticUserMessage];

      emit(
        ChatLoading(
          messages: optimisticMessages,
          chatHistory: state.chatHistory,
          user: _currentUser,
        ),
      );

      // Get current chat ID or create new chat if none exists
      _currentChatId = await ChatStorageService.getCurrentChatId();

      // If no current chat exists, create one NOW (when user sends first message)
      if (_currentChatId == null) {
        final newChat = await ChatStorageService.createNewChat(
          modelUsed: _pendingModelName ?? 'Default',
        );
        _currentChatId = newChat.id;
        _pendingModelName = null; // Clear pending model name
      }

      // Add user message to storage
      await ChatStorageService.addMessage(
        chatId: _currentChatId!,
        role: 'user',
        content: event.message,
      );

      // Get updated messages and history
      final messages = ChatStorageService.getMessagesForChat(_currentChatId!);
      final history = ChatStorageService.getAllChats();

      emit(
        ChatLoaded(
          messages: messages,
          chatHistory: history,
          currentChatId: _currentChatId,
          user: _currentUser,
        ),
      );

      // Add thinking message
      final thinkingMessage = await ChatStorageService.addMessage(
        chatId: _currentChatId!,
        role: 'assistant',
        content: 'Thinking...',
        isThinking: true,
      );

      _currentThinkingMessageId = thinkingMessage.id;

      final updatedMessages = ChatStorageService.getMessagesForChat(
        _currentChatId!,
      );
      emit(
        ChatStreaming(
          messages: updatedMessages,
          chatHistory: history,
          currentChatId: _currentChatId,
          user: _currentUser,
        ),
      );

      // Prepare conversation history for API
      final apiMessages = _prepareConversationHistory(_currentChatId!);

      // Stream AI response
      final responseStream = await _apiService.streamCompletion(
        messages: apiMessages,
      );

      // Use a Completer to handle the stream completion
      final completer = Completer<void>();
      String accumulatedResponse = '';

      _currentStream = responseStream.listen(
        (chunk) {
          if (!emit.isDone) {
            accumulatedResponse += chunk;

            // Optimistic in-memory update for UI performance
            final currentMessages = List<ChatMessage>.from(state.messages);
            final index = currentMessages.indexWhere(
              (m) => m.id == _currentThinkingMessageId,
            );

            if (index != -1) {
              final oldMessage = currentMessages[index];
              currentMessages[index] = ChatMessage(
                id: oldMessage.id,
                chatId: oldMessage.chatId,
                role: oldMessage.role,
                content: accumulatedResponse,
                timestamp: oldMessage.timestamp,
                // It's technically still "streaming/thinking" but for UI we might want to show text
                // If we set isThinking to false, it shows the text.
                isThinking: false,
              );
            }

            emit(
              ChatStreaming(
                messages: currentMessages,
                chatHistory: state.chatHistory,
                currentChatId: _currentChatId,
                user: _currentUser,
              ),
            );
          }
        },
        onError: (error) async {
          if (!emit.isDone) {
            await _handleError(emit, error.toString(), _currentChatId!);
          }
          completer.complete();
        },
        onDone: () async {
          // Final save to storage when stream is complete
          if (_currentThinkingMessageId != null && !emit.isDone) {
            try {
              await ChatStorageService.updateMessageContent(
                _currentThinkingMessageId!,
                accumulatedResponse,
              );
            } catch (e) {
              print('Error saving final message: $e');
            }
          }

          if (!emit.isDone) {
            _currentThinkingMessageId = null;
            final messages = ChatStorageService.getMessagesForChat(
              _currentChatId!,
            );
            final history = ChatStorageService.getAllChats();
            emit(
              ChatLoaded(
                messages: messages,
                chatHistory: history,
                currentChatId: _currentChatId,
                user: _currentUser,
              ),
            );
          }
          completer.complete();
        },
      );

      // Wait for the stream to complete before finishing the event handler
      await completer.future;
    } catch (error) {
      if (!emit.isDone) {
        await _handleError(emit, error.toString(), _currentChatId ?? 'unknown');
      }
    }
  }

  Future<void> _onLoadChatHistory(
    LoadChatHistory event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // Use smart loading - checks authentication and loads from appropriate source
      final history = await ChatStorageService.smartLoadChats();
      final currentChatId = await ChatStorageService.getCurrentChatId();

      List<ChatMessage> messages = [];
      if (currentChatId != null) {
        // Use smart loading for messages too
        messages = await ChatStorageService.smartLoadMessagesForChat(
          currentChatId,
        );
      }

      emit(
        ChatLoaded(
          messages: messages,
          chatHistory: history,
          currentChatId: currentChatId,
          user: _currentUser,
        ),
      );
    } catch (error) {
      if (!emit.isDone) {
        await _handleError(
          emit,
          error.toString(),
          await ChatStorageService.getCurrentChatId() ?? 'unknown',
        );
      }
    }
  }

  Future<void> _onLoadSpecificChat(
    LoadSpecificChat event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // Emit loading state immediately
      emit(
        ChatLoading(
          messages: [],
          chatHistory: state.chatHistory,
          user: _currentUser,
        ),
      );

      await ChatStorageService.setCurrentChatId(event.chatId);

      // Use smart loading
      final messages = await ChatStorageService.smartLoadMessagesForChat(
        event.chatId,
      );
      final history = await ChatStorageService.smartLoadChats();

      emit(
        ChatLoaded(
          messages: messages,
          chatHistory: history,
          currentChatId: event.chatId,
          user: _currentUser,
        ),
      );
    } catch (error) {
      if (!emit.isDone) {
        await _handleError(emit, error.toString(), event.chatId);
      }
    }
  }

  Future<void> _onCreateNewChat(
    CreateNewChat event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _currentStream?.cancel();

      // Clear current chat ID to indicate we're in "new chat" mode
      // But DON'T create the chat in storage yet
      await ChatStorageService.setCurrentChatId(
        '',
      ); // Empty string means "new chat pending"
      _pendingModelName = event.modelUsed; // Store model name for later
      _currentChatId = null;

      final history = ChatStorageService.getAllChats();

      // Emit empty messages state (new chat screen)
      // Immediately load history to show all saved chats in sidebar
      emit(
        ChatLoaded(
          messages: [],
          chatHistory: history,
          currentChatId: null,
          user: _currentUser,
        ),
      );
    } catch (error) {
      if (!emit.isDone) {
        await _handleError(emit, error.toString(), 'unknown');
      }
    }
  }

  Future<void> _onClearChat(ClearChat event, Emitter<ChatState> emit) async {
    try {
      await _currentStream?.cancel();
      final currentChatId = await ChatStorageService.getCurrentChatId();

      if (currentChatId != null && currentChatId.isNotEmpty) {
        await ChatStorageService.deleteChat(currentChatId);
      }

      // Clear current chat
      await ChatStorageService.setCurrentChatId('');
      _currentChatId = null;

      final history = ChatStorageService.getAllChats();
      emit(ChatLoaded(messages: [], chatHistory: history));
    } catch (error) {
      if (!emit.isDone) {
        await _handleError(emit, error.toString(), 'unknown');
      }
    }
  }

  Future<void> _onSearchChats(
    SearchChats event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final currentChatId = await ChatStorageService.getCurrentChatId();
      List<ChatMessage> messages = [];
      if (currentChatId != null && currentChatId.isNotEmpty) {
        messages = ChatStorageService.getMessagesForChat(currentChatId);
      }

      final searchResults = ChatStorageService.searchChats(event.query);

      emit(
        ChatLoaded(
          messages: messages,
          chatHistory: searchResults,
          currentChatId: currentChatId,
        ),
      );
    } catch (error) {
      if (!emit.isDone) {
        await _handleError(
          emit,
          error.toString(),
          await ChatStorageService.getCurrentChatId() ?? 'unknown',
        );
      }
    }
  }

  // Helper methods
  List<Map<String, String>> _prepareConversationHistory(String chatId) {
    final messages = ChatStorageService.getMessagesForChat(chatId);
    return messages
        .map((msg) => {'role': msg.role, 'content': msg.content})
        .toList();
  }

  Future<void> _handleError(
    Emitter<ChatState> emit,
    String error,
    String chatId,
  ) async {
    if (emit.isDone) return;

    // If there's a stuck "Thinking..." message, delete it
    if (_currentThinkingMessageId != null) {
      await ChatStorageService.deleteMessage(_currentThinkingMessageId!);
      _currentThinkingMessageId = null;
    }

    List<ChatMessage> messages = [];
    if (chatId != 'unknown' && chatId.isNotEmpty) {
      messages = ChatStorageService.getMessagesForChat(chatId);
    }
    final history = ChatStorageService.getAllChats();

    emit(ChatError(messages: messages, chatHistory: history, error: error));
  }

  @override
  Future<void> close() {
    _currentStream?.cancel();
    return super.close();
  }
}
