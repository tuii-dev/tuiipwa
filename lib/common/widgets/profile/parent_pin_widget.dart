import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuiicore/core/config/theme/tuii_colors.dart';
import 'package:tuiicore/core/services/snackbar_service.dart';
import 'package:tuiipwa/common/widgets/filled_rounded_pinput.dart';
import 'package:tuiipwa/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tuiipwa/features/auth/presentation/cubit/profile/profile_cubit.dart';
import 'package:tuiipwa/injection_container.dart';
import 'package:tuiipwa/utils/pwa_i18n.dart';
import 'package:tuiipwa/utils/spacing.dart';

class ParentPinWidget extends StatefulWidget {
  const ParentPinWidget(
      {super.key,
      required this.isInstantiatedInSettings,
      required this.containerHeight});

  final bool isInstantiatedInSettings;
  final double containerHeight;

  @override
  State<ParentPinWidget> createState() => _ParentPinWidgetState();
}

class _ParentPinWidgetState extends State<ParentPinWidget> {
  late SnackbarService _snackbarService;

  @override
  void initState() {
    _snackbarService = sl<SnackbarService>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
              child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Container(
                color: TuiiColors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Setup Parental PIN'.i18n,
                        style: const TextStyle(
                          fontSize: 18,
                          color: TuiiColors.defaultText,
                          fontWeight: FontWeight.w700,
                        )),
                    const SizedBox(height: space10),
                    Text('Add a four-digit security pin below'.i18n,
                        style: const TextStyle(
                          fontSize: 16,
                          color: TuiiColors.defaultText,
                          fontWeight: FontWeight.w700,
                        )),
                    const SizedBox(height: space10),
                    Flexible(
                      child: Padding(
                        padding: paddingHorizontal20,
                        child: Text(
                            'Your parental PIN is used to secure payments and learning profile switching. Having PIN protection activated ensures that your children cannot make payments to educators without your consent, and it blocks your children from activating other learning profiles registered on your account.'
                                .i18n,
                            style: const TextStyle(
                              fontSize: 14,
                              color: TuiiColors.defaultText,
                            )),
                      ),
                    ),
                    const SizedBox(height: space30),
                    Padding(
                        padding: paddingHorizontal20,
                        child: FilledRoundedPinPut(
                            defaultPinWidth: 64,
                            defaultPinHeight: 56,
                            fontSize: 24,
                            scaleUnit: 8,
                            length: 4,
                            completionCallback: (code) {
                              debugPrint('code: $code');
                              context.read<ProfileCubit>().pinCodeChanged(code);
                            })),
                    state.pinCode != null && state.pinCode!.length == 4
                        ? Padding(
                            padding: paddingHorizontal20,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: space20),
                                  Text('Confirm'.i18n,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: TuiiColors.defaultText,
                                      )),
                                  const SizedBox(height: space10),
                                  FilledRoundedPinPut(
                                      defaultPinWidth: 64,
                                      defaultPinHeight: 56,
                                      fontSize: 24,
                                      scaleUnit: 8,
                                      length: 4,
                                      completionCallback: (code) {
                                        debugPrint('code: $code');
                                        if (code == state.pinCode) {
                                          final user = context
                                              .read<AuthBloc>()
                                              .state
                                              .user!;
                                          context
                                              .read<ProfileCubit>()
                                              .completeOnboarding(user, false);
                                        } else {
                                          _snackbarService.queueSnackbar(
                                              context,
                                              true,
                                              'The PIN you entered is incorrect. Please try again.'
                                                  .i18n,
                                              500);
                                        }
                                      }),
                                ]),
                          )
                        : const SizedBox.shrink()
                  ],
                ),
              ),
            ),
          ));
        });
      },
    );
  }
}
