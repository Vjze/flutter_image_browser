import 'package:flutter/material.dart';

Future<void> showAlertDialog(BuildContext context, String errText) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // 设置为false，点击背景不会关闭
    builder: (BuildContext context) {
      return AlertDialog(
        title: SizedBox(height: 35, child: Center(child: const Text(' 错误 '))),
        content: SizedBox(height: 60, child: Center(child: Text(errText))),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('确定'),
          ),
        ],
      );
    },
  );
}
