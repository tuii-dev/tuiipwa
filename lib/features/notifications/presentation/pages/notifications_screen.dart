import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuiicore/core/config/theme/tuii_colors.dart';
import 'package:tuiipwa/features/notifications/presentation/widgets/notification_list_items_widget.dart';
import 'package:tuiipwa/features/tuii_app/presentation/bloc/tuii_notifications/tuii_notifications_bloc.dart';
import 'package:tuiipwa/utils/pwa_i18n.dart';
import 'package:tuiipwa/utils/spacing.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TuiiNotificationsBloc, TuiiNotificationsState>(
      builder: (context, state) {
        return Padding(
            padding: paddingAll20,
            child: TuiiNotificationListItems(
              notifications: state.notifications ?? [],
            ));
      },
    );
  }
}
