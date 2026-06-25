
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../di/injection.dart';
import '../keys/keys_screen.dart';
import '../operations/operations_screen.dart';
import '../cert/cert_screen.dart';
import '../profile/profile_screen.dart';
import 'main_bloc.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  final List<Widget> _screens = const [
    OperationsScreen(),
    CertScreen(),
    ProfileScreen(),
    KeysScreen(),
  ];

  final List<String> _titles = const [
    'Операции(Policy.getOperations)',
    'Сертификаты(Cert.getCertList)',
    'Профиль(Auth.getAuthList)',
    'Ключи(SigningKey.getListKeys)',
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
              body: _screens[state.currentIndex],
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
                BottomNavigationBarItem(
                  icon: Icon(Icons.key),
                  activeIcon: Icon(Icons.key_sharp),
                  label: 'Ключи',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}