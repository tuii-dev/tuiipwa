part of 'stream_chat_bloc.dart';

enum StreamChatStatus {
  initial,
  connecting,
  connected,
  disconnecting,
  disconnected,
  error,
}

class StreamChatState extends Equatable {
  final StreamChatStatus? status;
  final sc.StreamChatClient? client;
  final sc.User? streamChatUser;
  final sc.Channel? activeChannel;
  final int? activeChannelIndex;
  final bool? activeChannelUserOnline;
  final int? unreadCount;
  final bool? invalidate;
  final List<StreamUserPresenceModel>? userPresenceModels;

  final Failure? failure;

  const StreamChatState({
    this.status,
    this.client,
    this.streamChatUser,
    this.activeChannel,
    this.activeChannelIndex,
    this.activeChannelUserOnline,
    this.unreadCount,
    this.userPresenceModels,
    this.invalidate,
    this.failure,
  });

  factory StreamChatState.initial() {
    return const StreamChatState(
        status: StreamChatStatus.initial,
        unreadCount: 0,
        invalidate: false,
        userPresenceModels: []);
  }

  factory StreamChatState.disconnected() {
    return const StreamChatState(
        status: StreamChatStatus.disconnected,
        unreadCount: 0,
        invalidate: false,
        userPresenceModels: []);
  }

  StreamChatState copyWith({
    StreamChatStatus? status,
    sc.StreamChatClient? client,
    sc.User? streamChatUser,
    sc.Channel? activeChannel,
    int? activeChannelIndex,
    bool? activeChannelUserOnline,
    int? unreadCount,
    List<StreamUserPresenceModel>? userPresenceModels,
    bool? invalidate,
    Failure? failure,
  }) {
    return StreamChatState(
      status: status ?? this.status,
      client: client ?? this.client,
      streamChatUser: streamChatUser ?? this.streamChatUser,
      activeChannel: activeChannel ?? this.activeChannel,
      activeChannelIndex: activeChannelIndex ?? this.activeChannelIndex,
      activeChannelUserOnline:
          activeChannelUserOnline ?? this.activeChannelUserOnline,
      unreadCount: unreadCount ?? this.unreadCount,
      userPresenceModels: userPresenceModels ?? this.userPresenceModels,
      invalidate: invalidate ?? this.invalidate,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
        status,
        client,
        streamChatUser,
        activeChannel,
        activeChannelIndex,
        activeChannelUserOnline,
        unreadCount,
        userPresenceModels,
        invalidate,
        failure
      ];
}
