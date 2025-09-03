import 'dart:math';
import 'package:client/widgets/button.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/menu.dart';
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
      child: RectangleIconButton.small(
        icon: Icons.add,
        onPressed: widget.addTab,
      ),
    );
  }

  List<OverlayMenuItem> _buildItems(int start) {
    return [
      for (var i = start - 1; i >= 0; i--)
        OverlayMenuItem(
          height: widget.height ?? 35,
          child: Row(
            children: [
              if (widget.tabs[i].avatar != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 16, 0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: widget.tabs[i].avatar,
                  ),
                ),
              SizedBox(
                width: 60,
                child: Text(
                  widget.tabs[i].label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              if (widget.tabs[i].onDeleted != null)
                RectangleIconButton.tiny(
                  icon: Icons.close,
                  onPressed: () {
                    widget.tabs[i].onDeleted?.call();
                  },
                ),
              const SizedBox(width: kSpacingTiny),
            ],
          ),
          onTabSelected: () {
            widget.onReorder(i, widget.tabs.length);
            widget.tabs[i].onTap?.call();
          },
        )
    ];
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

      final moreTabIcon = SizedBox(
        width: 36,
        height: 36,
        child: Icon(
          size: 20,
          Icons.more_vert,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      );

      return Container(
        constraints: BoxConstraints(maxHeight: widget.height ?? 36),
        decoration: BoxDecoration(
          color: widget.color,
        ),
        child: SizedBox(
          child: ReorderableListView(
            header: start > 0
                ? OverlayMenu(
                    tabs: _buildItems(start),
                    child: moreTabIcon,
                  )
                : moreTabIcon,
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
                    style: style,
                  ),
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
  final BorderRadiusGeometry? borderRadius;
  CommonTabStyle({
    this.height,
    this.maxWidth,
    this.minWidth,
    this.color,
    this.selectedColor,
    this.hoverColor,
    this.labelAlign,
    this.borderRadius,
  });
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

  const CommonTab({
    Key? key,
    this.avatar,
    required this.label,
    required this.selected,
    this.items,
    this.onTap,
    this.onDeleted,
    this.style,
    this.width,
    this.height,
  }) : super(key: key);

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
          child: SizedBox(
            width: widget.width ?? defaultTabMaxWidth,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: kSpacingSmall,
                  child: VerticalDivider(
                    color: Theme.of(context).dividerColor,
                    thickness: kDividerThickness,
                    width: kDividerSize,
                    indent: 8,
                    endIndent: 8,
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(kSpacingTiny, 0, 0, 0),
                    height: widget.height ?? 40,
                    decoration: BoxDecoration(
                      color: color(),
                      borderRadius: widget.style?.borderRadius ??
                          const BorderRadius.all(Radius.circular(10)),
                    ),
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
                            constraints: const BoxConstraints(maxWidth: 50),
                            child: Text(
                              widget.label,
                              overflow: TextOverflow.ellipsis,
                              textAlign: widget.style?.labelAlign,
                            ),
                          ),
                        ),
                        if (widget.onDeleted != null) ...[
                          RectangleIconButton.tiny(
                            icon: Icons.close,
                            onPressed: widget.onDeleted,
                          ),
                          const SizedBox(width: kSpacingTiny),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
