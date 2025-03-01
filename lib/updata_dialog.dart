import 'package:Flutter_Image_Browser/src/rust/api/check_version.dart';
import 'package:flutter/material.dart';

class UpdateDialog extends StatelessWidget {
  final UpdateInfo updateInfo;
  final VoidCallback onDownload;

  const UpdateDialog({
    super.key,
    required this.updateInfo,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: SizedBox(
        height: 30,
        child: Center(child: Text('发现新版本 ${updateInfo.version}')),
      ),
      content: SizedBox(height: 100, child: Text(updateInfo.changelog)),
      actions: [
        Text("发布日期:${updateInfo.date}"),
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDownload();
          },
          child: const Text('下载更新'),
        ),
      ],
    );
  }
}
