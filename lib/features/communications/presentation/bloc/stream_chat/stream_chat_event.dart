part of 'stream_chat_bloc.dart';

abstract class StreamChatEvent extends Equatable {
  const StreamChatEvent();

  @override
  List<Object?> get props => [];
}

class ConnectToStreamChatApiEvent extends StreamChatEvent {
  final User user;
  final sc.StreamChatClient client;
  const ConnectToStreamChatApiEvent({
    required this.user,
    required this.client,
  });

  @override
  List<Object?> get props => [user, client];
}

class DisconnectFromStreamChatApiEvent extends StreamChatEvent {
  const DisconnectFromStreamChatApiEvent();

  @override
  List<Object?> get props => [];
}

class ListenUserStreamChannelsEvent extends StreamChatEvent {
  final sc.StreamChatClient client;
  final sc.OwnUser user;
  const ListenUserStreamChannelsEvent(
      {required this.client, required this.user});

  @override
  List<Object?> get props => [client, user];
}

class UnreadMessagesUpdatedEvent extends StreamChatEvent {
  final int unreadCount;

  const UnreadMessagesUpdatedEvent({
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [unreadCount];
}

class StreamUserPresenceUpdatedEvent extends StreamChatEvent {
  final List<StreamUserPresenceModel> models;
  final bool? invalidate;

  const StreamUserPresenceUpdatedEvent({
    required this.models,
    this.invalidate = false,
  });

  @override
  List<Object?> get props => [models, invalidate];
}

class DisableInvalidateEvent extends StreamChatEvent {}

class ActivateChannelEvent extends StreamChatEvent {
  final int index;
  final sc.Channel channel;
  final bool userOnline;

  const ActivateChannelEvent({
    required this.index,
    required this.channel,
    required this.userOnline,
  });

  @override
  List<Object?> get props => [index, channel, userOnline];
}
