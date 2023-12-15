import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:tuiiapp_domain_data_firestore/file/domain/repositories/tuii_module_repository.dart';
import 'package:tuiiapp_domain_data_firestore/file/domain/usecases/add_dispatch_job.dart';
import 'package:tuiiapp_domain_data_firestore/file/domain/usecases/get_system_configuration.dart';
import 'package:tuiiauth_domain_data_firestore/files/domain/usecases/change_password.dart';
import 'package:tuiicalendar_domain_data_firestore/files/domain/repositories/lesson_booking_repository.dart';
import 'package:tuiientitymodels/files/auth/data/models/child_settings_index_change_request_model.dart';
import 'package:tuiientitymodels/files/auth/domain/entities/user.dart';
import 'package:tuiientitymodels/files/calendar/data/models/lesson_booking_model.dart';
import 'package:tuiientitymodels/files/tuii_app/data/models/main_index_stream_payload.dart';
import 'package:tuiientitymodels/files/tuii_app/data/models/system_config_model.dart';
import 'package:tuiicore/core/enums/channel_type.dart';
import 'package:tuiicore/core/enums/email_message_type.dart';
import 'package:tuiicore/core/enums/job_dispatch_type.dart';
import 'package:tuiicore/core/enums/tuii_role_type.dart';
import 'package:tuiicore/core/models/communications_job_model.dart';
import 'package:tuiicore/core/models/job_dispatch_model.dart';
import 'package:tuiicore/core/usecases/usecase.dart';
import 'package:tuiipwa/web/constants/constants.dart';

part 'tuii_app_event.dart';
part 'tuii_app_state.dart';

class TuiiAppBloc extends Bloc<TuiiAppEvent, TuiiAppState> {
  late StreamController<MainIndexStreamPayload> _selectedIndexController;
  late StreamController<int> _moduleRootRequestedNotifierController;
  late StreamController<ChildSettingsIndexChangeRequestModel>
      _childIndexChangeRequestedNotifierController;

  TuiiAppBloc(
      {required this.getSystemConfiguration,
      required this.changePassword,
      required this.addDispatchJob,
      required this.repository,
      required this.lessonBookingRepository})
      : super(TuiiAppState.initial()) {
    _selectedIndexController =
        StreamController<MainIndexStreamPayload>.broadcast();
    _moduleRootRequestedNotifierController = StreamController<int>.broadcast();
    _childIndexChangeRequestedNotifierController =
        StreamController<ChildSettingsIndexChangeRequestModel>.broadcast();

    on<TuiiAppInitializeVersionManagementEvent>(
        _mapTuiiAppInitializeVersionManagementToState);

    on<TuiiAppInitializeDeepLinkingEvent>(
        _mapTuiiAppInitializeDeepLinkingToState);

    on<TuiiAppResetDeepLinkingEvent>(_mapTuiiAppResetDeepLinkingToState);

    on<TuiiAppInitializeSystemConfigEvent>(
        _mapTuiiAppInitializeSystemConfigToState);

    on<TuiiAppPendingVersionUpdateEvent>((event, emit) => emit(state.copyWith(
        pendingVersionUpdate: event.pendingUpdate,
        pendingVersionUpdateDismissed: false)));

    on<TuiiAppPendingVersionDismissedEvent>((event, emit) =>
        emit(state.copyWith(pendingVersionUpdateDismissed: true)));

    on<TuiiAppChangePassword>((event, emit) async {
      emit(state.copyWith(
          changingPasswordStatus: TuiiChangePasswordStatus.changingPassword));

      final params = ChangePasswordParams(
          currentPassword: event.currentPassword,
          newPassword: event.newPassword);

      final changePasswordEither = await changePassword(params);

      changePasswordEither.fold((failure) {
        emit(state.copyWith(
            changingPasswordStatus:
                TuiiChangePasswordStatus.changePasswordFailed));
      }, (user) {
        emit(state.copyWith(
            changingPasswordStatus:
                TuiiChangePasswordStatus.changePasswordSuccesful));
      });
    });

    on<TuiiAppUpdateChangePasswordStatusEvent>((event, emit) =>
        emit(state.copyWith(changingPasswordStatus: event.status)));

    on<TuiiAddJobDispatchEvent>(_mapTuiiAddJobDispatchToState);
  }

  final GetSystemConfigurationUseCase getSystemConfiguration;
  final ChangePasswordUseCase changePassword;
  final AddDispatchJobUseCase addDispatchJob;
  final TuiiModuleRepository repository;
  final CalendarLessonBookingRepository lessonBookingRepository;

  @override
  Future<void> close() {
    _selectedIndexController.close();
    _moduleRootRequestedNotifierController.close();
    _childIndexChangeRequestedNotifierController.close();
    return super.close();
  }

  initVersionManagementAndDeepLinking(
      String? version, String? deepLinkCommand) {
    if (version != null) {
      add(TuiiAppInitializeVersionManagementEvent(version: version));
    }

    if (deepLinkCommand != null) {
      add(TuiiAppInitializeDeepLinkingEvent(deepLinkCommand: deepLinkCommand));
    }
  }

  Future<User> getUser(String userId) async {
    return repository.getUser(userId);
  }

  // Deep Linking
  Future<LessonBookingModel?> getLessonBooking(
      {required String bookingId,
      required TuiiRoleType roleType,
      required String userId}) async {
    return await lessonBookingRepository.getLessonBooking(
        bookingId: bookingId, roleType: roleType, userId: userId);
  }

  Stream<MainIndexStreamPayload> get mainIndexStream =>
      _selectedIndexController.stream;
  Stream<int> get moduleRootRequestedNotificationStream =>
      _moduleRootRequestedNotifierController.stream;

  Stream<ChildSettingsIndexChangeRequestModel>
      get childIndexChangeRequestedStream =>
          _childIndexChangeRequestedNotifierController.stream;

  _mapTuiiAppInitializeVersionManagementToState(
      TuiiAppInitializeVersionManagementEvent event,
      Emitter<TuiiAppState> emit) async {
    emit(state.copyWith(appVersion: event.version));

    final configEither = await getSystemConfiguration(NoParams());

    configEither.fold((failure) {
      debugPrint('Configuration stream error!');
    }, (configStream) {
      configStream.listen((configModel) {
        add(TuiiAppInitializeSystemConfigEvent(systemConfig: configModel));
        const channel = SystemConstantsProvider.channel;
        switch (channel) {
          case ChannelType.app:
            if (configModel.versioning?.app != null) {
              if (configModel.versioning!.app != event.version) {
                add(const TuiiAppPendingVersionUpdateEvent(
                    pendingUpdate: true));
              }
            }
            break;
          case ChannelType.beta:
            if (configModel.versioning?.beta != null) {
              if (configModel.versioning!.beta != event.version) {
                add(const TuiiAppPendingVersionUpdateEvent(
                    pendingUpdate: true));
              }
            }
            break;
          case ChannelType.alpha:
            if (configModel.versioning?.alpha != null) {
              if (configModel.versioning!.alpha != event.version) {
                add(const TuiiAppPendingVersionUpdateEvent(
                    pendingUpdate: true));
              }
            }
            break;
          case ChannelType.dev:
            if (configModel.versioning?.dev != null) {
              if (configModel.versioning!.dev != event.version) {
                add(const TuiiAppPendingVersionUpdateEvent(
                    pendingUpdate: true));
              }
            }
            break;
        }
      });
    });
  }

  _mapTuiiAppInitializeDeepLinkingToState(
      TuiiAppInitializeDeepLinkingEvent event,
      Emitter<TuiiAppState> emit) async {
    emit(state.copyWith(deepLinkCommand: event.deepLinkCommand));
  }

  _mapTuiiAppResetDeepLinkingToState(
      TuiiAppResetDeepLinkingEvent event, Emitter<TuiiAppState> emit) async {
    emit(state.resetDeepLinkCommand());
  }

  _mapTuiiAppInitializeSystemConfigToState(
      TuiiAppInitializeSystemConfigEvent event,
      Emitter<TuiiAppState> emit) async {
    emit(state.copyWith(systemConfig: event.systemConfig));
  }

  _mapTuiiAddJobDispatchToState(
      TuiiAddJobDispatchEvent event, Emitter<TuiiAppState> emit) async {
    bool runJob = true;
    switch (event.job.jobType) {
      case JobDispatchType.createZoomBookings:
      case JobDispatchType.healZoom400Errors:
      case JobDispatchType.healZoom429Errors:
        runJob = false;
        break;
      case JobDispatchType.sendCommunications:
        final commsJob = event.job.payload as CommunicationsJobModel;
        if (commsJob.sendEmail == true) {
          assert(commsJob.emailPayload != null);
          if (event.user!.roleType == TuiiRoleType.tutor) {
            final tutorCommsConfig =
                event.user!.onboardingState?.externalCommsConfig?.tutorConfig;
            if (tutorCommsConfig != null) {
              switch (commsJob.emailPayload!.emailType) {
                case EmailMessageType.educatorWelcome:
                case EmailMessageType
                    .learnerConnectionRequestAccepted: // Student accepted invite
                  runJob = true;
                  break;
                case EmailMessageType.educatorConnectionRequest:
                  runJob =
                      tutorCommsConfig.receiveConnectionRequestReceivedEmail ??
                          true;
                  break;
                case EmailMessageType.educatorBookingRejected:
                  runJob = tutorCommsConfig.receiveBookingRejectedEmail ?? true;
                  break;
                case EmailMessageType.educatorPaymentReceived:
                  runJob = tutorCommsConfig
                          .receiveBookingAcceptedPaymentReceivedEmail ??
                      true;
                  break;
                case EmailMessageType.educatorRefundRequested:
                  runJob = tutorCommsConfig.receiveRefundRequestedEmail ?? true;
                  break;
                case EmailMessageType.educatorRescheduleAccepted:
                  runJob =
                      tutorCommsConfig.receiveRescheduleAcceptedEmail ?? true;
                  break;
                case EmailMessageType.educatorRescheduleRejected:
                  runJob =
                      tutorCommsConfig.receiveRescheduleRejectedEmail ?? true;
                  break;
                default:
                  runJob = false;
                  break;
              }
            }
          } else {
            // Student or Parent
            final learnerCommsConfig =
                event.user!.onboardingState?.externalCommsConfig?.learnerConfig;
            if (learnerCommsConfig != null) {
              switch (commsJob.emailPayload!.emailType) {
                case EmailMessageType.learnerWelcome:
                  runJob = true;
                  break;
                case EmailMessageType.learnerConnectionRequestAccepted:
                  runJob = learnerCommsConfig
                          .receiveConnectionRequestAcceptedEmail ??
                      true;
                  break;
                case EmailMessageType.learnerConnectionRequestRejected:
                  runJob = learnerCommsConfig
                          .receiveConnectionRequestRejectedEmail ??
                      true;
                  break;
                case EmailMessageType.learnerBookingRequestReceived:
                  runJob =
                      learnerCommsConfig.receiveBookingRequestEmail ?? true;
                  break;
                case EmailMessageType.learnerPaymentSuccessful:
                  runJob =
                      learnerCommsConfig.receivePaymentSuccessfulEmail ?? true;
                  break;
                case EmailMessageType.learnerRefundApproved:
                  runJob =
                      learnerCommsConfig.receiveRefundAcceptedEmail ?? true;
                  break;
                case EmailMessageType.learnerRefundRejected:
                  runJob =
                      learnerCommsConfig.receiveRefundRejectedEmail ?? true;
                  break;
                case EmailMessageType.learnerLessonRescheduled:
                  runJob =
                      learnerCommsConfig.receiveLessonRescheduledEmail ?? true;
                  break;
                case EmailMessageType.learnerRefundReceived:
                  runJob =
                      learnerCommsConfig.receiveRefundReceivedEmail ?? true;
                  break;
                case EmailMessageType.educatorDisputeRaised:
                case EmailMessageType.systemSupportDisputeRaised:
                  runJob = true;
                  break;
                default:
                  runJob = false;
              }
            }
          }
        }
        break;
      case JobDispatchType.manageBlockChain:
      case JobDispatchType.manageLessonWorkflow:
        runJob = true;
        break;
      default:
        runJob = false;
        break;
    }

    if (runJob == true) {
      final addJobDispatchEither =
          await addDispatchJob(AddDispatchJobParams(job: event.job));

      addJobDispatchEither.fold((failure) {
        debugPrint('Dispatch job failed.  Message: ${failure.message}');
      }, (success) {
        debugPrint('Dispatch job succeeded.');
      });
    } else {
      debugPrint('Job is disbaled by user');
    }
  }
}
