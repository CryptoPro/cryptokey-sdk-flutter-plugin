import 'package:flutter/material.dart';

extension DialogExtension on BuildContext {
  void showErrorDialog(String errorMessage) {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('Произошла ошибка'),
            ],
          ),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                // Закрываем диалог
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
