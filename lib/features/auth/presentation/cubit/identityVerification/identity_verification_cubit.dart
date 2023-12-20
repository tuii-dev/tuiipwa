import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:tuiiauth_domain_data_firestore/files/domain/repositories/auth_repository.dart';
import 'package:tuiiauth_domain_data_firestore/files/domain/usecases/email_verification.dart';
import 'package:tuiiauth_domain_data_firestore/files/domain/usecases/get_firebase_user_email_verified.dart';
import 'package:tuiiauth_domain_data_firestore/files/domain/usecases/refresh_firebase_user.dart';
import 'package:tuiicore/core/errors/failure.dart';
import 'package:tuiicore/core/usecases/usecase.dart';
import 'package:tuiientitymodels/files/auth/data/models/mfa_response_model.dart';
import 'package:tuiipwa/utils/pwa_i18n.dart';

part 'identity_verification_state.dart';

class IdentityVerificationCubit extends Cubit<IdentityVerificationState> {
  StreamSubscription<MfaResponseModel>? _mfaSubscription;

  IdentityVerificationCubit(
      {required this.emailVerification,
      required this.refreshUser,
      required this.getIsFirebaseUserEmailVerified,
      required this.repository})
      : super(IdentityVerificationState.initial());

  final EmailVerificationUseCase emailVerification;
  final RefreshFirebaseUserUseCase refreshUser;
  final GetIsFirebaseUserEmailVierfiedUseCase getIsFirebaseUserEmailVerified;
  final AuthRepository repository;

  void sendVerificationEmail() async {
    emit(state.copyWith(status: IdentityVerificationStatus.submitting));

    final emailEither = await emailVerification(NoParams());

    emailEither.fold(
        (failure) => emit(
            state.copyWith(status: IdentityVerificationStatus.emailFailed)),
        (success) =>
            emit(state.copyWith(status: IdentityVerificationStatus.emailSent)));
  }

  void refreshFirebaseUser() async {
    final refreshEither = await refreshUser(NoParams());

    refreshEither.fold(
        (failure) =>
            emit(state.copyWith(status: IdentityVerificationStatus.error)),
        (success) =>
            emit(state.copyWith(status: IdentityVerificationStatus.success)));
  }

  Future<bool> isFirebaseUserEmailVerified() async {
    final emailEither = await getIsFirebaseUserEmailVerified(NoParams());
    return emailEither.fold((failure) {
      debugPrint('Error: ${failure.message}');
      return false;
    }, (verified) async {
      return verified;
    });
  }

  void resetState() {
    emit(state.resetAllMfaCodes().copyWith(
        status: IdentityVerificationStatus.initial,
        isUnenrollingFromMultiFactor: false,
        componentType: IdentityVerificationComponentType.unknown));
  }

  void updatePhoneNumber(PhoneNumber number) {
    emit(state.copyWith(phoneNumber: number));
  }

  void initializeMfaSessionStream(
      IdentityVerificationComponentType componentType, Key componentKey,
      {bool? isUnenrollingFromMultiFactor = false}) {
    emit(state.copyWith(
        componentType: componentType,
        componentKey: componentKey,
        isUnenrollingFromMultiFactor: isUnenrollingFromMultiFactor));
    closeMfaSessionStream();

    _mfaSubscription =
        repository.initializeMfaSessionStream()!.listen((mfaResponse) {
      switch (mfaResponse.responseType) {
        case MfaResponseType.success:
          emit(state.copyWith(
              status: IdentityVerificationStatus.mfaVerificationIdRetrieved,
              mfaVerificationId: mfaResponse.payload));
          break;
        case MfaResponseType.failed:
          emit(state.copyWith(
              status: IdentityVerificationStatus.error,
              message: mfaResponse.payload));
          break;
        case MfaResponseType.timedOut:
          emit(state.copyWith(
              status: IdentityVerificationStatus.error,
              message: mfaResponse.payload));
          break;
        default:
          break;
      }
    });
  }

  void closeMfaSessionStream({bool? isComplete = false}) {
    _mfaSubscription?.cancel();
    repository.closeMfaSessionStream();
    if (isComplete == true) {
      emit(state.copyWith(
          componentType: IdentityVerificationComponentType.unknown));
    }
  }

  Future<void> getMultiFactorVerificationCodeForEnrollment(
      String phoneNumber) async {
    emit(state.copyWith(
        status: IdentityVerificationStatus.retrievingMfaVerificationId));

    await repository.getMultiFactorVerificationCodeForEnrollment(phoneNumber);
  }

  Future<bool> enrollUserMultiFactorAuth(
      String verificationId, String smsCode) async {
    try {
      final enrolled =
          await repository.enrollUserMultiFactorAuth(verificationId, smsCode);

      if (enrolled == true) {
        closeMfaSessionStream();
      }
      return enrolled;
    } on Failure catch (err) {
      emit(state.copyWith(
          status: IdentityVerificationStatus.error,
          message: err.message ?? 'An unanticipated error occurred.'.i18n));

      return false;
    }
  }

  Future<bool> unenrollUserMultiFactorAuth() async {
    try {
      final unenrolled = await repository.unenrollUserMultiFactorAuth();
      if (unenrolled) {
        emit(state.copyWith(
            status: IdentityVerificationStatus.success,
            phoneNumber: PhoneNumber(isoCode: "AU")));
      }

      return unenrolled;
    } on Failure catch (err) {
      emit(state.copyWith(
          status: IdentityVerificationStatus.error,
          message: err.message ?? 'An unanticipated error occurred.'.i18n));

      return false;
    }
  }

  void messageMfaUnenrollSuccess() {
    emit(state.copyWith(status: IdentityVerificationStatus.mfaUnenrolled));
  }

  Future<void> getMultiFactorVerificationCodeForLogin(
      MultiFactorSession session,
      PhoneMultiFactorInfo hint,
      Future<UserCredential> Function(MultiFactorAssertion)
          resolveSignIn) async {
    emit(state.copyWith(
        status: IdentityVerificationStatus.retrievingMfaVerificationId,
        resolveSignIn: resolveSignIn));

    await repository.getMultiFactorVerificationCodeForLogin(session, hint);
  }

  Future<bool> resolveMultiFactorSignIn(
      String verificationId, String smsCode) async {
    try {
      final success = await repository.resolveMultiFactorSignIn(
          verificationId, smsCode, state.resolveSignIn!);

      return success;
    } on Failure catch (err) {
      emit(state.copyWith(
          status: IdentityVerificationStatus.error,
          message: err.message ?? 'An unanticipated error occurred.'.i18n));

      return false;
    }
  }

  void mfaCode1Changed(int? mfaCode1) {
    if (mfaCode1 != null) {
      emit(state.copyWith(mfaCode1: mfaCode1));
    } else {
      emit(state.resetMfaCode1());
    }
  }

  void mfaCode2Changed(int? mfaCode2) {
    if (mfaCode2 != null) {
      emit(state.copyWith(mfaCode2: mfaCode2));
    } else {
      emit(state.resetMfaCode2());
    }
  }

  void mfaCode3Changed(int? mfaCode3) {
    if (mfaCode3 != null) {
      emit(state.copyWith(mfaCode3: mfaCode3));
    } else {
      emit(state.resetMfaCode3());
    }
  }

  void mfaCode4Changed(int? mfaCode4) {
    if (mfaCode4 != null) {
      emit(state.copyWith(mfaCode4: mfaCode4));
    } else {
      emit(state.resetMfaCode4());
    }
  }

  void mfaCode5Changed(int? mfaCode5) {
    if (mfaCode5 != null) {
      emit(state.copyWith(mfaCode5: mfaCode5));
    } else {
      emit(state.resetMfaCode5());
    }
  }

  void mfaCode6Changed(int? mfaCode6) {
    if (mfaCode6 != null) {
      emit(state.copyWith(mfaCode6: mfaCode6));
    } else {
      emit(state.resetMfaCode6());
    }
  }
}
