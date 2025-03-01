import 'package:flutter/material.dart';

void showAlertDialog(context, String message) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text("错误"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("确定"),
            ),
          ],
        ),
  );
}
