import 'package:flutter/material.dart';
import 'package:tuiicore/core/config/theme/tuii_colors.dart';
import 'package:tuiipwa/utils/pwa_i18n.dart';
import 'package:tuiipwa/utils/spacing.dart';

class AgeRestrictionWidget extends StatelessWidget {
  const AgeRestrictionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Age Restriction'.i18n,
            style: const TextStyle(
              fontSize: 16,
              color: TuiiColors.defaultText,
              fontWeight: FontWeight.w700,
            )),
        const SizedBox(
          height: space20,
        ),
        Flexible(
          child: Text(
              'Tuii requires you to be at least 18 years old to be an educator or an independent student.  If you are under 18 and a student, ask your parent or guardian to sign up, and then add you as a dependent user.'
                  .i18n,
              style: const TextStyle(
                fontSize: 14,
                color: TuiiColors.defaultText,
                fontWeight: FontWeight.normal,
              )),
        ),
      ],
    );
  }
}
