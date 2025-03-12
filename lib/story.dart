import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_browser/src/rust/api/simple.dart';

// 定义状态类
class StoryState {
  final List<ImageInfo> infos;
  final int currentIndex;
  final bool listView;
  final int totalImages;
  final String fileName;

  StoryState({
    required this.infos,
    required this.currentIndex,
    required this.listView,
    required this.totalImages,
    required this.fileName,
  });

  // 用于复制状态的 copyWith 方法，便于更新部分字段
  StoryState copyWith({
    List<ImageInfo>? infos,
    int? currentIndex,
    bool? listView,
    int? totalImages,
    String? fileName,
  }) {
    return StoryState(
      infos: infos ?? this.infos,
      currentIndex: currentIndex ?? this.currentIndex,
      listView: listView ?? this.listView,
      totalImages: totalImages ?? this.totalImages,
      fileName: fileName ?? this.fileName,
    );
  }
}

// 定义 StateNotifier
class StoryNotifier extends StateNotifier<StoryState> {
  StoryNotifier()
    : super(
        StoryState(
          infos: [],
          currentIndex: 0,
          listView: false,
          totalImages: 0,
          fileName: "",
        ),
      );

  void setTotalImages(int value) {
    state = state.copyWith(totalImages: value);
  }

  void setCurrentIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  void setInfos(List<ImageInfo> newInfos) {
    state = state.copyWith(infos: newInfos);
  }

  void setListView(bool value) {
    state = state.copyWith(listView: value);
  }

  void addImage(ImageInfo image) {
    state = state.copyWith(infos: [...state.infos, image]);
  }

  void clearInfos() {
    state = state.copyWith(infos: []);
  }
}

// 定义 Riverpod 的 provider
final storyProvider = StateNotifierProvider<StoryNotifier, StoryState>((ref) {
  return StoryNotifier();
});
