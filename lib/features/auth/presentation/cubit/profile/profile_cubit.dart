import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';
import 'package:email_validator/email_validator.dart';
import 'package:tuiiauth_domain_data_firestore/files/domain/repositories/auth_repository.dart';
import 'package:tuiiauth_domain_data_firestore/files/domain/usecases/email_verification.dart';
import 'package:tuiiauth_domain_data_firestore/files/domain/usecases/finalize_onboarding.dart';
import 'package:tuiiauth_domain_data_firestore/files/domain/usecases/is_email_unique.dart';
import 'package:tuiiauth_domain_data_firestore/files/domain/usecases/login_email_password.dart';
import 'package:tuiiauth_domain_data_firestore/files/domain/usecases/refresh_firebase_user.dart';
import 'package:tuiiauth_domain_data_firestore/files/domain/usecases/update_email.dart';
import 'package:tuiiauth_domain_data_firestore/files/domain/usecases/update_user.dart';
import 'package:tuiiauth_domain_data_firestore/files/domain/usecases/update_user_partition.dart';
import 'package:tuiiclassroom_domain_data_firestore/files/domain/usecases/upload_file.dart';
import 'package:tuiicore/core/common/common.dart';
import 'package:tuiicore/core/enums/email_message_type.dart';
import 'package:tuiicore/core/enums/enrollment_status_type.dart';
import 'package:tuiicore/core/enums/job_dispatch_type.dart';
import 'package:tuiicore/core/enums/resource_type.dart';
import 'package:tuiicore/core/enums/tuii_role_type.dart';
import 'package:tuiicore/core/errors/failure.dart';
import 'package:tuiicore/core/models/communications_job_model.dart';
import 'package:tuiicore/core/models/email_payload_model.dart';
import 'package:tuiicore/core/models/job_dispatch_model.dart';
import 'package:tuiicore/core/models/selected_file.dart';
import 'package:tuiientitymodels/files/auth/data/models/child_registration_model.dart';
import 'package:tuiientitymodels/files/auth/data/models/external_comms_config_model.dart';
import 'package:tuiientitymodels/files/auth/data/models/nullable_wrapper.dart';
import 'package:tuiientitymodels/files/auth/data/models/onboarding_state_model.dart';
import 'package:tuiientitymodels/files/auth/data/models/profile_completion_model.dart';
import 'package:tuiientitymodels/files/auth/domain/entities/user.dart';
import 'package:tuiipwa/common/common.dart';
import 'package:tuiipwa/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tuiipwa/features/tuii_app/presentation/bloc/tuii_app/tuii_app_bloc.dart';
import 'package:tuiipwa/utils/pwa_i18n.dart';
import 'package:tuiipwa/web/constants/constants.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  StreamSubscription<AuthState>? authBlocSubscription;
  Function deepEq = const DeepCollectionEquality().equals;

  ProfileCubit(
      {required this.finalizeOnboarding,
      required this.updateUser,
      required this.updateUserPartition,
      required this.uploadFile,
      required this.isEmailUnique,
      required this.updateEmail,
      required this.emailVerification,
      required this.loginWithEmailAndPassword,
      required this.authRepository,
      required this.refreshUser,
      required this.tuiiAppBloc,
      required this.authBloc})
      : super(ProfileState.initial()) {
    authBlocSubscription = authBloc.stream.listen((authState) async {
      if (authState.status == AuthStatus.unauthenticated) {
        emit(ProfileState.initial());
      } else if (authState.status == AuthStatus.authenticated ||
          authState.status == AuthStatus.authenticatedRequiresOnboarding) {
        final user = authState.user!;
        final phoneVerified = state.phoneVerified ?? false;

        switch (user.roleType) {
          case TuiiRoleType.parent:
            List<ChildRegistrationModel> children =
                user.onboardingState?.children ?? [];

            if (children.isNotEmpty) {
              if (children.length == 1) {
                children[0] = children[0].copyWith(
                    label: 'Child - 1'.i18n, showHeader: false, showBody: true);
              } else {
                for (int i = 0; i < children.length; i++) {
                  children[i] = children[i].copyWith(
                      label: 'Child - $i', showHeader: true, showBody: true);
                }
              }
            } else {
              if (state.children!.isEmpty) {
                addChild(ChildRegistrationModel(
                  label: 'Child - 1'.i18n,
                  lastName: state.lastName,
                  email: state.email,
                  creationTimestamp: DateTime.now(),
                  showHeader: false,
                  showBody: true,
                ));
              }
            }
            final externalCommsConfig = user
                    .onboardingState?.externalCommsConfig?.learnerConfig
                    ?.clone() ??
                LearnerExternalCommsConfigurationModel.initial();

            if (user.phoneVerified != phoneVerified) {
              emit(state.copyWith(
                originalUser: user,
                learnerExternalCommsConfig: externalCommsConfig,
                children: children,
                // emailVerified: user.emailVerified,
                phoneVerified: user.phoneVerified,
                phoneNumber: user.phoneNumber,
              ));

              // if (user.emailVerified == true) {
              //   await saveEmailVerifiedProfileCompletion(true);
              // }
            } else {
              emit(state.copyWith(
                originalUser: user,
                learnerExternalCommsConfig: externalCommsConfig,
                children: children,
              ));
            }
            break;
          case TuiiRoleType.tutor:
            final externalCommsConfig = user
                    .onboardingState?.externalCommsConfig?.tutorConfig
                    ?.clone() ??
                TutorExternalCommsConfigurationModel.initial();
            if (user.phoneVerified != phoneVerified) {
              emit(state.copyWith(
                originalUser: user,
                tutorExternalCommsConfig: externalCommsConfig,
                phoneVerified: user.phoneVerified,
                phoneNumber: user.phoneNumber,
              ));
            } else {
              emit(state.copyWith(
                originalUser: user,
                tutorExternalCommsConfig: externalCommsConfig,
              ));
            }
            break;
          case TuiiRoleType.student:
            final externalCommsConfig = user
                    .onboardingState?.externalCommsConfig?.learnerConfig
                    ?.clone() ??
                LearnerExternalCommsConfigurationModel.initial();
            if (user.phoneVerified != phoneVerified) {
              emit(state.copyWith(
                  originalUser: user,
                  learnerExternalCommsConfig: externalCommsConfig,
                  phoneNumber: user.phoneNumber,
                  phoneVerified: user.phoneVerified));
            } else {
              emit(state.copyWith(
                originalUser: user,
                learnerExternalCommsConfig: externalCommsConfig,
              ));
            }
            break;
          default:
            return;
        }
      }
    });
  }

  final FinalizeOnboardingUseCase finalizeOnboarding;
  final UpdateUserUseCase updateUser;
  final UpdateUserPartitionUseCase updateUserPartition;
  final UploadFile uploadFile;
  final IsEmailUniqueUseCase isEmailUnique;
  final UpdateEmailUseCase updateEmail;
  final EmailVerificationUseCase emailVerification;
  final LoginWithEmailAndPasswordUseCase loginWithEmailAndPassword;
  final AuthRepository authRepository;
  final RefreshFirebaseUserUseCase refreshUser;
  final TuiiAppBloc tuiiAppBloc;
  final AuthBloc authBloc;

  @override
  Future<void> close() {
    authBlocSubscription?.cancel();
    return super.close();
  }

  void init({
    required User user,
    required TuiiRoleType roleType,
    bool? isInstantiatedInSettings = false,
  }) async {
    List<ChildRegistrationModel>? children;

    if (roleType == TuiiRoleType.parent) {
      children = user.onboardingState?.children ?? [];

      if (children.isNotEmpty) {
        if (children.length == 1) {
          children[0] = children[0].copyWith(
              label: 'Child - 1'.i18n, showHeader: false, showBody: true);
        } else {
          for (int i = 0; i < children.length; i++) {
            children[i] = children[i].copyWith(
                label: 'Child - $i', showHeader: true, showBody: true);
          }
        }
      }
    }

    bool emailVerified = user.emailVerified ?? false;
    bool phoneVerified = user.phoneVerified ?? false;

    ProfileState newState;
    if (roleType == TuiiRoleType.tutor) {
      TutorExternalCommsConfigurationModel externalCommsConfig =
          user.onboardingState?.externalCommsConfig?.tutorConfig?.clone() ??
              TutorExternalCommsConfigurationModel.initial();

      newState = state.copyWith(
        status: ProfileStatus.initial,
        userId: user.id,
        provider: user.provider,
        email: user.email,
        newEmail: user.email,
        phoneNumber: user.phoneNumber,
        emailVerified: emailVerified,
        phoneVerified: phoneVerified,
        mfaOn: user.mfaOn ?? false,
        profileImageUrl: user.profileImageUrl,
        firstName: user.firstName,
        lastName: user.lastName,
        bio: user.bio,
        address: user.address,
        birthDate: user.dateOfBirth,
        children: children,
        personalInfoSaveRequired: false,
        childrenSaveRequired: false,
        phoneNumberSaveRequired: false,
        tutorExternalCommsConfig: externalCommsConfig,
        isInstantiatedInSettings: isInstantiatedInSettings,
        originalUser: user,
        cancelAppRoute: false,
        roleType: roleType,
      );
    } else {
      LearnerExternalCommsConfigurationModel externalCommsConfig =
          user.onboardingState?.externalCommsConfig?.learnerConfig?.clone() ??
              LearnerExternalCommsConfigurationModel.initial();
      newState = state.copyWith(
        status: ProfileStatus.initial,
        userId: user.id,
        provider: user.provider,
        email: user.email,
        newEmail: user.email,
        phoneNumber: user.phoneNumber,
        emailVerified: emailVerified,
        phoneVerified: phoneVerified,
        mfaOn: user.mfaOn ?? false,
        profileImageUrl: user.profileImageUrl,
        firstName: user.firstName,
        lastName: user.lastName,
        bio: user.bio,
        address: user.address,
        birthDate: user.dateOfBirth,
        children: children,
        personalInfoSaveRequired: false,
        childrenSaveRequired: false,
        phoneNumberSaveRequired: false,
        learnerExternalCommsConfig: externalCommsConfig,
        isInstantiatedInSettings: isInstantiatedInSettings,
        originalUser: user,
        cancelAppRoute: false,
        roleType: roleType,
      );
    }

    emit(newState);
  }

  void profileImageChanged(SelectedFile profileImage) {
    emit(state.copyWith(
        profileImage: profileImage,
        profileImageUrl: '',
        personalInfoSaveRequired: true));
  }

  void firstNameChanged(String firstName) {
    emit(state.copyWith(firstName: firstName, personalInfoSaveRequired: true));
  }

  void lastNameChanged(String lastName) {
    emit(state.copyWith(lastName: lastName, personalInfoSaveRequired: true));
  }

  void birthDateChanged(DateTime birthDate) {
    emit(state.copyWith(birthDate: birthDate, personalInfoSaveRequired: true));
  }

  void resetBirthDate() {
    emit(state.resetBirthDate());
  }

  void emailChanged(String email) {
    emit(state.copyWith(newEmail: email, personalInfoSaveRequired: true));
  }

  void addressChanged(String address) {
    emit(state.copyWith(address: address, personalInfoSaveRequired: true));
  }

  void bioChanged(String bio) {
    emit(state.copyWith(bio: bio, personalInfoSaveRequired: true));
  }

  void phoneNumberChanged(String phoneNumber, bool phoneVerified) {
    emit(state.copyWith(
        phoneNumber: phoneNumber,
        phoneVerified: phoneVerified,
        phoneNumberSaveRequired: true));
  }

  void emitFailure(String message) {
    emit(state.copyWith(
        status: ProfileStatus.error, failure: Failure(message: message)));

    Future.delayed(const Duration(milliseconds: 500), () {
      emit(state.copyWith(status: ProfileStatus.success));
    });
  }

  void resetStatus(ProfileStatus status) {
    emit(state.copyWith(status: status));
  }

  void resetErrorStatus() {
    emit(state.copyWith(status: ProfileStatus.success));
  }

  void completeOnboarding(User user, bool isUpdatingProfile) async {
    if (!EmailValidator.validate(state.newEmail ?? '')) {
      emit(state.copyWith(
          status: ProfileStatus.error,
          failure: Failure(message: 'Invalid email specified.'.i18n)));
      return;
    } else {
      if (state.newEmail != state.email && state.reauthenticated != true) {
        emit(state.copyWith(
            status: ProfileStatus.challengeReauthentication,
            failure: const Failure(
                message: '', code: 'REAUTHENTICATION_CHALLENGE')));
        return;
      }
    }

    emit(state.copyWith(status: ProfileStatus.submitting));

    final firstName = state.firstName ?? ""; // ?? user.firstName;
    final lastName = state.lastName ?? ""; // ?? user.lastName;

    List<String> searchTerms = [];
    if (firstName.isNotEmpty) {
      final parts = firstName.split(' ');
      for (String part in parts) {
        if (part.isNotEmpty) {
          searchTerms.add(part.toLowerCase());
        }
      }
    }

    if (lastName.isNotEmpty) {
      final parts = lastName.split(' ');
      for (String part in parts) {
        if (part.isNotEmpty) {
          searchTerms.add(part.toLowerCase());
        }
      }
    }

    if (state.address != null) {
      final parts = state.address!.split(' ');
      for (String part in parts) {
        if (part.isNotEmpty) {
          searchTerms.add(part.toLowerCase());
        }
      }
    }

    final profileCompletion = _getProfileCompletionModel(state);

    user = user.copyWith(
        roleType: state.roleType,
        hasCustodian: false,
        creationTimestamp: DateTime.now(),
        firstName: NullableWrapper<String?>.value(firstName.trim()),
        lastName: NullableWrapper<String?>.value(lastName.trim()),
        dateOfBirth: state.birthDate,
        birthYear: NullableWrapper<int?>.value(state.birthYear),
        bio: NullableWrapper<String?>.value(state.bio),
        address: NullableWrapper<String?>.value(state.address),
        profileImageUrl: state.profileImageUrl,
        emailVerified: true,
        phoneVerified: state.phoneVerified,
        phoneNumber: state.phoneNumber,
        age: state.birthDate != null ? calculateAge(state.birthDate!) : 0,
        userHasConfirmedLegalAge: true,
        profilePercentageComplete:
            profileCompletion.getProfileCompletionPercentage(
                state.roleType!), // _getProfileCompletePercentage(),
        enrollmentStatus: EnrollmentStatusType.inactive,
        userSubjects: const [],
        onboardingState: OnboardingStateModel(
            subjectTags: const [],
            profileCompletion: profileCompletion,
            externalCommsConfig: ExternalCommsConfigurationModel(
                tutorConfig: state.tutorExternalCommsConfig,
                learnerConfig: state.learnerExternalCommsConfig)),
        searchTerms: searchTerms,
        onboarded: true);

    if (state.profileImage != null) {
      // && (state.profileImageUrl == null || state.profileImageUrl!.isEmpty)) {
      final profileImageUrl =
          await _uploadProfileImage(state.profileImage!, user.id!);
      user = user.copyWith(profileImageUrl: profileImageUrl);
    }

    if (state.roleType == TuiiRoleType.parent) {
      String saCode = state.pinCode!.split('').join('-');
      debugPrint('Parental PIN unencoded: $saCode');
      user = user.copyWith(
        custodianSecurityCode: createSha256Hash(saCode),
      );

      List<ChildRegistrationModel> children = List.from(state.children ?? []);

      // Step 1: Create User id for all children if id is blank
      // if (!isUpdatingProfile) {
      for (int i = 0; i < children.length; i++) {
        final child = children[i];
        if (child.id == null || child.id!.isEmpty) {
          // final childIsNewForExistingParent = isUpdatingProfile;
          final id = authRepository.createUserEntityId();
          children[i] = children[i].copyWith(id: id, childIsNew: true);
        }
      }

      // Step 2: Create or update all child user documents
      // .       Add custodianId, and hasCustodian fields
      for (int i = 0; i < children.length; i++) {
        final child = children[i];
        await _updateUser(
            User(
              id: child.id,
              email: child.email ?? '',
              roleType: TuiiRoleType.student,
              hasCustodian: true,
              custodianId: user.id,
              custodianFirstName: firstName,
              custodianLastName: lastName,
              custodianProfileImageUrl: user.profileImageUrl,
              creationTimestamp: child.creationTimestamp,
              dateOfBirth: child.dateOfBirth,
              birthYear: child.birthYear,
              firstName: (child.firstName ?? "").trim(),
              lastName: (child.lastName ?? "").trim(),
              profileImageUrl: user.profileImageUrl,
              provider: user.provider,
              // age: _calculateAge(child.dateOfBirth ?? DateTime.now()),
              onboarded: true,
              profilePercentageComplete: 1,
              enrollmentStatus: EnrollmentStatusType.inactive,
            ),
            null,
            childIsNew: child.childIsNew ?? false);
      }

      // Step 3: update parent user onboarding state
      user = user.copyWith(
          onboardingState: user.onboardingState!.copyWith(children: children));
    }

    if (!isUpdatingProfile) {
      final success = await _finalizeOnboarding(user, state.newEmail);
      if (success) {
        if (state.newEmail != null &&
            state.newEmail!.isNotEmpty &&
            state.newEmail != state.email) {
          user = user.copyWith(email: state.newEmail);
        }
        tuiiAppBloc.add(TuiiAddJobDispatchEvent(
            user: user,
            job: JobDispatchModel(
                jobType: JobDispatchType.sendCommunications,
                payload: CommunicationsJobModel(
                    sendEmail: true,
                    sendSms: false,
                    emailPayload: EmailPayloadModel(
                        toAddresses: [user.email],
                        emailType: EmailMessageType.learnerWelcome,
                        attachments: const [],
                        substitutions: {
                          'first_name': user.firstName ?? 'there',
                          'login_url':
                              getAppUrl(SystemConstantsProvider.channel),
                        })))));
        authBloc.add(AuthUserChanged(
            user: user, delayStreamConnect: true, isImmediateSignUp: true));
        // Future.delayed(const Duration(milliseconds: 100), () {
        //   emit(state.onboardingComplete(
        //       status: ProfileStatus.onboardingComplete, reauthenticated: true));
        // });
      } else {
        emit(state.copyWith(
            status: ProfileStatus.error,
            failure: const Failure(message: 'Failed to create user!')));
      }
    } else {
      final success = await _updateUser(user, state.newEmail);
      if (success) {
        if (state.newEmail != null &&
            state.newEmail!.isNotEmpty &&
            state.newEmail != state.email) {
          user = user.copyWith(email: state.newEmail);
        }
        authBloc.add(AuthUserChanged(user: user));
        Future.delayed(const Duration(milliseconds: 100), () {
          emit(state.onboardingComplete(
              status: ProfileStatus.updateProfileComplete,
              reauthenticated: false));
        });
      } else {
        emit(state.copyWith(
            status: ProfileStatus.error,
            failure: const Failure(message: 'Failed to create user!')));
      }
    }
  }

  bool validatePersonalInfoForm() {
    Failure? failure = _validateForm(1);

    if (failure != null) {
      emit(state.copyWith(status: ProfileStatus.error, failure: failure));
      return false;
    } else {
      // emit(state.copyWith(status: ProfileStatus.success));
      return true;
    }
  }

  Future<void> savePersonalInfoForOnboardingParent() async {
    String? profileImageUrl;

    if (state.personalInfoSaveRequired == false) {
      if (state.children!.isEmpty) {
        final child = ChildRegistrationModel(
          label: 'Child - 1'.i18n,
          lastName: state.lastName,
          email: state.email,
          creationTimestamp: DateTime.now(),
          showHeader: false,
          showBody: true,
        );
        List<ChildRegistrationModel> children = List.from(state.children ?? []);
        children.add(child.copyWith(
            lastName: NullableWrapper<String?>.value(state.lastName),
            email: state.email));

        emit(state.copyWith(
            status: ProfileStatus.success,
            children: _manageChildDisplay(children),
            childrenSaveRequired: true,
            selectedFormIndex: 1,
            formIsReversing: false));
      } else {
        emit(state.copyWith(
            status: ProfileStatus.success,
            selectedFormIndex: 1,
            formIsReversing: false));
      }
      return;
    }

    emit(state.copyWith(status: ProfileStatus.incrementalSave));
    if (state.profileImage != null) {
      profileImageUrl =
          await _uploadProfileImage(state.profileImage!, state.userId!);
    }

    final profileCompletion = ProfileCompletionModel(
        personalInfo: ProfileCompletionModel.isPersonalInfoComplete(
            state.firstName, state.lastName, state.birthDate),
        emailVerified: state.emailVerified ?? false,
        phoneVerified: state.phoneVerified ?? false,
        identityVerified: ProfileCompletionModel.isIdentityVerified(
            state.emailVerified, state.phoneVerified));

    final ok = await _savePersonalInfo(
        profileImageUrl: profileImageUrl, profileCompletion: profileCompletion);

    if (ok) {
      if (state.children!.isEmpty) {
        final child = ChildRegistrationModel(
          label: 'Child - 1'.i18n,
          lastName: state.lastName,
          email: state.email,
          creationTimestamp: DateTime.now(),
          showHeader: false,
          showBody: true,
        );
        List<ChildRegistrationModel> children = List.from(state.children ?? []);
        children.add(child.copyWith(
            lastName: NullableWrapper<String?>.value(state.lastName),
            email: state.email));

        emit(state.copyWith(
            status: ProfileStatus.success,
            children: _manageChildDisplay(children),
            childrenSaveRequired: true,
            selectedFormIndex: 1,
            formIsReversing: false));
      } else {
        emit(state.copyWith(
            status: ProfileStatus.success,
            selectedFormIndex: 1,
            formIsReversing: false));
      }
    } else {
      emitFailure('Save operation failed.  Please contact support.');
    }
  }

  void reverseForm() {
    final newIndex = state.selectedFormIndex ?? 0;
    if (newIndex > 0) {
      emit(state.copyWith(
          selectedFormIndex: newIndex - 1, formIsReversing: true));
    }
  }

  // Student Stuff
  bool ensurePersonalInfoIsValid() {
    Failure? failure = _validateForm(1);
    if (failure == null) {
      if (isLegalAge(state.birthDate!)) {
        return true;
      } else {
        emit(state.copyWith(status: ProfileStatus.ageRestricted));
        return false;
      }
    } else {
      emit(state.copyWith(status: ProfileStatus.error, failure: failure));
      return false;
    }
  }

  // Parent Stuff
  // Was saveChildrenForSettings but renamed to saveChildren.
  // This is because the parent onboarding flow is now the same as the
  // parent settings flow.
  Future<bool> saveChildren(bool isInstantiatedInSettings) async {
    final failure = _validateForm(2);
    if (failure != null) {
      emitFailure(failure.message!);
      return false;
    } else {
      if (state.childrenSaveRequired == true) {
        emit(state.copyWith(status: ProfileStatus.incrementalSave));
        List<ChildRegistrationModel> children = List.from(state.children ?? []);
        for (int i = 0; i < children.length; i++) {
          final child = children[i];
          if (child.id == null || child.id!.isEmpty) {
            // final childIsNewForExistingParent = isUpdatingProfile;
            final id = authRepository.createUserEntityId();
            children[i] = children[i].copyWith(id: id, childIsNew: true);
          }
        }

        for (int i = 0; i < children.length; i++) {
          final child = children[i];
          await _updateUser(
              User(
                id: child.id,
                email: child.email ?? '',
                phoneNumber: state.phoneNumber,
                address: state.address,
                roleType: TuiiRoleType.student,
                hasCustodian: true,
                custodianId: state.userId!,
                custodianFirstName: state.firstName ?? '',
                custodianLastName: state.lastName ?? '',
                custodianProfileImageUrl: state.profileImageUrl ?? '',
                creationTimestamp: child.creationTimestamp,
                dateOfBirth: child.dateOfBirth,
                birthYear: child.birthYear,
                firstName: (child.firstName ?? "").trim(),
                lastName: (child.lastName ?? "").trim(),
                profileImageUrl: state.profileImageUrl ?? '',
                provider: state.provider ?? '',
                // age: _calculateAge(child.dateOfBirth ?? DateTime.now()),
                onboarded: true,
                profilePercentageComplete: 1,
                enrollmentStatus: EnrollmentStatusType.inactive,
              ),
              null,
              childIsNew: child.childIsNew ?? false);
        }

        final success = await _saveOnboardingState(children);
        if (success == true) {
          if (isInstantiatedInSettings == true) {
            emit(state.copyWith(
                status: ProfileStatus.success,
                childrenSaveRequired: false,
                children: children));
          } else {
            emit(state.copyWith(
                status: ProfileStatus.success,
                childrenSaveRequired: false,
                children: children,
                selectedFormIndex: 2,
                formIsReversing: false));
          }
        } else {
          emit(state.copyWith(
              status: ProfileStatus.error,
              failure: Failure(message: 'Save operation failed.'.i18n)));
        }
      } else {
        emit(state.copyWith(
            status: ProfileStatus.success,
            childrenSaveRequired: false,
            selectedFormIndex: 2,
            formIsReversing: false));
      }

      return true;
    }
  }

  void addChild(ChildRegistrationModel child) {
    List<ChildRegistrationModel> children = List.from(state.children ?? []);
    children.add(child.copyWith(
        lastName: NullableWrapper<String?>.value(state.lastName),
        email: state.email));

    emit(state.copyWith(
        children: _manageChildDisplay(children), childrenSaveRequired: true));
  }

  void removeChild(ChildRegistrationModel child) {
    List<ChildRegistrationModel> children = List.from(state.children ?? []);
    final i = _getChildIndex(child, children);
    if (i > -1) {
      debugPrint('Child index found: $i');
      children.removeAt(i);
      emit(state.copyWith(
          children: _manageChildDisplay(children), childrenSaveRequired: true));
    } else {
      debugPrint('Child index not found');
    }
  }

  void showChildBody(ChildRegistrationModel child) {
    List<ChildRegistrationModel> children = List.from(state.children ?? []);
    final i = _getChildIndex(child, children);
    if (i > -1) {
      debugPrint('Child index found: $i');
      children[i] = children[i].copyWith(showBody: true);
      emit(state.copyWith(children: children));
    } else {
      debugPrint('Child index not found');
    }
  }

  void hideChildBody(ChildRegistrationModel child) {
    List<ChildRegistrationModel> children = List.from(state.children ?? []);
    final i = _getChildIndex(child, children);
    if (i > -1) {
      debugPrint('Child index found: $i');
      children[i] = children[i].copyWith(showBody: false);
      emit(state.copyWith(children: children));
    } else {
      debugPrint('Child index not found');
    }
  }

  void childFirstNameChanged(ChildRegistrationModel child, String firstName) {
    List<ChildRegistrationModel> children = List.from(state.children ?? []);
    final i = _getChildIndex(child, children);
    if (i > -1) {
      debugPrint('Child index found: $i');
      children[i] = children[i]
          .copyWith(firstName: NullableWrapper<String?>.value(firstName));
      emit(state.copyWith(children: children, childrenSaveRequired: true));
    } else {
      debugPrint('Child index not found');
    }
  }

  void childLastNameChanged(ChildRegistrationModel child, String lastName) {
    List<ChildRegistrationModel> children = List.from(state.children ?? []);
    final i = _getChildIndex(child, children);
    if (i > -1) {
      debugPrint('Child index found: $i');
      children[i] = children[i]
          .copyWith(lastName: NullableWrapper<String?>.value(lastName));
      emit(state.copyWith(children: children, childrenSaveRequired: true));
    } else {
      debugPrint('Child index not found');
    }
  }

  void childBirthDateChanged(ChildRegistrationModel child, DateTime birthDate) {
    List<ChildRegistrationModel> children = List.from(state.children ?? []);
    final i = _getChildIndex(child, children);
    if (i > -1) {
      debugPrint('Child index found: $i');
      children[i] = children[i].copyWith(dateOfBirth: birthDate);
      emit(state.copyWith(children: children, childrenSaveRequired: true));
    } else {
      debugPrint('Child index not found');
    }
  }

  void resetChildBirthDate(ChildRegistrationModel child) {
    List<ChildRegistrationModel> children = List.from(state.children ?? []);
    final i = _getChildIndex(child, children);
    if (i > -1) {
      debugPrint('Child index found: $i');
      children[i] = children[i].resetBirthDate();
      emit(state.copyWith(children: children, childrenSaveRequired: true));
    } else {
      debugPrint('Child index not found');
    }
  }

  void pinCodeChanged(String pinCode) {
    emit(state.copyWith(pinCode: pinCode));
  }

  String createSha256Hash(String value) {
    var bytes = utf8.encode(value);
    return sha256.convert(bytes).toString();
  }

  // Private
  Failure? _validateForm(int selectedFormIndex) {
    switch (selectedFormIndex) {
      case 1: // Personal Info
        if (!EmailValidator.validate(state.newEmail ?? '')) {
          return Failure(message: 'Invalid email specified.'.i18n);
        } else {
          if (state.newEmail != state.email && state.reauthenticated != true) {
            return const Failure(
                message: '', code: 'REAUTHENTICATION_CHALLENGE');
          } else {
            // final currentYear = DateTime.now().year;
            // final birthYear = state.birthYear;
            // if (birthYear != null) {
            //   if (birthYear < 1900 || birthYear > currentYear) {
            //     return Failure(message: 'Invalid birth year specified.'.i18n);
            //   }
            // }
            if (state.firstName == null || state.firstName!.trim().isEmpty) {
              return Failure(message: 'First name is required.'.i18n);
            }

            if (state.lastName == null || state.lastName!.trim().isEmpty) {
              return Failure(message: 'Last name is required.'.i18n);
            }

            if (state.birthDate == null) {
              return Failure(
                  message: 'A valid date of birth is required.'.i18n);
            }
          }
        }
        break;
      case 2:
        if (state.children!.isEmpty) {
          return Failure(message: 'You must add at least one child.'.i18n);
        } else {
          final children = state.children!;
          for (int i = 0; i < children.length; i++) {
            final firstName = children[i].firstName;
            if (firstName == null || firstName.isEmpty) {
              return Failure(
                  message: 'First name for all children is required.'.i18n);
            }

            final lastName = children[i].lastName;
            if (lastName == null || lastName.isEmpty) {
              return Failure(
                  message: 'Last name for all children is required.'.i18n);
            }

            // final dateOfBirth = children[i].dateOfBirth;
            // if (dateOfBirth == null) {
            //   return Failure(
            //       message: 'Birth date  for all children is required.'.i18n);
            // }
          }
        }
        break;
      default:
        return null;
    }
    return null;
  }

  Future<String> _uploadProfileImage(
      SelectedFile selectedFile, String tutorId) async {
    final uploadEither = await uploadFile(UploadFileParams(
      tutorId: tutorId,
      fileName: selectedFile.fileName,
      fileBytes: selectedFile.fileBytes,
      resourceType: ResourceType.profileImage,
      taskManager: null,
    ));

    return uploadEither.fold((failure) {
      debugPrint(failure.message);
      return '';
    }, (documentUrl) {
      return documentUrl;
    });
  }

  Future<bool> _savePersonalInfo(
      {String? profileImageUrl,
      ProfileCompletionModel? profileCompletion,
      bool? reauthenticated = false}) async {
    emit(state.copyWith(status: ProfileStatus.incrementalSave));
    Map<String, dynamic> update = {};

    if (profileCompletion != null) {
      var onboardingState = state.originalUser!.onboardingState;
      if (onboardingState == null) {
        onboardingState =
            OnboardingStateModel(profileCompletion: profileCompletion);
      } else {
        onboardingState =
            onboardingState.copyWith(profileCompletion: profileCompletion);
      }
      update = {
        'profileImageUrl': profileImageUrl ?? state.profileImageUrl,
        'email': reauthenticated == true ? state.newEmail : state.email,
        'firstName': state.firstName,
        'lastName': state.lastName,
        'dateOfBirth': state.birthDate?.millisecondsSinceEpoch,
        'age': state.birthDate != null ? calculateAge(state.birthDate!) : 0,
        'bio': state.bio,
        'address': state.address,
        'profilePercentageComplete':
            profileCompletion.getProfileCompletionPercentage(state.roleType!),
        'onboardingState': onboardingState.toMap(),
      };
    } else {
      update = {
        'profileImageUrl': profileImageUrl ?? state.profileImageUrl,
        'email': reauthenticated == true ? state.newEmail : state.email,
        'firstName': state.firstName,
        'lastName': state.lastName,
        'dateOfBirth': state.birthDate?.millisecondsSinceEpoch,
        'age': state.birthDate != null ? calculateAge(state.birthDate!) : 0,
        'bio': state.bio,
        'address': state.address,
      };
    }

    return await _updateUserPartition(state.userId!, update);
  }

  Future<bool> _finalizeOnboarding(User user, String? newEmail) async {
    final finalizeEither = await finalizeOnboarding(
        FinalizeOnboardingParams(user: user, newEmail: newEmail));
    return finalizeEither.fold((failure) {
      // emit(state.copyWith(status: TutorStatus.error, failure: failure));
      return false;
    }, (success) {
      return true;
    });
  }

  Future<bool> _updateUser(User user, String? newEmail,
      {bool? childIsNew = false}) async {
    final updateEither = await updateUser(UpdateUserParams(
        user: user, newEmail: newEmail, childIsNew: childIsNew));
    return updateEither.fold((failure) {
      // emit(state.copyWith(status: TutorStatus.error, failure: failure));
      return false;
    }, (success) {
      return true;
    });
  }

  Future<bool> _saveOnboardingState(
      List<ChildRegistrationModel> children) async {
    Map<String, dynamic> update = {
      'onboardingState': _getOnboardingState(children: children).toMap(),
    };

    return await _updateUserPartition(state.userId!, update);
  }

  Future<bool> _updateUserPartition(
      String userId, Map<String, dynamic> partition) async {
    final updateEither = await updateUserPartition(
        UpdateUserPartitionParams(userId: userId, partition: partition));
    return updateEither.fold((failure) {
      // emit(state.copyWith(status: TutorStatus.error, failure: failure));
      return false;
    }, (success) {
      return true;
    });
  }

  OnboardingStateModel _getOnboardingState(
      {required List<ChildRegistrationModel> children}) {
    final onboardingState = state.originalUser!.onboardingState;

    if (onboardingState == null) {
      return OnboardingStateModel(children: children);
    } else {
      return onboardingState.copyWith(children: children);
    }
  }

  ProfileCompletionModel _getProfileCompletionModel(ProfileState state) {
    return ProfileCompletionModel(
        personalInfo: ProfileCompletionModel.isPersonalInfoComplete(
            state.firstName, state.lastName, state.birthDate),
        emailVerified: true,
        phoneVerified: state.phoneVerified ?? false,
        identityVerified: ProfileCompletionModel.isIdentityVerified(
            true, state.phoneVerified));
  }

  int _getChildIndex(
      ChildRegistrationModel child, List<ChildRegistrationModel> children) {
    int index = -1;

    for (int i = 0; i < children.length; i++) {
      if (identical(children[i], child)) {
        index = i;
        break;
      }
    }

    return index;
  }

  List<ChildRegistrationModel> _manageChildDisplay(
      List<ChildRegistrationModel> children) {
    if (children.isNotEmpty) {
      if (children.length == 1) {
        children[0] = children[0].copyWith(
            label: 'Child - 1'.i18n, showHeader: false, showBody: true);
      } else {
        for (int i = 0; i < children.length; i++) {
          children[i] = children[i].copyWith(
            label: 'Child - ${i + 1}',
            showHeader: true,
          );
        }
      }
    }

    return children;
  }
}
