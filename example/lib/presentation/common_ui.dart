import 'package:flutter/material.dart';

extension DialogExtension on BuildContext {
  void showInfoDialog(
      String message, {
        VoidCallback? onConfirm,
      }) {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline),
              SizedBox(width: 8),
              Text('Инофрмация'),
            ],
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (onConfirm != null) {
                  onConfirm();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
