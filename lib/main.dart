import 'dart:async';
import 'dart:io';

import 'package:Flutter_Image_Browser/dialog.dart';
import 'package:Flutter_Image_Browser/download_dialog.dart';
import 'package:Flutter_Image_Browser/src/rust/api/check_version.dart';
import 'package:Flutter_Image_Browser/updata_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Flutter_Image_Browser/src/rust/api/simple.dart' as rust_api;
import 'package:Flutter_Image_Browser/src/rust/frb_generated.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}

late final downloadpath;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Browser',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ImageBrowser(),
    );
  }
}

class ImageBrowser extends StatelessWidget {
  const ImageBrowser({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Browser',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ImageBrowserPage(),
    );
  }
}

class ImageBrowserPage extends StatefulWidget {
  const ImageBrowserPage({super.key});

  @override
  State<ImageBrowserPage> createState() => _ImageBrowserPageState();
}

class _ImageBrowserPageState extends State<ImageBrowserPage> {
  List<rust_api.ImageInfo> infos = [];
  int currentIndex = 0;
  final FocusNode _focusNode = FocusNode();
  bool isScanning = false;
  bool isLoading = false;
  int totalImages = 0;
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
          context: context,
          builder:
              (_) => UpdateDialog(
                updateInfo: updateInfo,
                onDownload: () => _showDownloadDialog(updateInfo),
              ),
        );
      }
    } catch (e) {
      showAlertDialog(context, "版本检测失败，请检查网络.");
    }
  }

  void _showDownloadDialog(UpdateInfo updateInfo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => DownloadProgressDialog(
            updateInfo: updateInfo,
            onInstall: () => installUpdate(filePath: downloadpath),
          ),
    );
  }

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  BuildContext get globalContext => navigatorKey.currentState!.overlay!.context;
  Future<void> _pickFolder() async {
    try {
      String? folderPath = rust_api.getPath();
      if (folderPath.isNotEmpty && folderPath.isNotEmpty) {
        // 扫描阶段
        setState(() {
          infos.clear();
          currentIndex = 0;
          isScanning = true;
          isLoading = false;
        });

        totalImages = await rust_api.scanImages(p: folderPath);

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
                setState(() {
                  infos.add(image);
                });
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
                showAlertDialog(context, "加载图片失败");
              },
            );
      }
    } catch (e) {
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
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    } else if (currentIndex == 0) {
      setState(() {
        currentIndex = infos.length - 1;
      });
    }
  }

  void _nextImage() {
    if (currentIndex < infos.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else if (currentIndex == infos.length - 1) {
      setState(() {
        currentIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Focus(
        // 确保焦点停留在整个页面，而不是按钮上
        focusNode: _focusNode,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _previousImage();
              return KeyEventResult.handled; // 表示已处理
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
          return KeyEventResult.ignored; // 未处理的事件交给其他控件
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
                      infos.isEmpty
                          ? const Text('请选择文件夹加载图片')
                          : Image.file(
                            File(infos[currentIndex].path),
                            fit: BoxFit.contain,
                          ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[200],
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
                            print("进度: ${snapshot.data}");
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
                  if (totalImages > 0 || infos.isNotEmpty)
                    Text(
                      '文件名: ${infos.isEmpty ? "未加载" : infos[currentIndex].name} | '
                      '分辨率: ${infos.isEmpty ? "未加载" : "${infos[currentIndex].width}x${infos[currentIndex].height}"} | '
                      '当前: ${infos.isEmpty ? 0 : currentIndex + 1}/$totalImages',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
