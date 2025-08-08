import 'package:client/models/sessions.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/dialog.dart';
import 'package:client/widgets/loading.dart';
import 'package:client/widgets/tab_widget.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SessionTabs extends ConsumerWidget {
  const SessionTabs({Key? key}) : super(key: key);

  // todo: 重复代码
  bool connIsBusy(SessionDetailModel model) {
    return (model.connId != null &&
        model.connState != null &&
        (model.connState == SQLConnectState.executing ||
            model.connState == SQLConnectState.connecting));
  }

  bool connIsConnected(SessionDetailModel model) {
    return (model.connId != null &&
        model.connState != null &&
        (model.connState == SQLConnectState.connected));
  }

  void closeSessionDialog(BuildContext context, WidgetRef ref,
      SessionDetailListModel model, int index) {
    // 如果正在执行语句，则提示连接繁忙，请稍后执行
    if (connIsBusy(model.sessions[index]) ||
        connIsConnected(model.sessions[index])) {
      return doActionDialog(
        context,
        AppLocalizations.of(context)!.tip_close_session,
        AppLocalizations.of(context)!.tip_close_session_desc,
        () {
          ref
              .read(sessionsServicesProvider.notifier)
              .deleteSessionByIndex(index);
        },
        icon: Icon(Icons.warning_amber_rounded,
            color: Theme.of(context).colorScheme.error),
      );
    } else {
      ref.read(sessionsServicesProvider.notifier).deleteSessionByIndex(index);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SessionDetailListModel model = ref.watch(sessionsNotifierProvider);
    return Padding(
      padding: const EdgeInsets.only(top: kSpacingTiny),
      child: Row(
        children: [
          Expanded(
            child: CommonTabBar(
              tabStyle: CommonTabStyle(
                minWidth: 90,
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest, // session tab 背景色
                selectedColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainer, // session tab 选择的颜色
                hoverColor: Theme.of(context)
                    .colorScheme
                    .surfaceDim, // session tab 鼠标移入的颜色
              ),
              addTab: () {
                ref.read(sessionsServicesProvider.notifier).newSession();
              },
              onReorder: (oldIndex, newIndex) {
                ref
                    .read(sessionsServicesProvider.notifier)
                    .reorderSession(oldIndex, newIndex);
              },
              tabs: [
                for (var i = 0; i < model.sessions.length; i++)
                  (model.sessions[i].instanceId == null)
                      ? CommonTabWrap(
                          label: AppLocalizations.of(context)!.new_tab,
                          onTap: () {
                            ref
                                .read(sessionsServicesProvider.notifier)
                                .selectSessionByIndex(i);
                          },
                          onDeleted: () {
                            closeSessionDialog(context, ref, model, i);
                          },
                          selected: model.sessions[i].sessionId ==
                              model.selectedSession?.sessionId,
                        )
                      : CommonTabWrap(
                          avatar: (model.sessions[i].sessionId !=
                                      model.selectedSession?.sessionId &&
                                  connIsBusy(model.sessions[i]))
                              ? const Loading.small()
                              : Image.asset(
                                  connectionMetaMap[model.sessions[i].dbType!]!
                                      .logoAssertPath),
                          label: model.sessions[i].instanceName!,
                          items: <PopupMenuEntry>[
                            PopupMenuItem<String>(
                              height: 30,
                              onTap: () {
                                closeSessionDialog(context, ref, model, i);
                              },
                              child: Text(AppLocalizations.of(context)!.close),
                            ),
                          ],
                          onTap: () {
                            ref
                                .read(sessionsServicesProvider.notifier)
                                .selectSessionByIndex(i);
                          },
                          onDeleted: () {
                            closeSessionDialog(context, ref, model, i);
                          },
                          selected: model.sessions[i].sessionId ==
                              model.selectedSession?.sessionId,
                        )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
