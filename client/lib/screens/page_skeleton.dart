import 'package:client/screens/app.dart';
import 'package:client/widgets/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sql_editor/re_editor.dart';
import 'package:window_manager/window_manager.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

// todo: 在windows上需要添加窗口按钮
final buttonColors = WindowButtonColors(
    iconNormal: const Color(0xFF805306),
    mouseOver: const Color(0xFFF6A00C),
    mouseDown: const Color(0xFF805306),
    iconMouseOver: const Color(0xFF805306),
    iconMouseDown: const Color(0xFFFFD500));

final closeButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconNormal: const Color(0xFF805306),
    iconMouseOver: Colors.white);

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}

// class DragToMoveArea2 extends StatelessWidget {
//   final Widget child;
//   const DragToMoveArea2({super.key, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       behavior: HitTestBehavior.translucent,
//       onPanStart: (details) {
//         windowManager.startDragging();
//       },
//       child: child,
//     );
//   }
// }

class MoveWindows extends StatelessWidget {
  const MoveWindows({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        windowManager.startDragging();
      },
      // todo: 存在手势竞争，换导致看起来点击child的按钮卡顿
      // onDoubleTap: () async {
      //   bool isMaximized = await windowManager.isMaximized();
      //   if (!isMaximized) {
      //     windowManager.maximize();
      //   } else {
      //     windowManager.unmaximize();
      //   }
      // },
      child: child,
    );
  }
}

class PageSkeleton extends StatelessWidget {
  final Widget? topBar;
  final Widget? bottomBar;
  final Widget child;
  final Widget? drawer;
  final Color? backgroundColor;

  const PageSkeleton({
    Key? key,
    this.topBar,
    this.bottomBar,
    this.drawer,
    required this.child,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithNavRail(
      child: Material(
        color: backgroundColor ??
            Theme.of(context).colorScheme.surfaceContainerLowest, // 全局背景色
        child: Row(
          children: [
            VerticalDivider(
              color: Theme.of(context).dividerColor,
              thickness: kBlockDividerThickness,
              width: kBlockDividerSize,
            ),
            Expanded(
              child: Column(children: [
                MoveWindows(
                  child: Container(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerLow, // header 背景色
                    height: tabbarHeight,
                    child: Row(
                      children: [
                        Expanded(
                          child: topBar ?? const SizedBox.expand(),
                        ),
                        const SizedBox(
                            width: kSpacingLarge), // 顶部 tab 空部分空间, 防止无法拖动窗口.
                        if (!kIsMacOS) const WindowButtons(),
                      ],
                    ),
                  ),
                ),
                Divider(
                  color: Theme.of(context).dividerColor,
                  thickness: kBlockDividerThickness,
                  height: kBlockDividerSize,
                ),
                Expanded(
                  child: child,
                ),
                Divider(
                  color: Theme.of(context).dividerColor,
                  thickness: kBlockDividerThickness,
                  height: kBlockDividerSize,
                ),
                Container(
                  height: bottomBarHeight,
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerLow, // bottom 背景色
                  child: bottomBar,
                )
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class BodyPageSkeleton extends StatelessWidget {
  final Widget header;
  final Widget child;
  final double? bottomSpaceSize;
  const BodyPageSkeleton({
    Key? key,
    required this.header,
    required this.child,
    this.bottomSpaceSize = kSpacingMedium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              kSpacingLarge,
              kSpacingMedium,
              kSpacingLarge,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 36,
                  child: header,
                ),
                const SizedBox(height: kSpacingSmall),
                const Divider(
                  thickness: kDividerThickness,
                  height: kDividerSize,
                ),
                SizedBox(height: bottomSpaceSize),
                // 产品描述部分
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
