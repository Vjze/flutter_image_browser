import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Flutter_Image_Browser/src/rust/api/simple.dart' as rust_api;
import 'package:Flutter_Image_Browser/src/rust/frb_generated.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}

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
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _subscription?.cancel();
    _progressTimer?.cancel();
    super.dispose();
  }

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
        print("扫描完成，总数: $totalImages");

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
                print("收到图片: ${image.path}");
                setState(() {
                  infos.add(image);
                });
              },
              onDone: () {
                print("加载完成，总数: ${infos.length}");
                _progressTimer?.cancel();
                setState(() {
                  isLoading = false;
                });
              },
              onError: (e) {
                print("加载错误: $e");
                _progressTimer?.cancel();
                setState(() {
                  isLoading = false;
                });
                _showAlertDialog("加载图片失败: $e");
              },
            );
      }
    } catch (e) {
      _showAlertDialog("获取文件夹路径失败: $e");
    }
  }

  void _stopScan() {
    print("停止扫描触发");
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
    }
  }

  void _nextImage() {
    if (currentIndex < infos.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  void _showAlertDialog(String message) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: KeyboardListener(
              focusNode: _focusNode,
              onKeyEvent: (event) {
                if (event is KeyDownEvent) {
                  if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                    _previousImage();
                  } else if (event.logicalKey ==
                      LogicalKeyboardKey.arrowRight) {
                    _nextImage();
                  } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                    _nextImage();
                  } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                    _previousImage();
                  }
                }
              },
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
    );
  }
}
