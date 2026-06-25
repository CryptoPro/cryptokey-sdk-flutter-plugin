import 'package:flutter/material.dart';

import '../presentation/auth/auth_screen.dart';
import '../presentation/cert/create_cert_screen.dart';
import '../presentation/main/main_screen.dart';
import '../presentation/start_screen.dart';

class AppRoutes {
  static const String start = '/';
  static const String auth = '/auth';
  static const String main = '/main';
  static const String create_cert = '/main/create_cert';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case start:
        return MaterialPageRoute(builder: (_) => const StartScreen());
      case auth:
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case create_cert:
        return MaterialPageRoute(builder: (_) => const CreateCertScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Путь ${settings.name} не найден')),
          ),
        );
    }
  }
}