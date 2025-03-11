import 'package:Flutter_Image_Browser/src/rust/api/simple.dart' as rust_api;
import 'package:flutter/material.dart';

class StoryModel extends ChangeNotifier {
  List<rust_api.ImageInfo> _infos = [];
  int _currentIndex = 0;
  bool _listView = false;
  int _totalImages = 0;
  final String _fileName = "";

  List<rust_api.ImageInfo> get infos => _infos;
  int get currentIndex => _currentIndex;
  bool get listView => _listView;
  int get totalImages => _totalImages;
  String get fileName => _fileName;

  void setTotalImages(int value) {
    _totalImages = value;
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners(); // 通知所有监听者
  }

  void setInfos(List<rust_api.ImageInfo> newInfos) {
    _infos = newInfos;
    notifyListeners();
  }

  void setListView(bool value) {
    _listView = value;
    notifyListeners();
  }

  void addImage(rust_api.ImageInfo image) {
    _infos.add(image);
    notifyListeners();
  }

  void clearInfos() {
    _infos.clear();
    notifyListeners();
  }
}
