import 'package:flutter/material.dart';
import 'package:Flutter_Image_Browser/src/rust/api/check_version.dart' as api;

void checkUpdate(BuildContext context) async {
  final currentVersion = "1.0.4";
  final result = await api.checkUpdate(currentVersion: currentVersion);

  if (result != null) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("发现新版本 ${result.version}"),
            content: Text(result.changelog),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("忽略"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  downloadAndInstall(context, result);
                },
                child: Text("立即更新"),
              ),
            ],
          ),
    );
  } else {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("已是最新版本")));
  }
}

void downloadAndInstall(BuildContext context, api.UpdateInfo updateInfo) async {
  final success = await api.downloadAndInstall(updateInfo: updateInfo);

  if (success) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("更新下载完成，正在启动安装程序")));
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("更新失败")));
  }
}
