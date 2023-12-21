import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:tuiicore/core/config/theme/tuii_colors.dart';
import 'package:tuiicore/core/enums/tuii_role_type.dart';
import 'package:tuiicore/core/services/snackbar_service.dart';
import 'package:tuiicore/core/widgets/save_button.dart';
import 'package:tuiipwa/common/widgets/profile/profile.dart';
import 'package:tuiipwa/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tuiipwa/features/auth/presentation/cubit/login/login_cubit.dart';
import 'package:tuiipwa/features/auth/presentation/cubit/profile/profile_cubit.dart';
import 'package:tuiipwa/features/auth/presentation/widgets/age_restriction_widget.dart';
import 'package:tuiipwa/features/tuii_app/presentation/pages/tuii_app_screen.dart';
import 'package:tuiipwa/injection_container.dart';
import 'package:tuiipwa/utils/pwa_i18n.dart';

class ProfileManagerWidget extends StatefulWidget {
  const ProfileManagerWidget(
      {super.key,
      required this.isInstantiatedInSettings,
      required this.containerHeight});

  final bool isInstantiatedInSettings;
  final double containerHeight;

  @override
  State<ProfileManagerWidget> createState() => _ProfileManagerWidgetState();
}

class _ProfileManagerWidgetState extends State<ProfileManagerWidget> {
  List<Widget> _forms = [];
  late SnackbarService _snackbarService;

  @override
  void initState() {
    final roleType = BlocProvider.of<LoginCubit>(context).state.roleType;
    if (roleType == TuiiRoleType.parent) {
      _forms = [
        PersonalInfoWidget(
          isInstantiatedInSettings: false,
          containerHeight: widget.containerHeight,
        ),
        ParentChildrenRegistrationWidget(
          isInstantiatedInSettings: false,
          containerHeight: widget.containerHeight,
        ),
        ParentPinWidget(
          isInstantiatedInSettings: false,
          containerHeight: widget.containerHeight,
        ),
      ];
    } else {
      _forms = [
        PersonalInfoWidget(
          isInstantiatedInSettings: false,
          containerHeight: widget.containerHeight,
        ),
      ];
    }

    if (widget.isInstantiatedInSettings) {
      _forms.add(const CommunicationSettingsWidget());
    }

    _snackbarService = sl<SnackbarService>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.loaderOverlay.hide();
          Navigator.of(context).pushNamedAndRemoveUntil(
              TuiiAppScreen.routeName, (route) => false);
        }
      },
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          bool cancelOverlay = false;
          if (state.status == ProfileStatus.incrementalSave ||
              state.status == ProfileStatus.submitting) {
            context.loaderOverlay.show();
          } else if (state.status == ProfileStatus.onboardingComplete) {
            cancelOverlay = true;
            Future.delayed(
                const Duration(milliseconds: 500),
                () => Navigator.of(context).pushNamedAndRemoveUntil(
                    TuiiAppScreen.routeName, (route) => false));
          } else if (state.status == ProfileStatus.success) {
            cancelOverlay = true;
          } else if (state.status == ProfileStatus.ageRestricted) {
            cancelOverlay = true;
            Future.delayed(Duration.zero, () async {
              await showModalBottomSheet(
                  context: context,
                  builder: (context) => const AgeRestrictionWidget());
            });
          } else if (state.status == ProfileStatus.error) {
            if (!(state.failure!.supressMessaging == true)) {
              String content =
                  state.failure!.message ?? 'Onboarding operation failed'.i18n;

              cancelOverlay = true;

              _snackbarService.queueSnackbar(context, true, content, 500);
              Future.delayed(const Duration(milliseconds: 100), () {
                BlocProvider.of<ProfileCubit>(context).resetErrorStatus();
              });
            } else {
              cancelOverlay = true;
            }
          }

          if (cancelOverlay == true) {
            context.loaderOverlay.hide();
          }
        },
        builder: (context, state) {
          return LayoutBuilder(builder: (context, constraints) {
            return Column(
              children: [
                SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight - 50,
                    child: PageTransitionSwitcher(
                      duration: const Duration(milliseconds: 300),
                      reverse: state.formIsReversing ?? false,
                      transitionBuilder: (
                        Widget child,
                        Animation<double> animation,
                        Animation<double> secondaryAnimation,
                      ) {
                        return SharedAxisTransition(
                          animation: animation,
                          secondaryAnimation: secondaryAnimation,
                          transitionType: SharedAxisTransitionType.horizontal,
                          child: child,
                        );
                      },
                      child: _forms[state.selectedFormIndex ?? 0],
                    )),
                SizedBox(
                    width: constraints.maxWidth,
                    height: 50,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Expanded(child: SizedBox.shrink()),
                          (state.selectedFormIndex ?? 0) > 0
                              ? SaveButton(
                                  callback: () => _manageBack(context),
                                  label: "BACK".i18n,
                                  width: 80,
                                  height: 30,
                                  fontColor: TuiiColors.primary,
                                  backgroundColor: TuiiColors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                )
                              : const SizedBox.shrink(),
                          const SizedBox(width: 10),
                          (state.selectedFormIndex ?? 0) < 2
                              ? SaveButton(
                                  callback: () => _manageNext(context),
                                  label: "NEXT".i18n,
                                  width: 80,
                                  height: 30,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                )
                              : const SizedBox.shrink(),
                        ])),
              ],
            );
          });
        },
      ),
    );
  }

  void _manageNext(BuildContext context) async {
    final cubit = context.read<ProfileCubit>();
    final state = cubit.state;
    if (state.selectedFormIndex == 0) {
      if (cubit.validatePersonalInfoForm()) {
        if (state.roleType == TuiiRoleType.parent) {
          await cubit.savePersonalInfoForOnboardingParent();
        } else {
          final user = BlocProvider.of<AuthBloc>(context).state.user!;
          cubit.completeOnboarding(user, false);
        }
      }
    } else if (state.selectedFormIndex == 1) {
      if (state.roleType == TuiiRoleType.parent) {
        await cubit.saveChildren(widget.isInstantiatedInSettings);
      }
    } else if (state.selectedFormIndex == 2) {
      if (state.roleType == TuiiRoleType.parent) {
        final user = BlocProvider.of<AuthBloc>(context).state.user!;
        cubit.completeOnboarding(user, false);
      }
    }
  }

  void _manageBack(BuildContext context) {
    final cubit = context.read<ProfileCubit>();
    final state = cubit.state;
    if ((state.selectedFormIndex ?? 0) > 0) {
      cubit.reverseForm();
    }
  }
}
