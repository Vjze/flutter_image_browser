import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_browser/dialog.dart';
import 'package:image_browser/download_dialog.dart';
import 'package:image_browser/src/rust/api/check_version.dart';
import 'package:image_browser/src/rust/api/simple.dart' as rust_api;
import 'package:image_browser/story.dart';
import 'package:image_browser/updata_dialog.dart';

class ImageBrowserPage extends ConsumerStatefulWidget {
  const ImageBrowserPage({super.key});

  @override
  ConsumerState<ImageBrowserPage> createState() => _ImageBrowserPageState();
}

class _ImageBrowserPageState extends ConsumerState<ImageBrowserPage> {
  final FocusNode _focusNode = FocusNode();
  bool isScanning = false;
  bool isLoading = false;

  StreamSubscription<rust_api.ImageInfo>? _subscription;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _checkForUpdate();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _subscription?.cancel();
    _progressTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkForUpdate() async {
    try {
      final updateInfo = await checkUpdate();
      if (updateInfo != null) {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder:
              (_) => UpdateDialog(
                updateInfo: updateInfo,
                onDownload: () => _showDownloadDialog(updateInfo),
              ),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showAlertDialog(context, "版本检测失败，请检查网络.");
    }
  }

  void _showDownloadDialog(UpdateInfo updateInfo) {
    final storyState = ref.read(storyProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => DownloadProgressDialog(
            updateInfo: updateInfo,
            onInstall: () => installUpdate(fileName: storyState.fileName),
          ),
    );
  }

  Future<void> _pickFolder() async {
    try {
      String? folderPath = rust_api.getPath();
      if (folderPath.isNotEmpty) {
        // 扫描阶段
        setState(() {
          ref.read(storyProvider.notifier).clearInfos();
          ref.read(storyProvider.notifier).setCurrentIndex(0);
          isScanning = true;
          isLoading = false;
        });

        final totalImages = await rust_api.scanImages(p: folderPath);
        ref.read(storyProvider.notifier).setTotalImages(totalImages);
        setState(() {
          isScanning = false;
          isLoading = true;
        });

        // 加载阶段
        _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (
          timer,
        ) {
          setState(() {});
        });
        _subscription = rust_api
            .listImages(p: folderPath, l: totalImages)
            .listen(
              (image) {
                ref.read(storyProvider.notifier).addImage(image);
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
                // ignore: use_build_context_synchronously
                showAlertDialog(context, "加载图片失败");
              },
            );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showAlertDialog(context, "获取文件夹路径失败");
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

  void _previousImage() {
    final storyState = ref.read(storyProvider);
    if (storyState.currentIndex > 0) {
      ref
          .read(storyProvider.notifier)
          .setCurrentIndex(storyState.currentIndex - 1);
    } else if (storyState.currentIndex == 0) {
      ref
          .read(storyProvider.notifier)
          .setCurrentIndex(storyState.infos.length - 1);
    }
  }

  void _nextImage() {
    final storyState = ref.read(storyProvider);
    if (storyState.currentIndex < storyState.infos.length - 1) {
      ref
          .read(storyProvider.notifier)
          .setCurrentIndex(storyState.currentIndex + 1);
    } else if (storyState.currentIndex == storyState.infos.length - 1) {
      ref.read(storyProvider.notifier).setCurrentIndex(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final storyState = ref.watch(storyProvider);
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _previousImage();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _nextImage();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            _nextImage();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            _previousImage();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 10.0,
              child: Center(
                child:
                    storyState.infos.isEmpty
                        ? const Text('请选择文件夹加载图片')
                        : Image.file(
                          File(storyState.infos[storyState.currentIndex].path),
                          fit: BoxFit.contain,
                        ),
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
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.only(topLeft: Radius.circular(18)),
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _pickFolder,
                      child: const Text('选择文件夹'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _previousImage,
                      child: const Text('上一张'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _nextImage,
                      child: const Text('下一张'),
                    ),
                    const SizedBox(width: 8),
                    if (isScanning) const Text("扫描中..."),
                    if (isLoading)
                      FutureBuilder<double>(
                        future: rust_api.getScanProgress(),
                        builder: (context, snapshot) {
                          final progress = snapshot.data ?? 0.0;
                          return Row(
                            children: [
                              Text("读取中: ${progress.toStringAsFixed(1)}%"),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 100,
                                child: LinearProgressIndicator(
                                  value: progress / 100,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _stopScan,
                                child: const Text("停止扫描"),
                              ),
                            ],
                          );
                        },
                      ),
                  ],
                ),
                if (storyState.totalImages > 0 || storyState.infos.isNotEmpty)
                  Row(
                    children: [
                      Text(
                        '文件名: ${storyState.infos.isEmpty ? "未加载" : storyState.infos[storyState.currentIndex].name} | '
                        '分辨率: ${storyState.infos.isEmpty ? "未加载" : "${storyState.infos[storyState.currentIndex].width}x${storyState.infos[storyState.currentIndex].height}"} | '
                        '当前: ${storyState.infos.isEmpty ? 0 : storyState.currentIndex + 1}/${storyState.totalImages}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      IconButton(
                        onPressed: () {
                          ref
                              .read(storyProvider.notifier)
                              .setListView(!storyState.listView);
                        },
                        icon: Icon(
                          storyState.listView
                              ? Icons.arrow_circle_left
                              : Icons.arrow_circle_right,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
