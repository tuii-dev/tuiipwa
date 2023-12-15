part of 'tuii_app_bloc.dart';

abstract class TuiiAppEvent extends Equatable {
  const TuiiAppEvent();

  @override
  List<Object?> get props => [];
}

class TuiiAppInitializeModulesEvent extends TuiiAppEvent {
  final TuiiRoleType role;
  final BuildContext context;
  const TuiiAppInitializeModulesEvent({
    required this.role,
    required this.context,
  });

  @override
  List<Object> get props => [role, context];
}

class TuiiAppInitializeVersionManagementEvent extends TuiiAppEvent {
  final String version;
  const TuiiAppInitializeVersionManagementEvent({
    required this.version,
  });

  @override
  List<Object> get props => [version];
}

class TuiiAppInitializeDeepLinkingEvent extends TuiiAppEvent {
  final String deepLinkCommand;
  const TuiiAppInitializeDeepLinkingEvent({
    required this.deepLinkCommand,
  });

  @override
  List<Object> get props => [deepLinkCommand];
}

class TuiiAppResetDeepLinkingEvent extends TuiiAppEvent {
  const TuiiAppResetDeepLinkingEvent();

  @override
  List<Object> get props => [];
}

class TuiiAppInitializeSystemConfigEvent extends TuiiAppEvent {
  final SystemConfigModel systemConfig;
  const TuiiAppInitializeSystemConfigEvent({
    required this.systemConfig,
  });

  @override
  List<Object> get props => [systemConfig];
}

class TuiiAppPendingVersionUpdateEvent extends TuiiAppEvent {
  final bool pendingUpdate;
  const TuiiAppPendingVersionUpdateEvent({
    required this.pendingUpdate,
  });

  @override
  List<Object> get props => [pendingUpdate];
}

class TuiiAppPendingVersionDismissedEvent extends TuiiAppEvent {}

class TuiiAppUnloadRouteArgsEvent extends TuiiAppEvent {
  const TuiiAppUnloadRouteArgsEvent();

  @override
  List<Object?> get props => [];
}

class TuiiAppChangePassword extends TuiiAppEvent {
  final String currentPassword;
  final String newPassword;

  const TuiiAppChangePassword({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [currentPassword, newPassword];
}

class TuiiAppUpdateChangePasswordStatusEvent extends TuiiAppEvent {
  final TuiiChangePasswordStatus status;

  const TuiiAppUpdateChangePasswordStatusEvent({required this.status});

  @override
  List<Object> get props => [status];
}

class TuiiAddJobDispatchEvent extends TuiiAppEvent {
  final JobDispatchModel job;
  final User? user;

  const TuiiAddJobDispatchEvent({required this.job, this.user});

  @override
  List<Object?> get props => [user, job];
}
