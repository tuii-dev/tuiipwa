part of 'tuii_app_link_bloc.dart';

enum TuiiAppLinkStatus {
  initial,
  empty,
  pendingCommand,
  pendingImpersonatedCommand,
  error
}

class TuiiAppLinkState extends Equatable {
  final TuiiAppLinkStatus? status;
  final AppLinkCommandModel? appLinkCommand;
  final String? message;

  const TuiiAppLinkState({
    this.status,
    this.appLinkCommand,
    this.message,
  });

  factory TuiiAppLinkState.initial() {
    return const TuiiAppLinkState(status: TuiiAppLinkStatus.initial);
  }

  factory TuiiAppLinkState.empty() {
    return const TuiiAppLinkState(status: TuiiAppLinkStatus.empty);
  }

  TuiiAppLinkState copyWith({
    TuiiAppLinkStatus? status,
    AppLinkCommandModel? appLinkCommand,
    String? message,
  }) {
    return TuiiAppLinkState(
      status: status ?? this.status,
      appLinkCommand: appLinkCommand ?? this.appLinkCommand,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, appLinkCommand, message];
}
