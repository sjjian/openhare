import 'package:client/l10n/app_localizations.dart';
import 'package:client/models/sessions.dart';
import 'package:client/screens/sessions/session_operation_bar.dart';
import 'package:client/services/sessions/session_controller.dart';
import 'package:client/services/sessions/session_drawer.dart';
import 'package:client/services/sessions/session_metadata.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:client/widgets/button.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/data_tree.dart';
import 'package:client/widgets/data_type_icon.dart';
import 'package:client/widgets/split_view.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/widgets/loading.dart';
import 'package:client/widgets/menu.dart';
import 'package:hugeicons/hugeicons.dart';

class SessionDrawerMetadata extends ConsumerStatefulWidget {
  const SessionDrawerMetadata({super.key});

  @override
  ConsumerState<SessionDrawerMetadata> createState() => _SessionDrawerMetadataState();
}

class _SessionDrawerMetadataState extends ConsumerState<SessionDrawerMetadata> {
  bool _refreshing = false;

  static const double _colRowHeight = 20;

  Widget loadingPage() {
    return const Align(
      alignment: Alignment.center,
      child: Loading.large(),
    );
  }

  Widget errorPage(BuildContext context, String error) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.error,
          size: 48, // todo: 使用统一图标大小
          color: Theme.of(context).colorScheme.errorContainer,
        ),
        const SizedBox(height: kSpacingSmall),
        Text(error),
        RectangleIconButton.medium(
          icon: Icons.refresh,
          onPressed: () {
            ref.read(selectedSessionMetadataProvider.notifier).refreshMetadata();
          },
        ),
      ],
    );
  }

  List<MetaDataNode> _relationItems(DataValueNode node) {
    return ref.read(selectedSessionMetadataProvider.notifier).findCachedRelation(node)?.items ??
        const [];
  }

  bool _showsDetailList(DataValueNode node) {
    return node.metaType == MetaType.table;
  }

  List<MetaDataNode> _detailColumnsOf(DataValueNode node) {
    if (!_showsDetailList(node)) return const [];
    return [
      for (final n in _relationItems(node))
        if (n.type == MetaType.column) n,
    ];
  }

  bool get _supportsSelectSql => ConnectionWrapper.supportsSelectSqlOf(_dbType);

  bool get _supportsInsertSql => ConnectionWrapper.supportsInsertSqlOf(_dbType);

  Future<void> _viewData(BuildContext context, DataValueNode node) async {
    if (!_supportsSelectSql) return;
    final session = ref.read(selectedSessionProvider);
    if (session == null) return;
    final bar = ref.read(sessionOpBarProvider);
    if (bar == null || !SQLConnectState.isIdle(bar.state)) {
      if (bar != null) {
        sessionOpBarConnectDialog(context, ref, bar);
      }
      return;
    }
    await ref.read(selectedSessionMetadataProvider.notifier).viewRelationData(session.sessionId, node);
  }

  Future<void> _copyInsertTemplate(DataValueNode node) async {
    final sql = ref.read(selectedSessionMetadataProvider.notifier).buildInsertSql(node);
    if (sql == null) return;
    await _copyText(sql);
  }

  DatabaseType get _dbType =>
      ref.read(selectedSessionDetailProvider)?.dbType ?? DatabaseType.mysql;

  Future<void> _copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  Future<void> _refresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      await ref.read(selectedSessionMetadataProvider.notifier).refreshMetadata();
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _useDatabaseRef(DatabaseRef schemaRef) async {
    final session = ref.read(selectedSessionProvider);
    if (session == null) return;
    await ref.read(sessionsServicesProvider.notifier).setSessionSchema(session.sessionId, schemaRef);
  }

  /// 打开右侧 AI 抽屉，并把表以 @mention 注入聊天输入框。
  void _pinToAi(DataValueNode node) {
    final session = ref.read(selectedSessionProvider);
    if (session == null) return;

    final label = switch (node.metaType) {
      MetaType.table => node.simpleName,
      _ => null,
    };
    if (label == null || label.isEmpty) return;

    final drawer = ref.read(sessionDrawerServicesProvider(session.sessionId).notifier);
    drawer.showRightPage();
    drawer.showChat();

    final chatInput = ref.read(selectedSessionControllerProvider).chatInputController;
    chatInput.appendMention(label);
  }

  Future<void> _onSelected(DataNode node) async {
    if (node is! DataValueNode) return;
    ref.read(selectedMetadataTreeNodeProvider.notifier).select(node);
  }

  Widget _toolbar(BuildContext context, SessionController sessionController) {
    final l10n = AppLocalizations.of(context)!;
    final search = sessionController.metadataSearchController;
    return Padding(
      padding: const EdgeInsets.only(bottom: kSpacingTiny),
      child: Row(
        children: [
          Expanded(
            child: SearchBarTheme(
              data: SearchBarThemeData(
                textStyle: WidgetStatePropertyAll(Theme.of(context).textTheme.bodySmall),
                backgroundColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.surfaceContainerLowest,
                ),
                elevation: const WidgetStatePropertyAll(0),
                constraints: const BoxConstraints(minHeight: 28),
              ),
              child: SearchBar(
                // todo: 抽取搜索框, 哪里都一样重复的代码
                side: WidgetStatePropertyAll(
                  BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                controller: search,
                onChanged: (_) => setState(() {}),
                trailing: [
                  if (search.text.isNotEmpty)
                    RectangleIconButton.tiny(
                      icon: Icons.close,
                      tooltip: l10n.metadata_tree_clear_search,
                      onPressed: () {
                        search.clear();
                        setState(() {});
                      },
                    )
                  else
                    const Icon(Icons.search, size: kIconSizeSmall),
                ],
              ),
            ),
          ),
          const SizedBox(width: kSpacingTiny),
          if (_refreshing)
            const SizedBox(
              width: kIconButtonSizeSmall,
              height: kIconButtonSizeSmall,
              child: Padding(
                padding: EdgeInsets.all(6),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            RectangleIconButton.small(
              tooltip: l10n.button_tooltip_refresh_metadata,
              icon: Icons.refresh,
              onPressed: _refresh,
            ),
        ],
      ),
    );
  }

  Widget _iconAction({
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return RectangleIconButton.small(
      tooltip: tooltip,
      icon: icon,
      onPressed: onPressed,
    );
  }

  Widget _moreMenu(
    BuildContext context,
    List<({String value, String label})> items,
    void Function(String) onSelected,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return OverlayMenu(
      spacing: kSpacingTiny,
      maxWidth: 220,
      header: const OverlayMenuHeader(height: 10, child: SizedBox.shrink()),
      footer: const OverlayMenuFooter(height: 10, child: SizedBox.shrink()),
      tabs: [
        for (final item in items)
          OverlayMenuItem(
            height: 28,
            onTabSelected: () => onSelected(item.value),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
              child: Row(
                children: [
                  Icon(
                    Icons.copy_outlined,
                    size: kIconSizeSmall,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: kSpacingTiny),
                  Expanded(
                    child: Text(item.label, style: Theme.of(context).textTheme.bodySmall),
                  ),
                ],
              ),
            ),
          ),
      ],
      child: RectangleIconButton.small(
        tooltip: l10n.metadata_tree_action_more,
        icon: Icons.more_vert,
        onPressed: null,
      ),
    );
  }

  Widget _actionToolbar(BuildContext context, DataValueNode node) {
    final l10n = AppLocalizations.of(context)!;
    final leading = <Widget>[];
    Widget? more;

    void addCopy() {
      leading.add(
        _iconAction(
          tooltip: l10n.metadata_tree_action_copy,
          icon: Icons.copy_outlined,
          onPressed: () => _copyText(node.qualifiedName),
        ),
      );
    }

    void addPinAi() {
      leading.add(
        _iconAction(
          tooltip: l10n.metadata_tree_action_pin_ai,
          icon: HugeIcons.strokeRoundedArtificialIntelligence01,
          onPressed: () => _pinToAi(node),
        ),
      );
    }

    switch (node.metaType) {
      case MetaType.table:
        if (_supportsSelectSql) {
          leading.add(
            _iconAction(
              tooltip: l10n.metadata_tree_action_view_data,
              icon: Icons.table_rows_outlined,
              onPressed: () => _viewData(context, node),
            ),
          );
        }
        addCopy();
        addPinAi();
        more = _moreMenu(
          context,
          [
            if (_supportsInsertSql)
              (value: 'insert', label: l10n.metadata_tree_action_insert_tpl),
            (value: 'copy_simple', label: l10n.metadata_tree_copy_name),
            (value: 'copy_qualified', label: l10n.metadata_tree_copy_qualified),
          ],
          (v) {
            switch (v) {
              case 'insert':
                _copyInsertTemplate(node);
              case 'copy_simple':
                _copyText(node.simpleName);
              case 'copy_qualified':
                _copyText(node.qualifiedName);
            }
          },
        );
      case MetaType.schema:
        leading.add(
          _iconAction(
            tooltip: l10n.metadata_tree_action_use,
            icon: Icons.check,
            onPressed: () {
              final db = node.database;
              if (db != null && db.isNotEmpty) {
                _useDatabaseRef(SchemaMode(database: db, schema: node.name));
              }
            },
          ),
        );
        addCopy();
        leading.add(
          _iconAction(
            tooltip: l10n.button_tooltip_refresh_metadata,
            icon: Icons.refresh,
            onPressed: _refresh,
          ),
        );
      case MetaType.database:
        leading.add(
          _iconAction(
            tooltip: l10n.metadata_tree_action_use,
            icon: Icons.check,
            onPressed: () => _useDatabaseRef(DatabaseMode(database: node.name)),
          ),
        );
        addCopy();
        leading.add(
          _iconAction(
            tooltip: l10n.button_tooltip_refresh_metadata,
            icon: Icons.refresh,
            onPressed: _refresh,
          ),
        );
      case MetaType.column:
      case MetaType.instance:
        addCopy();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
      child: Row(
        children: [
          ...leading,
          const Spacer(),
          if (more != null) more,
        ],
      ),
    );
  }

  Widget _metaTypeIcon(BuildContext context, MetaType type) {
    final scheme = Theme.of(context).colorScheme;
    final (icon, color) = switch (type) {
      MetaType.database => (HugeIcons.strokeRoundedDatabase, scheme.primary),
      MetaType.schema => (HugeIcons.strokeRoundedFolder02, scheme.primary),
      MetaType.table => (HugeIcons.strokeRoundedTable, scheme.primary),
      _ => (HugeIcons.strokeRoundedTable, scheme.onSurfaceVariant),
    };
    return HugeIcon(size: kIconSizeTiny, icon: icon, color: color);
  }

  Widget _pathCrumb(BuildContext context, MetaType type, String name) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _metaTypeIcon(context, type),
        const SizedBox(width: 3),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _pathFooter(BuildContext context, DataValueNode node) {
    final crumbs = <Widget>[];
    void add(MetaType type, String name) {
      if (crumbs.isNotEmpty) {
        crumbs.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '/',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ),
        );
      }
      crumbs.add(_pathCrumb(context, type, name));
    }

    if (node.metaType != MetaType.database &&
        node.metaType != MetaType.instance &&
        node.database != null &&
        node.database!.isNotEmpty) {
      add(MetaType.database, node.database!);
    }
    if (node.metaType != MetaType.schema && node.schema != null && node.schema!.isNotEmpty) {
      add(MetaType.schema, node.schema!);
    }
    add(node.metaType, node.name);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: crumbs),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text, {int? count}) {
    final label = count == null ? text : '$text [$count]';
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _columnRow(BuildContext context, MetaDataNode col) {
    return _ColumnHoverRow(
      name: col.value,
      typeLabel: dataTypeLabel(col),
      dataType: col.getProp<DataType>(MetaDataPropType.dataType) ?? DataType.char,
      onCopy: () => _copyText(col.value),
    );
  }

  Widget _detailPanel(BuildContext context, DataValueNode node) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final showColumns = _showsDetailList(node);
    final detailColumns = _detailColumnsOf(node);

    return ColoredBox(
      color: scheme.surfaceContainerLowest, // 与全局背景/树一致
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _actionToolbar(context, node),
          if (showColumns) ...[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 8),
                children: [
                  _sectionLabel(
                    context,
                    l10n.metadata_tree_column,
                    count: detailColumns.length,
                  ),
                  if (detailColumns.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
                      child: Text(
                        l10n.metadata_scope_empty,
                        style: textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    )
                  else
                    for (final col in detailColumns)
                      SizedBox(height: _colRowHeight, child: _columnRow(context, col)),
                ],
              ),
            ),
          ] else
            const Spacer(),
          _pathFooter(context, node),
        ],
      ),
    );
  }

  Widget _treePane(
    BuildContext context,
    DataTreeController controller,
    SessionController sessionController,
    DataNode? selected,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final filterQuery = sessionController.metadataSearchController.text;
    final hasFilter = filterQuery.trim().isNotEmpty;
    final roots = controller.roots;
    final anyMatch = !hasFilter || roots.any((n) => n.matchesFilter(filterQuery));

    if (!anyMatch) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.metadata_tree_no_match,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: kSpacingTiny),
            TextButton(
              onPressed: () {
                sessionController.metadataSearchController.clear();
                setState(() {});
              },
              child: Text(l10n.metadata_tree_clear_search),
            ),
          ],
        ),
      );
    }

    return DataTree(
      controller: controller,
      scrollController: sessionController.metadataTreeScrollController,
      selectedNode: selected,
      filterQuery: filterQuery,
      onSelected: _onSelected,
    );
  }

  Widget bodyPage(
    BuildContext context,
    DataTreeController controller,
    SessionController sessionController,
    DataNode? selected,
  ) {
    final selectedValue = selected is DataValueNode ? selected : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _toolbar(context, sessionController),
        Expanded(
          child: SplitView(
            controller: sessionController.metadataDetailSplitViewCtrl,
            axis: Axis.vertical,
            showSecond: selectedValue != null,
            first: _treePane(
              context,
              controller,
              sessionController,
              selected,
            ),
            second: selectedValue == null
                ? const SizedBox.shrink()
                : _detailPanel(context, selectedValue),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(selectedSessionMetadataTreeProvider);
    final sessionController = ref.watch(selectedSessionControllerProvider);
    final selected = ref.watch(selectedMetadataTreeNodeProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(kSpacingTiny, kSpacingTiny, kSpacingTiny - 2, kSpacingTiny),
      child: model.when(
        skipLoadingOnReload: true,
        skipLoadingOnRefresh: true,
        data: (value) => bodyPage(
          context,
          value.metadataTreeCtrl,
          sessionController,
          selected,
        ),
        error: (error, trace) => errorPage(context, error.toString()),
        loading: () => loadingPage(),
      ),
    );
  }
}

class _ColumnHoverRow extends StatefulWidget {
  final String name;
  final String typeLabel;
  final DataType dataType;
  final VoidCallback onCopy;

  const _ColumnHoverRow({
    required this.name,
    required this.typeLabel,
    required this.dataType,
    required this.onCopy,
  });

  @override
  State<_ColumnHoverRow> createState() => _ColumnHoverRowState();
}

class _ColumnHoverRowState extends State<_ColumnHoverRow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Tooltip(
              message: widget.typeLabel,
              child: DataTypeIcon(type: widget.dataType, size: kIconSizeSmall),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                widget.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(height: 1.2),
              ),
            ),
            SizedBox(
              width: kIconSizeTiny,
              child: _hovering
                  ? GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onCopy,
                      child: Tooltip(
                        message: AppLocalizations.of(context)!.metadata_tree_copy_column,
                        child: Icon(
                          Icons.copy_outlined,
                          size: kIconSizeTiny,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
