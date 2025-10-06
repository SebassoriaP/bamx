import 'package:flutter/material.dart';

void showErrorMessage(BuildContext context, String message, {Color color = Colors.redAccent, int seconds = 3}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize: 16),
      ),
      backgroundColor: color,
      duration: Duration(seconds: seconds),
    ),
  );
}



