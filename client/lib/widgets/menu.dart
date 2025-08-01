import 'package:flutter/material.dart';

class MoreTabMenuWidget extends StatefulWidget {
  final double? height;
  final List<MoreTabMenuItemWidget> tabs;
  final Widget child;

  const MoreTabMenuWidget({
    Key? key,
    required this.height,
    required this.tabs,
    required this.child,
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
      // 这里需要获取宿主widget的全局位置和大小
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

  Widget _buildMenu(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 220),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: [
          for (int i = 0; i < widget.tabs.length; i++)
            InkWell(
              onTap: () {
                widget.tabs[i].onTabSelected();
                setState(() {
                  _showingMenu = false;
                });
                _portalController.hide();
              },
              child: widget.tabs[i],
            )
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
              final Size screenSize = MediaQuery.of(context).size;
              final Offset position = _buttonPosition ?? Offset.zero;
              final Size buttonSize =
                  _buttonSize ?? Size(40, widget.height ?? 35);

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

class MoreTabMenuItemWidget extends StatefulWidget {
  final double? height;
  final Widget child;
  final void Function() onTabSelected;

  const MoreTabMenuItemWidget({
    Key? key,
    required this.height,
    required this.child,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  State<MoreTabMenuItemWidget> createState() => _MoreTabMenuItemWidgetState();
}

class _MoreTabMenuItemWidgetState extends State<MoreTabMenuItemWidget> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: SizedBox(
        height: widget.height ?? 35,
        child: Container(
          color: _hovering
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : Theme.of(context).colorScheme.surfaceContainerHigh,
          child: widget.child,
        ),
      ),
    );
  }
}
