import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuiicore/core/config/theme/tuii_colors.dart';
import 'package:tuiipwa/features/communications/presentation/bloc/stream_chat/stream_chat_bloc.dart';
import 'package:tuiipwa/features/communications/presentation/widgets/chat_header_widget.dart';
import 'package:tuiipwa/web/constants/constants.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as sc;

class ChatWidget extends StatelessWidget {
  const ChatWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = BlocProvider.of<StreamChatBloc>(context).state;
    return SystemConstantsProvider(
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: TuiiColors.defaultDarkColor,
            titleSpacing: 0.0,
            title: ChatHeaderWidget(
                channel: state.activeChannel!,
                userOnline: state.activeChannelUserOnline!),
          ),
          body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: sc.StreamChannel(
                      channel: state.activeChannel!,
                      child: Column(
                        children: [
                          Expanded(
                            child: sc.StreamMessageListView(
                              messageBuilder:
                                  (context, details, messages, defaultMessage) {
                                return defaultMessage.copyWith(
                                  showFlagButton: false,
                                  showEditMessage: false,
                                  showCopyMessage: true,
                                  showDeleteMessage: false,
                                  showReplyMessage: true,
                                  showThreadReplyMessage: false,
                                  showReactions: false,
                                );
                              },
                            ),
                          ),
                          const sc.StreamMessageInput(),
                        ],
                      )),
                )
              ])),
    );
  }
}
