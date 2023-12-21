import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as sc;
import 'package:tuiicore/core/common/common.dart';
import 'package:tuiicore/core/config/theme/tuii_colors.dart';
import 'package:tuiicore/core/enums/tuii_role_type.dart';
import 'package:tuiipwa/common/common.dart';
import 'package:tuiipwa/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tuiipwa/features/communications/presentation/bloc/stream_chat/stream_chat_bloc.dart';
import 'package:tuiipwa/features/communications/presentation/widgets/chat_widget.dart';
import 'package:tuiipwa/utils/pwa_i18n.dart';
import 'package:tuiipwa/utils/spacing.dart';

class StreamChatForm extends StatefulWidget {
  const StreamChatForm({super.key});

  @override
  State<StreamChatForm> createState() => _StreamChatFormState();
}

class _StreamChatFormState extends State<StreamChatForm> {
  sc.StreamChannelListController? _listController;
  late FocusNode _focus;
  late TextEditingController _controller;

  @override
  void initState() {
    _focus = FocusNode();
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final state = BlocProvider.of<StreamChatBloc>(context).state;
    final client = state.client;
    final user = state.streamChatUser;
    if (client != null && user != null) {
      setState(() {
        _listController = sc.StreamChannelListController(
          client: client,
          filter: sc.Filter.in_('members', [user.id]),
          channelStateSort: const [sc.SortOption('last_message_at')],
          limit: 100,
        );
      });
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _listController?.dispose();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StreamChatBloc, StreamChatState>(
      listenWhen: (prevState, state) =>
          prevState.invalidate != state.invalidate,
      listener: (context, state) {
        final client = state.client;
        final user = state.streamChatUser;
        if (state.invalidate == true && client != null && user != null) {
          setState(() {
            _listController = sc.StreamChannelListController(
              client: client,
              filter: sc.Filter.in_('members', [user.id]),
              channelStateSort: const [sc.SortOption('last_message_at')],
              limit: 100,
            );
          });

          BlocProvider.of<StreamChatBloc>(context)
              .add(DisableInvalidateEvent());
        }
      },
      builder: (context, state) {
        return Padding(
          padding: paddingAll20,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    height: 70,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Chats'.i18n,
                            style: const TextStyle(
                              color: TuiiColors.defaultText,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            )),
                        const SizedBox(
                          height: 8.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Container(
                              height: 38,
                              padding: EdgeInsets.zero,
                              child: TextFormField(
                                focusNode: _focus,
                                autofocus: false, // _autoFocus,
                                controller: _controller,
                                textAlignVertical: TextAlignVertical.center,
                                onFieldSubmitted: (value) =>
                                    _runSearch(state, value),
                                style: const TextStyle(fontSize: 16),
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    prefixIcon: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () =>
                                          _runSearch(state, _controller.text),
                                      child: const SizedBox(
                                        width: 18,
                                        height: 38,
                                        child: Icon(MdiIcons.magnify,
                                            color: TuiiColors.black, size: 24),
                                      ),
                                    ),
                                    suffixIcon: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () =>
                                          _runSearch(state, _controller.text),
                                      child: const SizedBox(
                                        width: 18,
                                        height: 38,
                                        child: Icon(MdiIcons.filterVariant,
                                            color: TuiiColors.black, size: 24),
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(19.0),
                                        borderSide: const BorderSide(
                                            color:
                                                TuiiColors.inactiveBackground,
                                            width: 1)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(19.0),
                                        borderSide: const BorderSide(
                                            color:
                                                TuiiColors.inactiveBackground,
                                            width: 1)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(19.0),
                                        borderSide: const BorderSide(
                                            color:
                                                TuiiColors.inactiveBackground,
                                            width: 1)),
                                    filled: true,
                                    hintStyle: const TextStyle(
                                        color: TuiiColors.muted),
                                    hintText: "Search...".i18n,
                                    hoverColor: TuiiColors.inactiveBackground,
                                    fillColor: TuiiColors.inactiveBackground),
                              )),
                        )
                      ],
                    )),
                const SizedBox(height: space5),
                Expanded(
                    child: _listController != null
                        ? sc.StreamChannelListView(
                            controller: _listController!,
                            itemBuilder: _transitionContainerBuilder,
                          )
                        : const Center(child: CircularProgressIndicator())),
              ]),
        );
      },
    );
  }

  Widget _transitionContainerBuilder(
      BuildContext context,
      List<sc.Channel> channels,
      int index,
      sc.StreamChannelListTile defaultChannelTile) {
    return OpenContainer<bool>(
      transitionType: ContainerTransitionType.fade,
      transitionDuration: const Duration(milliseconds: 300),
      openBuilder: (BuildContext _, VoidCallback openContainer) {
        return const ChatWidget();
      },
      onClosed: (ok) {},
      tappable: false,
      closedShape: const RoundedRectangleBorder(),
      closedElevation: 0.0,
      closedBuilder: (BuildContext _, VoidCallback openContainer) {
        return _channelTileBuilder(
            context, channels, index, defaultChannelTile, openContainer);
      },
    );
  }

  Widget _channelTileBuilder(
      BuildContext context,
      List<sc.Channel> channels,
      int index,
      sc.StreamChannelListTile defaultChannelTile,
      VoidCallback openContainer) {
    final channel = channels[index];
    final currentUser = BlocProvider.of<AuthBloc>(context).state.user;
    if (currentUser != null) {
      final state = BlocProvider.of<StreamChatBloc>(context).state;

      final tuii = channel.extraData['tuii'] as dynamic;
      dynamic userMap = currentUser.roleType == TuiiRoleType.tutor
          ? tuii['student']
          : tuii['tutor'];

      bool hasCustodian = userMap['hasCustodian'] ?? false;
      bool userOnline = false;
      DateTime? lastActive;

      String? userId = userMap['id']?.toString();
      if (userId != null && state.userPresenceModels != null) {
        int i = state.userPresenceModels!
            .indexWhere((model) => model.userId == userId);
        if (i > -1) {
          userOnline = state.userPresenceModels![i].online;
          lastActive = state.userPresenceModels![i].lastActive;
        }
      }

      String? imageUrl = userMap['profileImageUrl']?.toString();
      imageUrl = getImageCdnUrl(context, imageUrl, width: 50, height: 50);
      final fullName = userMap['name']?.toString() ?? '';
      String firstName = '';
      String lastName = '';
      if (fullName.isNotEmpty) {
        final parts = fullName.split(' ');
        firstName = parts[0];
        lastName = (parts.length > 1) ? parts[1] : '';
      }

      final lastMessage =
          getFirstMessage(channel.state?.messages.reversed.toList());
      String? timeAgoString;
      if (lastMessage != null) {
        if (lastActive != null) {
          if (lastMessage.createdAt.compareTo(lastActive) > 0) {
            timeAgoString = timeago.format(lastMessage.createdAt);
          } else {
            timeAgoString = timeago.format(lastActive);
          }
        } else {
          timeAgoString = timeago.format(lastMessage.createdAt);
        }
      } else {
        timeAgoString = (lastActive != null) ? timeago.format(lastActive) : '';
      }

      final subtitle = lastMessage == null
          ? ''
          : lastMessage.text?.replaceAll('\\', '') ?? '';
      final unreadCount = channel.state?.unreadCount ?? 0;
      final containerWidth = MediaQuery.of(context).size.width - 40 - 100;
      return GestureDetector(onTap: () {
        BlocProvider.of<StreamChatBloc>(context).add(ActivateChannelEvent(
            index: index, channel: channel, userOnline: userOnline));
        Future.delayed(const Duration(milliseconds: 250), () {
          openContainer();
        });
      }, child: LayoutBuilder(builder: (context, constraint) {
        final maxWidth = constraint.maxWidth;
        return ConstrainedBox(
          constraints: BoxConstraints(minWidth: maxWidth),
          child: IntrinsicWidth(
            child: Container(
                height: 72,
                width: containerWidth,
                color: Colors.transparent,
                child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              SizedBox(
                                width: 50.0,
                                height: 50.0,
                                child: imageUrl != null && imageUrl.isNotEmpty
                                    ? Center(
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              child: CachedNetworkImage(
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                                imageUrl: imageUrl,
                                              ),
                                            ),
                                            hasCustodian == true
                                                ? Positioned(
                                                    top: 0,
                                                    left: 0,
                                                    child: Container(
                                                      width: 22,
                                                      height: 22,
                                                      decoration: const BoxDecoration(
                                                          color: TuiiColors
                                                              .inactiveBackground,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          11))),
                                                      child: const Center(
                                                        child: Icon(
                                                            MdiIcons
                                                                .accountChildCircle,
                                                            color: TuiiColors
                                                                .defaultDarkColor,
                                                            size: 18),
                                                      ),
                                                    ))
                                                : const SizedBox.shrink(),
                                          ],
                                        ),
                                      )
                                    : Stack(
                                        children: [
                                          Container(
                                              width: 50.0,
                                              height: 50.0,
                                              decoration: BoxDecoration(
                                                  color: TuiiColors.primary,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.0)),
                                              child: Center(
                                                  child: Text(
                                                      getUserInitialsFromFirstAndLastName(
                                                          firstName, lastName),
                                                      style: const TextStyle(
                                                          fontSize: 18,
                                                          color:
                                                              TuiiColors.white,
                                                          fontWeight: FontWeight
                                                              .w700)))),
                                          hasCustodian == true
                                              ? Positioned(
                                                  top: 0,
                                                  left: 0,
                                                  child: Container(
                                                    width: 22,
                                                    height: 22,
                                                    decoration: const BoxDecoration(
                                                        color: TuiiColors
                                                            .inactiveBackground,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    11))),
                                                    child: const Center(
                                                      child: Icon(
                                                          MdiIcons
                                                              .accountChildCircle,
                                                          color: TuiiColors
                                                              .defaultDarkColor,
                                                          size: 18),
                                                    ),
                                                  ))
                                              : const SizedBox.shrink(),
                                        ],
                                      ),
                              ),
                              Positioned(
                                bottom: -2,
                                right: -2,
                                child: Container(
                                  width: 16.0,
                                  height: 16.0,
                                  decoration: BoxDecoration(
                                      color: userOnline
                                          ? TuiiColors.activeUser
                                          : TuiiColors.marquee1LoginColor,
                                      borderRadius: BorderRadius.circular(11.0),
                                      border: Border.all(
                                          color: TuiiColors.white, width: 2.0)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(fullName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: TuiiColors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 5),
                                // Text(subtitle,
                                //     overflow: TextOverflow.ellipsis,
                                //     style: const TextStyle(
                                //       color: TuiiColors.lightText,
                                //       fontSize: 12,
                                //     )),
                                sc.StreamTypingIndicator(
                                    channel: channel,
                                    alternativeWidget: Text(subtitle,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: TuiiColors.lightText,
                                          fontSize: 12,
                                        ))),
                              ])),
                          const SizedBox(width: 10),
                          timeAgoString != null && timeAgoString.isNotEmpty ||
                                  unreadCount > 0
                              ? SizedBox(
                                  width: 100,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(timeAgoString!,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: TuiiColors.inactiveTool,
                                              fontSize: 14,
                                            )),
                                        const Expanded(
                                            child: SizedBox.expand()),
                                        unreadCount > 0
                                            ? Container(
                                                width: 30,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                    color: TuiiColors.secondary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Center(
                                                  child: Text(
                                                      unreadCount.toString(),
                                                      style: const TextStyle(
                                                        color: TuiiColors.white,
                                                        fontSize: 10,
                                                      )),
                                                ),
                                              )
                                            : const SizedBox.shrink()
                                      ]))
                              : const SizedBox.shrink(),
                        ]))),
          ),
        );
      }));
    } else {
      return const SizedBox.shrink();
    }
  }

  void _runSearch(StreamChatState state, String value) {
    final client = state.client!;
    final user = state.streamChatUser!;
    setState(() {
      if (value.trim().isNotEmpty) {
        _listController = sc.StreamChannelListController(
          client: client,
          filter: sc.Filter.and([
            sc.Filter.in_('members', [user.id]),
            sc.Filter.autoComplete('member.user.name', value)
          ]),
          channelStateSort: const [sc.SortOption('last_message_at')],
          limit: 100,
        );
      } else {
        _listController = sc.StreamChannelListController(
          client: client,
          filter: sc.Filter.and([
            sc.Filter.in_('members', [user.id]),
          ]),
          channelStateSort: const [sc.SortOption('last_message_at')],
          limit: 100,
        );
      }
    });
  }
}
