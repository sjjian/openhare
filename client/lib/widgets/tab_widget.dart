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
  bool _showingMenu = false;
  Offset? _buttonPosition;
  Size? _buttonSize;

  final LayerLink _layerLink = LayerLink();
  final OverlayPortalController _portalController = OverlayPortalController();

  void _toggleMenu(BuildContext context) {
    if (_showingMenu) {
      setState(() {
        _showingMenu = false;
      });
      _portalController.hide();
    } else {
      // 这里需要获取icon的全局位置和大小
      final RenderBox? button = context.findRenderObject() as RenderBox?;
      if (button != null) {
        final Offset position = button.localToGlobal(Offset.zero);
        final Size size = button.size;
        setState(() {
          _buttonPosition = position;
          _buttonSize = size;
          _showingMenu = true;
        });
        _portalController.show();
      }
    }
  }

  Widget _buildItem(BuildContext context, int index) {
    return SizedBox(
      height: widget.height ?? 35,
      child: InkWell(
        onTap: () {
          widget.tabs[index].onTap?.call();
          widget.onTabSelected(index);
          setState(() {
            _showingMenu = false;
          });
          _portalController.hide();
        },
        child: Row(
          children: [
            if (widget.tabs[index].avatar != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 16, 0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: widget.tabs[index].avatar,
                ),
              ),
            SizedBox(
              width: 60,
              child: Text(
                widget.tabs[index].label,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.tabs[index].onDeleted != null)
                    IconButton(
                      icon: const Icon(size: 15, Icons.close),
                      padding: const EdgeInsets.all(5),
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        widget.tabs[index].onDeleted?.call();
                        // 不关闭菜单，强制刷新
                        setState(() {});
                      },
                      splashRadius: 16,
                      tooltip: '关闭',
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 220),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: [
          for (int i = 0; i < widget.tabs.length; i++) _buildItem(context, i),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Stack(
        children: [
          SizedBox(
            height: widget.height ?? 35,
            child: Builder(
              builder: (iconContext) => GestureDetector(
                onTap: () => _toggleMenu(iconContext),
                child: Icon(
                  size: 20,
                  Icons.more_vert,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
          OverlayPortal(
            controller: _portalController,
            overlayChildBuilder: (context) {
              // 计算弹出菜单的位置
              final Size screenSize = MediaQuery.of(context).size;
              final Offset position = _buttonPosition ?? Offset.zero;
              final Size buttonSize = _buttonSize ?? Size(40, widget.height ?? 35);

              // 菜单默认在按钮下方
              double left = position.dx;
              double top = position.dy + buttonSize.height;

              // 限制菜单不超出屏幕
              const double menuWidth = 220;
              if (left + menuWidth > screenSize.width) {
                left = screenSize.width - menuWidth - 8;
              }
              if (left < 8) left = 8;

              return Stack(
                children: [
                  // 点击遮罩关闭菜单
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          _showingMenu = false;
                        });
                        _portalController.hide();
                      },
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  Positioned(
                    left: left,
                    top: top,
                    child: Material(
                      color: Colors.transparent,
                      child: _buildMenu(context),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
