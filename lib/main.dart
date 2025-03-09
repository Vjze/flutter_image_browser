import 'dart:async';
import 'dart:io';

import 'package:Flutter_Image_Browser/dialog.dart';
import 'package:Flutter_Image_Browser/download_dialog.dart';
import 'package:Flutter_Image_Browser/image_view.dart';
import 'package:Flutter_Image_Browser/src/rust/api/check_version.dart';
import 'package:Flutter_Image_Browser/updata_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Flutter_Image_Browser/src/rust/api/simple.dart' as rust_api;
import 'package:Flutter_Image_Browser/src/rust/frb_generated.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}

late final fileName;

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


