import 'dart:async';

import 'package:client/widgets/const.dart';
import 'package:flutter/material.dart';

/// 与 [OverlayMenuLayer] 水平/底边留白一致。
const double _kOverlayMenuScreenEdgePad = 8.0;

class OverlayMenu extends StatefulWidget {
  final double maxHeight;
  final double maxWidth;
  final List<OverlayMenuItem> tabs;
  final OverlayMenuHeader? header;
  final OverlayMenuFooter? footer;
  final Widget child;

  /// 为 null（默认）时按屏幕空间自动选上/下；为 true/false 时强制在目标上方或下方。
  final bool? isAbove;

  /// 支持设置弹窗的间距。默认0
  final double spacing;

  /// 支持设置点击菜单项后是否关闭菜单。默认关闭
  final bool closeOnSelectItem;

  /// 把弹出菜单对齐到比 [child] 更大一圈的矩形时常用（例如与带 [InputDecoration.contentPadding] 的输入框外框对齐）。
  final EdgeInsetsGeometry alignmentInset;

  const OverlayMenu({
    super.key,
    this.maxHeight = 400,
    this.maxWidth = 220,
    required this.tabs,
    required this.child,
    this.header,
    this.footer,
    this.isAbove,
    this.spacing = 0,
    this.closeOnSelectItem = true,
    this.alignmentInset = EdgeInsets.zero,
  });

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

  void _dismissFromBarrier() {
    setState(() {
      _showingMenu = false;
    });
    _portalController.hide();
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
              final pos = _childPosition ?? Offset.zero;
              final size = _childSize ?? const Size(40, 40);
              return OverlayMenuLayer(
                targetTopLeft: pos,
                targetSize: size,
                maxHeight: widget.maxHeight,
                maxWidth: widget.maxWidth,
                tabs: widget.tabs,
                header: widget.header,
                footer: widget.footer,
                isAbove: widget.isAbove,
                spacing: widget.spacing,
                alignmentInset: widget.alignmentInset,
                closeOnSelectItem: widget.closeOnSelectItem,
                onDismissBarrier: _dismissFromBarrier,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 按 [targetTopLeft] / [targetSize] 定位的弹出菜单（全屏点击关闭）。由 [OverlayMenu] 与选区场景共用。
class OverlayMenuLayer extends StatelessWidget {
  final Offset targetTopLeft;
  final Size targetSize;
  final double maxHeight;
  final double maxWidth;
  final List<OverlayMenuItem> tabs;
  final OverlayMenuHeader? header;
  final OverlayMenuFooter? footer;

  final bool? isAbove;
  final double spacing;
  final EdgeInsetsGeometry alignmentInset;
  final bool closeOnSelectItem;
  final VoidCallback onDismissBarrier;

  const OverlayMenuLayer({
    super.key,
    required this.targetTopLeft,
    this.targetSize = Size.zero,
    this.maxHeight = 400,
    this.maxWidth = 220,
    required this.tabs,
    this.header,
    this.footer,
    this.isAbove,
    this.spacing = 0,
    this.alignmentInset = EdgeInsets.zero,
    this.closeOnSelectItem = true,
    required this.onDismissBarrier,
  });

  static bool _prefersOpenAbove(
    BuildContext context, {
    required Rect targetRect,
    required double menuHeight,
    double spacing = 0,
    double belowExtra = 0,
  }) {
    final screenH = MediaQuery.sizeOf(context).height;
    final belowTop = targetRect.bottom + belowExtra + spacing;
    return belowTop + menuHeight > screenH - _kOverlayMenuScreenEdgePad;
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final Offset position = targetTopLeft;
    final Size childSize = targetSize;
    final outset = alignmentInset.resolve(Directionality.of(context));

    double menuHeight = 0;
    if (header != null) {
      menuHeight += header!.height;
    }
    for (int i = 0; i < tabs.length; i++) {
      menuHeight += tabs[i].height;
    }
    if (footer != null) {
      menuHeight += footer!.height;
    }
    menuHeight = (menuHeight > maxHeight) ? maxHeight : menuHeight;

    final targetRect = Rect.fromLTWH(position.dx, position.dy, childSize.width, childSize.height);
    final resolvedIsAbove =
        isAbove ??
        _prefersOpenAbove(
          context,
          targetRect: targetRect,
          menuHeight: menuHeight,
          spacing: spacing,
          belowExtra: outset.bottom,
        );

    var left = position.dx - outset.left;
    final double top;
    if (resolvedIsAbove) {
      top = position.dy - outset.top - menuHeight - spacing;
    } else {
      top = position.dy + childSize.height + outset.bottom + spacing;
    }

    double? menuFixedWidth;
    var menuWidth = maxWidth;
    if (outset.horizontal > 0 && childSize.width > 0) {
      menuFixedWidth = childSize.width + outset.left + outset.right;
      menuWidth = menuFixedWidth;
    }
    final maxPanel = screenSize.width - _kOverlayMenuScreenEdgePad * 2;
    if (menuWidth > maxPanel) {
      menuWidth = maxPanel;
      if (menuFixedWidth != null) {
        menuFixedWidth = menuWidth;
      }
    }

    if (left + menuWidth > screenSize.width) {
      left = screenSize.width - menuWidth - _kOverlayMenuScreenEdgePad;
    }
    if (left < _kOverlayMenuScreenEdgePad) {
      left = _kOverlayMenuScreenEdgePad;
    }

    final onAfterItemTap = closeOnSelectItem ? onDismissBarrier : null;
    final menuPanel = Container(
      constraints: BoxConstraints(
        maxWidth: menuFixedWidth ?? maxWidth,
        maxHeight: menuHeight,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.outline,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        // 上面 Container 设置的圆角没作用，被下面的 widget 覆盖了
        children: [
          if (header != null) header!,
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                for (int i = 0; i < tabs.length; i++)
                  tabs[i].onTabSelected != null
                      ? InkWell(
                          onTap: () {
                            tabs[i].onTabSelected?.call();
                            onAfterItemTap?.call();
                          },
                          child: tabs[i],
                        )
                      : tabs[i],
              ],
            ),
          ),
          if (footer != null) footer!,
        ],
      ),
    );
    final menuWidget = menuFixedWidth != null ? SizedBox(width: menuFixedWidth, child: menuPanel) : menuPanel;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onDismissBarrier,
          ),
        ),
        Positioned(
          left: left,
          top: top,
          child: Material(
            color: Colors.transparent,
            child: menuWidget,
          ),
        ),
      ],
    );
  }
}

class OverlayMenuItem extends StatefulWidget {
  final double height;
  final Widget child;
  final void Function()? onTabSelected;

  const OverlayMenuItem({super.key, required this.height, required this.child, this.onTabSelected});

  @override
  State<OverlayMenuItem> createState() => _OverlayMenuItemState();
}

class _OverlayMenuItemState extends State<OverlayMenuItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final hoverColor = Theme.of(context).colorScheme.surfaceContainerLow; // 菜单列鼠标移入的颜色

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: SizedBox(
        height: widget.height,
        child: Container(color: _hovering ? hoverColor : null, child: widget.child),
      ),
    );
  }
}

class _OverlayNumberTextField extends StatefulWidget {
  const _OverlayNumberTextField({
    required this.value,
    required this.onChanged,
  });

  /// 当前应展示的数字（与外部状态一致；外部变更时通过 [didUpdateWidget] 同步到输入框）。
  final int value;
  final ValueChanged<int?> onChanged;

  @override
  State<_OverlayNumberTextField> createState() => _OverlayNumberTextFieldState();
}

class _OverlayNumberTextFieldState extends State<_OverlayNumberTextField> {
  late final TextEditingController _controller;
  bool _showSuccess = false;
  bool _hovering = false;
  Timer? _successTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(_OverlayNumberTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _successTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    widget.onChanged(int.tryParse(_controller.text.trim()));
    setState(() => _showSuccess = true);
    _successTimer?.cancel();
    _successTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showSuccess = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: SizedBox(
        width: 100,
        child: TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            filled: true,
            fillColor: cs.surfaceContainerHigh,
            isDense: true,
            hintStyle: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: kSpacingSmall),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: cs.outlineVariant,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: cs.primary),
            ),
            suffixIconConstraints: const BoxConstraints.tightFor(width: 32, height: 32),
            suffixIcon: SizedBox(
              width: 32,
              height: 32,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _showSuccess
                    ? Center(
                        key: const ValueKey('ok'),
                        child: Icon(
                          Icons.check_rounded,
                          size: kIconSizeMedium,
                          color: Colors.green.shade700,
                        ),
                      )
                    : _hovering
                    ? IconButton(
                        key: const ValueKey('go'),
                        padding: EdgeInsets.zero,
                        tooltip: '提交',
                        style: IconButton.styleFrom(
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                        onPressed: _submit,
                        icon: Icon(
                          Icons.task_alt_rounded,
                          size: kIconSizeMedium,
                          color: cs.onSurfaceVariant,
                        ),
                      )
                    : const SizedBox(key: ValueKey('empty')),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OverlayConfigItem extends OverlayMenuItem {
  OverlayConfigItem({
    super.key,
    required super.height,
    super.onTabSelected,
    required String title,
    String? description,
    required Widget trailing,
  }) : super(
         child: _OverlayConfigItemContent(
           title: title,
           description: description,
           trailing: trailing,
         ),
       );

  factory OverlayConfigItem.number({
    Key? key,
    required double height,
    required String title,
    String? description,
    required int value,
    required ValueChanged<int?> onChanged,
  }) {
    return OverlayConfigItem(
      key: key,
      height: height,
      title: title,
      description: description,
      trailing: _OverlayNumberTextField(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  factory OverlayConfigItem.checkbox({
    Key? key,
    required double height,
    required String title,
    String? description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return OverlayConfigItem(
      key: key,
      height: height,
      title: title,
      description: description,
      trailing: SizedBox(
        width: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: Checkbox(
                value: value,
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverlayConfigItemContent extends StatelessWidget {
  const _OverlayConfigItemContent({
    required this.title,
    this.description,
    required this.trailing,
  });

  final String title;
  final String? description;
  final Widget trailing;

  bool get _hasDescription => description != null && description!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSpacingSmall, horizontal: kSpacingMedium),
      child: Row(
        crossAxisAlignment: _hasDescription ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title),
                if (_hasDescription) ...[
                  const SizedBox(height: kSpacingTiny),
                  Text(
                    description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: kSpacingTiny),
          trailing,
        ],
      ),
    );
  }
}

class OverlayMenuHeader extends StatelessWidget {
  final double height;
  final Widget child;

  const OverlayMenuHeader({super.key, required this.height, required this.child});

  factory OverlayMenuHeader.tile({
    Key? key,
    double height = 74,
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return OverlayMenuHeader(
      key: key,
      height: height,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final cs = theme.colorScheme;
          final textTheme = theme.textTheme;
          return Padding(
            padding: const EdgeInsets.fromLTRB(kSpacingMedium, kSpacingMedium, kSpacingSmall, kSpacingSmall),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(kSpacingSmall),
                    child: Icon(
                      icon,
                      size: 20,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: kSpacingSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: textTheme.titleMedium),
                      if (subtitle != null && subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          style: textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height, child: child);
  }
}

class OverlayMenuFooter extends StatefulWidget {
  final double height;
  final Widget child;
  final VoidCallback? onTap;

  const OverlayMenuFooter({super.key, required this.height, required this.child, this.onTap});

  @override
  State<OverlayMenuFooter> createState() => _OverlayMenuFooterState();
}

class _OverlayMenuFooterState extends State<OverlayMenuFooter> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final base = SizedBox(height: widget.height, child: widget.child);

    const radius = BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12));
    final hoverColor = Theme.of(context).colorScheme.surfaceContainerLow; // 菜单footer鼠标移入的颜色

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(color: _hovering ? hoverColor : null, borderRadius: radius),
          child: base,
        ),
      ),
    );
  }
}
