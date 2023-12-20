import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:tuiiauth_domain_data_firestore/files/domain/usecases/send_phone_verification_code.dart';
import 'package:tuiiauth_domain_data_firestore/files/domain/usecases/verify_phone_verification_code.dart';
import 'package:tuiicore/core/errors/failure.dart';
import 'package:tuiientitymodels/files/auth/domain/entities/user.dart' as u;

part 'phone_verification_state.dart';

class PhoneVerificationCubit extends Cubit<PhoneVerificationState> {
  PhoneVerificationCubit({
    required this.sendPhoneVerificationCode,
    required this.verifyPhoneVerificationCode,
  }) : super(PhoneVerificationState.initial());

  final SendPhoneVerificationCodeUseCase sendPhoneVerificationCode;
  final VerifyPhoneVerificationCodeUseCase verifyPhoneVerificationCode;

  void reset() {
    emit(PhoneVerificationState.initial());
  }

  void phoneNumberChanged(PhoneNumber? phoneNumber) {
    emit(state.copyWith(
      phoneNumber: phoneNumber,
    ));
  }

  Future<void> sendPhoneVerificationCodePressed({required u.User user}) async {
    if (state.phoneNumber != null) {
      emit(state.copyWith(
        status: PhoneVerificationStatus.sendingSms,
      ));

      final sendEither =
          await sendPhoneVerificationCode(SendPhoneVerificationCodeParams(
        uid: user.id!,
        firebaseToken: user.firebaseToken!,
        phoneNumber: state.phoneNumber!.phoneNumber!,
      ));

      sendEither.fold(
        (Failure failure) {
          emit(state.copyWith(
            status: PhoneVerificationStatus.sendSmsError,
            failure: failure,
          ));
        },
        (bool success) {
          if (success == true) {
            emit(state.copyWith(
              status: PhoneVerificationStatus.smsSent,
              formIsReversing: false,
              selectedFormIndex: 1,
            ));
          } else {
            emit(state.copyWith(
              status: PhoneVerificationStatus.sendSmsError,
              failure: const Failure(message: 'Failed to send sms.'),
            ));
          }
        },
      );
    }
  }

  bool codeIsComplete(String? otpCode) {
    return otpCode != null && otpCode.length == 6;
  }

  Future<void> verifyPhoneVerificationCodePressed(
      {required u.User user, required String code}) async {
    if (codeIsComplete(code)) {
      emit(state.copyWith(
        status: PhoneVerificationStatus.verifyingCode,
      ));

      final verifyEither =
          await verifyPhoneVerificationCode(VerifyPhoneVerificationCodeParams(
        uid: user.id!,
        firebaseToken: user.firebaseToken!,
        phoneNumber: state.phoneNumber!.phoneNumber!,
        verificationCode: code,
      ));

      verifyEither.fold(
        (Failure failure) {
          emit(state.copyWith(
            status: PhoneVerificationStatus.verifyCodeError,
            failure: failure,
          ));
        },
        (bool success) {
          if (success == true) {
            emit(state.copyWith(
              status: PhoneVerificationStatus.codeVerified,
            ));
          } else {
            emit(state.copyWith(
              status: PhoneVerificationStatus.verifyCodeError,
              failure: const Failure(message: 'Invalid code specified.'),
            ));
          }
        },
      );
    } else {
      emit(state.copyWith(
        status: PhoneVerificationStatus.verifyCodeError,
        failure: const Failure(message: 'Invalid code specified.'),
      ));
    }
  }
}
