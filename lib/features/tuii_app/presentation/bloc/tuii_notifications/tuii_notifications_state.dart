part of 'tuii_notifications_bloc.dart';

enum TuiiNotificationStatus {
  initial,
  submitting,
  notificationSuccess,
  success,
  successOn,
  successOff,
  refreshinglessonBooking,
  lessonBookingRefreshed,
  error
}

class TuiiNotificationsState extends Equatable {
  final TuiiNotificationStatus? status;
  final int? unresolvedCount;
  final List<NotificationModel>? notifications;
  final NotificationModel? targetNotification;
  final LessonBookingModel? refreshedLessonBooking;
  final String? message;

  const TuiiNotificationsState({
    this.status,
    this.unresolvedCount,
    this.notifications,
    this.targetNotification,
    this.refreshedLessonBooking,
    this.message,
  });

  factory TuiiNotificationsState.initial() {
    return const TuiiNotificationsState(
        status: TuiiNotificationStatus.initial,
        unresolvedCount: 0,
        notifications: []);
  }

  TuiiNotificationsState copyWith({
    TuiiNotificationStatus? status,
    int? unresolvedCount,
    List<NotificationModel>? notifications,
    NotificationModel? targetNotification,
    LessonBookingModel? refreshedLessonBooking,
    String? message,
  }) {
    return TuiiNotificationsState(
      status: status ?? this.status,
      unresolvedCount: unresolvedCount ?? this.unresolvedCount,
      notifications: notifications ?? this.notifications,
      targetNotification: targetNotification ?? this.targetNotification,
      refreshedLessonBooking:
          refreshedLessonBooking ?? this.refreshedLessonBooking,
      message: message ?? this.message,
    );
  }

  List<NotificationModel> getUnresolvedNotifications() {
    return notifications != null
        ? notifications!.where((n) => n.resolved != true).toList()
        : [];
  }

  @override
  List<Object?> get props =>
      [status, unresolvedCount, notifications, refreshedLessonBooking, message];
}
