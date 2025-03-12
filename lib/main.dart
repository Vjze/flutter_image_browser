import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_browser/image_view.dart';
import 'package:image_browser/img_list.dart';
import 'package:image_browser/src/rust/frb_generated.dart';
import 'package:image_browser/story.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  // 初始化 FRB
  await RustLib.init();
  // 初始化 window_manager
  WidgetsFlutterBinding.ensureInitialized();
  await WindowManager.instance.ensureInitialized();

  // 设置窗口属性
  const windowOptions = WindowOptions(
    title: 'Image Browser',
    size: Size(1600, 900),
    center: true,
  );

  await WindowManager.instance.waitUntilReadyToShow(windowOptions, () async {
    await WindowManager.instance.show();
    await WindowManager.instance.focus();
  });
  Get.put(StoryState());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final story = Get.find<StoryState>();
    return MaterialApp(
      title: 'Image Browser',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Obx(
        () => Scaffold(
          body:
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
      ),
    );
  }
}
