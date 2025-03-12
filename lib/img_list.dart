import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_browser/src/rust/api/simple.dart' as rust_api;
import 'package:image_browser/story.dart';

class ImgList extends ConsumerStatefulWidget {
  const ImgList({super.key});

  @override
  ConsumerState<ImgList> createState() => _ImgListState();
}

class _ImgListState extends ConsumerState<ImgList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0)),
      ),

      child: ListView.builder(
        itemCount: ref.read(storyProvider).infos.length,
        itemBuilder: (context, index) {
          return _listItems(ref.read(storyProvider).infos[index], index);
        },
      ),
    );
  }

  Widget _listItems(rust_api.ImageInfo info, int index) {
    return InkWell(
      onTap: () => {ref.read(storyProvider.notifier).setCurrentIndex(index)},
      child: Container(
        margin: EdgeInsets.all(5.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.greenAccent[100],
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.file(
              File(info.path),
              width: 48,
              height: 48,
              fit: BoxFit.fill,
            ),
            SizedBox(
              width: 200 - 48,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end, // 整体右对齐
                children: [
                  Text(
                    textAlign: TextAlign.right,
                    info.name,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    softWrap: false,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${info.width}x${info.height}",
                    style: TextStyle(fontSize: 15),
                    textAlign: TextAlign.right,
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
