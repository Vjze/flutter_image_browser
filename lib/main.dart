import 'dart:async';
import 'package:Flutter_Image_Browser/image_view.dart';
import 'package:Flutter_Image_Browser/img_list.dart';
import 'package:Flutter_Image_Browser/story.dart';
import 'package:flutter/material.dart';
import 'package:Flutter_Image_Browser/src/rust/frb_generated.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(
    ChangeNotifierProvider(create: (context) => StoryModel(), child: MyApp()),
  );
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
      home: Scaffold(
        body: Consumer<StoryModel>(
          builder: (context, story, child) {
            return story.listView
                ? ImageBrowserPage()
                : Container(
                  margin: EdgeInsets.only(top: 10, right: 5),
                  child: Row(
                    children: [
                      Expanded(flex: 8, child: ImageBrowserPage()),
                      Expanded(flex: 2, child: ImgList()),
                    ],
                  ),
                );
          },
        ),
      ),
    );
  }
}
