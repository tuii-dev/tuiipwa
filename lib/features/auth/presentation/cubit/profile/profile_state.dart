part of 'profile_cubit.dart';

enum ProfileStatus {
  initial,
  submitting,
  incrementalSave,
  success,
  error,
  ageRestricted,
  onboardingComplete,
  updateProfileComplete,
  challengeReauthentication,
  reauthenticationSuccessful,
  reauthenticationForUnenrollSuccessful,
  pinSaveSuccessful,
  settingsPageNavigationRequested,
}

class ProfileState extends Equatable {
  final ProfileStatus? status;
  final String? userId;
  final int? selectedFormIndex;
  final bool? formIsReversing;
  final String? profileImageUrl;
  final SelectedFile? profileImage;
  final String? provider;
  final String? firstName;
  final String? lastName;
  final DateTime? birthDate;
  final int? birthYear;
  final String? phoneNumber;
  final String? email;
  final String? newEmail;
  final bool? emailVerified;
  final bool? phoneVerified;
  final bool? mfaOn;
  final bool? reauthenticated;
  final bool? isReauthenticating;
  final String? address;
  final String? bio;
  final List<ChildRegistrationModel>? children;
  final String? pinCode;
  final String? loadingMessage;
  final Failure? failure;

  final bool? personalInfoSaveRequired;
  final bool? childrenSaveRequired;
  final bool? phoneNumberSaveRequired;
  final bool? emailConfigSaveRequired;
  final LearnerExternalCommsConfigurationModel? learnerExternalCommsConfig;
  final TutorExternalCommsConfigurationModel? tutorExternalCommsConfig;
  final bool? isInstantiatedInSettings;
  final User? originalUser;

  final bool? cancelAppRoute;
  final TuiiRoleType? roleType;

  const ProfileState({
    this.status,
    this.userId,
    this.selectedFormIndex,
    this.formIsReversing,
    this.profileImageUrl,
    this.profileImage,
    this.provider,
    this.firstName,
    this.lastName,
    this.birthDate,
    this.birthYear,
    this.phoneNumber,
    this.email,
    this.newEmail,
    this.emailVerified,
    this.phoneVerified,
    this.mfaOn,
    this.reauthenticated,
    this.isReauthenticating,
    this.address,
    this.bio,
    this.children,
    this.pinCode,
    this.loadingMessage,
    this.failure,
    this.personalInfoSaveRequired,
    this.childrenSaveRequired,
    this.phoneNumberSaveRequired,
    this.emailConfigSaveRequired,
    this.learnerExternalCommsConfig,
    this.tutorExternalCommsConfig,
    this.isInstantiatedInSettings,
    this.originalUser,
    this.cancelAppRoute,
    this.roleType,
  });

  factory ProfileState.initial() {
    return const ProfileState(
      status: ProfileStatus.initial,
      selectedFormIndex: 0,
      formIsReversing: false,
      reauthenticated: false,
      isReauthenticating: false,
      children: [],
    );
  }

  @override
  List<Object?> get props {
    return [
      status,
      userId,
      selectedFormIndex,
      formIsReversing,
      profileImageUrl,
      profileImage,
      provider,
      firstName,
      lastName,
      birthDate,
      birthYear,
      phoneNumber,
      email,
      newEmail,
      emailVerified,
      phoneVerified,
      mfaOn,
      reauthenticated,
      isReauthenticating,
      address,
      bio,
      children,
      pinCode,
      loadingMessage,
      failure,
      personalInfoSaveRequired,
      childrenSaveRequired,
      phoneNumberSaveRequired,
      emailConfigSaveRequired,
      learnerExternalCommsConfig,
      tutorExternalCommsConfig,
      isInstantiatedInSettings,
      originalUser,
      cancelAppRoute,
      roleType,
    ];
  }

  ProfileState copyWith({
    ProfileStatus? status,
    String? userId,
    int? selectedFormIndex,
    bool? formIsReversing,
    String? profileImageUrl,
    SelectedFile? profileImage,
    String? provider,
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    int? birthYear,
    String? phoneNumber,
    String? email,
    String? newEmail,
    bool? emailVerified,
    bool? phoneVerified,
    bool? mfaOn,
    bool? reauthenticated,
    bool? isReauthenticating,
    String? address,
    String? bio,
    List<ChildRegistrationModel>? children,
    String? pinCode,
    String? loadingMessage,
    Failure? failure,
    bool? personalInfoSaveRequired,
    bool? childrenSaveRequired,
    bool? phoneNumberSaveRequired,
    bool? emailConfigSaveRequired,
    LearnerExternalCommsConfigurationModel? learnerExternalCommsConfig,
    TutorExternalCommsConfigurationModel? tutorExternalCommsConfig,
    bool? isInstantiatedInSettings,
    User? originalUser,
    bool? cancelAppRoute,
    TuiiRoleType? roleType,
  }) {
    return ProfileState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      selectedFormIndex: selectedFormIndex ?? this.selectedFormIndex,
      formIsReversing: formIsReversing ?? this.formIsReversing,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      profileImage: profileImage ?? this.profileImage,
      provider: provider ?? this.provider,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      birthYear: birthYear ?? this.birthYear,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      newEmail: newEmail ?? this.newEmail,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      mfaOn: mfaOn ?? this.mfaOn,
      reauthenticated: reauthenticated ?? this.reauthenticated,
      isReauthenticating: isReauthenticating ?? this.isReauthenticating,
      address: address ?? this.address,
      bio: bio ?? this.bio,
      children: children ?? this.children,
      pinCode: pinCode ?? this.pinCode,
      loadingMessage: loadingMessage ?? this.loadingMessage,
      failure: failure ?? this.failure,
      personalInfoSaveRequired:
          personalInfoSaveRequired ?? this.personalInfoSaveRequired,
      childrenSaveRequired: childrenSaveRequired ?? this.childrenSaveRequired,
      phoneNumberSaveRequired:
          phoneNumberSaveRequired ?? this.phoneNumberSaveRequired,
      emailConfigSaveRequired:
          emailConfigSaveRequired ?? this.emailConfigSaveRequired,
      learnerExternalCommsConfig:
          learnerExternalCommsConfig ?? this.learnerExternalCommsConfig,
      tutorExternalCommsConfig:
          tutorExternalCommsConfig ?? this.tutorExternalCommsConfig,
      isInstantiatedInSettings:
          isInstantiatedInSettings ?? this.isInstantiatedInSettings,
      originalUser: originalUser ?? this.originalUser,
      cancelAppRoute: cancelAppRoute ?? this.cancelAppRoute,
      roleType: roleType ?? this.roleType,
    );
  }

  ProfileState onboardingComplete({
    ProfileStatus? status,
    bool? reauthenticated,
  }) {
    return ProfileState(
      status: status ?? this.status,
      userId: userId,
      selectedFormIndex: selectedFormIndex,
      formIsReversing: formIsReversing,
      provider: provider,
      profileImageUrl: profileImageUrl,
      profileImage: null,
      firstName: firstName,
      lastName: lastName,
      birthDate: birthDate,
      birthYear: birthYear,
      email: email,
      newEmail: '',
      phoneNumber: phoneNumber,
      emailVerified: emailVerified,
      phoneVerified: phoneVerified,
      mfaOn: mfaOn,
      reauthenticated: reauthenticated ?? this.reauthenticated,
      isReauthenticating: isReauthenticating,
      bio: bio,
      address: address,
      children: children,
      pinCode: pinCode,
      loadingMessage: loadingMessage,
      failure: failure,
      personalInfoSaveRequired: personalInfoSaveRequired,
      childrenSaveRequired: childrenSaveRequired,
      phoneNumberSaveRequired: phoneNumberSaveRequired,
      emailConfigSaveRequired: emailConfigSaveRequired,
      learnerExternalCommsConfig: learnerExternalCommsConfig,
      tutorExternalCommsConfig: tutorExternalCommsConfig,
      isInstantiatedInSettings: isInstantiatedInSettings,
      originalUser: originalUser,
      cancelAppRoute: cancelAppRoute,
      roleType: roleType,
    );
  }

  ProfileState resetBirthDate() {
    return ProfileState(
      status: status,
      userId: userId,
      selectedFormIndex: selectedFormIndex,
      formIsReversing: formIsReversing,
      profileImageUrl: profileImageUrl,
      profileImage: profileImage,
      provider: provider,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      email: email,
      newEmail: newEmail,
      emailVerified: emailVerified,
      phoneVerified: phoneVerified,
      mfaOn: mfaOn,
      reauthenticated: reauthenticated,
      isReauthenticating: isReauthenticating,
      address: address,
      bio: bio,
      children: children,
      pinCode: pinCode,
      loadingMessage: loadingMessage,
      failure: failure,
      personalInfoSaveRequired: personalInfoSaveRequired,
      childrenSaveRequired: childrenSaveRequired,
      phoneNumberSaveRequired: phoneNumberSaveRequired,
      emailConfigSaveRequired: emailConfigSaveRequired,
      learnerExternalCommsConfig: learnerExternalCommsConfig,
      tutorExternalCommsConfig: tutorExternalCommsConfig,
      isInstantiatedInSettings: isInstantiatedInSettings,
      originalUser: originalUser,
      cancelAppRoute: cancelAppRoute,
      roleType: roleType,
    );
  }

  String getDateLabel(DateTime? theDate) {
    return theDate != null ? DateFormat('dd/MM/yyyy').format(theDate) : '';
  }
}
