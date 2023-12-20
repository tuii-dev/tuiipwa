import 'package:flutter/material.dart';
import 'package:tuiicore/core/config/theme/tuii_colors.dart';
import 'package:tuiicore/core/services/snackbar_service.dart';
import 'package:tuiipwa/common/widgets/filled_rounded_pinput.dart';
import 'package:tuiipwa/injection_container.dart';
import 'package:tuiipwa/utils/pwa_i18n.dart';
import 'package:tuiipwa/utils/spacing.dart';

class CodeCaptureWidget extends StatefulWidget {
  const CodeCaptureWidget({Key? key, this.title = 'Mobile Verification'})
      : super(key: key);

  final String? title;

  @override
  State<CodeCaptureWidget> createState() => _CodeCaptureWidgetState();
}

class _CodeCaptureWidgetState extends State<CodeCaptureWidget> {
  final SnackbarService snackbarService = sl<SnackbarService>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
        color: TuiiColors.white,
        height: 250,
        child: Form(
            key: formKey,
            child: Stack(
              children: [
                Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: space20),
                      Text(widget.title ?? 'Mobile Verification'.i18n,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Flexible(
                        child: Text(
                            'Please enter the code you received in the SMS below.'
                                .i18n,
                            style: const TextStyle(
                                fontSize: 14, color: TuiiColors.muted)),
                      ),
                      const SizedBox(height: space30),
                      Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: space20),
                          child: FilledRoundedPinPut(
                              defaultPinWidth: 44,
                              defaultPinHeight: 40,
                              fontSize: 14,
                              scaleUnit: 6,
                              length: 6,
                              completionCallback: (code) {
                                debugPrint('code: $code');
                                Navigator.of(context).pop(code);
                              })),
                      const SizedBox(height: space30),
                    ]),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Image.asset(
                    'assets/images/logos/tuii_collapsed_logo_1x.png',
                    width: 24,
                    height: 25,
                  ),
                ),
              ],
            )));
  }
}
