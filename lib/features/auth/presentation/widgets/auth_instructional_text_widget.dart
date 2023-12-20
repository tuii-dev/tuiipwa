import 'package:flutter/material.dart';
import 'package:tuiicore/core/config/theme/tuii_colors.dart';
import 'package:tuiipwa/utils/pwa_i18n.dart';
import 'package:tuiipwa/utils/spacing.dart';

class AuthInstructionalTextWidget extends StatelessWidget {
  const AuthInstructionalTextWidget({super.key, this.includeSubTitle = true});

  final bool? includeSubTitle;
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: space40,
          ),
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              "Welcome to the Tuii Platform".i18n,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: TuiiColors.white),
            ),
          ),
          const SizedBox(
            height: space20,
          ),
          includeSubTitle == true
              ? Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    "Sign in if you have an existing account, or sign up for new one"
                        .i18n,
                    style:
                        const TextStyle(fontSize: 18, color: TuiiColors.white),
                  ),
                )
              : const SizedBox.shrink(),
        ]);
  }
}
