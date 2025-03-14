import 'dart:io';
import 'package:app_installer/app_installer.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_browser/views/dialog.dart';
import 'package:image_browser/main.dart';
import 'package:image_browser/src/rust/api/check_version.dart';
import 'package:image_browser/story.dart';
import 'package:image_browser/update/download_dialog.dart';
import 'package:image_browser/update/updata_dialog.dart';
import 'package:path_provider/path_provider.dart';

class UpdateWorker {
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
    String? filePath = await getPath();
    try {
      await AppInstaller.installApk(filePath);
    } catch (e) {
      // ignore: use_build_context_synchronously
      showErrtDialog(context, "安装apk失败.$e");
    }
  }

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
