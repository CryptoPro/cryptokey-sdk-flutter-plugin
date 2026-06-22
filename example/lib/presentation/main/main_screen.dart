
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../di/injection.dart';
import '../operations/operations_screen.dart';
import '../cert/cert_screen.dart';
import '../profile/profile_screen.dart';
import 'main_bloc.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  // Список дочерних экранов
  final List<Widget> _screens = const [
    OperationsScreen(),
    CertScreen(),
    ProfileScreen(),
  ];

  // Заголовки для AppBar в зависимости от выбранного таба
  final List<String> _titles = const [
    'Список операций',
    'Мои сертификаты',
    'Профиль пользователя',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MainBloc>(
      create: (context) => getIt<MainBloc>(),
      child: BlocBuilder<MainBloc, MainState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_titles[state.currentIndex]),
              automaticallyImplyLeading: false, // Скрываем кнопку "Назад"
              centerTitle: true,
              elevation: 2,
            ),
            body: IndexedStack(
              index: state.currentIndex,
              children: _screens,
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: state.currentIndex,
              onTap: (index) {
                // Отправляем событие смены вкладки в BLoC
                context.read<MainBloc>().add(TabChanged(index));
              },
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.list_alt),
                  label: 'Операции',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.verified_user_outlined),
                  activeIcon: Icon(Icons.verified_user),
                  label: 'Сертификаты',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Профиль',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}