import 'package:client/models/sessions.dart';
import 'package:client/services/sessions/session_sql_result.dart';
import 'package:client/services/sessions/session_conn.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/dialog.dart';
import 'package:client/widgets/icon_button.dart';
import 'package:client/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:sql_parser/parser.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sql_editor/re_editor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SessionOpBar extends ConsumerWidget {
  final CodeLineEditingController codeController;
  final double height;

  const SessionOpBar({Key? key, required this.codeController, this.height = 36})
      : super(key: key);

  String getQuery() {
    var content = codeController.text.toString();
    List<SQLChunk> querys = Splitter(content, ";").split();
    CodeLineSelection s = codeController.selection;
    String query;
    // 当界面手动选中了文本片段则仅执行该片段，当前还不支持多SQL执行.
    if (!s.isCollapsed) {
      query = codeController.selectedText;
    } else {
      int line = s.baseIndex + 1;
      int row = s.baseOffset;
      SQLChunk chunk = querys.firstWhere((chunk) {
        if (line < chunk.end.line) {
          return true;
        } else if (line == chunk.end.line && row <= chunk.end.row) {
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
    if (connIsBusy(model)) {
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
    if (connIsBusy(model)) {
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

  bool connIsConnected(SessionOpBarModel model) {
    return (model.connId != null &&
        model.state != null &&
        (model.state == SQLConnectState.connected ||
            model.state == SQLConnectState.executing));
  }

  bool connIsDisconnected(SessionOpBarModel model) {
    return (model.connId == null ||
        model.state == null ||
        model.state == SQLConnectState.disconnected ||
        model.state == SQLConnectState.failed);
  }

  bool connIsIdle(SessionOpBarModel model) {
    return (model.connId != null &&
        model.state != null &&
        model.state == SQLConnectState.connected);
  }

  bool connIsBusy(SessionOpBarModel model) {
    return (model.connId != null &&
        model.state != null &&
        (model.state == SQLConnectState.executing ||
            model.state == SQLConnectState.connecting));
  }

  bool connIsConnecting(SessionOpBarModel model) {
    return (model.connId != null &&
        model.state != null &&
        model.state == SQLConnectState.connecting);
  }

  Widget connectWidget(
      BuildContext context, WidgetRef ref, SessionOpBarModel model) {
    if (connIsDisconnected(model)) {
      return RectangleIconButton(
        icon: Icons.link_rounded,
        iconColor: Theme.of(context).primaryColor,
        onPressed: () async {
          await ref
              .read(sessionsServicesProvider.notifier)
              .connectSession(model.sessionId);
        },
      );
    } else if (connIsConnecting(model)) {
      return const Loading();
    } else {
      // disconnect
      return RectangleIconButton(
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
    return RectangleIconButton(
      icon: Icons.play_circle_outline_rounded,
      iconColor: connIsIdle(model) ? Colors.green : Colors.grey,
      onPressed: connIsIdle(model)
          ? () {
              String query = getQuery();
              final sqlResultsServices =
                  ref.read(sQLResultsServicesProvider.notifier);

              SQLResultModel? resultModel =
                  sqlResultsServices.selectedSQLResult(model.sessionId);

              resultModel ??= sqlResultsServices.addSQLResult(model.sessionId);

              sqlResultsServices.loadFromQuery(resultModel.resultId, query);
            }
          : () {
              connectDialog(context, ref, model);
            },
    );
  }

  Widget executeAddWidget(
      BuildContext context, WidgetRef ref, SessionOpBarModel model) {
    return Stack(alignment: Alignment.center, children: [
      RectangleIconButton(
        icon: Icons.not_started_outlined,
        iconColor: connIsIdle(model) ? Colors.green : Colors.grey,
        onPressed: connIsIdle(model)
            ? () {
                String query = getQuery();
                if (query.isNotEmpty) {
                  final sqlResultsServices =
                      ref.read(sQLResultsServicesProvider.notifier);
                  final resultModel =
                      sqlResultsServices.addSQLResult(model.sessionId);
                  sqlResultsServices.loadFromQuery(resultModel.resultId, query);
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
    return RectangleIconButton(
      iconSize: 36,
      icon: Icons.e_mobiledata,
      iconColor: connIsIdle(model)
          ? const Color.fromARGB(255, 241, 192, 84)
          : Colors.grey,
      onPressed: connIsIdle(model)
          ? () {
              String query = getQuery();
              if (query.isNotEmpty) {
                final sqlResultsServices =
                    ref.read(sQLResultsServicesProvider.notifier);
                final resultModel =
                    sqlResultsServices.addSQLResult(model.sessionId);
                sqlResultsServices.loadFromQuery(
                    resultModel.resultId, "explain $query");
              }
            }
          : () {
              connectDialog(context, ref, model);
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
          // connect
          connectWidget(context, ref, model),
          // schema list
          SchemaBar(
            connId: model.connId,
            disable: !connIsIdle(model),
            currentSchema: model.currentSchema,
          ),
          divider(),
          executeWidget(context, ref, model),
          executeAddWidget(context, ref, model),
          explainWidget(context, ref, model),
          const Spacer(),
          if (model.isRightPageOpen == false)
            RectangleIconButton(
              icon: Icons.format_indent_decrease,
              iconColor: Theme.of(context).colorScheme.onSurface,
              onPressed: () {
                ref
                    .read(sessionDrawerNotifierProvider.notifier)
                    .showRightPage();
              },
            )
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
                    child: Text(schema));
              }).toList());
        },
        child: Container(
            padding: const EdgeInsets.only(left: kSpacingTiny),
            color: (isEnter && !widget.disable)
                ? Theme.of(context)
                    .colorScheme
                    .surfaceContainerHigh // schema 鼠标移入的颜色
                : null,
            child: Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedDatabase,
                  color: widget.iconColor ??
                      Theme.of(context).colorScheme.onSurface,
                  size: 20,
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
    );
  }
}
