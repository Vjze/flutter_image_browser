import 'dart:async';
import 'dart:io';
import 'package:Flutter_Image_Browser/main.dart';
import 'package:path/path.dart' as p;
import 'package:Flutter_Image_Browser/src/rust/api/check_version.dart';
import 'package:flutter/material.dart';

class DownloadProgressDialog extends StatefulWidget {
  final UpdateInfo updateInfo;
  final VoidCallback onInstall;

  const DownloadProgressDialog({
    super.key,
    required this.updateInfo,
    required this.onInstall,
  });

  @override
  State<DownloadProgressDialog> createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<DownloadProgressDialog> {
  double progress = 0.0;
  String speed = '0 KB/s';
  bool _isDownloading = false; // 控制進度彈窗顯示
  bool _hasError = false; // 控制錯誤狀態
  StreamSubscription<void>? _progressSubscription;
  @override
  void initState() {
    super.initState();
    // 延遲執行 _startDownload，直到 initState 完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startDownload();
    });
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    super.dispose();
  }

  void _startDownload() async {
    final filePath = await _getDownloadPath(widget.updateInfo.fileName);

    setState(() {
      _isDownloading = true;
      _hasError = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => PopScope(
            canPop: false,
            child: AlertDialog(
              title: const Text('下载更新中'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isDownloading) LinearProgressIndicator(value: progress),
                  Text('$speed (${(progress * 100).toStringAsFixed(1)}%)'),
                ],
              ),
            ),
          ),
    );

    _progressSubscription = downloadUpdate(
      url: widget.updateInfo.downloadUrl,
      destPath: filePath,
    ).listen(
      (event) {
        print("收到事件: $event");
        if (event is DownloadEvent_Progress) {
          print("監聽到進度事件");
          final progressData = event.field0;
          setState(() {
            progress = progressData.progress;
            speed = '${progressData.speed.toStringAsFixed(2)} KB/s';
          });
        } else if (event is DownloadEvent_Error) {
          print("監聽到錯誤事件");
          final errorMessage = event.field0;
          print("errorMessage = $errorMessage");

          setState(() {
            _isDownloading = false;
            _hasError = true;
          });

          Navigator.of(context).pop();

          Future.microtask(() {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('下載失敗'),
                    content: Text('下載失敗: $errorMessage'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          print("點擊確定，關閉錯誤彈窗");
                          Navigator.of(context).pop();
                          if (Navigator.of(context).canPop()) {
                            print("關閉父層彈窗");
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('確定'),
                      ),
                    ],
                  ),
            );
          });
        }
      },
      onDone: () {
        if (progress >= 1.0 && mounted && !_hasError) {
          Navigator.of(context).pop();
          downloadpath = filePath;
          Future.microtask(() {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('下载完成'),
                    content: Text('软件已下载完成，位置是:$filePath /n点击确定开始安装'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          widget.onInstall();
                          Navigator.of(context).pop();
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('確定'),
                      ),
                    ],
                  ),
            );
          });

          Navigator.of(context).pop();
        }
      },
      onError: (e) {
        setState(() {
          _isDownloading = false;
          _hasError = true;
        });
        Navigator.of(context).pop();
        Future.microtask(() {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('下載失敗'),
                  content: Text('下載失敗: $e'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('確定'),
                    ),
                  ],
                ),
          );
        });
      },
    );
  }

  Future<String> _getDownloadPath(String fileName) async {
    final dir = Directory.current; // 當前工作目錄
    return p.join(dir.path, fileName);
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // 將彈窗邏輯移到 _startDownload 中，這裡不顯示
  }
}
