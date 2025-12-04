import 'package:flutter/material.dart';

class OverlayMenu extends StatefulWidget {
  final double maxHeight;
  final double maxWidth;
  final List<OverlayMenuItem> tabs;
  final OverlayMenuHeader? header;
  final OverlayMenuFooter? footer;
  final Widget child;
  // 支持设置弹窗的位置。在上方或者下方。默认在下方
  final bool isAbove;
  // 支持设置弹窗的间距。默认0
  final double spacing;

  // 支持设置点击菜单项后是否关闭菜单。默认关闭
  final bool closeOnSelectItem;

  const OverlayMenu({
    Key? key,
    this.maxHeight = 400,
    this.maxWidth = 220,
    required this.tabs,
    required this.child,
    this.header,
    this.footer,
    this.isAbove = false,
    this.spacing = 0,
    this.closeOnSelectItem = true,
  }) : super(key: key);

  @override
  State<OverlayMenu> createState() => _OverlayMenuState();
}

class _OverlayMenuState extends State<OverlayMenu> {
  bool _showingMenu = false;
  Offset? _childPosition;
  Size? _childSize;

  final LayerLink _layerLink = LayerLink();
  final OverlayPortalController _portalController = OverlayPortalController();

  void _toggleMenu(BuildContext context) {
    if (_showingMenu) {
      setState(() {
        _showingMenu = false;
      });
      _portalController.hide();
    } else {
      // 这里需要获取宿主widget的全局位置和大小
      final RenderBox? child = context.findRenderObject() as RenderBox?;
      if (child != null) {
        final Offset position = child.localToGlobal(Offset.zero);
        final Size size = child.size;
        setState(() {
          _childPosition = position;
          _childSize = size;
          _showingMenu = true;
        });
        _portalController.show();
      }
    }
  }

  Widget _buildMenu(BuildContext context, double maxHeight) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: widget.maxWidth,
        maxHeight: maxHeight,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // 上面设置的圆角没作用，被下面的widget覆盖了
      child: Column(
        children: [
          if (widget.header != null) widget.header!,
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                for (int i = 0; i < widget.tabs.length; i++)
                  widget.tabs[i].onTabSelected != null
                      ? InkWell(
                          onTap: () {
                            widget.tabs[i].onTabSelected?.call();
                            if (widget.closeOnSelectItem) {
                              setState(() {
                                _showingMenu = false;
                              });
                              _portalController.hide();
                            }
                          },
                          child: widget.tabs[i],
                        )
                      : widget.tabs[i]
              ],
            ),
          ),
          if (widget.footer != null) widget.footer!,
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
          Builder(
            builder: (iconContext) => GestureDetector(
              onTap: () => _toggleMenu(iconContext),
              child: widget.child,
            ),
          ),
          OverlayPortal(
            controller: _portalController,
            overlayChildBuilder: (context) {
              // 计算弹出菜单的位置
              final Size screenSize = MediaQuery.of(context).size; // 屏幕大小
              final Offset position = _childPosition ?? Offset.zero; // 按钮位置
              final Size childSize = _childSize ?? const Size(40, 40);

              double top = 0;
              double left = position.dx;

              // 计算弹窗的总height
              double menuHeight = 0;
              if (widget.header != null) {
                menuHeight += widget.header!.height;
              }
              for (int i = 0; i < widget.tabs.length; i++) {
                menuHeight += widget.tabs[i].height;
              }
              if (widget.footer != null) {
                menuHeight += widget.footer!.height;
              }
              // 限制菜单高度
              menuHeight = (menuHeight > widget.maxHeight)
                  ? widget.maxHeight
                  : menuHeight;

              if (widget.isAbove) {
                top = position.dy - menuHeight - widget.spacing;
              } else {
                top = position.dy + childSize.height + widget.spacing;
              }

              // 限制菜单不超出屏幕
              final double menuWidth = widget.maxWidth;
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
                    ),
                  ),
                  Positioned(
                    left: left,
                    top: top,
                    child: Material(
                      color: Colors.transparent,
                      child: _buildMenu(context, menuHeight),
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

class OverlayMenuItem extends StatefulWidget {
  final double height;
  final Widget child;
  final void Function()? onTabSelected;
  final Color? hoverColor;

  const OverlayMenuItem({
    Key? key,
    required this.height,
    required this.child,
    this.onTabSelected,
    this.hoverColor,
  }) : super(key: key);

  @override
  State<OverlayMenuItem> createState() => _OverlayMenuItemState();
}

class _OverlayMenuItemState extends State<OverlayMenuItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final hoverColor = widget.hoverColor ??
        Theme.of(context).colorScheme.surfaceContainer;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: SizedBox(
        height: widget.height,
        child: Container(
          color: _hovering ? hoverColor : null,
          child: widget.child,
        ),
      ),
    );
  }
}

class OverlayMenuHeader extends StatelessWidget {
  final double height;
  final Widget child;
  const OverlayMenuHeader({Key? key, required this.height, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: child,
    );
  }
}

class OverlayMenuFooter extends StatefulWidget {
  final double height;
  final Widget child;
  final VoidCallback? onTap;
  final Color? hoverColor;

  const OverlayMenuFooter({
    Key? key,
    required this.height,
    required this.child,
    this.onTap,
    this.hoverColor,
  }) : super(key: key);

  @override
  State<OverlayMenuFooter> createState() => _OverlayMenuFooterState();
}

class _OverlayMenuFooterState extends State<OverlayMenuFooter> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final base = SizedBox(
      height: widget.height,
      child: widget.child,
    );

    final colorScheme = Theme.of(context).colorScheme;
    const radius = BorderRadius.only(
      bottomLeft: Radius.circular(12),
      bottomRight: Radius.circular(12),
    );
    final hoverColor =
        widget.hoverColor ?? colorScheme.surfaceContainerLow;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _hovering ? hoverColor : Colors.transparent,
            borderRadius: radius,
          ),
          child: base,
        ),
      ),
    );
  }
}
