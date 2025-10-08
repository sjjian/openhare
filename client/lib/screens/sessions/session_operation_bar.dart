import 'package:client/models/sessions.dart';
import 'package:client/services/sessions/session_drawer.dart';
import 'package:client/services/sessions/session_sql_editor.dart';
import 'package:client/services/sessions/session_sql_result.dart';
import 'package:client/services/sessions/session_conn.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/dialog.dart';
import 'package:client/widgets/button.dart';
import 'package:client/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:sql_parser/parser.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sql_editor/re_editor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:client/l10n/app_localizations.dart';

class SessionOpBar extends ConsumerWidget {
  final CodeLineEditingController codeController;
  final double height;

  const SessionOpBar({Key? key, required this.codeController, this.height = 36})
      : super(key: key);

  String getQuery() {
    var content = codeController.text.toString();
    List<SQLChunk> querys = Splitter(content, ";", skipWhitespace: true).split();
    CodeLineSelection s = codeController.selection;
    String query;
    // 当界面手动选中了文本片段则仅执行该片段，当前还不支持多SQL执行.
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

  void disconnectDialog(
      BuildContext context, WidgetRef ref, SessionOpBarModel model) {
    // 如果正在执行语句，则提示连接繁忙，请稍后执行
    if (SQLConnectState.isBusy(model.state)) {
      return doActionDialog(
        context,
        AppLocalizations.of(context)!.tip_connect_busy,
        AppLocalizations.of(context)!.tip_connect_busy_desc,
        () {
          // do nothing, just close the dialog
        },
        icon: Icon(Icons.warning_amber_rounded,
            color: Theme.of(context).colorScheme.error),
      );
    }
    return doActionDialog(
      context,
      AppLocalizations.of(context)!.tip_disconnect,
      AppLocalizations.of(context)!.tip_disconnect_desc,
      () async {
        await ref
            .read(sessionsServicesProvider.notifier)
            .disconnectSession(model.sessionId);
      },
      icon: Icon(Icons.link_off_rounded,
          color: Theme.of(context).colorScheme.error),
    );
  }

  void connectDialog(
      BuildContext context, WidgetRef ref, SessionOpBarModel model) {
    // 如果是connIsBusy，则提示连接繁忙，请稍后执行
    if (SQLConnectState.isBusy(model.state)) {
      return doActionDialog(
        context,
        AppLocalizations.of(context)!.tip_connect_busy,
        AppLocalizations.of(context)!.tip_connect_busy_desc,
        () {
          // do nothing, just close the dialog
        },
        icon: Icon(Icons.warning_amber_rounded,
            color: Theme.of(context).colorScheme.error),
      );
    }
    // 如果是connIsDisconnected，则提示连接未建立，请先连接
    return doActionDialog(
      context,
      AppLocalizations.of(context)!.tip_connect,
      AppLocalizations.of(context)!.tip_connect_desc,
      () async {
        await ref
            .read(sessionsServicesProvider.notifier)
            .connectSession(model.sessionId);
      },
      icon: Icon(Icons.link_rounded,
          color: Theme.of(context).colorScheme.primary),
    );
  }

  Widget connectWidget(
      BuildContext context, WidgetRef ref, SessionOpBarModel model) {
    if (SQLConnectState.isDisconnected(model.state)) {
      return RectangleIconButton.medium(
        tooltip: AppLocalizations.of(context)!.button_tooltip_connect,
        icon: Icons.link_rounded,
        iconColor: Theme.of(context).primaryColor,
        onPressed: () async {
          await ref
              .read(sessionsServicesProvider.notifier)
              .connectSession(model.sessionId);
        },
      );
    } else if (SQLConnectState.isConnecting(model.state)) {
      return const Loading.medium();
    } else {
      // disconnect
      return RectangleIconButton.medium(
        tooltip: AppLocalizations.of(context)!.button_tooltip_disconnect,
        icon: Icons.link_off_rounded,
        iconColor: Theme.of(context).primaryColor,
        onPressed: () async {
          disconnectDialog(context, ref, model);
        },
      );
    }
  }

  Widget executeWidget(
      BuildContext context, WidgetRef ref, SessionOpBarModel model) {
    return RectangleIconButton.medium(
      tooltip: AppLocalizations.of(context)!.button_tooltip_run_sql,
      icon: Icons.play_circle_outline_rounded,
      iconColor:
          SQLConnectState.isIdle(model.state) ? Colors.green : Colors.grey,
      onPressed: SQLConnectState.isIdle(model.state)
          ? () {
              String query = getQuery();
              if (query.isNotEmpty) {
              ref
                    .read(sQLResultsServicesProvider.notifier)
                    .query(model.sessionId, query);
              }
            }
          : () {
              connectDialog(context, ref, model);
            },
    );
  }

  Widget executeAddWidget(
      BuildContext context, WidgetRef ref, SessionOpBarModel model) {
    return Stack(alignment: Alignment.center, children: [
      RectangleIconButton.medium(
        tooltip: AppLocalizations.of(context)!.button_tooltip_run_sql_new_tab,
        icon: Icons.not_started_outlined,
        iconColor:
            SQLConnectState.isIdle(model.state) ? Colors.green : Colors.grey,
        onPressed: SQLConnectState.isIdle(model.state)
            ? () {
                String query = getQuery();
                if (query.isNotEmpty) {
                  ref
                      .read(sQLResultsServicesProvider.notifier)
                      .queryAddResult(model.sessionId, query);
                }
              }
            : () {
                connectDialog(context, ref, model);
              },
      ),
    ]);
  }

  Widget explainWidget(
      BuildContext context, WidgetRef ref, SessionOpBarModel model) {
    return RectangleIconButton.medium(
      tooltip: AppLocalizations.of(context)!.button_tooltip_explain_sql,
      icon: Icons.poll_outlined,
      iconColor: SQLConnectState.isIdle(model.state)
          ? const Color.fromARGB(255, 241, 192, 84)
          : Colors.grey,
      onPressed: SQLConnectState.isIdle(model.state)
          ? () {
              String query = getQuery();
              if (query.isNotEmpty) {
                ref
                    .read(sQLResultsServicesProvider.notifier)
                    .queryAddResult(model.sessionId, "explain $query");
              }
            }
          : () {
              connectDialog(context, ref, model);
            },
    );
  }

  Widget saveWidget(
      BuildContext context, WidgetRef ref, SessionOpBarModel model) {
    return RectangleIconButton.medium(
      tooltip: AppLocalizations.of(context)!.button_tooltip_save,
      icon: Icons.save,
      iconColor: Theme.of(context).colorScheme.onSurface,
      onPressed: () {
        ref
            .read(sessionSQLEditorServiceProvider(model.sessionId).notifier)
            .saveCode();
      },
    );
  }

  Widget divider() {
    return const VerticalDivider(
      thickness: kDividerThickness,
      width: kDividerSize,
      indent: 10,
      endIndent: 10,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SessionOpBarModel? model = ref.watch(sessionOpBarNotifierProvider);

    if (model == null) {
      return Container(
        color:
            Theme.of(context).colorScheme.surfaceContainerLowest, // op bar 背景色
        constraints: BoxConstraints(maxHeight: height),
        child: const Spacer(),
      );
    }
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest, // op bar 背景色
      constraints: BoxConstraints(maxHeight: height),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // connect
          connectWidget(context, ref, model),
          // schema list
          SchemaBar(
            connId: model.connId,
            disable: !SQLConnectState.isIdle(model.state),
            currentSchema: model.currentSchema,
          ),
          divider(),
          executeWidget(context, ref, model),
          executeAddWidget(context, ref, model),
          explainWidget(context, ref, model),
          saveWidget(context, ref, model),
          const Expanded(child: SessionDrawerBar()),
        ],
      ),
    );
  }
}

class SchemaBar extends ConsumerStatefulWidget {
  final String? currentSchema;
  final bool disable;
  final ConnId? connId;
  final Color? iconColor;

  const SchemaBar({
    Key? key,
    this.connId,
    required this.disable,
    this.currentSchema,
    this.iconColor,
  }) : super(key: key);

  @override
  ConsumerState<SchemaBar> createState() => _SchemaBarState();
}

class _SchemaBarState extends ConsumerState<SchemaBar> {
  bool isEnter = false;

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
        onTapUp: (detail) async {
          if (widget.disable) {
            return;
          }
          final position = detail.globalPosition;
          final RenderBox overlay =
              Overlay.of(context).context.findRenderObject() as RenderBox;
          final overlayPos = overlay.localToGlobal(Offset.zero);

          List<String> schemas = await ref
              .read(sessionConnsServicesProvider.notifier)
              .getSchemas(widget.connId!);

          // todo
          showMenu(
              context: context,
              position: RelativeRect.fromLTRB(
                position.dx - overlayPos.dx,
                position.dy - overlayPos.dy,
                position.dx - overlayPos.dx,
                position.dy - overlayPos.dy,
              ),
              items: schemas.map((schema) {
                return PopupMenuItem<String>(
                    height: 30,
                    onTap: () async {
                      await ref
                          .read(sessionConnsServicesProvider.notifier)
                          .setCurrentSchema(widget.connId!, schema);
                    },
                    child: Text(schema, overflow: TextOverflow.ellipsis));
              }).toList());
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, kSpacingTiny, 0, kSpacingTiny),
          child: Container(
              padding: const EdgeInsets.only(left: kSpacingTiny),
              decoration: BoxDecoration(
                color: (isEnter && !widget.disable)
                    ? Theme.of(context)
                        .colorScheme
                        .primaryContainer // schema 鼠标移入的颜色
                    : null,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedDatabase,
                    color: widget.iconColor ??
                        Theme.of(context).colorScheme.onSurface,
                    size: kIconSizeSmall,
                  ),
                  Container(
                      padding: const EdgeInsets.only(left: kSpacingTiny),
                      width: 120,
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.currentSchema ?? "",
                            overflow: TextOverflow.ellipsis,
                          ))),
                ],
              )),
        ),
      ),
    );
  }
}

class SessionDrawerBar extends ConsumerWidget {
  final double height;

  const SessionDrawerBar({Key? key, this.height = 36}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(sessionDrawerNotifierProvider);
    final services =
        ref.read(sessionDrawerServicesProvider(model.sessionId).notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(),
        if (model.isRightPageOpen) ...[
          RectangleIconButton.medium(
              tooltip:
                  AppLocalizations.of(context)!.button_tooltip_metadata_tree,
              icon: Icons.account_tree_outlined,
              backgroundColor: (model.drawerPage == DrawerPage.metadataTree)
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              onPressed: () {
                services.goToTree();
              }),
          RectangleIconButton.medium(
              tooltip: AppLocalizations.of(context)!.button_tooltip_sql_result,
              icon: Icons.article_outlined,
              backgroundColor: (model.drawerPage == DrawerPage.sqlResult)
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              onPressed: () {
                services.showSQLResult();
              }),
          // AI chat
          RectangleIconButton.medium(
              tooltip: AppLocalizations.of(context)!.button_tooltip_ai_chat,
              icon: Icons.auto_awesome,
              backgroundColor: (model.drawerPage == DrawerPage.aiChat)
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              onPressed: () {
                services.showChat();
              }),
          const SizedBox(width: kSpacingSmall),
          RectangleIconButton.medium(
            icon: model.isRightPageOpen ? Icons.menu : Icons.menu_open,
            iconColor: Theme.of(context).colorScheme.onSurface,
            onPressed: () => services.hideRightPage(),
          ),
        ],
        if (!model.isRightPageOpen)
          RectangleIconButton.medium(
            icon: model.isRightPageOpen ? Icons.menu : Icons.menu_open,
            iconColor: Theme.of(context).colorScheme.onSurface,
            onPressed: () => services.showRightPage(),
          )
      ],
    );
  }
}
