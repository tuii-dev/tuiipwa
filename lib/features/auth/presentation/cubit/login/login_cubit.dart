import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tuiiauth_domain_data_firestore/files/domain/usecases/forgot_password.dart';
import 'package:tuiiauth_domain_data_firestore/files/domain/usecases/login_email_password.dart';
import 'package:tuiiauth_domain_data_firestore/files/domain/usecases/login_google.dart';
import 'package:tuiicore/core/enums/tuii_role_type.dart';
import 'package:tuiicore/core/errors/failure.dart';
import 'package:tuiientitymodels/files/auth/data/models/child_registration_model.dart';
import 'package:tuiientitymodels/files/auth/domain/entities/user.dart';
import 'package:tuiipwa/features/auth/presentation/bloc/auth_bloc.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  StreamSubscription<AuthState>? authBlocSubscription;

  LoginCubit({
    required this.authBloc,
    required this.loginWithEmailAndPassword,
    required this.loginWithGoogleUseCase,
    // required this.loginWithAppleUseCase,
    required this.forgotPasswordUseCase,
  }) : super(LoginState.initial()) {
    authBlocSubscription = authBloc.stream.listen((state) {
      if (state.status == AuthStatus.unauthenticated) {
        emit(LoginState.initial());
      }
    });
  }

  final AuthBloc authBloc;
  final LoginWithEmailAndPasswordUseCase loginWithEmailAndPassword;
  final LoginWithGoogleUseCase loginWithGoogleUseCase;
  // final LoginWithAppleUseCase loginWithAppleUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;

  void setStatus(LoginStatus status) {
    emit(state.copyWith(status: status));
  }

  void emailChanged(String value) {
    emit(state.copyWith(email: value, status: LoginStatus.initial));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value, status: LoginStatus.initial));
  }

  void termsAcceptanceChanged(bool value) {
    emit(state.copyWith(userAgreedToTerms: value));
  }

  void roleTypeChanged(TuiiRoleType roleType) {
    emit(state.copyWith(
        status: roleType != TuiiRoleType.unknown
            ? LoginStatus.roleTypeSelected
            : LoginStatus.success,
        roleType: roleType));
  }

  // void roleTypeChangedComplete() {
  //   emit(state.copyWith(status: LoginStatus.success));
  // }

  void loginWithCredentials() async {
    // Do not execute if we dont have credentials or
    // its already submitting
    if (!state.isFormValid || state.status == LoginStatus.submitting) return;
    emit(state.copyWith(status: LoginStatus.submitting));
    // we have email and password on state
    final loginEither = await loginWithEmailAndPassword(
        LoginWithEmailAndPasswordParams(
            email: state.email, password: state.password));
    loginEither.fold((failure) {
      emit(state.copyWith(failure: failure, status: LoginStatus.error));
    }, (user) {
      emit(state.copyWith(status: LoginStatus.success));
    });
  }

  void signUpWithCredentials() async {
    // Do not execute if we dont have credentials or
    // its already submitting
    // if (state.profileImage != null && state.profileImageUrl.isEmpty) {
    //   await _uploadProfileImage();
    // }
    emit(state.copyWith(status: LoginStatus.submitting));
    // we have email and password on state
    final loginEither =
        await loginWithEmailAndPassword(LoginWithEmailAndPasswordParams(
      isSignUp: true,
      email: state.email,
      password: state.password,
    ));
    loginEither.fold((failure) {
      emit(state.copyWith(failure: failure, status: LoginStatus.error));
    }, (user) {
      emit(state.copyWith(status: LoginStatus.success));
    });
  }

  void signUpWithGoogle() async {
    // Do not execute if we dont have credentials or
    // its already submitting
    // if (state.profileImage != null && state.profileImageUrl.isEmpty) {
    //   await _uploadProfileImage();
    // }
    emit(state.copyWith(status: LoginStatus.submitting));
    // we have email and password on state
    final loginEither =
        await loginWithGoogleUseCase(const SignInWithGoogleParams());
    loginEither.fold((failure) {
      emit(state.copyWith(failure: failure, status: LoginStatus.error));
    }, (user) {
      authBloc.add(AuthUserChanged(user: user));
      Future.delayed(const Duration(milliseconds: 100), () {
        emit(state.copyWith(status: LoginStatus.success));
      });
    });
  }

  void loginWithGoogle() async {
    // Do not execute if we dont have credentials or
    // its already submitting
    emit(state.copyWith(status: LoginStatus.submitting));
    // we have email and password on state
    final loginEither =
        await loginWithGoogleUseCase(const SignInWithGoogleParams());
    loginEither.fold((failure) {
      emit(state.copyWith(failure: failure, status: LoginStatus.error));
    }, (user) {
      authBloc.add(AuthUserChanged(user: user));
      Future.delayed(const Duration(milliseconds: 100), () {
        emit(state.copyWith(status: LoginStatus.success));
      });
    });
  }

  // void loginWithApple() async {
  //   // Do not execute if we dont have credentials or
  //   // its already submitting
  //   emit(state.copyWith(status: LoginStatus.submitting));
  //   // we have email and password on state
  //   final loginEither =
  //       await loginWithAppleUseCase(const LoginWithAppleParams());
  //   loginEither.fold((failure) {
  //     emit(state.copyWith(failure: failure, status: LoginStatus.error));
  //   }, (user) {
  //     authBloc.add(AuthUserChanged(user: user));
  //     Future.delayed(const Duration(milliseconds: 100), () {
  //       emit(state.copyWith(status: LoginStatus.success));
  //     });
  //   });
  // }

  // void signUpWithApple() async {
  //   // Do not execute if we dont have credentials or
  //   // its already submitting
  //   // if (state.profileImage != null && state.profileImageUrl.isEmpty) {
  //   //   await _uploadProfileImage();
  //   // }

  //   emit(state.copyWith(status: LoginStatus.submitting));
  //   // we have email and password on state
  //   final loginEither =
  //       await loginWithAppleUseCase(const LoginWithAppleParams());
  //   loginEither.fold((failure) {
  //     emit(state.copyWith(failure: failure, status: LoginStatus.error));
  //   }, (user) {
  //     authBloc.add(AuthUserChanged(user: user));
  //     Future.delayed(const Duration(milliseconds: 100), () {
  //       emit(state.copyWith(status: LoginStatus.success));
  //     });
  //   });
  // }

  void sendPasswordResetEmail(String email) async {
    emit(state.copyWith(status: LoginStatus.sendingPasswordEmail));
    final loginEither =
        await forgotPasswordUseCase(ForgotPasswordParams(email: email));
    loginEither.fold((failure) {
      emit(state.copyWith(failure: failure, status: LoginStatus.error));
    }, (user) {
      emit(state.copyWith(status: LoginStatus.resetPasswordEmailSuccess));
    });
  }
}
