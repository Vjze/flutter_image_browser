import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final story = ref.watch(storyProvider);
    return MaterialApp(
      title: 'Image Browser',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body:
            story.listView
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
