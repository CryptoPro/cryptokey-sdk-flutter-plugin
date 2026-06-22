import 'package:cpkey_example/presentation/start_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../di/injection.dart';
import '../navigation/app_routes.dart';
import '../navigation/navigation_service.dart';
import 'common_ui.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StartBloc>(
      // Получаем StartBloc из DI контейнера getIt
      create: (context) => getIt<StartBloc>(),
      child: Scaffold(
        body: BlocConsumer<StartBloc, StartState>(
          // listener отвечает за побочные эффекты (диалоги, навигацию, снэкбары)
          listener: (context, state) {
            if (state is ShowError) {
              context.showErrorDialog(state.message);
            }
          },
          // builder отвечает ТОЛЬКО за отрисовку интерфейса
          builder: (context, state) {
            // Если состояние загрузки/проверки авторизации
            if (state is StartLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Проверка авторизации...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            // Начальное состояние экрана с кнопкой (и любые другие состояния)
            return Container(
              width: double.infinity,
              color: Colors.blueGrey[50],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/cpkey_icon.svg',
                    width: 80,
                    height: 100,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Демо приложение',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Демонстрация базовых функций DSS SDK',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // Отправляем событие проверки статуса в BLoC
                      context.read<StartBloc>().add(Initialization());
                    },
                    child: const Text(
                      'Открыть Демо(init + initBioRng)',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
