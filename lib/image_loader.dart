import 'dart:io';
import 'package:Flutter_Image_Browser/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/rust/api/simple.dart' as rust_api;

class ImageBrowser extends StatefulWidget {
  const ImageBrowser({super.key});

  @override
  State<ImageBrowser> createState() => _ImageBrowserState();
}

class _ImageBrowserState extends State<ImageBrowser> {
  // List<String> paths = [];
  // rust_api.ImageInfo? image;
  List<rust_api.ImageInfo> infos = [];
  int currentIndex = 0;
  final FocusNode _focusNode = FocusNode();

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
    super.dispose();
  }

  // 选择文件夹并加载图片
  Future<void> _pickFolder() async {
    // String? folderPath = rust_api.getPath();
    // final res = rust_api.getPath();
    try {
      String? folderPath = rust_api.getPath();
      // rust_api.getPath();
      if (folderPath.isNotEmpty) {
        setState(() {
          infos.clear();
          currentIndex = 0;
        });
        try {
          final loadinfos = await rust_api.listImages(p: folderPath);
          setState(() {
            infos = loadinfos;
          });
        } catch (e) {
          showAlertDialog(context, "加载图片失败");
        }
      }
    } catch (e) {
      showAlertDialog(context, "获取文件夹路径失败");
    }
  }

  // 上一张
  void _previousImage() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  // 下一张
  void _nextImage() {
    if (currentIndex < infos.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardListener(
        focusNode: _focusNode, // 确保监听键盘事件
        onKeyEvent:
            (event) => {
              if (event is KeyDownEvent)
                {
                  if (event.logicalKey == LogicalKeyboardKey.arrowLeft)
                    {_previousImage()}
                  else if (event.logicalKey == LogicalKeyboardKey.arrowRight)
                    {_nextImage()}
                  else if (event.logicalKey == LogicalKeyboardKey.arrowDown)
                    {_nextImage()}
                  else if (event.logicalKey == LogicalKeyboardKey.arrowUp)
                    {_previousImage()},
                },
            }, // 监听键盘事件
        child: Column(
          children: [
            Expanded(
              // child: KeyboardListener(
              child: InteractiveViewer(
                panEnabled: true, // 启用拖动
                boundaryMargin: EdgeInsets.all(20),
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
