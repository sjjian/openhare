import 'package:client/screens/app.dart';
import 'package:client/widgets/const.dart';
import 'package:flutter/material.dart';
import 'package:sql_editor/re_editor.dart';
import 'package:window_manager/window_manager.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:client/widgets/divider.dart';

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final colors = WindowButtonColors(
      iconNormal: theme.onSurface, // 深灰色图标
      mouseOver: theme.surfaceContainerHigh, // 浅灰色背景（悬停）
      mouseDown: theme.surfaceContainerHigh, // 稍深的灰色背景（按下）
      iconMouseOver: theme.onSurface, // 悬停时图标保持深灰色
      iconMouseDown: theme.onSurface, // 按下时图标保持深灰色
    );
    final closeColors = WindowButtonColors(
      iconNormal: theme.onSurface, // 深灰色图标
      mouseOver: theme.error, // 浅灰色背景（悬停）
      mouseDown: theme.error, // 稍深的灰色背景（按下）
      iconMouseOver: theme.onError, // 悬停时图标保持深灰色
      iconMouseDown: theme.onError, // 按下时图标保持深灰色
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MinimizeWindowButton(colors: colors),
        MaximizeWindowButton(colors: colors),
        CloseWindowButton(colors: closeColors),
      ],
    );
  }
}

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
            const PixelVerticalDivider(),
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
                const PixelDivider(),
                Expanded(
                  child: child,
                ),
                const PixelDivider(),
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
                const PixelDivider(),
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
