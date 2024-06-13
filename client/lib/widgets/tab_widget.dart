import 'package:flutter/material.dart';

class CommonTabBar extends StatefulWidget {
  final List<CommonTabWrap>? tabs;
  final ReorderCallback? onReorder;
  final Color? color;
  final CommonTabStyle? tabStyle;

  const CommonTabBar(
      {Key? key, this.tabs, this.onReorder, this.color, this.tabStyle})
      : super(key: key);

  @override
  State<CommonTabBar> createState() => _CommonTabBarState();
}

class _CommonTabBarState extends State<CommonTabBar> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, c) {
      return Container(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        decoration: BoxDecoration(
          color: widget.color ??
              Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: SizedBox(
          height: 40,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (widget.tabs != null)
                for (var i = 0; i < widget.tabs!.length; i++)
                  CommonTab(
                    avatar: widget.tabs![i].avatar,
                    label: widget.tabs![i].label,
                    selected: widget.tabs![i].selected,
                    style: widget.tabStyle,
                    onTap: widget.tabs![i].onTap,
                    onDeleted: widget.tabs![i].onDeleted,
                  ),
              const Expanded(
                child: Spacer(),
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
  final double? maxWidth;
  final double? width;
  final Color? color;
  final Color? selectedColor;
  final Color? hoverColor;
  CommonTabStyle(
      {this.maxWidth,
      this.width,
      this.color,
      this.selectedColor,
      this.hoverColor});
}

class CommonTab extends StatefulWidget {
  final Widget? avatar; // image or icon
  final String label;
  final List<PopupMenuEntry>? items;
  final bool selected;
  final CommonTabStyle? style;

  final GestureTapCallback? onTap;
  final VoidCallback? onDeleted;

  const CommonTab({
    Key? key,
    required this.label,
    required this.selected,
    this.onTap,
    this.onDeleted,
    this.items,
    this.avatar,
    this.style,
  }) : super(key: key);

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
            padding: const EdgeInsets.all(5),
            width: 150,
            height: 35,
            decoration: BoxDecoration(
                color: color(),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5), topRight: Radius.circular(5))),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: widget.avatar,
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  constraints: const BoxConstraints(maxWidth: 50),
                  child: Text(
                    widget.label,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Expanded(child: Spacer()),
                Container(
                    constraints:
                        const BoxConstraints(maxHeight: 30, maxWidth: 30),
                    child: IconButton(
                      alignment: Alignment.center,
                      constraints: const BoxConstraints(minHeight: 100),
                      onPressed: widget.onDeleted,
                      icon: const Icon(size: 10, Icons.close),
                    ))
              ],
            ),
          ),
        ));
  }
}
