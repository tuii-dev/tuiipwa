part of 'tuii_app_bloc.dart';

enum TuiiAppStatus { loggedIn, loggedOut, success, error }

enum TuiiSideBarAnimationStatus {
  animateExpanded,
  animateCollapsed,
  complete,
  error
}

enum TuiiChangePasswordStatus {
  changingPassword,
  changePasswordSuccesful,
  changePasswordFailed,
  unknown,
}

class TuiiAppState extends Equatable {
  final TuiiAppStatus? status;
  final TuiiChangePasswordStatus? changingPasswordStatus;
  final String? message;
  final String? appVersion;
  final bool? pendingVersionUpdate;
  final bool? pendingVersionUpdateDismissed;
  final String? deepLinkCommand;
  final SystemConfigModel? systemConfig;

  const TuiiAppState({
    this.status,
    this.changingPasswordStatus,
    this.message,
    this.appVersion,
    this.pendingVersionUpdate,
    this.pendingVersionUpdateDismissed,
    this.deepLinkCommand,
    this.systemConfig,
  });

  factory TuiiAppState.initial() {
    return const TuiiAppState(
        status: TuiiAppStatus.loggedOut,
        changingPasswordStatus: TuiiChangePasswordStatus.unknown,
        pendingVersionUpdate: false);
  }

  @override
  List<Object?> get props => [
        status,
        changingPasswordStatus,
        message,
        appVersion,
        pendingVersionUpdate,
        pendingVersionUpdateDismissed,
        deepLinkCommand,
        systemConfig,
      ];

  TuiiAppState copyWith({
    TuiiAppStatus? status,
    TuiiChangePasswordStatus? changingPasswordStatus,
    String? message,
    String? appVersion,
    bool? pendingVersionUpdate,
    bool? pendingVersionUpdateDismissed,
    String? deepLinkCommand,
    SystemConfigModel? systemConfig,
  }) {
    return TuiiAppState(
      status: status ?? this.status,
      changingPasswordStatus:
          changingPasswordStatus ?? this.changingPasswordStatus,
      message: message ?? this.message,
      appVersion: appVersion ?? this.appVersion,
      pendingVersionUpdate: pendingVersionUpdate ?? this.pendingVersionUpdate,
      pendingVersionUpdateDismissed:
          pendingVersionUpdateDismissed ?? this.pendingVersionUpdateDismissed,
      deepLinkCommand: deepLinkCommand ?? this.deepLinkCommand,
      systemConfig: systemConfig ?? this.systemConfig,
    );
  }

  TuiiAppState resetDeepLinkCommand() {
    return TuiiAppState(
      status: status,
      changingPasswordStatus: changingPasswordStatus,
      message: message,
      appVersion: appVersion,
      pendingVersionUpdate: pendingVersionUpdate,
      pendingVersionUpdateDismissed: pendingVersionUpdateDismissed,
      deepLinkCommand: null,
      systemConfig: systemConfig,
    );
  }
}
