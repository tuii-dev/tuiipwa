import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as sc;
import 'package:tuiicommunications_domain_data_firestore/files/domain/usecases/add_channel_message.dart';
import 'package:tuiicommunications_domain_data_firestore/files/domain/usecases/create_stream_token.dart';
import 'package:tuiicommunications_domain_data_firestore/files/domain/usecases/revoke_stream_token.dart';
import 'package:tuiientitymodels/files/communications/domain/entities/stream_user_presence.dart';
import 'package:tuiicore/core/enums/blockchain_action_type.dart';
import 'package:tuiicore/core/enums/blockchain_entity_type.dart';
import 'package:tuiicore/core/enums/job_dispatch_type.dart';
import 'package:tuiicore/core/enums/tuii_role_type.dart';
import 'package:tuiicore/core/models/blockchain_job_model.dart';
import 'package:tuiicore/core/models/job_dispatch_model.dart';
import 'package:tuiientitymodels/files/auth/domain/entities/user.dart';
import 'package:tuiicore/core/errors/failure.dart';
import 'package:tuiipwa/features/tuii_app/presentation/bloc/tuii_app/tuii_app_bloc.dart';
import 'package:tuiipwa/web/constants/constants.dart';

part 'stream_chat_event.dart';
part 'stream_chat_state.dart';

class StreamChatBloc extends Bloc<StreamChatEvent, StreamChatState> {
  final String streamCreateTokenUrl =
      SystemConstantsProvider.streamCreateTokenUrl;
  final String streamRevokeTokenUrl =
      SystemConstantsProvider.streamRevokeTokenUrl;
  final String streamMessageUrl = SystemConstantsProvider.streamMessageUrl;

  StreamSubscription? _channelSubscription;

  StreamChatBloc({
    required this.createStreamToken,
    required this.revokeStreamToken,
    required this.addChannelMessage,
    required this.tuiiAppBloc,
  }) : super(StreamChatState.initial()) {
    on<ConnectToStreamChatApiEvent>(_mapConnectToStreamChatToState);

    on<DisconnectFromStreamChatApiEvent>(_mapDisconnectFromStreamChatToState);

    on<ListenUserStreamChannelsEvent>(_mapManageUserStreamChannelsToState);

    on<UnreadMessagesUpdatedEvent>(_mapUnreadMessagesUpdatedToState);

    on<ActivateChannelEvent>(_mapActivateChannelToState);

    on<StreamUserPresenceUpdatedEvent>(_mapStreamUserPresenceUpdatedToState);

    on<DisableInvalidateEvent>(
        (event, emit) => emit(state.copyWith(invalidate: false)));
  }

  final CreateStreamTokenUseCase createStreamToken;
  final RevokeStreamTokenUseCase revokeStreamToken;
  final AddChannelMessageUseCase addChannelMessage;
  final TuiiAppBloc tuiiAppBloc;

  @override
  Future<void> close() {
    _channelSubscription?.cancel();
    return super.close();
  }

  _mapConnectToStreamChatToState(
      ConnectToStreamChatApiEvent event, Emitter<StreamChatState> emit) async {
    if (state.status != StreamChatStatus.connecting &&
        state.status != StreamChatStatus.connected) {
      emit(state.copyWith(status: StreamChatStatus.connecting));

      sc.StreamChatClient? client = event.client;
      // client ??= sc.StreamChatClient(streamChatAppKey, logLevel: sc.Level.INFO);

      final name = '${event.user.firstName ?? ''} ${event.user.lastName ?? ''}';

      final token = await _getUserStreamToken(event.user);
      debugPrint('Stream chat token for user: $token');

      if (token != null) {
        final roleType = event.user.roleType ?? TuiiRoleType.student;
        final streamChatUser = sc.User(
            id: event.user.id!,
            image: event.user.profileImageUrl,
            name: name,
            extraData: {'tuiiRoleType': roleType.display});
        try {
          final streamUser = await client.connectUser(streamChatUser, token);
          debugPrint(
              '*** STREAMCHAT CONNECTED: User ${streamUser.id} connected to stream chat.  Total unread message count: ${streamUser.totalUnreadCount}');

          emit(state.copyWith(
              status: StreamChatStatus.connected,
              unreadCount: streamUser.totalUnreadCount,
              client: client,
              streamChatUser: streamChatUser));
          Future.delayed(const Duration(milliseconds: 100), () {
            add(ListenUserStreamChannelsEvent(
                client: client, user: streamUser));
          });
        } catch (e) {
          const msg = 'An error occurred connecting to the stream chat api.';
          debugPrint(msg);
          emit(state.copyWith(
              status: StreamChatStatus.error,
              failure: const Failure(message: msg)));
        }
      } else {
        const msg = 'An error occurred attempting to create stream chat token.';
        debugPrint(msg);
        emit(state.copyWith(
            status: StreamChatStatus.error,
            failure: const Failure(message: msg)));
      }
    }
  }

  _mapDisconnectFromStreamChatToState(DisconnectFromStreamChatApiEvent event,
      Emitter<StreamChatState> emit) async {
    emit(state.copyWith(status: StreamChatStatus.disconnecting));
    final client = state.client;

    if (client != null) {
      try {
        await client.disconnectUser();

        _channelSubscription?.cancel();

        emit(StreamChatState.disconnected());
      } catch (e) {
        const msg = 'An error occurred disconnecting from the stream chat api.';
        debugPrint(msg);
        emit(state.copyWith(
            status: StreamChatStatus.error,
            failure: const Failure(message: msg)));
      }
    }
  }

  _mapUnreadMessagesUpdatedToState(
      UnreadMessagesUpdatedEvent event, Emitter<StreamChatState> emit) {
    if (state.unreadCount != event.unreadCount) {
      emit(state.copyWith(unreadCount: event.unreadCount));
    }
  }

  _mapStreamUserPresenceUpdatedToState(
      StreamUserPresenceUpdatedEvent event, Emitter<StreamChatState> emit) {
    emit(state.copyWith(userPresenceModels: event.models));
  }

  _mapManageUserStreamChannelsToState(ListenUserStreamChannelsEvent event,
      Emitter<StreamChatState> emit) async {
    if (state.status == StreamChatStatus.connected) {
      final client = event.client;
      final currentUserId = state.streamChatUser!.id;

      _queryStreamChannels(client, currentUserId, true);
      final screenedBlockChainTypes = [
        'connection.recovered',
        'connection.changed',
        'user.watching.stop',
        'user.watching.start',
      ];

      _channelSubscription = client.on().listen((sc.Event e) {
        final type = e.type.toLowerCase();

        if (!screenedBlockChainTypes.contains(type)) {
          final channelId = e.channelId;
          final parts = channelId?.split('_');
          final tutorId = parts != null && parts.isNotEmpty ? parts[0] : '';
          final studentId = parts != null && parts.isNotEmpty ? parts[1] : '';
          final payload = e.toJson();
          payload['tutorId'] = tutorId;
          payload['studentId'] = studentId;

          final job = BlockChainJobModel(
            entityType: BlockChainEntityType.chats,
            actionType: BlockChainActionType.create,
            payload: payload,
          );

          tuiiAppBloc.add(TuiiAddJobDispatchEvent(
              job: JobDispatchModel(
                  jobType: JobDispatchType.manageBlockChain, payload: job)));
        }
        if (e.totalUnreadCount != null) {
          debugPrint('unread messages count is now: ${e.totalUnreadCount}');
          if (e.totalUnreadCount != state.unreadCount) {
            add(UnreadMessagesUpdatedEvent(unreadCount: e.totalUnreadCount!));
          }
          return;
        }

        if (e.unreadChannels != null) {
          debugPrint('unread channels count is now: ${e.unreadChannels}');
          return;
        }

        switch (type) {
          case 'user.presence.changed':
            debugPrint('user.presence.changed event recieved');
            final user = e.user;
            if (user != null) {
              List<StreamUserPresenceModel> statePresenceModels =
                  List.from(state.userPresenceModels ?? []);

              int i = statePresenceModels
                  .indexWhere((model) => model.userId == user.id);

              if (i > -1) {
                statePresenceModels[i] =
                    statePresenceModels[i].copyWith(online: user.online);

                add(StreamUserPresenceUpdatedEvent(
                    models: statePresenceModels));
              }
            }
            break;
          case 'notification.added_to_channel':
            if (e.member?.userId == currentUserId) {
              _queryStreamChannels(client, currentUserId, false);
            }
            break;
        }
      });
    }
  }

  _mapActivateChannelToState(
      ActivateChannelEvent event, Emitter<StreamChatState> emit) {
    emit(state.copyWith(
        activeChannelIndex: event.index,
        activeChannel: event.channel,
        activeChannelUserOnline: event.userOnline));
  }

  _queryStreamChannels(
      sc.StreamChatClient client, String currentUserId, bool watch) async {
    client
        .queryChannels(
      filter: sc.Filter.in_('members', [currentUserId]),
      channelStateSort: const [sc.SortOption('last_message_at')],
      watch: watch,
    )
        .listen((channels) async {
      List<String> userIds = [];
      for (var channel in channels) {
        final channelId = channel.id;
        if (channelId != null) {
          debugPrint('Received queryChannel update for channel $channelId');
          final ids = channelId.split('_');
          if (ids[0] != currentUserId) {
            userIds.add(ids[0]);
          } else {
            userIds.add(ids[1]);
          }
        }
      }

      bool invalidate = false;
      if (userIds.isNotEmpty) {
        List<StreamUserPresenceModel> statePresenceModels =
            List.from(state.userPresenceModels ?? []);

        for (var id in userIds) {
          int i = statePresenceModels.indexWhere((model) => model.userId == id);
          if (i == -1) {
            invalidate = true;
            final result = await client.queryUsers(
              filter: sc.Filter.in_('id', [id]),
              presence: true,
            );
            if (result.users.isNotEmpty) {
              final online = result.users[0].online;
              final lastActive = result.users[0].lastActive;
              statePresenceModels.add(StreamUserPresenceModel(
                  userId: id, online: online, lastActive: lastActive));
            }
          }
        }

        add(StreamUserPresenceUpdatedEvent(
            models: statePresenceModels, invalidate: invalidate));
      }
    });
  }

  Future<String?> _getUserStreamToken(User user) async {
    final params = CreateStreamTokenParams(
        userId: user.id!,
        streamCreateTokenUrl: streamCreateTokenUrl,
        firebaseToken: user.firebaseToken!);

    final tokenEither = await createStreamToken(params);

    return tokenEither.fold((failure) {
      debugPrint('Error: ${failure.message}');
      return null;
    }, (response) async {
      return response.streamToken;
    });
  }

  // Future<bool> _revokeUserStreamToken(User user) async {
  //   final params = RevokeStreamTokenParams(
  //       userId: user.id!,
  //       streamRevokeTokenUrl: streamRevokeTokenUrl,
  //       firebaseToken: user.firebaseToken!);

  //   final tokenEither = await revokeStreamToken(params);

  //   return tokenEither.fold((failure) {
  //     debugPrint('Error: ${failure.message}');
  //     return false;
  //   }, (success) async {
  //     return success;
  //   });
  // }
}
