import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:tuiiapp_domain_data_firestore/file/domain/usecases/create_notification.dart';
import 'package:tuiiapp_domain_data_firestore/file/domain/usecases/delete_notification.dart';
import 'package:tuiiapp_domain_data_firestore/file/domain/usecases/get_notification_stream.dart';
import 'package:tuiiapp_domain_data_firestore/file/domain/usecases/refresh_lesson_booking.dart';
import 'package:tuiiapp_domain_data_firestore/file/domain/usecases/update_notification.dart';
import 'package:tuiiapp_domain_data_firestore/file/domain/usecases/update_notification_list.dart';
import 'package:tuiicore/core/enums/enums.dart';
import 'package:tuiientitymodels/files/calendar/data/models/lesson_booking_model.dart';
import 'package:tuiientitymodels/files/tuii_app/data/models/booking_confirmation_payload.dart';
import 'package:tuiientitymodels/files/tuii_app/data/models/notification_model.dart';
import 'package:tuiipwa/features/auth/presentation/bloc/auth_bloc.dart';

part 'tuii_notifications_event.dart';
part 'tuii_notifications_state.dart';

class TuiiNotificationsBloc
    extends Bloc<TuiiNotificationEvent, TuiiNotificationsState> {
  StreamSubscription<List<Future<NotificationModel>>>?
      _notificationsSubscription;
  bool _isInitialized = false;
  StreamSubscription<AuthState>? _authBlocSubscription;

  TuiiNotificationsBloc({
    required this.getNotificationsStream,
    required this.createNotification,
    required this.updateNotification,
    required this.updateNotificationList,
    required this.deleteNotification,
    required this.refreshLessonBooking,
    required this.authBloc,
  }) : super(TuiiNotificationsState.initial()) {
    on<ResetBlocEvent>((event, emit) => emit(TuiiNotificationsState.initial()));

    on<InitializeTuiiNotificationsEvent>(
        _mapInitializeTuiiNotificationsToState);

    on<UpdateTuiiNotificationsEvent>(_mapUpdateTuiiNotificationsToState);

    on<AddTuiiNotificationEvent>(_mapAddTuiiNotificationToState);

    on<UpdateTuiiNotificationEvent>(_mapUpdateTuiiNotificationToState);

    on<UpdateTuiiNotificationPersistEvent>(
        _mapUpdateTuiiNotificationPersistToState);

    on<UpdateTuiiNotificationListEvent>(_mapUpdateTuiiNotificationListToState);

    on<UpdateTuiiNotificationListPersistEvent>(
        _mapUpdateTuiiNotificationListPersistToState);

    on<DeleteTuiiNotificationEvent>(_mapDeleteTuiiNotificationToState);

    on<ResetTuiiNotificationStatusEvent>(
        _mapResetTuiiNotificationStatusToState);

    on<UnresolveTuiiBookingNotificationsEvent>(
        _mapUnresolveTuiiBookingNotificationsToState);

    on<RefreshLessonBookingEvent>(_mapRefreshLessonBookingEventToState);

    _authBlocSubscription = authBloc.stream.listen((authState) {
      if (authState.status == AuthStatus.unauthenticated) {
        _isInitialized = false;
        _notificationsSubscription?.cancel();
        add(const ResetBlocEvent());
      }
    });
  }

  final GetNotificationStreamUseCase getNotificationsStream;
  final CreateNotificationUseCase createNotification;
  final UpdateNotificationUseCase updateNotification;
  final UpdateNotificationListUseCase updateNotificationList;
  final DeleteNotificationUseCase deleteNotification;
  final RefreshLessonBookingUseCase refreshLessonBooking;
  final AuthBloc authBloc;

  void init(String userId) {
    if (!_isInitialized) {
      _isInitialized = true;
      add(InitializeTuiiNotificationsEvent(userId: userId));
    }
  }

  @override
  Future<void> close() {
    _authBlocSubscription?.cancel();
    _notificationsSubscription?.cancel();
    return super.close();
  }

  _mapInitializeTuiiNotificationsToState(InitializeTuiiNotificationsEvent event,
      Emitter<TuiiNotificationsState> emit) {
    emit(state.copyWith(
      status: TuiiNotificationStatus.submitting,
    ));

    final notificationsEither =
        getNotificationsStream(GetNotificationParams(userId: event.userId));

    notificationsEither.fold((failure) {
      emit(state.copyWith(
          status: TuiiNotificationStatus.error,
          message: failure.message ?? 'Failed to load notifications.'));
    }, (notificationsStream) {
      _initNotificationStream(notificationsStream);
    });
  }

  void _initNotificationStream(
      Stream<List<Future<NotificationModel>>> notificationsStream) {
    _notificationsSubscription?.cancel();
    _notificationsSubscription =
        notificationsStream.listen((notifcationFutures) async {
      final notifications = await Future.wait(notifcationFutures);
      if (notifications.isNotEmpty) {
        add(UpdateTuiiNotificationsEvent(notifications: notifications));
      }
    });
  }

  _mapUpdateTuiiNotificationsToState(UpdateTuiiNotificationsEvent event,
      Emitter<TuiiNotificationsState> emit) {
    int unresolvedCount = _getUnresolvedCount(event.notifications);

    emit(state.copyWith(
        status: TuiiNotificationStatus.success,
        unresolvedCount: unresolvedCount,
        notifications: event.notifications));
  }

  _mapAddTuiiNotificationToState(AddTuiiNotificationEvent event,
      Emitter<TuiiNotificationsState> emit) async {
    if (event.showToast == true) {
      emit(state.copyWith(
        status: TuiiNotificationStatus.notificationSuccess,
        message: event.toastMessage != null && event.toastMessage!.isNotEmpty
            ? event.toastMessage
            : 'Notification sent!',
      ));
    } else {
      emit(state.copyWith(
        status: TuiiNotificationStatus.submitting,
      ));
    }

    final createEither = await createNotification(
        CreateNotificationParams(notification: event.notification));

    createEither.fold((failure) {
      emit(state.copyWith(
          status: TuiiNotificationStatus.error,
          message: failure.message ?? 'Failed to create notification.'));
    }, (notification) {
      debugPrint('Notification successfully created.');
      emit(state.copyWith(
        status: TuiiNotificationStatus.success,
      ));
    });
  }

  _mapUpdateTuiiNotificationToState(
      UpdateTuiiNotificationEvent event, Emitter<TuiiNotificationsState> emit) {
    List<NotificationModel> notifications =
        List.from(state.notifications ?? []);

    int i = notifications.indexWhere((n) => n.id == event.notification.id);

    if (i > -1) {
      notifications[i] = event.notification;
    } else {
      notifications.add(event.notification);
    }

    final status = state.status != TuiiNotificationStatus.successOn
        ? TuiiNotificationStatus.successOn
        : TuiiNotificationStatus.successOff;

    emit(state.copyWith(status: status, notifications: notifications));

    Future.delayed(const Duration(milliseconds: 100), () {
      add(UpdateTuiiNotificationPersistEvent(notification: event.notification));
    });
  }

  _mapUpdateTuiiNotificationPersistToState(
      UpdateTuiiNotificationPersistEvent event,
      Emitter<TuiiNotificationsState> emit) async {
    final updateEither = await updateNotification(
        UpdateNotificationParams(notification: event.notification));

    updateEither.fold((failure) {
      emit(state.copyWith(
          status: TuiiNotificationStatus.error,
          message: failure.message ?? 'Failed to create notification.'));
    }, (notification) {
      debugPrint('Notification successfully created.');
      emit(state.copyWith(
        status: TuiiNotificationStatus.success,
      ));
    });
  }

  _mapUpdateTuiiNotificationListToState(UpdateTuiiNotificationListEvent event,
      Emitter<TuiiNotificationsState> emit) {
    emit(state.copyWith(
      status: TuiiNotificationStatus.submitting,
    ));

    List<NotificationModel> stateNotifications =
        List.from(state.notifications ?? []);

    for (NotificationModel notification in event.notifications) {
      int i = stateNotifications.indexWhere((n) => n.id == notification.id);

      if (i > -1) {
        stateNotifications[i] = notification;
      } else {
        stateNotifications.add(notification);
      }
    }

    final status = state.status != TuiiNotificationStatus.successOn
        ? TuiiNotificationStatus.successOn
        : TuiiNotificationStatus.successOff;

    emit(state.copyWith(status: status, notifications: stateNotifications));

    Future.delayed(const Duration(milliseconds: 100), () {
      add(UpdateTuiiNotificationListPersistEvent(
          notifications: event.notifications));
    });
  }

  _mapUpdateTuiiNotificationListPersistToState(
      UpdateTuiiNotificationListPersistEvent event,
      Emitter<TuiiNotificationsState> emit) async {
    final updateListEither = await updateNotificationList(
        UpdateNotificationListParams(notifications: event.notifications));

    updateListEither.fold((failure) {
      emit(state.copyWith(
          status: TuiiNotificationStatus.error,
          message: failure.message ?? 'Failed to update notification list.'));
    }, (notification) {
      debugPrint('Notification list successfully updated.');
      emit(state.copyWith(
        status: TuiiNotificationStatus.success,
      ));
    });
  }

  _mapDeleteTuiiNotificationToState(DeleteTuiiNotificationEvent event,
      Emitter<TuiiNotificationsState> emit) async {
    emit(state.copyWith(
      status: TuiiNotificationStatus.submitting,
    ));

    final deleteEither = await deleteNotification(
        DeleteNotificationParams(notification: event.notification));

    deleteEither.fold((failure) {
      emit(state.copyWith(
          status: TuiiNotificationStatus.error,
          message: failure.message ?? 'Failed to delete notification.'));
    }, (notification) {
      debugPrint('Notification successfully delete.');
      emit(state.copyWith(
        status: TuiiNotificationStatus.success,
      ));
    });
  }

  _mapResetTuiiNotificationStatusToState(ResetTuiiNotificationStatusEvent event,
      Emitter<TuiiNotificationsState> emit) {
    emit(state.copyWith(status: event.status, message: ''));
  }

  _mapRefreshLessonBookingEventToState(RefreshLessonBookingEvent event,
      Emitter<TuiiNotificationsState> emit) async {
    emit(
        state.copyWith(status: TuiiNotificationStatus.refreshinglessonBooking));

    final refreshEither = await refreshLessonBooking(
        RefreshLessonBookingParams(lessonBookingId: event.lessonBookingId));

    refreshEither.fold((failure) {
      emit(state.copyWith(
          status: TuiiNotificationStatus.error,
          message: failure.message ?? 'Failed to refresh lessonBooking.'));
    }, (lessonBooking) {
      debugPrint('LessonBooking successfully refreshed.');
      emit(state.copyWith(
        status: TuiiNotificationStatus.lessonBookingRefreshed,
        targetNotification: event.notification,
        refreshedLessonBooking: lessonBooking,
      ));
    });
  }

  _mapUnresolveTuiiBookingNotificationsToState(
      UnresolveTuiiBookingNotificationsEvent event,
      Emitter<TuiiNotificationsState> emit) {
    List<NotificationModel> notifications =
        List.from(state.notifications ?? []);
    List<NotificationModel> unresolveList = [];

    List<NotificationModel> unresolvedNotifications =
        notifications.where((n) => n.resolved != true).toList();

    if (unresolvedNotifications.isNotEmpty) {
      List<NotificationModel> bookingNotifications = unresolvedNotifications
          .where((n) =>
              n.notificationType ==
              NotificationType.bookingConfirmationRequested)
          .toList();

      if (bookingNotifications.isNotEmpty) {
        for (int i = 0; i < bookingNotifications.length; i++) {
          NotificationModel notif = bookingNotifications[i];
          final payload = BookingConfirmationPayload.fromMap(notif.payload!);
          if (payload.lessonBooking.id == event.bookingId) {
            notif =
                notif.copyWith(resolved: true, resolutionDate: DateTime.now());
            unresolveList.add(notif);
          }
        }
      }
    }

    if (unresolveList.isNotEmpty) {
      add(UpdateTuiiNotificationListEvent(notifications: unresolveList));
    }
  }

  int _getUnresolvedCount(List<NotificationModel> notifications) {
    return notifications.fold(0, (sum, item) {
      return (item.resolved != true) ? ++sum : sum;
    });
  }
}
