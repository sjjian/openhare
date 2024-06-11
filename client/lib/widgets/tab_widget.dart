import 'package:flutter/material.dart';

class CommonTab extends StatefulWidget {
  final bool selected;
  final GestureTapCallback? onTap;
  final VoidCallback? onDeleted;
  final List<PopupMenuEntry>? items;
  final Widget? avatar; // image or icon
  final String label;
  final Color? color;
  final Color? selectedColor;
  final Color? hoverColor;

  const CommonTab({
    Key? key,
    required this.label,
    required this.selected,
    this.onTap,
    this.onDeleted,
    this.items,
    this.avatar,
    this.color,
    this.selectedColor,
    this.hoverColor,
  }) : super(key: key);

  @override
  State<CommonTab> createState() => _CommonTabState();
}

class _CommonTabState extends State<CommonTab> {
  bool isEnter = false;

  Color color() {
    if (widget.selected) {
      return widget.selectedColor == null
          ? Theme.of(context).colorScheme.surfaceContainer
          : widget.selectedColor!;
    }
    if (isEnter) {
      return widget.hoverColor == null
          ? Theme.of(context).colorScheme.primaryContainer
          : widget.hoverColor!;
    }
    return widget.color == null
        ? Theme.of(context).colorScheme.surface
        : widget.color!;
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
