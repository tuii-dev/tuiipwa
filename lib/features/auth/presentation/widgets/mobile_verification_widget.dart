// ignore_for_file: use_build_context_synchronously

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tuiicore/core/config/theme/tuii_colors.dart';
import 'package:tuiicore/core/services/snackbar_service.dart';
import 'package:tuiipwa/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tuiipwa/features/auth/presentation/cubit/phoneVerification/phone_verification_cubit.dart';
import 'package:tuiipwa/common/widgets/filled_rounded_pinput.dart';
import 'package:tuiipwa/features/auth/presentation/pages/onboarding_screen.dart';
import 'package:tuiipwa/features/tuii_app/presentation/pages/tuii_app_screen.dart';
import 'package:tuiipwa/injection_container.dart';
import 'package:tuiipwa/common/common.dart';
import 'package:tuiipwa/utils/pwa_i18n.dart';
import 'package:tuiipwa/utils/spacing.dart';

class MobileVerificationWidget extends StatefulWidget {
  const MobileVerificationWidget({super.key});

  @override
  State<MobileVerificationWidget> createState() =>
      _MobileVerificationWidgetState();
}

class _MobileVerificationWidgetState extends State<MobileVerificationWidget> {
  late SnackbarService _snackbarService;
  late List<Widget> _forms;

  @override
  void initState() {
    _snackbarService = sl<SnackbarService>();
    _forms = const [_MobileCaptureForm(), _CodeCaptureForm()];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PhoneVerificationCubit, PhoneVerificationState>(
      listenWhen: (prevState, state) => prevState.status != state.status,
      listener: (context, state) {
        if (state.status == PhoneVerificationStatus.sendingSms) {
          context.loaderOverlay.show();
        } else if (state.status == PhoneVerificationStatus.verifyingCode) {
          context.loaderOverlay.show();
        } else if (state.status == PhoneVerificationStatus.sendSmsError) {
          context.loaderOverlay.hide();
          _snackbarService.queueSnackbar(
              context,
              true,
              state.failure?.message ??
                  'Failed to send phone verification sms.'.i18n,
              500);
        } else if (state.status == PhoneVerificationStatus.verifyCodeError) {
          context.loaderOverlay.hide();
          _snackbarService.queueSnackbar(context, true,
              state.failure?.message ?? 'Invalid code specified.'.i18n, 500);
        } else if (state.status == PhoneVerificationStatus.smsSent) {
          context.loaderOverlay.hide();
          // snackbarService.queueSnackbar(context, false,
          //     'A verification code has been sent to your phone.'.i18n, 500);
        } else if (state.status == PhoneVerificationStatus.codeVerified) {
          context.loaderOverlay.hide();
          Navigator.of(context)
              .pushReplacementNamed(OnboardingScreen.routeName);
        }
      },
      builder: (context, state) {
        return PageTransitionSwitcher(
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
        );
      },
    );
  }
}

class _MobileCaptureForm extends StatefulWidget {
  const _MobileCaptureForm();

  @override
  State<_MobileCaptureForm> createState() => _MobileCaptureFormState();
}

class _MobileCaptureFormState extends State<_MobileCaptureForm> {
  final SnackbarService snackbarService = sl<SnackbarService>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController controller = TextEditingController();

  // @override
  // void didChangeDependencies() async {
  //   final cubit = BlocProvider.of<PhoneVerificationCubit>(context);
  //   final phoneNumber = cubit.state.phoneNumber?.phoneNumber;
  //   bool isValid =
  //       phoneNumber != null ? await validatePhoneNumber(phoneNumber) : false;
  //   controller.text = isValid ? phoneNumber : controller.text;
  //   super.didChangeDependencies();
  // }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final platformCountries = getPlatformCountries(context);

    return Container(
      color: TuiiColors.white,
      height: 280,
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Mobile Verification'.i18n,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Flexible(
              child: Text(
                  'Please enter your mobile number below and click the Send Code button.'
                      .i18n,
                  style:
                      const TextStyle(fontSize: 14, color: TuiiColors.muted)),
            ),
            // const SizedBox(height: 5),
            // Text(
            //     'When you receive the SMS, enter the code in the form presented to you.'
            //         .i18n,
            //     style: const TextStyle(
            //         fontSize: 16, color: TuiiColors.muted)),
            const SizedBox(height: space20),
            SizedBox(
              height: 50,
              child: InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) {
                  BlocProvider.of<PhoneVerificationCubit>(context)
                      .phoneNumberChanged(number);
                },
                onInputValidated: (bool value) {
                  debugPrint('Validated: ${value.toString()}');
                },
                countries: platformCountries,
                selectorConfig: const SelectorConfig(
                  selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                  showFlags: true,
                  leadingPadding: 0,
                  trailingSpace: false,
                ),
                ignoreBlank: false,
                autoFocus: true,
                autoValidateMode: AutovalidateMode.disabled,
                selectorTextStyle:
                    const TextStyle(color: TuiiColors.defaultText),
                // initialValue: '',
                textFieldController: controller,
                formatInput: false,
                keyboardType: const TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                inputBorder: const OutlineInputBorder(),
                onSaved: (PhoneNumber number) {
                  debugPrint('On Saved: $number');
                },
                onFieldSubmitted: (value) async {
                  _sendCode(context, snackbarService);
                },
              ),
            ),
            const SizedBox(height: space30),
            _SendCodeButton(
                snackbarService: snackbarService, label: 'Send Code'.i18n),
          ],
        ),
      ),
    );
  }
}

class _CodeCaptureForm extends StatefulWidget {
  const _CodeCaptureForm();

  @override
  State<_CodeCaptureForm> createState() => __CodeCaptureFormState();
}

class __CodeCaptureFormState extends State<_CodeCaptureForm> {
  final SnackbarService snackbarService = sl<SnackbarService>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
        color: TuiiColors.white,
        height: 280,
        child: Form(
            key: formKey,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Mobile Verification'.i18n,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
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
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: FilledRoundedPinPut(
                          defaultPinWidth: 50,
                          defaultPinHeight: 46,
                          fontSize: 18,
                          scaleUnit: 6,
                          length: 6,
                          completionCallback: (code) {
                            debugPrint('code: $code');
                            final user =
                                BlocProvider.of<AuthBloc>(context).state.user!;
                            BlocProvider.of<PhoneVerificationCubit>(context)
                                .verifyPhoneVerificationCodePressed(
                                    user: user, code: code);
                          })),
                  const SizedBox(height: space30),
                  _SendCodeButton(
                      snackbarService: snackbarService,
                      label: 'Resend Code'.i18n,
                      width: 160.0),
                ])));
  }
}

class _SendCodeButton extends StatelessWidget {
  const _SendCodeButton(
      {required this.snackbarService, required this.label, this.width = 130.0});

  final SnackbarService snackbarService;
  final String label;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
              color: TuiiColors.onboardingButtonColor,
              borderRadius: BorderRadius.circular(10.0)),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                _sendCode(context, snackbarService);
                // BlocProvider.of<PhoneVerificationCubit>(context).test();
              },
              child: SizedBox(
                  width: width,
                  height: 40.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(MdiIcons.sendCircleOutline,
                          size: 20, color: TuiiColors.white),
                      const SizedBox(width: 10),
                      Text(label,
                          style: const TextStyle(
                              fontSize: 16.0, color: TuiiColors.white)),
                    ],
                  )),
            ),
          ),
        ),
      ],
    );
  }
}

void _sendCode(BuildContext context, SnackbarService snackbarService) async {
  final cubit = BlocProvider.of<PhoneVerificationCubit>(context);
  final user = BlocProvider.of<AuthBloc>(context).state.user!;
  final phoneNumber = cubit.state.phoneNumber?.phoneNumber;
  final isoCode = cubit.state.phoneNumber?.isoCode;
  if (phoneNumber != null) {
    final isValid = await validatePhoneNumber(phoneNumber, isoCode: isoCode);
    if (isValid) {
      cubit.sendPhoneVerificationCodePressed(user: user);
    } else {
      snackbarService.queueSnackbar(
          context, true, 'Invalid phone number specified.'.i18n, 500);
    }
  } else {
    snackbarService.queueSnackbar(
        context, true, 'Invalid phone number specified.'.i18n, 500);
  }
}
