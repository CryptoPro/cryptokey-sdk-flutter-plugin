
import 'package:cpkey_example/presentation/profile/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/injection.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (context) => getIt<ProfileBloc>()..add(LoadProfile()),
      child: Scaffold(
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProfileLoaded) {
              final profile = state.user;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    const CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.blue,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 60, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.name ?? 'Без имени',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (profile.alias != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        profile.alias!,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Карточка с основной информацией
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Основная информация',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(Icons.fingerprint, 'UID', profile.uid),
                            _buildInfoRow(Icons.key, 'KID', profile.kid),
                            _buildInfoRow(Icons.label_outline, 'Псевдоним', profile.alias),
                            _buildInfoRow(Icons.circle, 'Статус', profile.state),
                            _buildInfoRow(Icons.link, 'Сервис', profile.serviceUrl),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Карточка с информацией о ключах
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ключ аутентификации',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              Icons.vpn_key,
                              'Тип ключа',
                              profile.authKeyType == 1
                                  ? 'Распределённые ключи'
                                  : profile.authKeyType == 0
                                  ? 'Стандартный'
                                  : null,
                            ),
                            _buildInfoRow(
                              Icons.calendar_today,
                              'Действует с',
                              profile.notBefore != null
                                  ? _formatTimestamp(profile.notBefore!)
                                  : null,
                            ),
                            _buildInfoRow(
                              Icons.event_busy,
                              'Действует до',
                              profile.notAfter != null
                                  ? _formatTimestamp(profile.notAfter!)
                                  : null,
                            ),
                            _buildInfoRow(
                              Icons.warning_amber,
                              'Требуется подпись для привязки',
                              profile.isSignatureRequired == true ? 'Да' : 'Нет',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Карточка с информацией о пароле
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Пароль',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              Icons.lock_clock,
                              'Создан',
                              profile.passwordCreatedTime != null
                                  ? _formatTimestamp(profile.passwordCreatedTime!)
                                  : null,
                            ),
                            _buildInfoRow(
                              Icons.lock_open,
                              'Истекает',
                              profile.passwordExpirationTime != null
                                  ? _formatTimestamp(profile.passwordExpirationTime!)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Кнопка выхода
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          context.read<ProfileBloc>().add(LogoutRequested());
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          'Выйти из профиля',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            }

            return const Center(child: Text('Не удалось загрузить профиль'));
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value ?? '—',
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}