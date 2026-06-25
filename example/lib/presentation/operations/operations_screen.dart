import 'dart:convert';

import 'package:cpkey/CpKeyPlugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/injection.dart';
import '../common_ui.dart';
import 'operation_bloc.dart';

class OperationsScreen extends StatelessWidget {
  const OperationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OperationsBloc>(
      create: (context) => getIt<OperationsBloc>()..add(LoadOperations()),
      child: Scaffold(
        body: BlocListener<OperationsBloc, OperationsState>(
          listenWhen: (previous, current) => current is OperationSuccess,
          listener: (context, state) {
            if (state is OperationSuccess) {
              _handleOperationSuccess(context, state);
            }
          },
          child: BlocBuilder<OperationsBloc, OperationsState>(
            buildWhen: (previous, current) => current is! OperationSuccess,
            builder: (context, state) {
              if (state is OperationsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is OperationsLoaded) {
                return _OperationsList(operations: state.operations);
              }

              return const Center(child: Text('Не удалось загрузить операции'));
            },
          ),
        ),
      ),
    );
  }

  // --- Обработка диалогов (Side Effects) ---

  void _handleOperationSuccess(BuildContext context, OperationSuccess state) {
    final result = state.result;
    final bloc = context.read<OperationsBloc>();

    switch (result.resultType) {
      case DssSignMtResultType.success:
        context.showInfoDialog(
          "Операция успешно подписана",
          onConfirm: () => bloc.add(LoadOperations()),
        );
        break;

      case DssSignMtResultType.partialSuccess:
        final errorDocs = result.documentsWithErrors ?? [];
        _showStatusDialog(
          context: context,
          title: 'Частичный успех',
          message: 'Операция выполнена частично.\nДокументов с ошибками: ${errorDocs.length}',
          onDismiss: () => bloc.add(LoadOperations()),
        );
        break;

      case DssSignMtResultType.suspendedConfirm:
        _showStatusDialog(
          context: context,
          title: 'Ожидание подтверждения',
          message: 'Операция приостановлена и ожидает отправки подтверждения на сервер.',
          onDismiss: () => bloc.add(LoadOperations()),
        );
        break;
    }
  }

  void _showStatusDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onDismiss,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onDismiss();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _OperationsList extends StatelessWidget {
  final List<DssOperation> operations;

  const _OperationsList({required this.operations});

  @override
  Widget build(BuildContext context) {
    if (operations.isEmpty) {
      return const Center(child: Text('Список операций пуст'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: operations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _OperationCard(operation: operations[index]);
      },
    );
  }
}

class _OperationCard extends StatelessWidget {
  final DssOperation operation;

  const _OperationCard({required this.operation});

  @override
  Widget build(BuildContext context) {
    final title = _getOperationTitle(operation);
    final description = operation.description.description;
    final createdDate = _formatTimestamp(operation.createdAt);
    final expiresDate = _formatTimestamp(operation.expiresAt);
    final isExpired = DateTime.now().millisecondsSinceEpoch > (operation.expiresAt * 1000);

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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Создана: $createdDate'),
                      Text(
                        'Истекает: $expiresDate',
                        style: TextStyle(
                          color: isExpired ? Colors.red : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Описание (если есть)
            if (description != null && description.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const Divider(height: 24),
            // Детали операции
            _DetailRow(
              label: 'ID транзакции:',
              value: operation.transactionId ?? 'Отсутствует',
            ),
            _DetailRow(
              label: 'Кол-во документов:',
              value: '${operation.documentCount} шт.',
            ),
            _DetailRow(
              label: 'Тип операции:',
              value: operation.description.type,
            ),
            _DetailRow(
              label: 'Подпись на устройстве:',
              value: operation.isClientSide ? 'Да (смарт-карта/токен)' : 'Нет (облачная)',
            ),
            const SizedBox(height: 16),
            // Кнопка действия
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  context.read<OperationsBloc>().add(
                    OpenOperation(operation: operation),
                  );
                },
                child: const Text(
                  'Открыть(SignMt)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
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