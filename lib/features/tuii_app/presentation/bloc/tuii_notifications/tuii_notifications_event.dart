part of 'tuii_notifications_bloc.dart';

abstract class TuiiNotificationEvent extends Equatable {
  const TuiiNotificationEvent();

  @override
  List<Object?> get props => [];
}

class ResetBlocEvent extends TuiiNotificationEvent {
  const ResetBlocEvent();
}

class InitializeTuiiNotificationsEvent extends TuiiNotificationEvent {
  final String userId;

  const InitializeTuiiNotificationsEvent({
    required this.userId,
  });

  @override
  List<Object> get props => [userId];
}

class UpdateTuiiNotificationsEvent extends TuiiNotificationEvent {
  final List<NotificationModel> notifications;

  const UpdateTuiiNotificationsEvent({
    required this.notifications,
  });

  @override
  List<Object> get props => [notifications];
}

class AddTuiiNotificationEvent extends TuiiNotificationEvent {
  final NotificationModel notification;
  final bool? showToast;
  final String? toastMessage;

  const AddTuiiNotificationEvent({
    required this.notification,
    this.showToast = false,
    this.toastMessage = '',
  });

  @override
  List<Object?> get props => [notification, showToast, toastMessage];
}

class UpdateTuiiNotificationEvent extends TuiiNotificationEvent {
  final NotificationModel notification;

  const UpdateTuiiNotificationEvent({
    required this.notification,
  });

  @override
  List<Object> get props => [notification];
}

class UpdateTuiiNotificationPersistEvent extends TuiiNotificationEvent {
  final NotificationModel notification;

  const UpdateTuiiNotificationPersistEvent({
    required this.notification,
  });

  @override
  List<Object> get props => [notification];
}

class UpdateTuiiNotificationListEvent extends TuiiNotificationEvent {
  final List<NotificationModel> notifications;

  const UpdateTuiiNotificationListEvent({
    required this.notifications,
  });

  @override
  List<Object> get props => [notifications];
}

class UpdateTuiiNotificationListPersistEvent extends TuiiNotificationEvent {
  final List<NotificationModel> notifications;

  const UpdateTuiiNotificationListPersistEvent({
    required this.notifications,
  });

  @override
  List<Object> get props => [notifications];
}

class DeleteTuiiNotificationEvent extends TuiiNotificationEvent {
  final NotificationModel notification;

  const DeleteTuiiNotificationEvent({
    required this.notification,
  });

  @override
  List<Object> get props => [notification];
}

class ResetTuiiNotificationStatusEvent extends TuiiNotificationEvent {
  final TuiiNotificationStatus status;

  const ResetTuiiNotificationStatusEvent({
    required this.status,
  });

  @override
  List<Object> get props => [status];
}

class UnresolveTuiiBookingNotificationsEvent extends TuiiNotificationEvent {
  final String bookingId;

  const UnresolveTuiiBookingNotificationsEvent({
    required this.bookingId,
  });

  @override
  List<Object> get props => [bookingId];
}

class RefreshLessonBookingEvent extends TuiiNotificationEvent {
  final String lessonBookingId;
  final NotificationModel notification;

  const RefreshLessonBookingEvent({
    required this.lessonBookingId,
    required this.notification,
  });

  @override
  List<Object> get props => [lessonBookingId, notification];
}
