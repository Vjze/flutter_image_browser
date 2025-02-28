import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Flutter_Image_Browser/src/rust/api/simple.dart' as rust_api;

void main() {
  runApp(const ImageBrowser());
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
    _progressTimer?.cancel();
    super.dispose();
  }

  Future<void> _pickFolder() async {
    try {
      String? folderPath = await rust_api.getPath();
      if (folderPath.isNotEmpty && folderPath.isNotEmpty) {
        setState(() {
          infos.clear();
          currentIndex = 0;
          isScanning = true;
        });

        // 启动进度刷新
        _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (
          timer,
        ) {
          setState(() {}); // 定期刷新 UI
        });

        try {
          final loadedInfos = await rust_api.listImages(p: folderPath);
          _progressTimer?.cancel();
          setState(() {
            infos = loadedInfos;
            isScanning = false;
          });
        } catch (e) {
          _progressTimer?.cancel();
          setState(() {
            isScanning = false;
          });
          _showAlertDialog("加载图片失败");
        }
      }
    } catch (e) {
      _showAlertDialog("获取文件夹路径失败");
    }
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
    if (isScanning) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text("正在扫描图片...", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              FutureBuilder(
                future: rust_api.getScanProgress(),
                builder: (context, snapshot) {
                  final progress = snapshot.data ?? 0.0;
                  return Column(
                    children: [
                      Text("${progress.toStringAsFixed(1)}%"),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 200,
                        child: LinearProgressIndicator(value: progress / 100),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _previousImage();
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              _nextImage();
            } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              _nextImage();
            } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              _previousImage();
            }
          }
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
                    ],
                  ),
                  if (infos.isNotEmpty)
                    Text(
                      '文件名: ${infos[currentIndex].name} | '
                      '分辨率: ${infos[currentIndex].width}x${infos[currentIndex].height} | '
                      '当前: ${currentIndex + 1}/${infos.length}',
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
