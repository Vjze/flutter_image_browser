import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_browser/dialog.dart';
import 'package:image_browser/src/rust/api/simple.dart' as rust_api;
import 'package:image_browser/story.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_browser/update/updateWork.dart';

class MobileImageView extends StatefulWidget {
  const MobileImageView({super.key});

  @override
  State<MobileImageView> createState() => _MobileImageViewState();
}

class _MobileImageViewState extends State<MobileImageView> {
  bool isScanning = false;
  bool isLoading = false;
  final story = Get.find<StoryState>();
  StreamSubscription<rust_api.ImageInfo>? _subscription;
  Timer? _progressTimer;
  late PageController _pageController; // 添加 PageController
  double _scale = 1.0;
  @override
  void initState() {
    requestPermissions();
    UpdateWorker.checkForUpdate(context);
    _pageController = PageController(
      initialPage: story.currentIndex.value,
    ); // 初始化 PageController
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _progressTimer?.cancel();
    _pageController.dispose(); // 释放 PageController
    super.dispose();
  }

  // 双击放大功能
  void _onDoubleTap() {
    setState(() {
      _scale = _scale == 1.0 ? 2.0 : 1.0; // 双击切换缩放
    });
  }

  Future<void> requestPermissions() async {
    List<Permission> permissions = [];
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        permissions.add(Permission.photos);
      } else {
        permissions.add(Permission.storage);
      }
    } else if (Platform.isIOS) {
      permissions.add(Permission.photos);
    }

    for (var permission in permissions) {
      PermissionStatus status = await permission.status;

      if (status.isDenied) {
        Map<Permission, PermissionStatus> newStatuses =
            await permissions.request();

        if (newStatuses[permission]!.isGranted) {
          continue;
        } else if (newStatuses[permission]!.isPermanentlyDenied) {
          // 显示弹窗提示
          showAlertDialog(
            context,
            "权限被永久拒绝",
            "请在系统设置中手动启用${permission.toString()}权限",
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await openAppSettings();
                },
                child: const Text("去设置"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("取消"),
              ),
            ],
          );
          break;
        } else {
          // 显示弹窗提示
          showAlertDialog(
            context,
            "权限被拒绝",
            "${permission.toString()}权限被拒绝，无法正常使用图片浏览功能",
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("确定"),
              ),
            ],
          );
          break;
        }
      } else if (status.isPermanentlyDenied) {
        // 显示弹窗提示
        showAlertDialog(
          context,
          "权限被永久拒绝",
          "请在系统设置中手动启用${permission.toString()}权限",
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings();
              },
              child: const Text("去设置"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("取消"),
            ),
          ],
        );
        break;
      } else if (!status.isGranted) {}
    }
  }

  Future<void> _pickFolder() async {
    bool hasPermission =
        Platform.isAndroid
            ? (await Permission.storage.status).isGranted ||
                (await Permission.photos.status).isGranted
            : (await Permission.photos.status).isGranted;

    if (!hasPermission) {
      await requestPermissions();
      hasPermission =
          Platform.isAndroid
              ? (await Permission.storage.status).isGranted ||
                  (await Permission.photos.status).isGranted
              : (await Permission.photos.status).isGranted;
    }

    if (hasPermission) {
      try {
        String? folderPath = await FilePicker.platform.getDirectoryPath();
        if (folderPath != null) {
          setState(() {
            story.infos.clear();
            story.currentIndex.value = 0;
            isScanning = true;
            isLoading = false;
          });

          final totalImages = await rust_api.scanImages(p: folderPath);
          story.totalImages.value = totalImages;
          setState(() {
            isScanning = false;
            isLoading = true;
          });

          _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (
            timer,
          ) {
            setState(() {});
          });
          _subscription = rust_api
              .listImages(p: folderPath, l: totalImages)
              .listen(
                (image) {
                  story.infos.add(image);
                },
                onDone: () {
                  _progressTimer?.cancel();
                  setState(() {
                    isLoading = false;
                  });
                },
                onError: (e) {
                  _progressTimer?.cancel();
                  setState(() {
                    isLoading = false;
                  });
                  showErrtDialog(context, "加载图片失败: $e");
                },
              );
        }
      } catch (e) {
        showErrtDialog(context, "获取文件夹路径失败：$e");
      }
    } else {
      showErrtDialog(context, "需要存储权限才能选择文件夹");
    }
  }

  void _stopScan() {
    rust_api.stopScan();
    _subscription?.cancel();
    _progressTimer?.cancel();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title:
              story.infos.isNotEmpty
                  ? Text(story.infos[story.currentIndex.value].name)
                  : Text("图片浏览器"),
          actions: [
            IconButton(
              icon: const Icon(Icons.folder_open),
              onPressed: isScanning || isLoading ? _stopScan : _pickFolder,
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onDoubleTap: _onDoubleTap, // 双击放大
                child:
                    story.infos.isEmpty
                        ? const Text('请选择文件夹加载图片')
                        : PageView.builder(
                          controller: _pageController,
                          itemCount: story.infos.length,
                          onPageChanged: (index) {
                            story.currentIndex.value = index; // 更新当前索引
                          },
                          itemBuilder: (context, index) {
                            return InteractiveViewer(
                              panEnabled: true,
                              boundaryMargin: const EdgeInsets.all(10),
                              minScale: 0.5,
                              maxScale: 10.0,
                              child: Transform.scale(
                                scale: _scale, // 控制缩放
                                child: Image.file(
                                  File(story.infos[index].path),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 8,
                left: 12,
                right: 12,
              ),
              decoration: BoxDecoration(color: Colors.grey[300]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 扫描或加载时显示进度，否则显示分辨率
                  if (isScanning || isLoading)
                    FutureBuilder<double>(
                      future: rust_api.getScanProgress(),
                      builder: (context, snapshot) {
                        final progress = snapshot.data ?? 0.0;
                        return Row(
                          children: [
                            Text(
                              isScanning
                                  ? "扫描中: ${progress.toStringAsFixed(1)}%"
                                  : "读取中: ${progress.toStringAsFixed(1)}%",
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 100,
                              child: LinearProgressIndicator(
                                value: progress / 100,
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  else if (story.infos.isNotEmpty)
                    Text(
                      '分辨率: ${story.infos[story.currentIndex.value].width}x${story.infos[story.currentIndex.value].height}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    )
                  else
                    const SizedBox.shrink(), // 占位，避免布局跳动
                  // 右侧显示当前张数
                  if (!isScanning && !isLoading && story.infos.isNotEmpty)
                    Text(
                      '当前: ${story.currentIndex.value + 1}/${story.totalImages.value}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    )
                  else
                    const SizedBox.shrink(), // 占位，避免布局跳动
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
