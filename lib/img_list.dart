import 'dart:io';
import 'package:Flutter_Image_Browser/story.dart';
import 'package:flutter/material.dart';
import 'package:Flutter_Image_Browser/src/rust/api/simple.dart' as rust_api;
import 'package:provider/provider.dart';

class ImgList extends StatefulWidget {
  const ImgList({super.key});

  @override
  State<ImgList> createState() => _ImgListState();
}

class _ImgListState extends State<ImgList> {
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
    final story = Provider.of<StoryModel>(context);
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),

      child: ListView.builder(
        itemCount: story.infos.length,
        itemBuilder: (context, index) {
          return _listItems(story.infos[index], index);
        },
      ),
    );
  }

  Widget _listItems(rust_api.ImageInfo info, int index) {
    final story = Provider.of<StoryModel>(context);
    return InkWell(
      onTap: () => {story.setCurrentIndex(index)},
      child: Container(
        margin: EdgeInsets.all(5.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.greenAccent[100],
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10.0),
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
            Column(
              children: [
                Text(
                  info.name,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: false,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ),
                Center(
                  child: Text(
                    "${info.width}x${info.height}",
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
