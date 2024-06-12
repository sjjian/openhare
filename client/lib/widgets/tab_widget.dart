import 'package:flutter/material.dart';

class CommonTabBar extends StatefulWidget {
  final List<CommonTabBuilder>? tabs;
  final ReorderCallback? onReorder;
  final Color? color;

  const CommonTabBar({Key? key, this.tabs, this.onReorder, this.color})
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
                  widget.tabs![i].builder(ctx),
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

class CommonTabBuilder extends StatefulWidget {
  final Widget Function(BuildContext context) builder;

  const CommonTabBuilder({Key? key, required this.builder}) : super(key: key);

  @override
  State<CommonTabBuilder> createState() => _CommonTabBuilderState();
}

class _CommonTabBuilderState extends State<CommonTabBuilder> {
  @override
  build(BuildContext context) => widget.builder(context);
}

class CommonTabStyle {
  final double? maxWidth;
  final Color? color;
  final Color? selectedColor;
  final Color? hoverColor;
  CommonTabStyle(
      {this.maxWidth, this.color, this.selectedColor, this.hoverColor});
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
