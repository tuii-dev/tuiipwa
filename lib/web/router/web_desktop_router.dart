import 'package:flutter/material.dart';

class WebDesktopRouter {
  static String currentRoute = '';
  static Route? onGenerateRoute(RouteSettings settings) {
    debugPrint("Route: $settings");
    if (settings.name != WebDesktopRouter.currentRoute) {
      WebDesktopRouter.currentRoute = settings.name ?? '';
      switch (settings.name) {
        case "/":
          return MaterialPageRoute(
              settings: const RouteSettings(name: "/"),
              builder: (_) => const Scaffold());

        default:
          return _errorRoute();
      }
    } else {
      return null;
    }
  }

  static Route onGenerateNestedRoute(RouteSettings settings) {
    debugPrint("Nested Route: $settings");
    switch (settings.name) {
      default:
        return _errorRoute();
    }
  }

  static Route _errorRoute() {
    return MaterialPageRoute(
        settings: const RouteSettings(name: "/error"),
        builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text("Error"),
            ),
            body: const Center(child: Text("Something went wrong!"))));
  }
}
