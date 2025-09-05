import 'package:client/models/sessions.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/dialog.dart';
import 'package:client/widgets/loading.dart';
import 'package:client/widgets/tab_widget.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/l10n/app_localizations.dart';

class SessionTabs extends ConsumerWidget {
  const SessionTabs({Key? key}) : super(key: key);

  void closeSessionDialog(BuildContext context, WidgetRef ref,
      SessionDetailListModel model, int index) {
    // 如果正在执行语句，则提示连接繁忙，请稍后执行
    final state = model.sessions[index].connState;
    if (SQLConnectState.isBusy(state) || SQLConnectState.isConnected(state)) {
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
    SessionDetailListModel model = ref.watch(sessionsDetailNotifierProvider);
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
                    .surfaceContainerHigh, // session tab 背景色
                selectedColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerLow, // session tab 选择的颜色
                hoverColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainer, // session tab 鼠标移入的颜色
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                ),
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
                                  SQLConnectState.isBusy(
                                      model.sessions[i].connState))
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
