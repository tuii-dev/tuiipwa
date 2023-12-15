import 'dart:async';

import 'package:context_holder/context_holder.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as sc;
import 'package:tuiicore/core/bloc/system_overlay/system_overlay_bloc.dart';
import 'package:tuiicore/core/config/theme/tuii_colors.dart';
import 'package:tuiicore/core/config/theme/tuii_dark_theme.dart';
import 'package:tuiicore/core/config/theme/tuii_light_theme.dart';
import 'package:tuiicore/core/models/system_constants.dart';
import 'package:tuiipwa/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tuiipwa/features/auth/presentation/cubit/login/login_cubit.dart';
import 'package:tuiipwa/features/auth/presentation/pages/login_screen.dart';
import 'package:tuiipwa/features/auth/presentation/pages/mobile_screen.dart';
import 'package:tuiipwa/features/auth/presentation/pages/profile_selection_screen.dart';
import 'package:tuiipwa/features/auth/presentation/pages/signup_screen.dart';
import 'package:tuiipwa/features/communications/presentation/bloc/stream_chat/stream_chat_bloc.dart';
import 'package:tuiipwa/features/splash/presentation/pages/splash_screen.dart';
import 'package:tuiipwa/features/tuii_app/presentation/bloc/tuii_app/tuii_app_bloc.dart';
import 'package:tuiipwa/features/tuii_app/presentation/bloc/tuii_app_link/tuii_app_link_bloc.dart';
import 'package:tuiipwa/features/tuii_app/presentation/bloc/tuii_beacon/tuii_beacon_bloc.dart';
import 'package:tuiipwa/features/tuii_app/presentation/bloc/tuii_notifications/tuii_notifications_bloc.dart';
import 'package:tuiipwa/routes.dart';
import 'package:tuiipwa/utils/conditional_route_widget.dart';
import 'package:tuiipwa/web/constants/constants.dart';
import 'firebase_options.dart';
import 'injection_container.dart' as di;

bool get isInDebugMode {
  bool inDebugMode = true;
  return inDebugMode;
}

String? urlCommandKey;
String? urlCommandPayload;
String? urlDeepLinkPayload;
String? appVersion;

// App Key 6aby9fv6jwxm
// Dev Key 5erm4235gptj
const String streamChatAppKey = '6aby9fv6jwxm';
final client = sc.StreamChatClient(streamChatAppKey, logLevel: sc.Level.SEVERE);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  urlCommandKey = _getT1UrlParam(false);
  urlCommandPayload = _getT2UrlParam(false);
  urlDeepLinkPayload = _getT3UrlParam(false);

  // Flutter >= 1.17 and Dart >= 2.8
  runZonedGuarded<Future<void>>(() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    debugPrint(
        'Connecting to project: ${DefaultFirebaseOptions.currentPlatform.projectId}');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    final constants = SystemConstants(
        channel: SystemConstantsProvider.channel,
        channelSignUpIsSecured: SystemConstantsProvider.channelSignUpIsSecured,
        runIdentityVerification:
            SystemConstantsProvider.runIdentityVerification,
        projectId: SystemConstantsProvider.projectId,
        apiRootUrl: SystemConstantsProvider.apiRootUrl,
        streamCreateTokenUrl: SystemConstantsProvider.streamCreateTokenUrl,
        streamRevokeTokenUrl: SystemConstantsProvider.streamRevokeTokenUrl,
        streamMessageUrl: SystemConstantsProvider.streamMessageUrl,
        createAppLinkUrl: SystemConstantsProvider.createAppLinkUrl,
        helpScoutBeaconId: SystemConstantsProvider.helpScoutBeaconId,
        smsSendUrl: SystemConstantsProvider.smsSendUrl,
        smsSendPhoneVerificationCodeUrl:
            SystemConstantsProvider.smsSendPhoneVerificationCodeUrl,
        smsVerifyPhoneVerificationCodeUrl:
            SystemConstantsProvider.smsVerifyPhoneVerificationCodeUrl);

    await di.init(constants);

    runApp(const TuiiPwaApp());

    //p
  }, (error, stackTrace) async {
    debugPrint('Caught Dart Error!');
    if (isInDebugMode) {
      // in development, print error and stack trace
      debugPrint('$error');
      debugPrint('$stackTrace');
    } else {
      // report to a error tracking system in production
    }
  });

  // You only need to call this method if you need the binding to be initialized before calling runApp.
  WidgetsFlutterBinding.ensureInitialized();
  // This captures errors reported by the Flutter framework.
  FlutterError.onError = (FlutterErrorDetails details) async {
    final dynamic exception = details.exception;
    final StackTrace? stackTrace = details.stack;
    if (isInDebugMode) {
      debugPrint('Caught Framework Error!');
      // In development mode simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode report to the application zone
      Zone.current.handleUncaughtError(exception, stackTrace!);
    }
  };
}

class TuiiPwaApp extends StatelessWidget {
  const TuiiPwaApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<TuiiBeaconBloc>()..init(),
        ),
        BlocProvider(
          create: (context) => di.sl<SystemOverlayBloc>(),
        ),
        BlocProvider(
          create: (context) =>
              di.sl<AuthBloc>()..init(client, urlCommandKey, urlCommandPayload),
        ),
        BlocProvider(
          create: (context) => di.sl<LoginCubit>(),
        ),
        BlocProvider(
          create: (context) => di.sl<StreamChatBloc>(),
        ),
        BlocProvider(
          create: (context) => di.sl<TuiiAppBloc>()
            ..initVersionManagementAndDeepLinking(
                appVersion, urlDeepLinkPayload),
        ),
        BlocProvider(
          create: (context) => di.sl<TuiiAppLinkBloc>()..init(urlCommandKey),
        ),
        BlocProvider(
          create: (context) => di.sl<TuiiNotificationsBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Tuii',
        debugShowCheckedModeBanner: false,
        navigatorKey: ContextHolder.key,
        themeMode: ThemeMode.system,
        theme: getLightTheme(),
        darkTheme: getDarkTheme(),
        // initialRoute: SplashScreen.routeName,
        // onGenerateRoute: WebDesktopRouter.onGenerateRoute,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
        ],
        builder: (context, child) {
          return sc.StreamChat(
            client: client,
            streamChatThemeData: sc.StreamChatThemeData(
                colorTheme: sc.StreamColorTheme.light(
                  appBg: TuiiColors.inactiveBackground,
                ),
                messageInputTheme: const sc.StreamMessageInputThemeData(
                  sendButtonColor: TuiiColors.primary,
                  expandButtonColor: TuiiColors.primary,
                  sendButtonIdleColor: TuiiColors.inactiveTool,
                  elevation: 0,
                ),
                otherMessageTheme: const sc.StreamMessageThemeData(
                    messageBackgroundColor: TuiiColors.primary,
                    messageBorderColor: TuiiColors.primary,
                    messageTextStyle: TextStyle(
                        color: TuiiColors.white, fontWeight: FontWeight.w500),
                    messageAuthorStyle: TextStyle(
                        fontWeight: FontWeight.w700, color: TuiiColors.black),
                    createdAtStyle: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: TuiiColors.lightText)),
                ownMessageTheme: const sc.StreamMessageThemeData(
                    messageBackgroundColor: TuiiColors.otherMessageBackground,
                    messageBorderColor: TuiiColors.otherMessageBackground,
                    messageTextStyle: TextStyle(
                        color: TuiiColors.black, fontWeight: FontWeight.w600),
                    messageAuthorStyle: TextStyle(
                        fontWeight: FontWeight.w700, color: TuiiColors.black),
                    createdAtStyle: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: TuiiColors.lightText))),
            streamChatConfigData:
                sc.StreamChatConfigurationData(reactionIcons: []),
            child: ResponsiveBreakpoints(
                breakpoints: const [
                  Breakpoint(start: 0, end: 450, name: MOBILE),
                  Breakpoint(start: 451, end: 800, name: TABLET),
                  Breakpoint(start: 801, end: 1920, name: DESKTOP),
                  Breakpoint(start: 1921, end: double.infinity, name: '4K'),
                ],
                child: LoaderOverlay(
                    useDefaultLoading: false,
                    overlayWidget: const Center(
                        child: SizedBox(
                            width: 50,
                            height: 50,
                            child: LoadingIndicator(
                              indicatorType: Indicator.lineScale,
                              colors: [
                                TuiiColors.primary,
                                TuiiColors.defaultColor,
                                TuiiColors.defaultDarkColor,
                                TuiiColors.active,
                              ],
                              strokeWidth: 0.25,
                            ))),
                    child: child!)),
          );
        },
        initialRoute: '/splash',
        // The following code implements the legacy ResponsiveWrapper AutoScale functionality
        // using the new ResponsiveScaledBox. The ResponsiveScaledBox widget preserves
        // the legacy ResponsiveWrapper behavior, scaling the UI instead of resizing.
        //
        // A ConditionalRouteWidget is used to showcase how to disable the AutoScale
        // behavior for a page.
        onGenerateRoute: (RouteSettings settings) {
          // A custom `fadeThrough` route transition animation.
          return Routes.fadeThrough(settings, (context) {
            // Wrap widgets with another widget based on the route.
            // Wrap the page with the ResponsiveScaledBox for desired pages.
            return ConditionalRouteWidget(
                routesExcluded: const [], // Excluding a page from AutoScale.
                builder: (context, child) => MaxWidthBox(
                      // A widget that limits the maximum width.
                      // This is used to create a gutter area on either side of the content.
                      maxWidth: 1200,
                      background: Container(color: TuiiColors.bgColorScreen),
                      child: ResponsiveScaledBox(
                          // ResponsiveScaledBox renders its child with a FittedBox set to the `width` value.
                          // Set the fixed width value based on the active breakpoint.
                          width: ResponsiveValue<double>(context,
                              conditionalValues: [
                                const Condition.equals(
                                    name: MOBILE, value: 450),
                                const Condition.between(
                                    start: 800, end: 1100, value: 800),
                                const Condition.between(
                                    start: 1000, end: 1200, value: 1000),
                                // There are no conditions for width over 1200
                                // because the `maxWidth` is set to 1200 via the MaxWidthBox.
                              ]).value,
                          child: child!),
                    ),
                child: BouncingScrollWrapper.builder(
                    context, buildPage(settings.name ?? '', settings.arguments),
                    dragWithMouse: true));
          });
        },
      ),
    );
  }
}

// onGenerateRoute route switcher.
// Navigate using the page name, `Navigator.pushNamed(context, ListPage.name)`.
Widget buildPage(String name, Object? arguments) {
  switch (name) {
    case '/splash':
      return const SplashScreen();
    case '/auth/login':
      return I18n(child: const LoginScreen());
    case '/auth/signup':
      return I18n(child: const SignUpScreen());
    case '/auth/profile':
      return I18n(child: const ProfileSelectionScreen());
    case '/auth/mobile':
      return I18n(child: const MobileScreen());
    default:
      return _errorRoute();
  }
}

String? _getT1UrlParam(bool isDebugMode) {
  final key = isDebugMode
      ? const String.fromEnvironment('t1')
      : Uri.base.queryParameters['t1'];

  return key;
}

String? _getT2UrlParam(bool isDebugMode) {
  final key = isDebugMode
      ? const String.fromEnvironment('t2')
      : Uri.base.queryParameters['t2'];

  return key;
}

String? _getT3UrlParam(bool isDebugMode) {
  final key = isDebugMode
      ? const String.fromEnvironment('t3')
      : Uri.base.queryParameters['t3'];

  return key;
}

Widget _errorRoute() {
  return Scaffold(
      appBar: AppBar(
        title: const Text("Error"),
      ),
      body: const Center(child: Text("Something went wrong!")));
}
