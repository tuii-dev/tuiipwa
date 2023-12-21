import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as sc;
import 'package:tuiicore/core/config/theme/tuii_colors.dart';
import 'package:tuiicore/core/enums/tuii_role_type.dart';
import 'package:tuiipwa/common/common.dart';
import 'package:tuiipwa/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tuiipwa/utils/spacing.dart';

class ChatHeaderWidget extends StatelessWidget {
  const ChatHeaderWidget(
      {Key? key, required this.channel, required this.userOnline})
      : super(key: key);

  final sc.Channel channel;
  final bool userOnline;

  @override
  Widget build(BuildContext context) {
    String? imageUrl;
    String fullName = '';
    String firstName = '';
    String lastName = '';
    bool hasCustodian = false;

    final currentUser = BlocProvider.of<AuthBloc>(context).state.user;
    if (currentUser != null) {
      final tuii = channel.extraData['tuii'] as dynamic;
      dynamic userMap = currentUser.roleType == TuiiRoleType.tutor
          ? tuii['student']
          : tuii['tutor'];
      hasCustodian = userMap['hasCustodian'] ?? false;

      imageUrl = userMap['profileImageUrl']?.toString();
      imageUrl = getImageCdnUrl(context, imageUrl, width: 50, height: 50);
      fullName = userMap['name']?.toString() ?? '';
      if (fullName.isNotEmpty) {
        final parts = fullName.split(' ');
        firstName = parts[0];
        lastName = (parts.length > 1) ? parts[1] : '';
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            height: 60,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? Center(
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: CachedNetworkImage(
                                        width: 40,
                                        height: 40,
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
                                                          Radius.circular(11))),
                                              child: const Center(
                                                child: Icon(
                                                    MdiIcons.accountChildCircle,
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
                                      width: 40.0,
                                      height: 40.0,
                                      decoration: BoxDecoration(
                                          color: TuiiColors.primary,
                                          borderRadius:
                                              BorderRadius.circular(25.0)),
                                      child: Center(
                                          child: Text(
                                              getUserInitialsFromFirstAndLastName(
                                                  firstName, lastName),
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  color: TuiiColors.white,
                                                  fontWeight:
                                                      FontWeight.w700)))),
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
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(11))),
                                            child: const Center(
                                              child: Icon(
                                                  MdiIcons.accountChildCircle,
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
                          width: 14.0,
                          height: 14.0,
                          decoration: BoxDecoration(
                              color: userOnline
                                  ? TuiiColors.activeUser
                                  : TuiiColors.marquee1LoginColor,
                              borderRadius: BorderRadius.circular(7.0),
                              border: Border.all(
                                  color: TuiiColors.white, width: 2.0)),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(width: space10),
                  Expanded(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(fullName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: TuiiColors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ])),
                ])),
      ],
    );
  }
}
