import 'dart:math';
import 'package:flutter/material.dart';

const double defaultTabMaxWidth = 200;

class CommonTabBar extends StatefulWidget {
  final double? height;
  final List<CommonTabWrap>? tabs;
  final ReorderCallback? onReorder;
  final VoidCallback? addTab;
  final Color? color;
  final CommonTabStyle? tabStyle;

  const CommonTabBar(
      {Key? key,
      this.height,
      this.tabs,
      this.onReorder,
      this.addTab,
      this.color,
      this.tabStyle})
      : super(key: key);

  @override
  State<CommonTabBar> createState() => _CommonTabBarState();
}

class _CommonTabBarState extends State<CommonTabBar> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, c) {
      CommonTabStyle style = widget.tabStyle ?? CommonTabStyle();
      double width = min(c.maxWidth / widget.tabs!.length,
          style.maxWidth ?? defaultTabMaxWidth);

      Widget addTabWidget = SizedBox(
          height: widget.height ?? 35,
          // padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
          child: IconButton(
            alignment: Alignment.center,
            constraints: const BoxConstraints(),
            onPressed: widget.addTab,
            icon: Icon(
                size: 20,
                Icons.add,
                color: Theme.of(context).colorScheme.onSurface),
          ));

      return Container(
        constraints: BoxConstraints(maxHeight: widget.height ?? 40),
        decoration: BoxDecoration(
          color: widget.color ??
              Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: SizedBox(
          child: widget.onReorder != null
              ? ReorderableListView(
                  footer: widget.addTab != null ? addTabWidget : null,
                  buildDefaultDragHandles: false,
                  scrollDirection: Axis.horizontal,
                  onReorder: widget.onReorder!,
                  children: [
                    if (widget.tabs != null)
                      for (var i = 0; i < widget.tabs!.length; i++)
                        ReorderableDragStartListener(
                          index: i,
                          key: ValueKey(i),
                          child: CommonTab.fromWarp(
                              warp: widget.tabs![i],
                              width: width,
                              height: widget.height,
                              style: style),
                        ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (widget.tabs != null)
                      for (var i = 0; i < widget.tabs!.length; i++)
                        CommonTab.fromWarp(
                            warp: widget.tabs![i],
                            width: width,
                            height: widget.height,
                            style: style),
                    if (widget.addTab != null) addTabWidget,
                    const Spacer()
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
  final Color? color;
  final Color? selectedColor;
  final Color? hoverColor;
  final TextAlign? labelAlign;
  CommonTabStyle(
      {this.height,
      this.maxWidth,
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
      Color defaultColor = Theme.of(context).colorScheme.surfaceContainer;
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
