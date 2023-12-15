part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthUserChanged extends AuthEvent {
  final User? user;
  final bool? delayStreamConnect;
  final bool? isImmediateSignUp;
  final bool? forceAppScreenRoute;

  const AuthUserChanged(
      {this.user,
      this.delayStreamConnect = false,
      this.isImmediateSignUp = false,
      this.forceAppScreenRoute = false});

  @override
  List<Object?> get props =>
      [user, delayStreamConnect, isImmediateSignUp, forceAppScreenRoute];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthRecordAppLinkCommandKeyEvent extends AuthEvent {
  final String appLinkCommandKey;

  const AuthRecordAppLinkCommandKeyEvent({
    required this.appLinkCommandKey,
  });

  @override
  List<Object> get props => [appLinkCommandKey];
}

class AuthRecordAppLinkCommandPayloadEvent extends AuthEvent {
  final String appLinkCommandPayload;

  const AuthRecordAppLinkCommandPayloadEvent({
    required this.appLinkCommandPayload,
  });

  @override
  List<Object> get props => [appLinkCommandPayload];
}
