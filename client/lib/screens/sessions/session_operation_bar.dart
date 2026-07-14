import 'package:client/models/instances.dart';
import 'package:client/models/sessions.dart';
import 'package:client/screens/settings/settings.dart';
import 'package:client/screens/tasks/export_data.dart';
import 'package:client/screens/tasks/task_overview.dart';
import 'package:client/services/sessions/session_drawer.dart';
import 'package:client/services/sessions/session_sql_result.dart';
import 'package:client/services/sessions/session_conn.dart';
import 'package:client/services/sessions/session_metadata.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:client/services/settings/settings.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/menu.dart';
import 'package:client/widgets/dialog.dart';
import 'package:client/widgets/button.dart';
import 'package:client/widgets/divider.dart';
import 'package:client/widgets/loading.dart';
import 'package:client/widgets/sql_highlight.dart';
import 'package:client/utils/time_format.dart';
import 'package:client/widgets/tooltip.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sql_parser/parser.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sql_editor/re_editor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:client/l10n/app_localizations.dart';

/// 与 [SessionOpBar.getQuery] 相同逻辑，供右键菜单等复用。
String sessionOpBarGetQuery(CodeLineEditingController codeController, SessionOpBarModel model) {
  var content = codeController.text.toString();
  List<SQLChunk> querys = splitSQL(
    model.dbType?.dialectType ?? DialectType.mysql,
    content,
    skipWhitespace: true,
    skipComment: true,
  );
  CodeLineSelection s = codeController.selection;
  String query;
  if (!s.isCollapsed) {
    query = codeController.selectedText;
  } else {
    Pos cursor = Pos(0, s.baseIndex + 1, s.baseOffset);
    SQLChunk chunk = querys.firstWhere((chunk) {
      if (cursor.between(chunk.start, chunk.end)) {
        return true;
      }
      return false;
    }, orElse: () => SQLChunk.empty());
    query = chunk.content;
  }
  return query.trim();
}

void sessionOpBarUnhealthReconnectDialog(BuildContext context, WidgetRef ref, SessionOpBarModel model) {
  return doActionDialog(
    context,
    AppLocalizations.of(context)!.tip_reconnect,
    AppLocalizations.of(context)!.tip_reconnect_desc,
    () async {
      await ref.read(sessionsServicesProvider.notifier).disconnectSession(model.sessionId);
      await ref.read(sessionsServicesProvider.notifier).connectSession(model.sessionId);
    },
    icon: Icon(Icons.link_rounded, color: Theme.of(context).colorScheme.primary),
  );
}

void sessionOpBarConnectDialog(BuildContext context, WidgetRef ref, SessionOpBarModel model) {
  if (SQLConnectState.isBusy(model.state)) {
    return doActionDialog(
      context,
      AppLocalizations.of(context)!.tip_connect_busy,
      AppLocalizations.of(context)!.tip_connect_busy_desc,
      () {
        // do nothing, just close the dialog
      },
      icon: Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error),
    );
  }
  if (SQLConnectState.isUnhealthy(model.state)) {
    return sessionOpBarUnhealthReconnectDialog(context, ref, model);
  }

  return doActionDialog(
    context,
    AppLocalizations.of(context)!.tip_connect,
    AppLocalizations.of(context)!.tip_connect_desc,
    () async {
      await ref.read(sessionsServicesProvider.notifier).connectSession(model.sessionId);
    },
    icon: Icon(Icons.link_rounded, color: Theme.of(context).colorScheme.primary),
  );
}

void sessionOpBarRunExecute({
  required BuildContext context,
  required WidgetRef ref,
  required SessionOpBarModel model,
  required CodeLineEditingController codeController,
}) {
  if (!SQLConnectState.isIdle(model.state)) {
    sessionOpBarConnectDialog(context, ref, model);
    return;
  }
  String query = sessionOpBarGetQuery(codeController, model);
  if (query.isNotEmpty) {
    final df = parser(model.dbType?.dialectType ?? DialectType.mysql, query);
    if (df.isDangerousSQL && model.config.enableQueryCheck) {
      queryDangerousSQLDialog(
        context,
        ref,
        model.sessionId,
        model.config,
        model.dbType?.dialectType ?? DialectType.mysql,
        query,
      );
    } else {
      ref.read(sQLResultsServicesProvider.notifier).query(model.sessionId, query);
    }
  }
}

void sessionOpBarRunExecuteAdd({
  required BuildContext context,
  required WidgetRef ref,
  required SessionOpBarModel model,
  required CodeLineEditingController codeController,
}) {
  if (!SQLConnectState.isIdle(model.state)) {
    sessionOpBarConnectDialog(context, ref, model);
    return;
  }
  String query = sessionOpBarGetQuery(codeController, model);
  if (query.isNotEmpty) {
    final df = parser(model.dbType?.dialectType ?? DialectType.mysql, query);
    if (df.isDangerousSQL && model.config.enableQueryCheck) {
      queryDangerousSQLDialog(
        context,
        ref,
        model.sessionId,
        model.config,
        model.dbType?.dialectType ?? DialectType.mysql,
        query,
      );
    } else {
      ref.read(sQLResultsServicesProvider.notifier).queryAddResult(model.sessionId, query);
    }
  }
}

void sessionOpBarExplain({
  required BuildContext context,
  required WidgetRef ref,
  required SessionOpBarModel model,
  required CodeLineEditingController codeController,
}) {
  if (!SQLConnectState.isIdle(model.state)) {
    sessionOpBarConnectDialog(context, ref, model);
    return;
  }
  String query = sessionOpBarGetQuery(codeController, model);
  if (query.isNotEmpty) {
    ref.read(sQLResultsServicesProvider.notifier).explainAddResult(model.sessionId, query);
  }
}

bool sessionOpBarSupportsExplain(WidgetRef ref, SessionOpBarModel model) {
  final connId = model.connId;
  if (connId == null) {
    return false;
  }
  return ref.read(sessionConnsServicesProvider.notifier).supportsExplain(connId);
}

void sessionOpBarExportDownload({
  required BuildContext context,
  required SessionOpBarModel model,
  required CodeLineEditingController codeController,
}) {
  showExportDataDialog(
    context,
    instanceId: model.instanceId!,
    schema: model.currentSchema,
    query: sessionOpBarGetQuery(codeController, model),
    dbType: model.dbType ?? DatabaseType.mysql,
  );
}

class SessionOpBar extends ConsumerWidget {
  final CodeLineEditingController codeController;
  final double height;

  const SessionOpBar({
    super.key,
    required this.codeController,
    this.height = 36,
  });

  String getQuery(SessionOpBarModel model) => sessionOpBarGetQuery(codeController, model);

  void disconnectDialog(BuildContext context, WidgetRef ref, SessionOpBarModel model) {
    // 如果正在执行语句，则提示连接繁忙，请稍后执行
    if (SQLConnectState.isBusy(model.state)) {
      return doActionDialog(
        context,
        AppLocalizations.of(context)!.tip_connect_busy,
        AppLocalizations.of(context)!.tip_connect_busy_desc,
        () {
          // do nothing, just close the dialog
        },
        icon: Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error),
      );
    }
    return doActionDialog(
      context,
      AppLocalizations.of(context)!.tip_disconnect,
      AppLocalizations.of(context)!.tip_disconnect_desc,
      () async {
        await ref.read(sessionsServicesProvider.notifier).disconnectSession(model.sessionId);
      },
      icon: Icon(Icons.link_off_rounded, color: Theme.of(context).colorScheme.error),
    );
  }

  void unhealthReconnectDialog(BuildContext context, WidgetRef ref, SessionOpBarModel model) {
    sessionOpBarUnhealthReconnectDialog(context, ref, model);
  }

  void connectDialog(BuildContext context, WidgetRef ref, SessionOpBarModel model) {
    sessionOpBarConnectDialog(context, ref, model);
  }

  Widget connectWidget(BuildContext context, WidgetRef ref, SessionOpBarModel model) {
    if (SQLConnectState.isDisconnected(model.state)) {
      return RectangleIconButton.medium(
        tooltip: AppLocalizations.of(context)!.button_tooltip_connect,
        icon: Icons.link_rounded,
        iconColor: Theme.of(context).colorScheme.primary, // 连接数据库按钮颜色
        onPressed: () async {
          await ref.read(sessionsServicesProvider.notifier).connectSession(model.sessionId);
        },
      );
    } else if (SQLConnectState.isUnhealthy(model.state)) {
      return RectangleIconButton.medium(
        tooltip: AppLocalizations.of(context)!.button_tooltip_connect,
        icon: Icons.link_rounded,
        iconColor: Theme.of(context).colorScheme.primary, // 连接数据库按钮颜色
        onPressed: () {
          unhealthReconnectDialog(context, ref, model);
        },
      );
    } else if (SQLConnectState.isConnecting(model.state)) {
      return const Loading.medium();
    } else {
      // disconnect
      return RectangleIconButton.medium(
        tooltip: AppLocalizations.of(context)!.button_tooltip_disconnect,
        icon: Icons.link_off_rounded,
        iconColor: Theme.of(context).colorScheme.primary, // 连接数据库按钮颜色
        onPressed: () async {
          disconnectDialog(context, ref, model);
        },
      );
    }
  }

  Widget executeWidget(BuildContext context, WidgetRef ref, SessionOpBarModel model) {
    return RectangleIconButton.medium(
      tooltip: tooltipWithShortcutDisplay(
        AppLocalizations.of(context)!.button_tooltip_run_sql,
        ref.read(systemSettingServiceProvider.notifier).getShortcutModel(KeyboardShortcut.sqlExecute).toDisplayString(),
      ),
      icon: Icons.play_circle_outline_rounded,
      iconColor: SQLConnectState.isIdle(model.state) ? Colors.green : Colors.grey,
      onPressed: () => sessionOpBarRunExecute(
        context: context,
        ref: ref,
        model: model,
        codeController: codeController,
      ),
    );
  }

  Widget executeAddWidget(BuildContext context, WidgetRef ref, SessionOpBarModel model) {
    return Stack(
      alignment: Alignment.center,
      children: [
        RectangleIconButton.medium(
          tooltip: tooltipWithShortcutDisplay(
            AppLocalizations.of(context)!.button_tooltip_run_sql_new_tab,
            ref
                .read(systemSettingServiceProvider.notifier)
                .getShortcutModel(KeyboardShortcut.sqlExecuteAdd)
                .toDisplayString(),
          ),
          icon: Icons.not_started_outlined,
          iconColor: SQLConnectState.isIdle(model.state) ? Colors.green : Colors.grey,
          onPressed: () => sessionOpBarRunExecuteAdd(
            context: context,
            ref: ref,
            model: model,
            codeController: codeController,
          ),
        ),
      ],
    );
  }

  Widget explainWidget(BuildContext context, WidgetRef ref, SessionOpBarModel model) {
    return RectangleIconButton.medium(
      tooltip: tooltipWithShortcutDisplay(
        AppLocalizations.of(context)!.button_tooltip_explain_sql,
        ref.read(systemSettingServiceProvider.notifier).getShortcutModel(KeyboardShortcut.sqlExplain).toDisplayString(),
      ),
      icon: Icons.poll_outlined,
      iconColor: SQLConnectState.isIdle(model.state) ? const Color.fromARGB(255, 241, 192, 84) : Colors.grey,
      onPressed: () => sessionOpBarExplain(
        context: context,
        ref: ref,
        model: model,
        codeController: codeController,
      ),
    );
  }

  Widget exportDataWidget(BuildContext context, WidgetRef ref, SessionOpBarModel model) {
    return RectangleIconButton.medium(
      tooltip: tooltipWithShortcutDisplay(
        AppLocalizations.of(context)!.button_tooltip_sql_result_download,
        ref.read(systemSettingServiceProvider.notifier).getShortcutModel(KeyboardShortcut.sqlExport).toDisplayString(),
      ),
      icon: Icons.file_download_sharp,
      iconColor: Colors.green,
      verticalOffset: 1,
      onPressed: () => sessionOpBarExportDownload(
        context: context,
        model: model,
        codeController: codeController,
      ),
    );
  }

  Widget taskOverviewWidget(BuildContext context, WidgetRef ref, SessionOpBarModel model) {
    final l10n = AppLocalizations.of(context)!;

    final childWidget = model.runningTaskCount > 0
        ? const Loading.medium()
        : RectangleIconButton.medium(
            tooltip: l10n.scheduled_task,
            icon: Icons.schedule,
            onPressed: null,
          );

    return TaskOverviewMenu(
      child: childWidget,
    );
  }

  String saveTooltip(BuildContext context, WidgetRef ref, SessionOpBarModel model) {
    final description = tooltipWithShortcutDisplay(
      AppLocalizations.of(context)!.button_tooltip_save,
      ref
          .read(systemSettingServiceProvider.notifier)
          .getShortcutModel(KeyboardShortcut.sqlEditorSave)
          .toDisplayString(),
    );
    return '$description\n${AppLocalizations.of(context)!.button_tooltip_save_last_saved(
      model.codeSaveTime?.formatDateTime(context) ?? "-",
    )}';
  }

  Widget saveWidget(BuildContext context, WidgetRef ref, SessionOpBarModel model) {
    return RectangleIconButton.medium(
      tooltip: saveTooltip(context, ref, model),
      icon: Icons.save,
      onPressed: () {
        ref.read(sessionsServicesProvider.notifier).saveCode(model.sessionId);
      },
    );
  }

  Widget divider(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: kSpacingTiny),
      child: PixelVerticalDivider(indent: 10, endIndent: 10),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SessionOpBarModel? model = ref.watch(sessionOpBarProvider);
    final sessionDrawer = ref.watch(sessionDrawerProvider);
    if (model == null) {
      return Container(
        constraints: BoxConstraints(maxHeight: height),
        child: const Spacer(),
      );
    }

    return Container(
      constraints: BoxConstraints(maxHeight: height),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 2), // 将分割线与code editor linenumber 的分割线对齐
          RectangleIconButton(
            size: kIconButtonSizeMedium,
            iconSize: kIconSizeMedium - 2, // 将icon调小点，与其他icon视觉上大小类似
            padding: 4,
            tooltip: AppLocalizations.of(context)!.button_tooltip_metadata_tree,
            icon: Icons.account_tree_outlined,
            backgroundColor: sessionDrawer.isMetadataTreeOpen
                ? Theme.of(context)
                      .colorScheme
                      .primaryContainer // 元数据tree页面 icon 背景色
                : null,
            onPressed: () {
              ref.read(sessionDrawerServicesProvider(sessionDrawer.sessionId).notifier).toggleMetadataTree();
            },
          ),
          divider(context),
          // schema list
          SchemaBar(
            instanceId: model.instanceId,
            connId: model.connId,
            disable: !SQLConnectState.isIdle(model.state),
            currentSchema: model.currentSchema,
          ),
          // connect
          connectWidget(context, ref, model),
          // execute
          executeWidget(context, ref, model),
          executeAddWidget(context, ref, model),
          if (sessionOpBarSupportsExplain(ref, model)) explainWidget(context, ref, model),
          exportDataWidget(context, ref, model),
          taskOverviewWidget(context, ref, model),
          SessionConfigBar(model: model),
          saveWidget(context, ref, model),
          // 快捷键查看
          RectangleIconButton.medium(
            tooltip: AppLocalizations.of(context)!.settings_shortcut_all_dialog_title,
            icon: Icons.keyboard_rounded,
            onPressed: () => showSqlEditorShortcutsDialog(context, ref),
          ),
          const Expanded(child: SessionDrawerBar()),
        ],
      ),
    );
  }
}

class SchemaBar extends ConsumerStatefulWidget {
  final DatabaseRef? currentSchema;
  final bool disable;
  final InstanceId? instanceId;
  final ConnId? connId;
  final Color? iconColor;

  const SchemaBar({
    super.key,
    this.instanceId,
    required this.disable,
    this.currentSchema,
    this.iconColor,
    this.connId,
  });

  @override
  ConsumerState<SchemaBar> createState() => _SchemaBarState();
}

class _SchemaBarState extends ConsumerState<SchemaBar> {
  bool isEnter = false;
  late final TextEditingController _schemaSearchController;

  @override
  void initState() {
    super.initState();
    _schemaSearchController = TextEditingController();
  }

  @override
  void dispose() {
    _schemaSearchController.dispose();
    super.dispose();
  }

  void _onSchemaSearchChanged() {
    setState(() {});
  }

  List<DatabaseRef> _filteredDatabaseRefs(List<DatabaseRef> refs, String q) {
    if (q.isEmpty) {
      return refs;
    }
    final lower = q.toLowerCase();
    return refs.where((r) => r.toString().toLowerCase().contains(lower)).toList();
  }

  Widget _schemaBarTriggerContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kSpacingTiny),
      child: MouseRegion(
        onEnter: (_) => setState(() => isEnter = true),
        onExit: (_) => setState(() => isEnter = false),
        child: Container(
          height: 26,
          padding: const EdgeInsets.fromLTRB(kSpacingTiny, 0, kSpacingTiny, 0),
          decoration: BoxDecoration(
            color: isEnter ? Theme.of(context).colorScheme.surfaceContainerLow : null, // schema 框鼠标移入的颜色
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedDatabase,
                color: Theme.of(context).colorScheme.onSurface, // schema bar icon 颜色
                size: kIconSizeSmall,
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 120, maxWidth: 180),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: kSpacingTiny,
                    right: kSpacingTiny,
                    bottom: 2, // 为了字体和icon在视觉上对齐, 这是一个我觉得协调的值.
                  ),
                  child: Text(
                    widget.currentSchema?.toString() ?? "",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Icon(
                Icons.expand_more,
                size: kIconSizeSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// database / schema 模式共用：一级列表，标签为 [DatabaseRef.toString]。
  Widget _buildSchemaBarRefMenu(BuildContext context, SelectedSessionSchemaModel data) {
    final searchText = _schemaSearchController.text;
    final filtered = _filteredDatabaseRefs(data.schemas, searchText);
    final List<OverlayMenuItem> tabs;
    if (filtered.isEmpty) {
      tabs = [
        OverlayMenuItem(
          height: 36,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context)!.display_msg_no_data),
            ),
          ),
        ),
      ];
    } else {
      tabs = filtered.map((schemaRef) {
        final label = schemaRef.toString();
        final cur = widget.currentSchema;
        final isSelected = cur != null && cur.toString() == label;
        final itemColor = isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface; // schema list 里当前schema的颜色

        return OverlayMenuItem(
          height: 30,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedDatabase,
                    color: itemColor,
                    size: kIconSizeSmall,
                  ),
                  const SizedBox(width: kSpacingTiny),
                  Expanded(
                    child: TooltipText(
                      text: label,
                      style: TextStyle(color: itemColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
          onTabSelected: () async {
            await ref.read(sessionConnsServicesProvider.notifier).setCurrentSchema(widget.connId!, schemaRef);
          },
        );
      }).toList();
    }

    return _buildSchemaBarOverlay(context, tabs);
  }

  Widget _buildSchemaBarOverlay(
    BuildContext context,
    List<OverlayMenuItem> tabs,
  ) {
    final schemaBarContent = _schemaBarTriggerContent(context);

    if (widget.disable) {
      return schemaBarContent;
    }

    final header = OverlayMenuHeader(
      height: 42,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(kSpacingSmall, kSpacingSmall, kSpacingSmall, kSpacingTiny),
        child: SearchBarTheme(
          data: SearchBarThemeData(
            textStyle: WidgetStatePropertyAll(Theme.of(context).textTheme.bodySmall),
            backgroundColor: WidgetStatePropertyAll(
              Theme.of(context).colorScheme.surfaceContainerLowest, // schema 页面搜索框背景色
            ),
            elevation: const WidgetStatePropertyAll(0),
            constraints: const BoxConstraints(minHeight: 24),
          ),
          child: SearchBar(
            // todo: 抽取搜索框, 哪里都一样重复的代码
            side: WidgetStatePropertyAll(
              BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant, // session 页面搜索框边框颜色
              ),
            ),
            controller: _schemaSearchController,
            onChanged: (_) => _onSchemaSearchChanged(),
            trailing: const [Icon(Icons.search, size: kIconSizeSmall)],
          ),
        ),
      ),
    );

    final footer = OverlayMenuFooter(
      height: kIconButtonSizeSmall + kSpacingTiny * 2,
      child: Padding(
        padding: const EdgeInsets.only(right: kSpacingSmall, top: kSpacingTiny, bottom: kSpacingTiny),
        child: Align(
          alignment: Alignment.bottomRight,
          child: RectangleIconButton.small(
            tooltip: AppLocalizations.of(context)!.button_tooltip_refresh_metadata,
            icon: Icons.refresh,
            onPressed: () async {
              ref.read(selectedSessionMetadataProvider.notifier).refreshMetadata();
            },
          ),
        ),
      ),
    );

    return OverlayMenu(
      spacing: kSpacingTiny,
      maxHeight: 300,
      maxWidth: 300,
      tabs: tabs,
      header: header,
      footer: footer,
      child: schemaBarContent,
    );
  }

  Widget _buildSchemaBarSingleMode() {
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.instanceId == null) {
      return const SizedBox.shrink();
    }

    final schemasAsync = ref.watch(selectedSessionSchemaProvider);
    return schemasAsync.when(
      data: (data) {
        switch (data.databaseMode) {
          case DatabaseModeType.singleMode:
            return _buildSchemaBarSingleMode();
          case DatabaseModeType.databaseMode:
          case DatabaseModeType.schemaMode:
            return _buildSchemaBarRefMenu(context, data);
        }
      },
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: SizedBox(
          height: 24,
          width: 132,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Loading.medium(),
          ),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class SessionConfigBar extends ConsumerStatefulWidget {
  final SessionOpBarModel model;

  const SessionConfigBar({
    super.key,
    required this.model,
  });

  @override
  ConsumerState<SessionConfigBar> createState() => _SessionConfigBarState();
}

class _SessionConfigBarState extends ConsumerState<SessionConfigBar> {
  void _onQueryLimitChanged(int? value) {
    if (value == null) {
      return;
    }
    setState(() {
      ref
          .read(sessionsServicesProvider.notifier)
          .updateSessionConfig(
            widget.model.sessionId,
            widget.model.config.copyWith(queryLimit: value),
          );
    });
  }

  void _onEnableQueryCheckChanged(bool value) {
    setState(() {
      ref
          .read(sessionsServicesProvider.notifier)
          .updateSessionConfig(
            widget.model.sessionId,
            widget.model.config.copyWith(enableQueryCheck: value),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final header = OverlayMenuHeader.tile(
      icon: Icons.tune,
      title: l10n.session_config_title,
      subtitle: l10n.session_config_subtitle,
    );

    return OverlayMenu(
      closeOnSelectItem: false,
      spacing: kSpacingTiny,
      maxHeight: 320,
      maxWidth: 420,
      header: header,
      footer: OverlayMenuFooter(height: kSpacingMedium, child: const SizedBox.shrink()),
      tabs: [
        OverlayConfigItem.number(
          height: 84,
          title: l10n.session_config_query_limit,
          description: l10n.session_config_query_limit_hint,
          value: widget.model.config.queryLimit,
          onChanged: _onQueryLimitChanged,
        ),
        OverlayConfigItem.checkbox(
          height: 84,
          title: l10n.session_config_query_check,
          description: l10n.session_config_query_check_desc,
          value: widget.model.config.enableQueryCheck,
          onChanged: (v) {
            _onEnableQueryCheckChanged(v);
          },
        ),
      ],
      child: RectangleIconButton.medium(
        tooltip: l10n.button_tooltip_session_config,
        icon: Icons.tune,
        onPressed: null,
        iconColor: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class SessionDrawerBar extends ConsumerWidget {
  final double height;

  const SessionDrawerBar({
    super.key,
    this.height = 36,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(sessionDrawerProvider);
    final services = ref.read(sessionDrawerServicesProvider(model.sessionId).notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(),
        if (model.isRightPageOpen) ...[
          RectangleIconButton.medium(
            tooltip: AppLocalizations.of(context)!.button_tooltip_sql_result,
            icon: Icons.article_outlined,
            backgroundColor: (model.drawerPage == DrawerPage.sqlResult)
                ? Theme.of(context)
                      .colorScheme
                      .primaryContainer // 结果页面 icon 背景色
                : null,
            onPressed: () {
              services.showSQLResult();
            },
          ),
          // AI chat
          RectangleIconButton(
            size: kIconButtonSizeMedium,
            iconSize: kIconSizeMedium - 2, // 将icon调小点，与其他icon视觉上大小类似
            padding: 4,
            tooltip: AppLocalizations.of(context)!.button_tooltip_ai_chat,
            icon: Icons.auto_awesome,
            iconColor: Colors.purple[600]!,
            backgroundColor: (model.drawerPage == DrawerPage.aiChat)
                ? Theme.of(context)
                      .colorScheme
                      .primaryContainer // AI chat 页面 icon 背景色
                : null,
            onPressed: () {
              services.showChat();
            },
          ),
          const SizedBox(width: kSpacingSmall),
          RectangleIconButton.medium(
            icon: model.isRightPageOpen ? Icons.menu : Icons.menu_open,
            iconColor: Theme.of(context).colorScheme.onSurface, // 关闭drawer页面 icon 颜色
            onPressed: () => services.hideRightPage(),
          ),
        ],
        if (!model.isRightPageOpen)
          RectangleIconButton.medium(
            icon: model.isRightPageOpen ? Icons.menu : Icons.menu_open,
            iconColor: Theme.of(context).colorScheme.onSurface, // 打开drawer页面 icon 颜色
            onPressed: () => services.showRightPage(),
          ),
      ],
    );
  }
}

void queryDangerousSQLDialog(
  BuildContext context,
  WidgetRef ref,
  SessionId sessionId,
  SessionConfigModel config,
  DialectType dialectType,
  String query,
) {
  final textTheme = Theme.of(context).textTheme;
  showDialog(
    context: context,
    builder: (_) => CustomDialog(
      title: AppLocalizations.of(context)!.tip_dangerous_sql_title,
      titleIcon: Icon(
        Icons.play_circle_outline_rounded,
        color: Colors.green,
      ),
      subtitle: AppLocalizations.of(context)!.tip_dangerous_sql_desc,
      footerLeading: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.tip_dangerous_sql_footer_hint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: kSpacingTiny),
          Text("\""),
          Icon(
            Icons.tune,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          Text("\""),
        ],
      ),
      maxHeight: 420,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: kSpacingSmall,
                vertical: kSpacingMedium,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SelectableText.rich(
                    getSQLHighlightTextSpan(
                      dialectType,
                      query,
                      defalutStyle: GoogleFonts.robotoMono(
                        textStyle: textTheme.bodySmall,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        const SizedBox(width: kSpacingSmall),
        TextButton(
          onPressed: () {
            ref.read(sQLResultsServicesProvider.notifier).query(sessionId, query);
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.confirm),
        ),
      ],
    ),
  );
}
