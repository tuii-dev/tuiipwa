// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart' as ev;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_validation/form_validation.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tuiicore/core/config/theme/tuii_colors.dart';
import 'package:tuiicore/core/enums/tuii_role_type.dart';
import 'package:tuiicore/core/services/snackbar_service.dart';
import 'package:tuiicore/core/widgets/google_signin_button.dart';
import 'package:tuiicore/core/widgets/login_signup_button.dart';
import 'package:tuiicore/core/widgets/password_form_field.dart';
import 'package:tuiipwa/common/widgets/code_capture_widget.dart';
import 'package:tuiipwa/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tuiipwa/features/auth/presentation/cubit/identityVerification/identity_verification_cubit.dart';
import 'package:tuiipwa/features/auth/presentation/cubit/login/login_cubit.dart';
import 'package:tuiipwa/features/auth/presentation/pages/login_screen.dart';
import 'package:tuiipwa/features/auth/presentation/pages/mobile_screen.dart';
import 'package:tuiipwa/features/auth/presentation/pages/onboarding_screen.dart';
import 'package:tuiipwa/features/auth/presentation/pages/profile_selection_screen.dart';
import 'package:tuiipwa/features/tuii_app/presentation/bloc/tuii_app/tuii_app_bloc.dart';
import 'package:tuiipwa/features/tuii_app/presentation/bloc/tuii_app_link/tuii_app_link_bloc.dart';
import 'package:tuiipwa/features/tuii_app/presentation/bloc/tuii_notifications/tuii_notifications_bloc.dart';
import 'package:tuiipwa/features/tuii_app/presentation/pages/tuii_app_screen.dart';
import 'package:tuiipwa/common/common.dart';
import 'package:tuiipwa/injection_container.dart';
import 'package:tuiipwa/utils/pwa_i18n.dart';
import 'package:tuiipwa/utils/spacing.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late SnackbarService _snackbarService;

  @override
  void initState() {
    _snackbarService = sl<SnackbarService>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prevState, state) {
        return prevState.status != state.status ||
            (prevState.status ==
                AuthStatus.authenticatedRequiresMobileVerificationOn);
      },
      listener: (context, authState) {
        if (authState.status == AuthStatus.authenticated) {
          final user = authState.user!;
          final userId = user.id!;
          context.loaderOverlay.hide();

          BlocProvider.of<TuiiNotificationsBloc>(context).init(userId);
          final appLinkCmd =
              BlocProvider.of<TuiiAppLinkBloc>(context).state.appLinkCommand;
          if (user.roleType == TuiiRoleType.parent && appLinkCmd == null) {
            if (authState.forceAppScreenRoute == true) {
              Future.delayed(Duration.zero, () {
                Navigator.of(context)
                    .pushReplacementNamed(TuiiAppScreen.routeName);
              });
            } else {
              Future.delayed(Duration.zero, () {
                // TODO: Implement later
                // Navigator.of(context)
                //     .pushNamed(ParentProfileSelectionScreen.routeName);

                Future.delayed(Duration.zero, () {
                  Navigator.of(context)
                      .pushReplacementNamed(TuiiAppScreen.routeName);
                });
              });
            }
          } else {
            Future.delayed(Duration.zero, () {
              Navigator.of(context)
                  .pushReplacementNamed(TuiiAppScreen.routeName);
            });
          }
        } else if (authState.status ==
                AuthStatus.authenticatedRequiresMobileVerificationOn ||
            authState.status ==
                AuthStatus.authenticatedRequiresMobileVerificationOff) {
          context.loaderOverlay.hide();
          Navigator.of(context).pushReplacementNamed(MobileScreen.routeName);
        } else if (authState.status ==
            AuthStatus.authenticatedRequiresOnboarding) {
          if (mounted) {
            context.loaderOverlay.hide();
            Navigator.of(context)
                .pushReplacementNamed(ProfileSelectionScreen.routeName);
          }
        } else {
          // if (authState.isImpersonating != true) {
          //   // Goto Start Main Login
          //   Navigator.of(context).pushNamed(TuiiAuthScreen.routeName);
          // }
        }
      },
      child: BlocListener<IdentityVerificationCubit, IdentityVerificationState>(
        listenWhen: (prevState, state) {
          return (prevState.status != state.status &&
              state.componentType ==
                  IdentityVerificationComponentType.mainLogin &&
              mounted == true &&
              state.componentKey == widget.key);
        },
        listener: (context, identityState) async {
          final cubit = BlocProvider.of<IdentityVerificationCubit>(context);
          if (identityState.status == IdentityVerificationStatus.submitting) {
            context.loaderOverlay.show();
          } else if (identityState.status ==
              IdentityVerificationStatus.retrievingMfaVerificationId) {
            // EasyLoading.show(status: 'Initializing...'.i18n);
          } else if (identityState.status ==
              IdentityVerificationStatus.mfaVerificationIdRetrieved) {
            context.loaderOverlay.hide();

            final verificationdId = identityState.mfaVerificationId;
            if (verificationdId != null && verificationdId.isNotEmpty) {
              final code = await showModalBottomSheet(
                  context: context,
                  builder: (context) => const CodeCaptureWidget(
                      title: 'Multi-Factor Authentication'));

              if (code != null && (code as String).isNotEmpty) {
                Future.delayed(Duration.zero, () async {
                  context.loaderOverlay.show();
                  final success = await cubit.resolveMultiFactorSignIn(
                      verificationdId, code);
                  if (success == true) {
                    cubit.resetState();
                    cubit.closeMfaSessionStream(isComplete: true);
                    Future.delayed(const Duration(milliseconds: 1500), () {
                      context.loaderOverlay.hide();
                    });
                  }
                });
              } else {
                cubit.resetState();
              }
            }
          } else if (identityState.status ==
              IdentityVerificationStatus.success) {
            context.loaderOverlay.hide();
          } else if (identityState.status == IdentityVerificationStatus.error) {
            context.loaderOverlay.hide();

            _snackbarService.queueSnackbar(
                context,
                true,
                identityState.message ??
                    'An unanticipated error occurred.'.i18n,
                250);

            cubit.closeMfaSessionStream(isComplete: true);
            cubit.resetState();
          }
        },
        child: BlocConsumer<LoginCubit, LoginState>(
          listenWhen: (prevState, state) {
            return prevState.status != state.status && mounted == true;
          },
          listener: (context, state) {
            bool cancelDismiss = false;
            if (state.status == LoginStatus.submitting) {
              context.loaderOverlay.show();
            } else if (state.status == LoginStatus.success) {
              cancelDismiss = true;
            } else if (state.status == LoginStatus.sendingPasswordEmail) {
              context.loaderOverlay.show();
            } else if (state.status == LoginStatus.resetPasswordEmailSuccess) {
              cancelDismiss = true;

              final msg =
                  'Password reset email has been sent to your inbox.'.i18n;
              _snackbarService.queueSnackbar(context, false, msg, 500,
                  backgroundColor: Colors.green,
                  icon: const Icon(MdiIcons.emailFast, color: Colors.white));
            } else if (state.status == LoginStatus.error) {
              if (state.failure!.supressMessaging != true) {
                String content = state.failure!.message ?? 'Login failed';
                if (state.failure!.code ==
                    'account-exists-with-different-credential') {
                  content =
                      'The account already exists with a different credential.';
                } else if (state.failure!.code == 'invalid-credential') {
                  content =
                      'Error occurred while accessing credentials. Try again.';
                } else {
                  content = state.failure!.message!;
                }

                cancelDismiss = true;

                _snackbarService.queueSnackbar(context, true, content, 500);
              } else {
                if (state.failure!.code == 'REQUIRES_MULTIFACTOR_AUTH') {
                  final cubit =
                      BlocProvider.of<IdentityVerificationCubit>(context);
                  if (cubit.state.componentType ==
                      IdentityVerificationComponentType.unknown) {
                    cubit.initializeMfaSessionStream(
                        IdentityVerificationComponentType.mainLogin,
                        widget.key!);
                    cubit.getMultiFactorVerificationCodeForLogin(
                        state.failure!.multiFactorSession!,
                        state.failure!.multiFactorInfo!,
                        state.failure!.resolveSignIn!);
                  }
                } else {
                  cancelDismiss = true;
                }
              }
            }
            if (cancelDismiss) {
              context.loaderOverlay.hide();
            }
          },
          builder: (context, state) {
            return Form(
              key: _formKey,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Login'.i18n,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: TuiiColors.defaultText)),
                    const SizedBox(height: 10),
                    Text('Enter your credentials to continue'.i18n,
                        style: const TextStyle(
                            fontSize: 14, color: TuiiColors.muted)),
                    const SizedBox(height: space20),
                    TextFormField(
                      decoration: InputDecoration(
                          suffixIcon: const Icon(Icons.email_outlined,
                              color: TuiiColors.inactiveTool),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: const BorderSide(
                                  color: TuiiColors.inactiveTool, width: 1)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: const BorderSide(
                                  color: TuiiColors.inactiveTool, width: 1)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: const BorderSide(
                                  color: TuiiColors.inactiveTool, width: 1)),
                          filled: true,
                          hintStyle:
                              const TextStyle(color: TuiiColors.inactiveTool),
                          hintText: 'Email',
                          hoverColor: Colors.white70,
                          fillColor: Colors.white70),
                      onChanged: (value) {
                        context.read<LoginCubit>().emailChanged(value);
                      },
                      onFieldSubmitted: (value) {
                        _submitEmailPasswordForm(context, state.status);
                      },
                      validator: (value) {
                        var validator = Validator(
                          validators: [
                            RequiredValidator(),
                            EmailValidator(),
                          ],
                        );

                        return validator.validate(
                          context: context,
                          label: 'You must enter a valid email'.i18n,
                          value: value,
                        );
                      },
                    ),
                    const SizedBox(
                      height: 14.0,
                    ),
                    PasswordFormField(
                      changeHandler: (String value) =>
                          context.read<LoginCubit>().passwordChanged(value),
                      fieldSubmittedHandler: (String value) =>
                          _submitEmailPasswordForm(context, state.status),
                      skipPasswordValidation: true,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Expanded(
                            child: SizedBox.shrink(),
                            // child: SingleChildScrollView(
                            //   scrollDirection: Axis.horizontal,
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.start,
                            //     mainAxisSize: MainAxisSize.min,
                            //     children: [
                            //       Checkbox(
                            //         value: remeberMeSelected,
                            //         activeColor: TuiiColors.primary,
                            //         onChanged: (bool? checked) {
                            //           setState(() {
                            //             remeberMeSelected = checked == true;
                            //           });
                            //         },
                            //       ),
                            //       const SizedBox(width: 5),
                            //       Text('Remember Me'.i18n,
                            //           maxLines: 1,
                            //           overflow: TextOverflow.ellipsis,
                            //           style: const TextStyle(
                            //               fontSize: 16.0,
                            //               color: TuiiColors.inactiveTool)),
                            //     ],
                            //   ),
                            // ),
                          ),
                          GestureDetector(
                            onTap: () => _runForgotPassword(),
                            child: Text('Forgot Password?'.i18n,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 14.0, color: TuiiColors.primary)),
                          ),
                        ]),
                    const SizedBox(
                      height: 15,
                    ),
                    Column(
                      children: [
                        LoginSignUpButton(
                          label: 'Sign In'.i18n,
                          height: 36.0,
                          callback: () {
                            _submitEmailPasswordForm(context, state.status);
                          },
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        getOrText(),
                        const SizedBox(
                          height: 15,
                        ),
                        GoogleSignInButton(
                            height: 36.0,
                            onPressed: () {
                              _loginWithGoogle(context, state.status);
                            }),
                      ],
                    ),
                  ]),
            );
          },
        ),
      ),
    );
  }

  void _submitEmailPasswordForm(BuildContext context, LoginStatus status) {
    if (_formKey.currentState != null) {
      if (_formKey.currentState!.validate()) {
        if (status != LoginStatus.submitting) {
          context.read<LoginCubit>().loginWithCredentials();
        }
      }
    }
  }

  void _loginWithGoogle(BuildContext context, LoginStatus status) {
    if (status != LoginStatus.submitting) {
      context.read<LoginCubit>().loginWithGoogle();
    }
  }

  // void _loginWithApple(BuildContext context, LoginStatus status) {
  //   if (status != LoginStatus.submitting) {
  //     context.read<LoginCubit>().loginWithApple();
  //   }
  // }

  // TODO: Snackbar ????
  void _runForgotPassword() async {
    final email = BlocProvider.of<LoginCubit>(context).state.email;

    if (email.isNotEmpty) {
      if (ev.EmailValidator.validate(email)) {
        BlocProvider.of<LoginCubit>(context).sendPasswordResetEmail(email);
      } else {
        final msg = 'Specified email is not a valid email'.i18n;
        _snackbarService.queueSnackbar(context, true, msg, 500);
      }
    } else {
      final msg = 'Email is a required'.i18n;
      _snackbarService.queueSnackbar(context, true, msg, 500);
    }
  }
}
