part of 'identity_verification_cubit.dart';

enum IdentityVerificationStatus {
  initial,
  submitting,
  emailSent,
  emailFailed,
  retrievingMfaVerificationId,
  mfaVerificationIdRetrieved,
  mfaEnrolled,
  mfaUnenrolled,
  success,
  error
}

enum IdentityVerificationComponentType {
  mainLogin,
  mobileVerification,
  unknown
}

class IdentityVerificationState extends Equatable {
  final IdentityVerificationStatus status;
  final String? mfaVerificationId;
  final IdentityVerificationComponentType? componentType;
  final Key? componentKey;
  final Future<UserCredential> Function(MultiFactorAssertion)? resolveSignIn;
  final PhoneNumber? phoneNumber;
  final bool? isUnenrollingFromMultiFactor;
  final int? mfaCode1;
  final int? mfaCode2;
  final int? mfaCode3;
  final int? mfaCode4;
  final int? mfaCode5;
  final int? mfaCode6;
  final String? message;

  const IdentityVerificationState({
    required this.status,
    this.mfaVerificationId,
    this.componentType,
    this.componentKey,
    this.resolveSignIn,
    this.phoneNumber,
    this.isUnenrollingFromMultiFactor,
    this.mfaCode1,
    this.mfaCode2,
    this.mfaCode3,
    this.mfaCode4,
    this.mfaCode5,
    this.mfaCode6,
    this.message,
  });

  factory IdentityVerificationState.initial() {
    return IdentityVerificationState(
        status: IdentityVerificationStatus.initial,
        phoneNumber: PhoneNumber(isoCode: 'AU'),
        componentType: IdentityVerificationComponentType.unknown);
  }

  IdentityVerificationState copyWith({
    IdentityVerificationStatus? status,
    String? mfaVerificationId,
    IdentityVerificationComponentType? componentType,
    Key? componentKey,
    Future<UserCredential> Function(MultiFactorAssertion)? resolveSignIn,
    PhoneNumber? phoneNumber,
    bool? isUnenrollingFromMultiFactor,
    int? mfaCode1,
    int? mfaCode2,
    int? mfaCode3,
    int? mfaCode4,
    int? mfaCode5,
    int? mfaCode6,
    String? message,
  }) {
    return IdentityVerificationState(
      status: status ?? this.status,
      mfaVerificationId: mfaVerificationId ?? this.mfaVerificationId,
      componentType: componentType ?? this.componentType,
      componentKey: componentKey ?? this.componentKey,
      resolveSignIn: resolveSignIn ?? this.resolveSignIn,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isUnenrollingFromMultiFactor:
          isUnenrollingFromMultiFactor ?? this.isUnenrollingFromMultiFactor,
      mfaCode1: mfaCode1 ?? this.mfaCode1,
      mfaCode2: mfaCode2 ?? this.mfaCode2,
      mfaCode3: mfaCode3 ?? this.mfaCode3,
      mfaCode4: mfaCode4 ?? this.mfaCode4,
      mfaCode5: mfaCode5 ?? this.mfaCode5,
      mfaCode6: mfaCode6 ?? this.mfaCode6,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
        status,
        mfaVerificationId,
        componentType,
        componentKey,
        resolveSignIn,
        phoneNumber,
        isUnenrollingFromMultiFactor,
        mfaCode1,
        mfaCode2,
        mfaCode3,
        mfaCode4,
        mfaCode5,
        mfaCode6,
        message
      ];

  IdentityVerificationState resetMfaCode1() {
    return IdentityVerificationState(
      status: status,
      mfaVerificationId: mfaVerificationId,
      componentType: componentType,
      componentKey: componentKey,
      resolveSignIn: resolveSignIn,
      phoneNumber: phoneNumber,
      isUnenrollingFromMultiFactor: isUnenrollingFromMultiFactor,
      mfaCode1: null,
      mfaCode2: mfaCode2,
      mfaCode3: mfaCode3,
      mfaCode4: mfaCode4,
      mfaCode5: mfaCode5,
      mfaCode6: mfaCode6,
      message: message,
    );
  }

  IdentityVerificationState resetMfaCode2() {
    return IdentityVerificationState(
      status: status,
      mfaVerificationId: mfaVerificationId,
      componentType: componentType,
      componentKey: componentKey,
      resolveSignIn: resolveSignIn,
      phoneNumber: phoneNumber,
      isUnenrollingFromMultiFactor: isUnenrollingFromMultiFactor,
      mfaCode1: mfaCode1,
      mfaCode2: null,
      mfaCode3: mfaCode3,
      mfaCode4: mfaCode4,
      mfaCode5: mfaCode5,
      mfaCode6: mfaCode6,
      message: message,
    );
  }

  IdentityVerificationState resetMfaCode3() {
    return IdentityVerificationState(
      status: status,
      mfaVerificationId: mfaVerificationId,
      componentType: componentType,
      componentKey: componentKey,
      resolveSignIn: resolveSignIn,
      phoneNumber: phoneNumber,
      isUnenrollingFromMultiFactor: isUnenrollingFromMultiFactor,
      mfaCode1: mfaCode1,
      mfaCode2: mfaCode2,
      mfaCode3: null,
      mfaCode4: mfaCode4,
      mfaCode5: mfaCode5,
      mfaCode6: mfaCode6,
      message: message,
    );
  }

  IdentityVerificationState resetMfaCode4() {
    return IdentityVerificationState(
      status: status,
      mfaVerificationId: mfaVerificationId,
      componentType: componentType,
      componentKey: componentKey,
      resolveSignIn: resolveSignIn,
      phoneNumber: phoneNumber,
      isUnenrollingFromMultiFactor: isUnenrollingFromMultiFactor,
      mfaCode1: mfaCode1,
      mfaCode2: mfaCode2,
      mfaCode3: mfaCode3,
      mfaCode4: null,
      mfaCode5: mfaCode5,
      mfaCode6: mfaCode6,
      message: message,
    );
  }

  IdentityVerificationState resetMfaCode5() {
    return IdentityVerificationState(
      status: status,
      mfaVerificationId: mfaVerificationId,
      componentType: componentType,
      componentKey: componentKey,
      resolveSignIn: resolveSignIn,
      phoneNumber: phoneNumber,
      isUnenrollingFromMultiFactor: isUnenrollingFromMultiFactor,
      mfaCode1: mfaCode1,
      mfaCode2: mfaCode2,
      mfaCode3: mfaCode3,
      mfaCode4: mfaCode4,
      mfaCode5: null,
      mfaCode6: mfaCode6,
      message: message,
    );
  }

  IdentityVerificationState resetMfaCode6() {
    return IdentityVerificationState(
      status: status,
      mfaVerificationId: mfaVerificationId,
      componentType: componentType,
      componentKey: componentKey,
      resolveSignIn: resolveSignIn,
      phoneNumber: phoneNumber,
      isUnenrollingFromMultiFactor: isUnenrollingFromMultiFactor,
      mfaCode1: mfaCode1,
      mfaCode2: mfaCode2,
      mfaCode3: mfaCode3,
      mfaCode4: mfaCode4,
      mfaCode5: mfaCode5,
      mfaCode6: null,
      message: message,
    );
  }

  IdentityVerificationState resetAllMfaCodes() {
    return IdentityVerificationState(
      status: status,
      mfaVerificationId: mfaVerificationId,
      componentType: componentType,
      componentKey: componentKey,
      resolveSignIn: resolveSignIn,
      phoneNumber: phoneNumber,
      isUnenrollingFromMultiFactor: isUnenrollingFromMultiFactor,
      mfaCode1: null,
      mfaCode2: null,
      mfaCode3: null,
      mfaCode4: null,
      mfaCode5: null,
      mfaCode6: null,
      message: message,
    );
  }
}
