import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_browser/dialog.dart';
import 'package:image_browser/main.dart';
import 'package:image_browser/src/rust/api/check_version.dart';
import 'package:image_browser/story.dart';
import 'package:image_browser/update/download_dialog.dart';
import 'package:image_browser/update/updata_dialog.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class Getdowmloadpath {
  static Future<String> getPath() async {
    final story = Get.find<StoryState>();
    final fileName = story.fileName.value;
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final androidInfo = await deviceInfoPlugin.androidInfo;
    if (androidInfo.version.sdkInt >= 29) {
      final dir = await getExternalStorageDirectory();
      final apkPath = '${dir!.path}/${fileName.trim()}'; // trim() 去除文件名两端的空格

      return apkPath;
    } else {
      var dir = Directory('/storage/emulated/0/Download');
      final apkPath = '${dir.path}/${fileName.trim()}'; // trim() 去除文件名两端的空格

      return apkPath;
    }
  }
}

class UpdateWorker {
  static Future<void> checkForUpdate(BuildContext context) async {
    final story = Get.find<StoryState>();
    try {
      final updateInfo = await checkUpdate();
      if (updateInfo != null) {
        story.fileName.value = updateInfo.fileName;
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder:
              (_) => UpdateDialog(
                updateInfo: updateInfo,
                onDownload:
                    () =>
                        isDesktopPlatform()
                            ? _showDownloadDialog(updateInfo, context)
                            : _showApkDownloadDialog(updateInfo, context),
              ),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showErrtDialog(context, "版本检测失败，请检查网络.");
    }
  }

  static void _showApkDownloadDialog(
    UpdateInfo updateInfo,
    BuildContext context,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => DownloadProgressDialog(
            updateInfo: updateInfo,
            onInstall:
                () => {
                  if (Platform.isAndroid)
                    {installApk(context)}
                  else
                    {showErrtDialog(context, "ios端暂时无法实现")},
                },
          ),
    );
  }

  static Future<void> installApk(BuildContext context) async {
    String? filePath = await Getdowmloadpath.getPath();
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        throw Exception("Failed to open APK: ${result.message}");
      }
    } catch (e) {
      print("安装失败: $e");
      rethrow;
    }
  }
  // if (filePath.isEmpty) {
  //   showErrtDialog(context, "下载路径无效，无法安装 APK.");
  //   return;
  // }
  // print("filePath: " + filePath);

  // final intent = AndroidIntent(
  //   action: 'android.intent.action.VIEW',
  //   data: Uri.parse('file://$filePath').toString(), // 修正 URI 格式
  //   type: 'application/vnd.android.package-archive',
  //   flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
  // );
  // await intent.launch();
  // }

  static void _showDownloadDialog(UpdateInfo updateInfo, BuildContext context) {
    final story = Get.find<StoryState>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => DownloadProgressDialog(
            updateInfo: updateInfo,
            onInstall: () => {installUpdate(fileName: story.fileName.value)},
          ),
    );
  }
}
