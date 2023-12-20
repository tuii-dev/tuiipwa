import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuiicore/core/config/theme/tuii_colors.dart';
import 'package:tuiicore/core/enums/tuii_role_type.dart';
import 'package:tuiicore/core/widgets/save_button.dart';
import 'package:tuiipwa/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tuiipwa/features/auth/presentation/widgets/auth_instructional_text_widget.dart';
import 'package:tuiipwa/features/auth/presentation/widgets/role_spec_button.dart';
import 'package:tuiipwa/common/common.dart';
import 'package:tuiipwa/utils/pwa_i18n.dart';
import 'package:tuiipwa/utils/spacing.dart';

class ProfileSelectionScreen extends StatefulWidget {
  static const String routeName = '/auth/profile';

  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return Stack(
              children: [
                Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          flex: 1,
                          child: Container(
                              color: TuiiColors.defaultDarkColor,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    space20, spaceAppBar / 2, space20, space0),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/logos/tuii_expanded_logo_1x.png',
                                            width: 59,
                                            height: 27,
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: SaveButton(
                                                callback: () {
                                                  manageLoginScreenRoute(
                                                      context);
                                                },
                                                label: "Login".i18n,
                                                width: 80,
                                                height: 30,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const AuthInstructionalTextWidget(),
                                    ]),
                              ))),
                      Expanded(
                          flex: 1,
                          child: Container(color: TuiiColors.bgColorScreen)),
                    ]),
                Positioned(
                    top: size.height * 0.3,
                    left: 0,
                    child: Padding(
                      padding: paddingHorizontal20,
                      child: Container(
                          height: 280,
                          width: size.width - (space20 * 2),
                          decoration: BoxDecoration(
                              color: TuiiColors.white,
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: paddingAll20,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      "Please Select Your Profile".i18n,
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: TuiiColors.defaultText),
                                    ),
                                  ),
                                  const SizedBox(height: space5),
                                  Flexible(
                                    child: Text(
                                      "Tuii Profile Registration".i18n,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: TuiiColors.defaultText),
                                    ),
                                  ),
                                  const SizedBox(height: space40),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        RoleSpecButton(
                                          roleType: TuiiRoleType.tutor,
                                          isDelayedOnboarding:
                                              _getIsDelayedOnboarding(
                                                  state.status),
                                        ),
                                        const SizedBox(width: 15),
                                        RoleSpecButton(
                                          roleType: TuiiRoleType.parent,
                                          isDelayedOnboarding:
                                              _getIsDelayedOnboarding(
                                                  state.status),
                                        ),
                                        const SizedBox(width: 15),
                                        RoleSpecButton(
                                          roleType: TuiiRoleType.student,
                                          isDelayedOnboarding:
                                              _getIsDelayedOnboarding(
                                                  state.status),
                                        ),
                                      ],
                                    ),
                                  )
                                ]),
                          )),
                    )),
              ],
            );
          },
        ),
      ),
    );
  }

  bool _getIsDelayedOnboarding(AuthStatus? status) {
    return status == AuthStatus.authenticatedRequiresOnboarding ||
        status == AuthStatus.authenticatedRequiresMobileVerificationOff ||
        status == AuthStatus.authenticatedRequiresMobileVerificationOn;
  }
}
