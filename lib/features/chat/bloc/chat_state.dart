part of 'chat_bloc.dart';

@immutable
abstract class ChatState {
  final List<ChatMessage> messages;
  final List<Chat> chatHistory;
  final User? user; // Add user to all states

  const ChatState({
    required this.messages,
    required this.chatHistory,
    this.user,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatState &&
        other.messages == messages &&
        other.chatHistory == chatHistory &&
        other.user == user;
  }

  @override
  int get hashCode => messages.hashCode ^ chatHistory.hashCode ^ user.hashCode;
}

class ChatInitial extends ChatState {
  const ChatInitial() : super(messages: const [], chatHistory: const []);
}

class ChatLoading extends ChatState {
  const ChatLoading({
    List<ChatMessage> messages = const [],
    List<Chat> chatHistory = const [],
    User? user,
  }) : super(messages: messages, chatHistory: chatHistory, user: user);
}

class ChatStreaming extends ChatState {
  final String? currentChatId;

  const ChatStreaming({
    List<ChatMessage> messages = const [],
    List<Chat> chatHistory = const [],
    this.currentChatId,
    User? user,
  }) : super(messages: messages, chatHistory: chatHistory, user: user);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatStreaming &&
        other.messages == messages &&
        other.chatHistory == chatHistory &&
        other.currentChatId == currentChatId &&
        other.user == user;
  }

  @override
  int get hashCode =>
      messages.hashCode ^
      chatHistory.hashCode ^
      currentChatId.hashCode ^
      user.hashCode;
}

class ChatLoaded extends ChatState {
  final String? currentChatId;

  const ChatLoaded({
    List<ChatMessage> messages = const [],
    List<Chat> chatHistory = const [],
    this.currentChatId,
    User? user,
  }) : super(messages: messages, chatHistory: chatHistory, user: user);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatLoaded &&
        other.messages == messages &&
        other.chatHistory == chatHistory &&
        other.currentChatId == currentChatId &&
        other.user == user;
  }

  @override
  int get hashCode =>
      messages.hashCode ^
      chatHistory.hashCode ^
      currentChatId.hashCode ^
      user.hashCode;
}

class ChatUserProfile extends ChatState {
  const ChatUserProfile({
    List<ChatMessage> messages = const [],
    List<Chat> chatHistory = const [],
    User? user,
  }) : super(messages: messages, chatHistory: chatHistory, user: user);
}

class ChatError extends ChatState {
  final String error;

  const ChatError({
    List<ChatMessage> messages = const [],
    List<Chat> chatHistory = const [],
    required this.error,
    User? user,
  }) : super(messages: messages, chatHistory: chatHistory, user: user);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatError &&
        other.messages == messages &&
        other.chatHistory == chatHistory &&
        other.error == error &&
        other.user == user;
  }

  @override
  int get hashCode =>
      messages.hashCode ^ chatHistory.hashCode ^ error.hashCode ^ user.hashCode;
}