
import 'dart:convert';

import 'package:cpkey/CpKeyPlugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/injection.dart';
import 'operation_bloc.dart';

class OperationsScreen extends StatelessWidget {
  const OperationsScreen({Key? key}) : super(key: key);

  // Вспомогательный метод для форматирования Unix-time в читаемую дату
  String _formatTimestamp(int timestamp) {
    if (timestamp <= 0) return '—';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day.$month.$year $hour:$minute';
  }

  // Вспомогательный метод для получения понятного названия из caption JSON
  String _getOperationTitle(DssOperation operation) {
    final captionJson = operation.description.caption;
    if (captionJson != null && captionJson.isNotEmpty) {
      try {
        final Map<String, dynamic> parsed = jsonDecode(captionJson);
        final Map<String, dynamic>? values = parsed['values'];

        if (values != null) {
          final optype = values['optype'];
          if (optype != null && optype.toString().trim().isNotEmpty) {
            return optype.toString();
          }
          final server = values['server'];
          if (server != null) {
            return 'Операция на $server';
          }
        }
      } catch (_) {}
    }
    return operation.description.type;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OperationsBloc>(
      create: (context) => getIt<OperationsBloc>()..add(LoadOperations()),
      child: Scaffold(
        body: BlocBuilder<OperationsBloc, OperationsState>(
          builder: (context, state) {
            if (state is OperationsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is OperationsLoaded) {
              final List<DssOperation> operations = state.operations;

              if (operations.isEmpty) {
                return const Center(child: Text('Список операций пуст'));
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                itemCount: operations.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final DssOperation operation = operations[index];

                  final title = _getOperationTitle(operation);
                  final description = operation.description.description;
                  final createdDate = _formatTimestamp(operation.createdAt);
                  final expiresDate = _formatTimestamp(operation.expiresAt);

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
                              const CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Icon(Icons.security, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Создана: $createdDate'),
                                    Text(
                                      'Истекает: $expiresDate',
                                      style: TextStyle(
                                        color: DateTime.now().millisecondsSinceEpoch > (operation.expiresAt * 1000)
                                            ? Colors.red
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (description != null && description.isNotEmpty) ...[
                            const Divider(height: 24),
                            Text(
                              description,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                          const Divider(height: 24),
                          _buildDetailRow('ID транзакции:', operation.transactionId ?? 'Отсутствует'),
                          _buildDetailRow('Кол-во документов:', '${operation.documentCount} шт.'),
                          _buildDetailRow('Тип операции:', operation.description.type),
                          _buildDetailRow('Подпись на устройстве:', operation.isClientSide ? 'Да (смарт-карта/токен)' : 'Нет (облачная)'),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  context.read<OperationsBloc>().add(
                                    OpenOperation(operation: operation),
                                  );
                                },
                                icon: const Icon(Icons.open_in_new, size: 18),
                                label: const Text('Открыть'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            return const Center(child: Text('Не удалось загрузить операции'));
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
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}