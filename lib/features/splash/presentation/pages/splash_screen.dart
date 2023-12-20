import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuiicore/core/config/theme/tuii_colors.dart';
import 'package:tuiipwa/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tuiipwa/features/auth/presentation/pages/login_screen.dart';
import 'package:tuiipwa/features/auth/presentation/pages/mobile_screen.dart';
import 'package:tuiipwa/features/auth/presentation/pages/profile_selection_screen.dart';
import 'package:tuiipwa/features/tuii_app/presentation/bloc/tuii_beacon/tuii_beacon_bloc.dart';
import 'package:tuiipwa/features/tuii_app/presentation/pages/tuii_app_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/splash';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<TuiiBeaconBloc>(context)
          .add(const HideBeaconCommandEvent());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (mounted) {
          if (state.status == AuthStatus.authenticated) {
            Navigator.of(context).pushReplacementNamed(TuiiAppScreen.routeName);
          } else if (state.status == AuthStatus.unauthenticated) {
            Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
          } else if (state.status ==
                  AuthStatus.authenticatedRequiresMobileVerificationOn ||
              state.status ==
                  AuthStatus.authenticatedRequiresMobileVerificationOff) {
            Navigator.of(context).pushReplacementNamed(MobileScreen.routeName);
          } else if (state.status ==
              AuthStatus.authenticatedRequiresOnboarding) {
            Navigator.of(context)
                .pushReplacementNamed(ProfileSelectionScreen.routeName);
          } else if (state.status == AuthStatus.error) {
            Navigator.of(context).pushReplacementNamed('/error');
          }
        }
      },
      child: Container(
          color: TuiiColors.defaultDarkColor,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logos/tuii_expanded_logo_2x.png',
                  width: size.width,
                ),
              ])),
    );
  }
}
