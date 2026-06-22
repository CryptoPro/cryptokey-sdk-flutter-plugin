import 'package:cpkey_example/presentation/auth/auth_screen.dart';
import 'package:cpkey_example/presentation/main/main_screen.dart';
import 'package:cpkey_example/presentation/start_bloc.dart';
import 'package:cpkey_example/presentation/start_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:cpkey/cpkey.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'di/injection.dart';
import 'navigation/app_routes.dart';
import 'navigation/navigation_service.dart';

void main() async {
  // 1. Обязательный вызов для асинхронной инициализации Flutter-биндингов
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Инициализируем getIt (настраиваем зависимости, зарегистрированные через @injectable)
  configureDependencies();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  // Если Cpkey зарегистрирован в getIt, его можно получить оттуда: getIt<Cpkey>()
  // Если нет, оставляем создание объекта здесь:
  final _cpkeyPlugin = Cpkey();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion =
          await _cpkeyPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  /*@override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DSS SDK App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      // Оборачиваем всё приложение в BlocProvider для управления глобальным состоянием навигации/авторизации
      home: BlocProvider<StartBloc>(
        create: (context) => getIt<StartBloc>(),
        child: BlocBuilder<StartBloc, StartState>(
          builder: (context, state) {
            // Динамически переключаем экраны на основе состояния StartBloc
            return const StartScreen();
          },
        ),
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    final navigationService = getIt<NavigationService>();

    return MaterialApp(
      title: 'DSS SDK App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      // 2. Связываем NavigationService с навигатором Flutter
      navigatorKey: navigationService.navigatorKey,

      // 3. Указываем стартовый роут
      initialRoute: AppRoutes.start,

      // 4. Подключаем ручной генератор роутов
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
