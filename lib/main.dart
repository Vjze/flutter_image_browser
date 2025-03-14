import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_browser/image_view.dart';
import 'package:image_browser/img_list.dart';
import 'package:image_browser/mobile_image_view.dart';
import 'package:image_browser/src/rust/frb_generated.dart';
import 'package:image_browser/story.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  // 初始化 FRB
  await RustLib.init();
  // 初始化 window_manager
  WidgetsFlutterBinding.ensureInitialized();
  // 如果是桌面端，初始化窗口管理
  if (isDesktopPlatform()) {
    await windowManager.ensureInitialized();
    await setWindowSizeForDesktop();
  }
  Get.put(StoryState());
  runApp(MyApp());
}

// 判断是否为桌面平台
bool isDesktopPlatform() {
  if (kIsWeb) return false; // Web 通常视为非桌面
  return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
}

// 设置桌面端窗口大小
Future<void> setWindowSizeForDesktop() async {
  Size windowSize;

  if (Platform.isMacOS) {
    windowSize = Size(1600, 900); // macOS 默认窗口大小
  } else if (Platform.isWindows) {
    windowSize = Size(1600, 900); // Windows 默认窗口大小
  } else {
    windowSize = Size(1600, 900); // Linux 默认窗口大小
  }
  await windowManager.setTitle('Image Browser');
  await windowManager.setSize(windowSize);
  await windowManager.center(); // 将窗口居中显示
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Browser',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: isDesktopPlatform() ? DesktopHome() : MobileHome(),
    );
  }
}

// 桌面端布局
class DesktopHome extends StatelessWidget {
  const DesktopHome({super.key});

  @override
  Widget build(BuildContext context) {
    final story = Get.find<StoryState>();
    return Scaffold(
      body: Obx(
        () =>
            story.listView.value
                ? Container(
                  margin: EdgeInsets.only(right: 5),
                  child: Row(
                    children: [
                      Expanded(flex: 8, child: ImageBrowserPage()),
                      Expanded(flex: 2, child: ImgList()),
                    ],
                  ),
                )
                : ImageBrowserPage(),
      ),
    );
  }
}

// 移动端布局
class MobileHome extends StatelessWidget {
  const MobileHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: MobileImageView());
  }
}
