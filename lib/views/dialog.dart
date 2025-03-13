import 'package:flutter/material.dart';

void showErrDialog(context, String message) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text("提示"),
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

void showAlertDialog(
  BuildContext context,
  String title,
  String message, {
  List<Widget>? actions,
}) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions:
              actions ??
              [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("确定"),
                ),
              ],
        ),
  );
}
