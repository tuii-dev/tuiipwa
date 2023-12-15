part of 'auth_bloc.dart';

enum AuthStatus {
  unknown,
  authenticated,
  authenticatedRequiresMobileVerificationOn,
  authenticatedRequiresMobileVerificationOff,
  authenticatedRequiresOnboarding,
  unauthenticated,
  error
}

// ignore: must_be_immutable
class AuthState extends Equatable {
  User? user;
  AuthStatus? status;
  String? message;
  String? appLinkCommandKey;
  AppLinkCommandPayload? appLinkCommandPayload;
  bool? isImmediateSignUp;
  bool? forceAppScreenRoute;
  bool? emailVerified;
  bool? phoneVerified;

  AuthState({
    this.user,
    this.status = AuthStatus.unknown,
    this.message,
    this.appLinkCommandKey,
    this.appLinkCommandPayload,
    this.isImmediateSignUp = false,
    this.forceAppScreenRoute = false,
    this.emailVerified = false,
    this.phoneVerified = false,
  });

  factory AuthState.unknown() => AuthState();

  factory AuthState.authenticated({
    required User? user,
    String? appLinkCommandKey,
    AppLinkCommandPayload? appLinkCommandPayload,
    bool? isImmediateSignUp,
    bool? forceAppScreenRoute,
  }) =>
      AuthState(
        user: user,
        status: AuthStatus.authenticated,
        appLinkCommandKey: appLinkCommandKey,
        appLinkCommandPayload: appLinkCommandPayload,
        isImmediateSignUp: isImmediateSignUp,
        forceAppScreenRoute: forceAppScreenRoute,
        emailVerified: user?.emailVerified ?? false,
        phoneVerified: user?.phoneVerified ?? false,
      );

  factory AuthState.authenticatedRequiresOnboarding(
          {required User user,
          String? appLinkCommandKey,
          AppLinkCommandPayload? appLinkCommandPayload}) =>
      AuthState(
          user: user,
          status: AuthStatus.authenticatedRequiresOnboarding,
          appLinkCommandKey: appLinkCommandKey,
          appLinkCommandPayload: appLinkCommandPayload);

  factory AuthState.authenticatedRequiresMobileVerificationOn(
          {required User user,
          String? appLinkCommandKey,
          AppLinkCommandPayload? appLinkCommandPayload}) =>
      AuthState(
          user: user,
          appLinkCommandKey: appLinkCommandKey,
          appLinkCommandPayload: appLinkCommandPayload,
          status: AuthStatus.authenticatedRequiresMobileVerificationOn);

  factory AuthState.authenticatedRequiresMobileVerificationOff(
          {required User user,
          String? appLinkCommandKey,
          AppLinkCommandPayload? appLinkCommandPayload}) =>
      AuthState(
          user: user,
          appLinkCommandKey: appLinkCommandKey,
          appLinkCommandPayload: appLinkCommandPayload,
          status: AuthStatus.authenticatedRequiresMobileVerificationOff);

  factory AuthState.unauthenticated({
    String? appLinkCommandKey,
    AppLinkCommandPayload? appLinkCommandPayload,
  }) =>
      AuthState(
          status: AuthStatus.unauthenticated,
          appLinkCommandKey: appLinkCommandKey,
          appLinkCommandPayload: appLinkCommandPayload);

  factory AuthState.error({required message}) =>
      AuthState(status: AuthStatus.error, message: message);

  @override
  List<Object?> get props => [
        user,
        status,
        message,
        appLinkCommandKey,
        appLinkCommandPayload,
        isImmediateSignUp,
        forceAppScreenRoute,
        emailVerified,
        phoneVerified,
      ];

  @override
  bool get stringify => true;

  AuthState copyWith({
    String? appLinkCommandKey,
    AppLinkCommandPayload? appLinkCommandPayload,
  }) {
    return AuthState(
      user: user,
      status: status,
      message: message,
      appLinkCommandKey: appLinkCommandKey ?? this.appLinkCommandKey,
      appLinkCommandPayload:
          appLinkCommandPayload ?? this.appLinkCommandPayload,
      isImmediateSignUp: isImmediateSignUp,
      forceAppScreenRoute: forceAppScreenRoute,
      emailVerified: emailVerified,
      phoneVerified: phoneVerified,
    );
  }
}
