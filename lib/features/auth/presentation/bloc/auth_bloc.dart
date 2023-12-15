import 'dart:async';
// import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as sc;

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tuiiauth_domain_data_firestore/tuiiauth_domain_data_firestore.dart';
import 'package:tuiicore/core/common/common.dart';
import 'package:tuiientitymodels/files/auth/data/models/app_link_command_payload.dart';
import 'package:tuiientitymodels/files/auth/data/models/user_model.dart';
import 'package:tuiientitymodels/files/auth/domain/entities/user.dart';
// import 'package:tuiicore/core/enums/impersonation_route_command_type.dart';
// import 'package:tuiicore/core/enums/tuii_role_type.dart';
import 'package:tuiicore/core/models/login_impersonation_directive_model.dart';
import 'package:tuiicore/core/services/local_store_service.dart';
import 'package:tuiipwa/features/communications/presentation/bloc/stream_chat/stream_chat_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

const String logoutFailureMessage = 'Failed to logout.';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  StreamSubscription<UserModel?>? _userSubscription;
  bool firestoreUserStreamInitialized = false;
  bool firebaseUserStreamInitialized = false;
  sc.StreamChatClient? client;

  AuthBloc(
      {required this.streamChatBloc,
      required this.authRepository,
      required this.localStore,
      required this.logout})
      : super(AuthState.unknown()) {
    on<AuthUserChanged>((event, emit) async {
      // bool processingDirective = false;
      if (event.user != null) {
        final user = event.user!;
        if (!firestoreUserStreamInitialized) {
          firestoreUserStreamInitialized = true;
          authRepository.initFirestoreUserStream(userId: user.id!);
        }

        if (user.isEmpty == true || user.onboarded != true) {
          if (user.phoneVerified != true) {
            if (state.status ==
                AuthStatus.authenticatedRequiresMobileVerificationOn) {
              emit(AuthState.authenticatedRequiresMobileVerificationOff(
                  user: event.user!,
                  appLinkCommandKey: state.appLinkCommandKey,
                  appLinkCommandPayload: state.appLinkCommandPayload));
            } else {
              emit(AuthState.authenticatedRequiresMobileVerificationOn(
                  user: event.user!,
                  appLinkCommandKey: state.appLinkCommandKey,
                  appLinkCommandPayload: state.appLinkCommandPayload));
            }
          } else {
            emit(AuthState.authenticatedRequiresOnboarding(
                user: event.user!,
                appLinkCommandKey: state.appLinkCommandKey,
                appLinkCommandPayload: state.appLinkCommandPayload));
          }
        } else {
          assert(client != null, 'Stream chat client not set!');
          // if (user.roleType == TuiiRoleType.parent) {
          //   if (state.isImpersonating != true) {
          //     tuiiImpersonationCubit.activateHost(user);
          //     //  if (tuiiImpersonationCubit.state.impersonatableAccounts == null) {
          //     final children = user.onboardingState!.children;

          //     if (children != null && children.isNotEmpty) {
          //       final ids = children.map((c) => c.id!).toList();

          //       final accountsEither = await authRepository.loadAccounts(ids);
          //       accountsEither.fold((failure) {
          //         debugPrint(
          //             'Failed to load child accounts: ${failure.message}');
          //       }, (accounts) {
          //         tuiiImpersonationCubit.setImpersonatableAccounts(accounts);
          //       });

          //       final impersonationDirective = await localStore
          //           .getLoginImpersonationDirective(targetUserId: user.id!);

          //       // TESTING ONLY
          //       // const impersonationDirective = LoginImpersonationDirective(
          //       //     targetUserId: 'Q4HEr8uXpwV9bhS3aVDo42x2h5r1',
          //       //     impersonationId: 'nvl0HJwODf8tQdTBDKdB');

          //       if (impersonationDirective != null) {
          //         await localStore.deleteLoginImpersonationDirective(
          //             targetUserId: user.id!);

          //         // If there is an applinkcommand ignore the impersonation directive
          //         // if (state.appLinkCommandKey == null) {
          //         processingDirective = true;
          //         final i = tuiiImpersonationCubit.state.impersonatableAccounts!
          //             .indexWhere((acct) =>
          //                 acct.id == impersonationDirective.impersonationId);

          //         if (i > -1) {
          //           final account =
          //               tuiiImpersonationCubit.state.impersonatableAccounts![i];
          //           Future.delayed(const Duration(milliseconds: 10), () {
          //             final name = account.firstName ?? '';
          //             final loadingMessage = name.isNotEmpty
          //                 ? 'Activating $name\'s Learning Profile'
          //                 : 'Activating Learning Profile'.i18n;
          //             add(AuthImpersonationRequested(
          //                 account: account,
          //                 forceAppScreenRoute: true,
          //                 impersonationRouteCommand:
          //                     ScheduleImpersonationRouteCommandEvent(
          //                         commandType:
          //                             ImpersonationRouteCommandType.noop,
          //                         loadingMessage: loadingMessage)));
          //           });
          //         }
          //         // }
          //       }
          //     }
          //     // }
          //   }
          // } else if (user.roleType == TuiiRoleType.student &&
          //     user.hasCustodian == true) {
          //   if (user.stripeCustomerId != null &&
          //       user.stripeCustomerId!.isNotEmpty) {
          //     tuiiImpersonationCubit.updateHostStripeCustomerId(
          //         user.custodianId!, user.stripeCustomerId!);
          //   }
          // }

          emit(AuthState.authenticated(
              user: user,
              // user: processingDirective ? null : user,
              // isImpersonating: event.isImpersonating ?? false,
              appLinkCommandKey: state.appLinkCommandKey,
              appLinkCommandPayload: state.appLinkCommandPayload,
              isImmediateSignUp: event.isImmediateSignUp,
              forceAppScreenRoute: event.forceAppScreenRoute));

          if (event.delayStreamConnect == true) {
            Future.delayed(const Duration(milliseconds: 5000), () {
              streamChatBloc.add(ConnectToStreamChatApiEvent(
                  user: event.user!, client: client!));
            });
          } else {
            streamChatBloc.add(ConnectToStreamChatApiEvent(
                user: event.user!, client: client!));
          }
        }
      } else {
        _runLogout(emit);
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      final user = state.user!;
      if (user.hasCustodian == true &&
          user.custodianId != null &&
          user.custodianId!.isNotEmpty) {
        await localStore.deleteLoginImpersonationDirective(
            targetUserId: user.custodianId!);
      }

      final logoutEither = await logout(const LogoutParams());

      logoutEither.fold((failure) {
        emit(AuthState.error(message: logoutFailureMessage));
      }, (success) {
        // final isImpersonating = state.isImpersonating ?? false;
        // _runLogout(emit, isImpersonating: isImpersonating);
        _runLogout(emit);
      });
    });

    on<AuthRecordAppLinkCommandKeyEvent>((event, emit) =>
        emit(state.copyWith(appLinkCommandKey: event.appLinkCommandKey)));

    on<AuthRecordAppLinkCommandPayloadEvent>((event, emit) {
      final jsonString = decodeBase64(event.appLinkCommandPayload);
      emit(state.copyWith(
          appLinkCommandPayload: AppLinkCommandPayload.fromJson(jsonString)));
    });
  }

  final StreamChatBloc streamChatBloc;
  final AuthRepository authRepository;
  final LocalStoreService localStore;
  final LogoutUseCase logout;

  init(sc.StreamChatClient streamClient, String? appLinkCommandKey,
      String? appLinkCommandPayload) {
    client ??= streamClient;

    if (appLinkCommandKey != null) {
      add(AuthRecordAppLinkCommandKeyEvent(
          appLinkCommandKey: appLinkCommandKey));
    }

    if (appLinkCommandPayload != null) {
      add(AuthRecordAppLinkCommandPayloadEvent(
          appLinkCommandPayload: appLinkCommandPayload));
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      _manageFirebaseUserSubscription();
    });
  }

  Future<bool> impersonationDirectivePending(String userId) async {
    final directive =
        await localStore.getLoginImpersonationDirective(targetUserId: userId);
    return directive != null;
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }

  Future<void> saveLoginImpersonationDirective(
      LoginImpersonationDirective directive) async {
    await localStore.saveLoginImpersonationDirective(directive: directive);

    return;
  }

  _runLogout(Emitter<AuthState> emit, {bool? isImpersonating = false}) {
    firestoreUserStreamInitialized = false;
    authRepository.closeFirestoreUserStream();
    _manageFirebaseUserSubscription();

    if (isImpersonating != true) {
      emit(AuthState.unauthenticated(
          appLinkCommandKey: state.appLinkCommandKey,
          appLinkCommandPayload: state.appLinkCommandPayload));
    }

    Future.delayed(Duration.zero, () {
      streamChatBloc.add(const DisconnectFromStreamChatApiEvent());
    });
  }

  void _manageFirebaseUserSubscription() {
    if (!firebaseUserStreamInitialized) {
      firebaseUserStreamInitialized = true;
      authRepository.initFirebaseUserStream();
    }

    _userSubscription?.cancel();
    _userSubscription = authRepository.user.listen((model) {
      User? user;
      if (model != null) {
        user = User.fromModel(model: model);
      }
      add(AuthUserChanged(user: user));
    });
  }
}
