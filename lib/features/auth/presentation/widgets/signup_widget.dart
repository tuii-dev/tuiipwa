import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_validation/form_validation.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:tuiicore/core/common/confirm_password_validator.dart';
import 'package:tuiicore/core/config/theme/tuii_colors.dart';
import 'package:tuiicore/core/enums/tuii_role_type.dart';
import 'package:tuiicore/core/services/snackbar_service.dart';
import 'package:tuiicore/core/widgets/google_signin_button.dart';
import 'package:tuiicore/core/widgets/login_signup_button.dart';
import 'package:tuiicore/core/widgets/password_form_field.dart';
import 'package:tuiipwa/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tuiipwa/features/auth/presentation/cubit/login/login_cubit.dart';
import 'package:tuiipwa/features/auth/presentation/pages/mobile_screen.dart';
import 'package:tuiipwa/features/auth/presentation/pages/onboarding_screen.dart';
import 'package:tuiipwa/features/tuii_app/presentation/bloc/tuii_notifications/tuii_notifications_bloc.dart';
import 'package:tuiipwa/features/tuii_app/presentation/pages/tuii_app_screen.dart';
import 'package:tuiipwa/common/common.dart';
import 'package:tuiipwa/features/tuii_app/presentation/bloc/tuii_app/tuii_app_bloc.dart';
import 'package:tuiipwa/injection_container.dart';
import 'package:tuiipwa/utils/pwa_i18n.dart';
import 'package:tuiipwa/utils/spacing.dart';

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({super.key});

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _passwordController;
  late SnackbarService _snackbarService;

  @override
  void initState() {
    _snackbarService = sl<SnackbarService>();
    _passwordController = TextEditingController();
    _passwordController.addListener(() {
      context.read<LoginCubit>().passwordChanged(_passwordController.text);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (prevState, state) => prevState.status != state.status,
      listener: ((context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.loaderOverlay.hide();
          final user = state.user!;
          final userId = user.id!;
          BlocProvider.of<TuiiNotificationsBloc>(context).init(userId);
          Future.delayed(Duration.zero, () {
            Navigator.of(context).pushReplacementNamed(TuiiAppScreen.routeName);
          });
        } else if (state.status ==
                AuthStatus.authenticatedRequiresMobileVerificationOn ||
            state.status ==
                AuthStatus.authenticatedRequiresMobileVerificationOff) {
          context.loaderOverlay.hide();
          Navigator.of(context).pushReplacementNamed(MobileScreen.routeName);
        } else if (state.status == AuthStatus.authenticatedRequiresOnboarding) {
          Navigator.of(context)
              .pushReplacementNamed(OnboardingScreen.routeName);
        }
      }),
      builder: (context, authState) {
        return BlocConsumer<LoginCubit, LoginState>(
          listenWhen: (prevState, state) => prevState.status != state.status,
          listener: (context, state) {
            bool cancelDismiss = false;
            if (state.status == LoginStatus.submitting) {
              context.loaderOverlay.show();
            } else if (state.status == LoginStatus.success) {
              context.loaderOverlay.hide();
            } else if (state.status == LoginStatus.error) {
              if (!(state.failure!.supressMessaging == true)) {
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

                debugPrint(content);
                cancelDismiss = true;

                _snackbarService.queueSnackbar(context, true, content, 500);
              } else {
                if (state.failure!.code == 'REQUIRES_MULTIFACTOR_AUTH') {
                  _snackbarService.queueSnackbar(
                      context,
                      true,
                      'This Google account is already in use.  Please sign up with a different Google account.'
                          .i18n,
                      500);
                }
                cancelDismiss = true;
              }
            }
            if (cancelDismiss) {
              context.loaderOverlay.hide();
            }
          },
          builder: (context, state) {
            return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Sign Up'.i18n,
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: TuiiColors.defaultText)),
                        const SizedBox(height: space10),
                        Text(
                            'Enter your credentials to create your account'
                                .i18n,
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
                                      color: TuiiColors.inactiveTool,
                                      width: 1)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                      color: TuiiColors.inactiveTool,
                                      width: 1)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                      color: TuiiColors.inactiveTool,
                                      width: 1)),
                              filled: true,
                              hintStyle: const TextStyle(
                                  color: TuiiColors.inactiveTool),
                              hintText: 'Email',
                              hoverColor: Colors.white70,
                              fillColor: Colors.white70),

                          onChanged: (value) {
                            context.read<LoginCubit>().emailChanged(value);
                          },
                          // context.read<LoginCubit>().emailChanged(value),
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
                            changeHandler: (value) => {},
                            fieldSubmittedHandler: (value) => {},
                            controller: _passwordController),
                        const SizedBox(
                          height: 10.0,
                        ),
                        PasswordFormField(
                          changeHandler: (value) => {},
                          fieldSubmittedHandler: (value) {
                            _handleSignUpRequest(state, context);
                          },
                          hint: 'Confirm Password'.i18n,
                          validators: [
                            ConfirmPasswordValidator(
                                passwordController: _passwordController),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: state.userAgreedToTerms ?? false,
                                activeColor: TuiiColors.primary,
                                onChanged: (bool? val) {
                                  if (val != null) {
                                    context
                                        .read<LoginCubit>()
                                        .termsAcceptanceChanged(val);
                                  }
                                },
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          final val = context
                                              .read<LoginCubit>()
                                              .state
                                              .userAgreedToTerms;
                                          if (val != null) {
                                            context
                                                .read<LoginCubit>()
                                                .termsAcceptanceChanged(!val);
                                          }
                                        },
                                        child: Text(
                                            'Yes I accept Tuii\'s '.i18n,
                                            style:
                                                const TextStyle(fontSize: 16)),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        final url =
                                            BlocProvider.of<TuiiAppBloc>(
                                                        context)
                                                    .state
                                                    .systemConfig
                                                    ?.administration
                                                    ?.termsAndConditionsUrl ??
                                                'https://www.tuii.io/terms';

                                        html.window.open(url, '_blank');
                                      },
                                      child: Text('Terms of Service'.i18n,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              decoration:
                                                  TextDecoration.underline,
                                              color: TuiiColors.linkTextColor)),
                                    ),
                                  ])),
                            ]),
                        const SizedBox(
                          height: 15,
                        ),
                        LoginSignUpButton(
                            label: 'Create Account'.i18n,
                            height: 36.0,
                            callback: () {
                              _handleSignUpRequest(state, context);
                            }),
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
                              if (state.userAgreedToTerms == true) {
                                _signUpWithGoogle(context, state.status);
                              } else {
                                _snackbarService.queueSnackbar(
                                    context,
                                    true,
                                    'You must accept Tuii\'s terms of service and privacy policy before signing up.',
                                    500);
                              }
                            }),
                      ]),
                ));
          },
        );
      },
    );
  }

  void _handleSignUpRequest(LoginState state, BuildContext context) {
    if (state.userAgreedToTerms == true) {
      _signUpEmailPassword(context, state.status);
    } else {
      _snackbarService.queueSnackbar(
          context,
          true,
          'You must accept Tuii\'s terms of service and privacy policy before signing up.',
          500);
    }
  }

  void _signUpEmailPassword(BuildContext context, LoginStatus status) {
    if (_formKey.currentState != null) {
      if (_formKey.currentState!.validate()) {
        if (status != LoginStatus.submitting) {
          context.read<LoginCubit>().signUpWithCredentials();
        }
      }
    }
  }

  void _signUpWithGoogle(BuildContext context, LoginStatus status) {
    if (status != LoginStatus.submitting) {
      context.read<LoginCubit>().signUpWithGoogle();
    }
  }
}
