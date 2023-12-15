import 'package:flutter/material.dart';
import 'package:tuiicore/core/config/theme/tuii_colors.dart';
import 'package:tuiicore/core/widgets/save_button.dart';
import 'package:tuiipwa/features/auth/presentation/widgets/auth_instructional_text_widget.dart';
import 'package:tuiipwa/utils/pwa_i18n.dart';
import 'package:tuiipwa/utils/spacing.dart';

class LoginScreen extends StatefulWidget {
  static const String name = '/auth/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                            Navigator.of(context)
                                                .pushNamed('/auth/profile');
                                          },
                                          label: "Sign Up".i18n,
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
                    flex: 1, child: Container(color: TuiiColors.bgColorScreen)),
              ]),
          Positioned(
              top: size.height * 0.3,
              left: 0,
              child: Padding(
                padding: paddingHorizontal20,
                child: Container(
                    height: 400,
                    width: size.width - (space20 * 2),
                    decoration: BoxDecoration(
                        color: TuiiColors.white,
                        borderRadius: BorderRadius.circular(15)),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text("Login Screen"),
                    )),
              )),
        ],
      ),
    );
  }
}
