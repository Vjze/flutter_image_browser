import 'package:get/get.dart';

// 定义状态类
class StoryState extends GetxController {
  var infos = [].obs;
  var currentIndex = 0.obs;
  var listView = false.obs;
  var totalImages = 0.obs;
  var fileName = ''.obs;
}
