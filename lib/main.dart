import 'package:Flutter_Image_Browser/image_loader.dart';
import 'package:Flutter_Image_Browser/src/rust/frb_generated.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(MyApp());
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
