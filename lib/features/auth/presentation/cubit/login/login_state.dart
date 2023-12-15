part of 'login_cubit.dart';

enum LoginStatus {
  initial,
  uploadingContent,
  submitting,
  incrementalSave,
  success,
  sendingPasswordEmail,
  resetPasswordEmailSuccess,
  roleTypeSelected,
  pinSaveSuccessful,
  error
}

// ignore: must_be_immutable
class LoginState extends Equatable {
  final LoginStatus status;
  final String email;
  final String password;
  final bool? emailVerified;
  final bool? mfaOn;
  final User? user;
  final TuiiRoleType? roleType;
  final bool? userAgreedToTerms;
  final String? phoneNumber;
  final bool? phoneVerified;
  final String? userId;
  final String? provider;
  final String? firstName;
  final String? lastName;
  final DateTime? birthDate;
  final String? address;
  final String? bio;
  final bool? userHasConfirmedLegalAge;
  final Failure? failure;

  bool get isFormValid => email.isNotEmpty && password.isNotEmpty;

  final bool? personalInfoSaveRequired;
  final bool? phoneNumberSaveRequired;

  // Parent Stuff
  final bool? childrenSaveRequired;
  final List<ChildRegistrationModel>? children;
  int? saCode1;
  int? saCode2;
  int? saCode3;
  int? saCode4;
  int? saCode1Confirm;
  int? saCode2Confirm;
  int? saCode3Confirm;
  int? saCode4Confirm;

  LoginState({
    required this.status,
    required this.email,
    required this.password,
    this.emailVerified,
    this.mfaOn,
    this.user,
    this.roleType,
    this.userAgreedToTerms,
    this.phoneNumber,
    this.phoneVerified,
    this.userId,
    this.provider,
    this.firstName,
    this.lastName,
    this.birthDate,
    this.address,
    this.bio,
    this.userHasConfirmedLegalAge,
    this.failure,
    this.personalInfoSaveRequired,
    this.phoneNumberSaveRequired,
    this.childrenSaveRequired,
    this.children,
    this.saCode1,
    this.saCode2,
    this.saCode3,
    this.saCode4,
    this.saCode1Confirm,
    this.saCode2Confirm,
    this.saCode3Confirm,
    this.saCode4Confirm,
  });

  factory LoginState.initial() {
    return LoginState(
        email: '',
        password: '',
        status: LoginStatus.initial,
        roleType: TuiiRoleType.unknown,
        userAgreedToTerms: false,
        failure: Failure.empty());
  }

  LoginState copyWith({
    LoginStatus? status,
    String? email,
    String? password,
    bool? emailVerified,
    bool? mfaOn,
    User? user,
    TuiiRoleType? roleType,
    bool? userAgreedToTerms,
    String? phoneNumber,
    bool? phoneVerified,
    String? userId,
    String? provider,
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    String? address,
    String? bio,
    bool? userHasConfirmedLegalAge,
    Failure? failure,
    bool? personalInfoSaveRequired,
    bool? phoneNumberSaveRequired,
    bool? childrenSaveRequired,
    List<ChildRegistrationModel>? children,
    int? saCode1,
    int? saCode2,
    int? saCode3,
    int? saCode4,
    int? saCode1Confirm,
    int? saCode2Confirm,
    int? saCode3Confirm,
    int? saCode4Confirm,
  }) {
    return LoginState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      emailVerified: emailVerified ?? this.emailVerified,
      mfaOn: mfaOn ?? this.mfaOn,
      user: user ?? this.user,
      roleType: roleType ?? this.roleType,
      userAgreedToTerms: userAgreedToTerms ?? this.userAgreedToTerms,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      userId: userId ?? this.userId,
      provider: provider ?? this.provider,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      address: address ?? this.address,
      bio: bio ?? this.bio,
      userHasConfirmedLegalAge:
          userHasConfirmedLegalAge ?? this.userHasConfirmedLegalAge,
      failure: failure ?? this.failure,
      personalInfoSaveRequired:
          personalInfoSaveRequired ?? this.personalInfoSaveRequired,
      phoneNumberSaveRequired:
          phoneNumberSaveRequired ?? this.phoneNumberSaveRequired,
      childrenSaveRequired: childrenSaveRequired ?? this.childrenSaveRequired,
      children: children ?? this.children,
      saCode1: saCode1 ?? this.saCode1,
      saCode2: saCode2 ?? this.saCode2,
      saCode3: saCode3 ?? this.saCode3,
      saCode4: saCode4 ?? this.saCode4,
      saCode1Confirm: saCode1Confirm ?? this.saCode1Confirm,
      saCode2Confirm: saCode2Confirm ?? this.saCode2Confirm,
      saCode3Confirm: saCode3Confirm ?? this.saCode3Confirm,
      saCode4Confirm: saCode4Confirm ?? this.saCode4Confirm,
    );
  }

  @override
  String toString() {
    return 'LoginState(status: $status, email: $email, password: $password, emailVerified: $emailVerified, mfaOn: $mfaOn, user: $user, roleType: $roleType, userAgreedToTerms: $userAgreedToTerms, phoneNumber: $phoneNumber, phoneVerified: $phoneVerified, userId: $userId, provider: $provider, firstName: $firstName, lastName: $lastName, birthDate: $birthDate, address: $address, bio: $bio, userHasConfirmedLegalAge: $userHasConfirmedLegalAge, failure: $failure, personalInfoSaveRequired: $personalInfoSaveRequired, phoneNumberSaveRequired: $phoneNumberSaveRequired, childrenSaveRequired: $childrenSaveRequired, children: $children, saCode1: $saCode1, saCode2: $saCode2, saCode3: $saCode3, saCode4: $saCode4, saCode1Confirm: $saCode1Confirm, saCode2Confirm: $saCode2Confirm, saCode3Confirm: $saCode3Confirm, saCode4Confirm: $saCode4Confirm)';
  }

  @override
  List<Object?> get props {
    return [
      status,
      email,
      password,
      emailVerified,
      mfaOn,
      user,
      roleType,
      userAgreedToTerms,
      phoneNumber,
      phoneVerified,
      userId,
      provider,
      firstName,
      lastName,
      birthDate,
      address,
      bio,
      userHasConfirmedLegalAge,
      failure,
      personalInfoSaveRequired,
      phoneNumberSaveRequired,
      childrenSaveRequired,
      children,
      saCode1,
      saCode2,
      saCode3,
      saCode4,
      saCode1Confirm,
      saCode2Confirm,
      saCode3Confirm,
      saCode4Confirm,
    ];
  }
}
