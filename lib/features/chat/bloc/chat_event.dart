part of 'chat_bloc.dart';

@immutable
abstract class ChatEvent {}

class SendMessage extends ChatEvent {
  final String message;

  SendMessage(this.message);
}

class InitializeStorage extends ChatEvent {}

class ClearChat extends ChatEvent {}

class LoadChatHistory extends ChatEvent {}

class LoadUserProfile extends ChatEvent {}

class RegenerateResponse extends ChatEvent {
  final String? messageContent;
  RegenerateResponse({this.messageContent});
}

class LoadSpecificChat extends ChatEvent {
  final String chatId;
  LoadSpecificChat(this.chatId);
}

class CreateNewChat extends ChatEvent {
  final String? modelUsed;
  CreateNewChat({this.modelUsed});
}

class CreateFreshChat extends ChatEvent {
  final String? modelUsed;
  CreateFreshChat({this.modelUsed});
}

class SearchChats extends ChatEvent {
  final String query;
  SearchChats(this.query);
}
