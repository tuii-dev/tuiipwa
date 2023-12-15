// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:tuiicore/core/config/theme/tuii_colors.dart';
import 'package:tuiipwa/utils/pwa_i18n.dart';

class GoogleRecaptchaWidget extends StatelessWidget {
  const GoogleRecaptchaWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('This site is protected by reCAPTCHA and the '.i18n,
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Google '.i18n,
                          style: const TextStyle(fontSize: 16)),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            const privacyUrl =
                                'https://policies.google.com/privacy';

                            html.window.open(privacyUrl, '_blank');
                          },
                          child: Text('Privacy Policy'.i18n,
                              style: const TextStyle(
                                  fontSize: 16,
                                  decoration: TextDecoration.underline,
                                  color: TuiiColors.linkTextColor)),
                        ),
                      ),
                      Text(' and '.i18n, style: const TextStyle(fontSize: 16)),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            const url = 'https://policies.google.com/terms';

                            html.window.open(url, '_blank');
                          },
                          child: Text('Terms of Service'.i18n,
                              style: const TextStyle(
                                  fontSize: 16,
                                  decoration: TextDecoration.underline,
                                  color: TuiiColors.linkTextColor)),
                        ),
                      ),
                      Text(' apply.'.i18n,
                          style: const TextStyle(fontSize: 16)),
                    ])
              ]),
        ]);
  }
}
