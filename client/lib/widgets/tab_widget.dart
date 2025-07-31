import 'dart:math';
import 'package:flutter/material.dart';

const double defaultTabMaxWidth = 200;

class CommonTabBar extends StatefulWidget {
  final double? height;
  final List<CommonTabWrap> tabs;
  final ReorderCallback onReorder;
  final VoidCallback? addTab;
  final Color? color;
  final CommonTabStyle? tabStyle;

  const CommonTabBar(
      {Key? key,
      this.height,
      required this.tabs,
      required this.onReorder,
      this.addTab,
      this.color,
      this.tabStyle})
      : super(key: key);

  @override
  State<CommonTabBar> createState() => _CommonTabBarState();
}

class _CommonTabBarState extends State<CommonTabBar> {
  Widget addTabWidget() {
    return SizedBox(
      height: widget.height ?? 35,
      child: IconButton(
        alignment: Alignment.center,
        constraints: const BoxConstraints(),
        onPressed: widget.addTab,
        icon: Icon(
            size: 20,
            Icons.add,
            color: Theme.of(context).colorScheme.onSurface), // tab add 的字体颜色
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, c) {
      CommonTabStyle style = widget.tabStyle ?? CommonTabStyle();
      // 设置的tab最小width;
      final minWidth = style.minWidth ?? (35 + 20 + 10);
      final addTabWidth = widget.addTab != null ? 36 : 0;
      const moreWidth = 36;
      // tab 可用的总width;
      final sumTabLength = c.maxWidth - addTabWidth - moreWidth;

      // 每个tab的平均 width；
      double width = min(sumTabLength / widget.tabs.length,
          style.maxWidth ?? defaultTabMaxWidth);

      // 如果总宽度不够，就只能展示后面length个tab
      int length = widget.tabs.length;
      int start = 0;
      if (width < minWidth) {
        width = minWidth;
        length = sumTabLength ~/ minWidth; // 取整

        start = widget.tabs.length - length;
        // 重新计算width, 让length个tab占据总宽度
        width = sumTabLength / length;
      }

      return Container(
        constraints: BoxConstraints(maxHeight: widget.height ?? 40),
        decoration: BoxDecoration(
          color: widget.color,
        ),
        child: SizedBox(
          child: ReorderableListView(
            header: start > 0
                ? MoreTabMenuWidget(
                    height: widget.height,
                    tabs: widget.tabs.sublist(0, start),
                    onTabSelected: (index) {
                      widget.onReorder(index, index);
                    })
                : null,
            footer: widget.addTab != null ? addTabWidget() : null,
            buildDefaultDragHandles: false,
            scrollDirection: Axis.horizontal,
            onReorder: (oldIndex, newIndex) {
              widget.onReorder(oldIndex + start, newIndex + start);
            },
            children: [
              for (var i = start; i < widget.tabs.length; i++)
                ReorderableDragStartListener(
                  index: i - start,
                  key: ValueKey(i - start),
                  child: CommonTab.fromWarp(
                      warp: widget.tabs[i],
                      width: width,
                      height: widget.height,
                      style: style),
                )
            ],
          ),
        ),
      );
    });
  }
}

class CommonTabWrap {
  final Widget? avatar; // image or icon
  final String label;
  final List<PopupMenuEntry>? items;
  final bool selected;

  final GestureTapCallback? onTap;
  final VoidCallback? onDeleted;

  CommonTabWrap(
      {this.avatar,
      required this.label,
      this.items,
      required this.selected,
      this.onTap,
      this.onDeleted});
}

class CommonTabStyle {
  final double? height;
  final double? maxWidth;
  final double? minWidth;
  final Color? color;
  final Color? selectedColor;
  final Color? hoverColor;
  final TextAlign? labelAlign;
  CommonTabStyle(
      {this.height,
      this.maxWidth,
      this.minWidth,
      this.color,
      this.selectedColor,
      this.hoverColor,
      this.labelAlign});
}

class CommonTab extends StatefulWidget {
  final Widget? avatar; // image or icon
  final String label;
  final List<PopupMenuEntry>? items;
  final bool selected;
  final double? width;
  final double? height;
  final CommonTabStyle? style;

  final GestureTapCallback? onTap;
  final VoidCallback? onDeleted;

  const CommonTab(
      {Key? key,
      this.avatar,
      required this.label,
      required this.selected,
      this.items,
      this.onTap,
      this.onDeleted,
      this.style,
      this.width,
      this.height})
      : super(key: key);

  CommonTab.fromWarp(
      {super.key,
      required CommonTabWrap warp,
      this.style,
      this.width,
      this.height})
      : avatar = warp.avatar,
        label = warp.label,
        items = warp.items,
        onTap = warp.onTap,
        onDeleted = warp.onDeleted,
        selected = warp.selected;

  @override
  State<CommonTab> createState() => _CommonTabState();
}

class _CommonTabState extends State<CommonTab> {
  bool isEnter = false;

  Color color() {
    if (widget.selected) {
      Color defaultColor = Theme.of(context).colorScheme.surfaceContainerHigh;
      return widget.style != null
          ? (widget.style!.selectedColor ?? defaultColor)
          : defaultColor;
    } else if (isEnter) {
      Color defaultColor = Theme.of(context).colorScheme.primaryContainer;
      return widget.style != null
          ? (widget.style!.hoverColor ?? defaultColor)
          : defaultColor;
    } else {
      Color defaultColor = Theme.of(context).colorScheme.surface;
      return widget.style != null
          ? (widget.style!.color ?? defaultColor)
          : defaultColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        onEnter: (_) {
          setState(() {
            isEnter = true;
          });
        },
        onExit: (_) {
          setState(() {
            isEnter = false;
          });
        },
        child: GestureDetector(
          onTap: widget.onTap,
          onSecondaryTapUp: widget.items == null
              ? null
              : (detail) {
                  final position = detail.globalPosition;
                  final RenderBox overlay = Overlay.of(context)
                      .context
                      .findRenderObject() as RenderBox;
                  final overlayPos = overlay.localToGlobal(Offset.zero);

                  showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(
                      position.dx - overlayPos.dx,
                      position.dy - overlayPos.dy,
                      position.dx - overlayPos.dx,
                      position.dy - overlayPos.dy,
                    ),
                    items: widget.items!,
                  );
                },
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            width: widget.width ?? defaultTabMaxWidth,
            height: widget.height ?? 40,
            decoration: BoxDecoration(
                color: color(),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5), topRight: Radius.circular(5))),
            child: Row(
              children: [
                if (widget.avatar != null)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: widget.avatar,
                  ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                    constraints: const BoxConstraints(maxWidth: 50),
                    child: Text(
                      widget.label,
                      overflow: TextOverflow.ellipsis,
                      textAlign: widget.style?.labelAlign,
                    ),
                  ),
                ),
                if (widget.onDeleted != null)
                  Container(
                      padding: const EdgeInsets.all(5),
                      child: IconButton(
                        alignment: Alignment.center,
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(5),
                        onPressed: widget.onDeleted,
                        icon: const Icon(size: 15, Icons.close),
                      ))
              ],
            ),
          ),
        ));
  }
}

class MoreTabMenuWidget extends StatefulWidget {
  final double? height;
  final List<CommonTabWrap> tabs;
  final void Function(int index) onTabSelected;
  // final VoidCallback? onMore;

  const MoreTabMenuWidget({
    Key? key,
    required this.height,
    required this.tabs,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  State<MoreTabMenuWidget> createState() => _MoreTabMenuWidgetState();
}

class _MoreTabMenuWidgetState extends State<MoreTabMenuWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height ?? 35,
      child: PopupMenuButton<int>(
        icon: Icon(
          size: 20,
          Icons.more_vert,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        itemBuilder: (ctx) {
          // 只显示0到start的tab
          return [
            for (int i = 0; i < widget.tabs.length; i++)
              PopupMenuItem<int>(
                height: widget.height ?? 35,
                value: i,
                child: SizedBox(
                  // width: 100,
                  child: Row(
                    children: [
                      if (widget.tabs[i].avatar != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                          child: SizedBox(
                              width: 20,
                              height: 20,
                              child: widget.tabs[i].avatar),
                        ),
                      SizedBox(
                        width: 60,
                        child: Text(
                          widget.tabs[i].label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (widget.tabs[i].onDeleted != null)
                              IconButton(
                                onPressed: widget.tabs[i].onDeleted,
                                icon: const Icon(size: 15, Icons.close),
                              ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
          ];
        },
        onSelected: (index) {
          setState(() {});
          widget.tabs[index].onTap?.call();
          widget.onTabSelected(index);
        },
        tooltip: '更多标签',
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}
