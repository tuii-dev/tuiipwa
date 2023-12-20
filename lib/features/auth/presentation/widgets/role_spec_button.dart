import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuiicore/core/config/theme/tuii_colors.dart';
import 'package:tuiicore/core/enums/tuii_role_type.dart';
import 'package:tuiipwa/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tuiipwa/features/auth/presentation/cubit/login/login_cubit.dart';
import 'package:tuiipwa/features/auth/presentation/pages/mobile_screen.dart';
import 'package:tuiipwa/features/auth/presentation/pages/onboarding_screen.dart';
import 'package:tuiipwa/features/auth/presentation/pages/signup_screen.dart';

class RoleSpecButton extends StatefulWidget {
  const RoleSpecButton(
      {Key? key, required this.roleType, required this.isDelayedOnboarding})
      : super(key: key);

  final TuiiRoleType roleType;
  final bool isDelayedOnboarding;

  @override
  State<RoleSpecButton> createState() => _RoleSpecButtonState();
}

class _RoleSpecButtonState extends State<RoleSpecButton> {
  bool tapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        setState(() => tapped = true);
      },
      onTapUp: (details) {
        setState(() => tapped = false);
      },
      onTapCancel: () {
        setState(() => tapped = false);
      },
      onTap: () {
        BlocProvider.of<LoginCubit>(context).roleTypeChanged(widget.roleType);
        if (widget.isDelayedOnboarding) {
          if (_getRequiresPhoneVerication(context)) {
            Navigator.of(context).pushReplacementNamed(MobileScreen.routeName);
          } else {
            Navigator.of(context)
                .pushReplacementNamed(OnboardingScreen.routeName);
          }
        } else {
          Navigator.of(context).pushReplacementNamed(SignUpScreen.routeName);
        }
      },
      child: Container(
          width: 100,
          height: 120,
          decoration: BoxDecoration(
              color: tapped
                  ? TuiiColors.primaryTransparentBackground
                  : Colors.transparent,
              border: Border.all(
                  color: tapped ? TuiiColors.primary : TuiiColors.inactiveTool),
              borderRadius: BorderRadius.circular(8)),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                widget.roleType == TuiiRoleType.tutor
                    ? Image.asset(
                        'assets/images/onboarding/flow/tutor_role.png',
                        width: 45,
                        height: 52,
                      )
                    : widget.roleType == TuiiRoleType.parent
                        ? Image.asset(
                            'assets/images/onboarding/flow/parent_role.png',
                            width: 63,
                            height: 56,
                          )
                        : Image.asset(
                            'assets/images/onboarding/flow/student_role.png',
                            width: 45,
                            height: 52,
                          ),
                SizedBox(
                    height: widget.roleType == TuiiRoleType.parent ? 11 : 15),
                Text(widget.roleType.display,
                    style: const TextStyle(
                      fontSize: 14,
                      color: TuiiColors.black,
                      fontWeight: FontWeight.w700,
                    ))
              ])),
    );
  }

  bool _getRequiresPhoneVerication(BuildContext context) {
    final status = BlocProvider.of<AuthBloc>(context).state.status;
    return status == AuthStatus.authenticatedRequiresMobileVerificationOff ||
        status == AuthStatus.authenticatedRequiresMobileVerificationOn;
  }
}
