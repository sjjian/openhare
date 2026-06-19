import 'package:client/widgets/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// 与设置页导航 Tab 一致：文字无 padding，下划线与标签等宽对齐。
class UnderlineNavTab extends StatefulWidget {
  const UnderlineNavTab({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.labelColor,
    this.underlineColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? labelColor;
  final Color? underlineColor;

  @override
  State<UnderlineNavTab> createState() => _UnderlineNavTabState();
}

class _UnderlineNavTabState extends State<UnderlineNavTab> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final muted = theme.colorScheme.onSurfaceVariant;

    final Color labelColor;
    if (widget.labelColor != null) {
      labelColor = widget.labelColor!;
    } else if (widget.selected) {
      labelColor = _hovering ? theme.colorScheme.onSurface : primary;
    } else {
      labelColor = _hovering ? primary : muted;
    }

    final underlineColor = widget.underlineColor ?? (widget.selected ? primary : Colors.transparent);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: labelColor,
                  fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              const SizedBox(height: kSpacingTiny),
              SizedBox(
                height: 2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: underlineColor,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnchorTabSection {
  const AnchorTabSection({
    required this.id,
    required this.label,
    required this.children,
    this.description,
    this.labelColor,
  });

  final String id;
  final String label;
  final String? description;
  final List<Widget> children;
  final Color? labelColor;
}

/// Tab 锚点 + 纵向分区滚动联动布局。
class AnchorTabScrollLayout extends StatefulWidget {
  const AnchorTabScrollLayout({
    super.key,
    required this.sections,
    this.contentPadding = const EdgeInsets.only(right: kSpacingMedium),
  });

  final List<AnchorTabSection> sections;
  final EdgeInsetsGeometry contentPadding;

  @override
  State<AnchorTabScrollLayout> createState() => _AnchorTabScrollLayoutState();
}

class _AnchorTabScrollLayoutState extends State<AnchorTabScrollLayout> {
  static const _scrollActivationSlop = 12.0;

  String? _selectedSectionId;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {};
  bool _isProgrammaticScroll = false;

  @override
  void initState() {
    super.initState();
    final sections = widget.sections;
    _selectedSectionId = sections.isNotEmpty ? sections.first.id : null;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  double? _sectionScrollOffset(BuildContext context) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) {
      return null;
    }
    final viewport = RenderAbstractViewport.maybeOf(box);
    return viewport?.getOffsetToReveal(box, 0).offset;
  }

  void _onScroll() {
    if (_isProgrammaticScroll || widget.sections.isEmpty) {
      return;
    }
    final position = _scrollController.offset + _scrollActivationSlop;
    String? active;
    for (final section in widget.sections) {
      final ctx = _sectionKeys[section.id]?.currentContext;
      if (ctx == null) {
        continue;
      }
      final offset = _sectionScrollOffset(ctx);
      if (offset != null && offset <= position) {
        active = section.id;
      }
    }
    active ??= widget.sections.first.id;
    if (active != _selectedSectionId) {
      setState(() => _selectedSectionId = active);
    }
  }

  Future<void> _onSelectSection(String sectionId) async {
    setState(() => _selectedSectionId = sectionId);
    final ctx = _sectionKeys[sectionId]?.currentContext;
    if (ctx == null) {
      return;
    }
    _isProgrammaticScroll = true;
    try {
      await Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        alignment: 0,
      );
    } finally {
      // ensureVisible 会触发 scroll listener，延迟释放以免 Tab 高亮抖动。
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        _isProgrammaticScroll = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sections = widget.sections;
    if (sections.isEmpty) {
      return const SizedBox.shrink();
    }
    for (final section in sections) {
      _sectionKeys.putIfAbsent(section.id, GlobalKey.new);
    }

    final selected = _selectedSectionId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < sections.length; i++) ...[
                if (i > 0) const SizedBox(width: kSpacingMedium),
                UnderlineNavTab(
                  label: sections[i].label,
                  selected: sections[i].id == selected,
                  labelColor: sections[i].labelColor,
                  onTap: () => _onSelectSection(sections[i].id),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: kSpacingSmall),
        Expanded(
          child: Scrollbar(
            controller: _scrollController,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: widget.contentPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < sections.length; i++) ...[
                    if (i > 0) ...[
                      const SizedBox(height: kSpacingMedium),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      const SizedBox(height: kSpacingMedium),
                    ],
                    _AnchorTabSectionBody(
                      key: _sectionKeys[sections[i].id],
                      section: sections[i],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnchorTabSectionBody extends StatelessWidget {
  const _AnchorTabSectionBody({
    super.key,
    required this.section,
  });

  final AnchorTabSection section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final description = section.description;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (description != null && description.isNotEmpty) ...[
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: kSpacingMedium),
        ],
        ...section.children,
      ],
    );
  }
}
