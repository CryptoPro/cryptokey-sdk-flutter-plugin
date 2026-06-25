import 'dart:convert';

import 'package:cpkey/CpKeyPlugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../di/injection.dart';
import 'keys_bloc.dart';

class KeysScreen extends StatelessWidget {
  const KeysScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<KeysBloc>(
      create: (context) => getIt<KeysBloc>(),
      child: Scaffold(
        body: BlocBuilder<KeysBloc, KeysState>(
          builder: (context, state) {
            if (state is KeysInitial) {
              context.read<KeysBloc>().add(FetchKeysEvent());
              return const Center(child: CircularProgressIndicator());
            }

            if (state is KeysLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is KeysError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ошибка загрузки ключей:\n${state.message}',
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<KeysBloc>().add(FetchKeysEvent());
                        },
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is KeysLoaded) {
              final keys = state.keys;

              if (keys.isEmpty) {
                return const Center(
                  child: Text('Ключи подписи не найдены на устройстве'),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                itemCount: keys.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final DSSSigningKeyInfo keyInfo = keys[index];

                  final String title = keyInfo.containerName ?? 'Без названия';
                  final String? fullName = keyInfo.containerFullName;
                  final String createdDate = _formatTimestamp(
                    keyInfo.createdAtMs,
                  );
                  final String installedDate = _formatTimestamp(
                    keyInfo.installedAtMs,
                  );
                  final String containerTypeStr =
                      keyInfo.keyContainerType?.name ?? "";

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: keyInfo.isInstalled
                                    ? Colors.green
                                    : Colors.orange,
                                child: const Icon(
                                  Icons.vpn_key,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (keyInfo.createdAtMs != null)
                                      Text(
                                        'Создан: $createdDate',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    if (keyInfo.installedAtMs != null)
                                      Text(
                                        'Установлен: $installedDate',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    Text(
                                      keyInfo.isInstalled
                                          ? 'Сертификат установлен'
                                          : 'Сертификат отсутствует',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: keyInfo.isInstalled
                                            ? Colors.green[700]
                                            : Colors.orange[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (fullName != null && fullName.isNotEmpty) ...[
                            const Divider(height: 24),
                            Text(
                              'Полное имя:\n$fullName',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                          const Divider(height: 24),
                          _buildDetailRow(
                            'ID пользователя (UID):',
                            keyInfo.uid ?? 'Не указан',
                          ),
                          _buildDetailRow(
                            'ID сертификата (CID):',
                            keyInfo.cid ?? 'Отсутствует',
                          ),
                          _buildDetailRow(
                            'ID запроса (RID):',
                            keyInfo.rid ?? 'Отсутствует',
                          ),
                          _buildDetailRow('Тип контейнера:', containerTypeStr),
                          // Если это Android и есть инфо о провайдере
                          if (keyInfo.providerInfo != null)
                            _buildDetailRow(
                              'Криптопровайдер:',
                              '${keyInfo.providerInfo?.provName ?? 'Неизвестно'} (тип: ${keyInfo.providerInfo?.provType ?? '?'})',
                            ),
                          // Если это iOS и есть имя провайдера
                          if (keyInfo.providerName != null)
                            _buildDetailRow(
                              'Провайдер (iOS):',
                              keyInfo.providerName!,
                            ),
                          if (keyInfo.isExportable != null)
                            _buildDetailRow(
                              'Экспортируемый:',
                              keyInfo.isExportable! ? 'Да (УНЭП)' : 'Нет',
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(int? timestampMs) {
    if (timestampMs == null) return 'Нет данных';
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  }

  void _onKeySelected(BuildContext context, DSSSigningKeyInfo keyInfo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Выбран контейнер: ${keyInfo.containerName}')),
    );
  }
}
