import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as sc;
import 'package:tuiicore/core/models/system_constants.dart';
import 'package:tuiipwa/web/constants/constants.dart';
import 'firebase_options.dart';
import 'injection_container.dart' as di;

bool get isInDebugMode {
  bool inDebugMode = true;
  return inDebugMode;
}

// App Key 6aby9fv6jwxm
// Dev Key 5erm4235gptj
const String streamChatAppKey = '6aby9fv6jwxm';
final client = sc.StreamChatClient(streamChatAppKey, logLevel: sc.Level.SEVERE);

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
