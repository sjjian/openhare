import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

/// 内部记录 offset 并能在重建时恢复的 ScrollController
class KeepOffestScrollController extends ScrollController {
  double _savedOffset = 0.0;

  KeepOffestScrollController({double initialOffset = 0.0}) : super(initialScrollOffset: initialOffset);

  @override
  void attach(ScrollPosition position) {
    super.attach(position);
    // 滚动时自动保存 offset
    addListener(_saveOffset);

    // 恢复 offset
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasClients) jumpTo(_savedOffset);
    });
  }

  @override
  void detach(ScrollPosition position) {
    removeListener(_saveOffset);
    _saveOffset();
    super.detach(position);
  }

  @override
  void dispose() {
    removeListener(_saveOffset);
    _saveOffset();
    super.dispose();
  }

  void _saveOffset() {
    if (hasClients) {
      _savedOffset = offset;
    }
  }
}


/// 支持自动保存 offset 的 LinkedScrollControllerGroup
class KeepOffestLinkedScrollControllerGroup extends LinkedScrollControllerGroup {
  double _offset = 0.0;

  @override
  ScrollController addAndGet() {
    final controller = super.addAndGet();

    // 恢复 offset
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.hasClients) {
        controller.jumpTo(_offset);
      }
    });

    // 滚动时更新全局 offset
    controller.addListener(() {
      if (controller.hasClients) {
        _offset = controller.offset;
      }
    });
    return controller;
  }
}