import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuiicore/core/common/common.dart';
import 'package:tuiicore/core/config/theme/tuii_colors.dart';
import 'package:tuiicore/core/enums/user_agent_type.dart';
import 'package:tuiientitymodels/files/tuii_app/data/models/notification_model.dart';
import 'package:tuiipwa/features/notifications/presentation/widgets/notification_tile_widget.dart';
import 'package:tuiipwa/features/tuii_app/presentation/bloc/tuii_notifications/tuii_notifications_bloc.dart';
import 'package:tuiipwa/utils/pwa_i18n.dart';

class TuiiNotificationListItems extends StatelessWidget {
  const TuiiNotificationListItems({Key? key, required this.notifications})
      : super(key: key);

  final List<NotificationModel> notifications;

  @override
  Widget build(BuildContext context) {
    // final isDesktop = getUserAgent() == UserAgentType.desktop;
    final unresolvedNotifications =
        BlocProvider.of<TuiiNotificationsBloc>(context)
            .state
            .getUnresolvedNotifications();

    return SizedBox(
      height: double.infinity,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Notifications'.i18n,
                      style: const TextStyle(
                          fontSize: 20.0,
                          color: TuiiColors.defaultText,
                          fontWeight: FontWeight.w700)),
                ),
                // unresolvedNotifications.isNotEmpty
                //     ?
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    final saveNotifications = unresolvedNotifications
                        .map((n) => n.copyWith(
                            resolved: true, resolutionDate: DateTime.now()))
                        .toList();

                    BlocProvider.of<TuiiNotificationsBloc>(context).add(
                        UpdateTuiiNotificationListEvent(
                            notifications: saveNotifications));

                    Navigator.of(context).pop();
                  },
                  child: Text('Mark All As Read'.i18n,
                      style: const TextStyle(
                          fontSize: 12.0, color: TuiiColors.defaultText)),
                )
                // : const SizedBox.shrink(),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.separated(
                  padding: EdgeInsets.zero,
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider();
                  },
                  itemCount: notifications.length,
                  itemBuilder: (_, i) =>
                      NotificationTile(notification: notifications[i])),
            ),
          ]),
    );
  }
}
