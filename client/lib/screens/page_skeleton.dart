import 'package:client/screens/app.dart';
import 'package:client/widgets/const.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

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

class PageSkeleton extends StatelessWidget {
  final Widget? topBar;
  final Widget? bottomBar;
  final Widget child;
  final Widget? drawer;
  final Color? backgroundColor;

  const PageSkeleton(
      {Key? key, this.topBar, this.bottomBar, this.drawer, required this.child, this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithNavRail(
      child: Material(
        color: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerLow, // 全局背景色
        child: Column(children: [
          Container(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHigh, // header 背景色
            height: tabbarHeight,
            child: Row(
              children: [
                Expanded(
                  child: MoveWindow(
                    // todo: MoveWindow 存在延迟, 看后续如何优化, 参考: https://github.com/bitsdojo/bitsdojo_window/issues/187
                    child: topBar,
                  ),
                ),
                const SizedBox(width: kSpacingLarge), // 顶部 tab 空部分空间, 防止无法拖动窗口.
                if (!kIsWeb) const WindowButtons(),
              ],
            ),
          ),
          Expanded(
            child: child,
          ),
          Container(
            height: tabbarHeight,
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHigh, // bottom 背景色
            child: bottomBar,
          )
        ]),
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
