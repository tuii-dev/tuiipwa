import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuiicore/core/config/theme/tuii_colors.dart';
import 'package:tuiipwa/features/auth/presentation/bloc/auth_bloc.dart';

class SplashScreen extends StatelessWidget {
  static const String name = '/splash';

  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else if (state.status == AuthStatus.unauthenticated) {
          Navigator.of(context).pushReplacementNamed('/auth/login');
        } else if (state.status ==
                AuthStatus.authenticatedRequiresMobileVerificationOn ||
            state.status ==
                AuthStatus.authenticatedRequiresMobileVerificationOff) {
          Navigator.of(context).pushReplacementNamed('/auth/mobile');
        } else if (state.status == AuthStatus.authenticatedRequiresOnboarding) {
          Navigator.of(context).pushReplacementNamed('/auth/profile');
        } else if (state.status == AuthStatus.error) {
          Navigator.of(context).pushReplacementNamed('/error');
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
