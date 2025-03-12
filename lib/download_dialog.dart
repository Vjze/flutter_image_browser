import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_browser/src/rust/api/check_version.dart';
import 'package:image_browser/story.dart';

class DownloadProgressDialog extends ConsumerStatefulWidget {
  final UpdateInfo updateInfo;
  final VoidCallback onInstall;

  const DownloadProgressDialog({
    super.key,
    required this.updateInfo,
    required this.onInstall,
  });

  @override
  ConsumerState<DownloadProgressDialog> createState() =>
      _DownloadProgressDialogState();
}

class _DownloadProgressDialogState
    extends ConsumerState<DownloadProgressDialog> {
  double progress = 0.0;
  String speed = '0 KB/s';
  bool _isDownloading = false; // 控制進度彈窗顯示
  bool _hasError = false; // 控制錯誤狀態
  StreamSubscription<void>? _progressSubscription;
  @override
  void initState() {
    super.initState();
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
      fileName: ref.read(storyProvider).fileName,
    ).listen(
      (event) {
        if (event is DownloadEvent_Progress) {
          final progressData = event.field0;
          setState(() {
            progress = progressData.progress;
            speed = '${progressData.speed.toStringAsFixed(2)} KB/s';
          });
        } else if (event is DownloadEvent_Error) {
          final errorMessage = event.field0;

          setState(() {
            _isDownloading = false;
            _hasError = true;
          });
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();

          Future.microtask(() {
            showDialog(
              barrierDismissible: false,
              // ignore: use_build_context_synchronously
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('下載失敗'),
                    content: Text('下載失敗: $errorMessage'),
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
        }
      },
      onDone: () {
        if (progress >= 1.0 && mounted && !_hasError) {
          Navigator.of(context).pop();
          Future.microtask(() {
            showDialog(
              barrierDismissible: false,
              // ignore: use_build_context_synchronously
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('下载完成'),
                    content: Text('软件已下载完成，点击确定开始安装'),
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
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        Future.microtask(() {
          showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            barrierDismissible: false,
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

  @override
  Widget build(BuildContext context) {
    return Container(); // 將彈窗邏輯移到 _startDownload 中，這裡不顯示
  }
}
