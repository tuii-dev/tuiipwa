part of 'phone_verification_cubit.dart';

enum PhoneVerificationStatus {
  initial,
  sendingSms,
  verifyingCode,
  smsSent,
  codeVerified,
  sendSmsError,
  verifyCodeError,
  error
}

class PhoneVerificationState extends Equatable {
  final PhoneVerificationStatus status;
  final int? selectedFormIndex;
  final bool? formIsReversing;
  final PhoneNumber? phoneNumber;
  final String? otpCode;
  final Failure? failure;
  final String? message;

  const PhoneVerificationState({
    required this.status,
    this.selectedFormIndex,
    this.formIsReversing,
    this.phoneNumber,
    this.otpCode,
    this.failure,
    this.message,
  });

  factory PhoneVerificationState.initial() {
    return PhoneVerificationState(
      status: PhoneVerificationStatus.initial,
      phoneNumber: PhoneNumber(isoCode: 'AU'),
      formIsReversing: false,
      selectedFormIndex: 0,
    );
  }

  PhoneVerificationState copyWith({
    PhoneVerificationStatus? status,
    int? selectedFormIndex,
    bool? formIsReversing,
    PhoneNumber? phoneNumber,
    String? otpCode,
    Failure? failure,
    String? message,
  }) {
    return PhoneVerificationState(
      status: status ?? this.status,
      selectedFormIndex: selectedFormIndex ?? this.selectedFormIndex,
      formIsReversing: formIsReversing ?? this.formIsReversing,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otpCode: otpCode ?? this.otpCode,
      failure: failure ?? this.failure,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props {
    return [
      status,
      selectedFormIndex,
      formIsReversing,
      phoneNumber,
      otpCode,
      failure,
      message,
    ];
  }

  PhoneVerificationState resetOtpCode() {
    return PhoneVerificationState(
      status: status,
      selectedFormIndex: selectedFormIndex,
      formIsReversing: formIsReversing,
      phoneNumber: phoneNumber,
      otpCode: null,
      failure: failure,
      message: message,
    );
  }
}
