import 'dart:async';

import 'package:client/models/sessions.dart';
import 'package:client/models/settings.dart';
import 'package:client/services/ai/agent.dart';
import 'package:client/services/ai/prompt.dart';
import 'package:client/services/sessions/session_chat.dart';
import 'package:client/services/sessions/session_controller.dart';
import 'package:client/services/sessions/session_sql_result.dart';
import 'package:client/services/settings/settings.dart';
import 'package:client/utils/sql_highlight.dart';
import 'package:client/widgets/button.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/loading.dart';
import 'package:client/widgets/menu.dart';
import 'package:client/widgets/tooltip.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/services/ai/chat.dart';
import 'package:client/models/ai.dart';
import 'package:go_router/go_router.dart';
import 'package:gpt_markdown/custom_widgets/code_field.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:client/l10n/app_localizations.dart';

class SessionDrawerChat extends ConsumerStatefulWidget {
  const SessionDrawerChat({Key? key}) : super(key: key);

  @override
  ConsumerState<SessionDrawerChat> createState() => _SessionDrawerChatState();
}

class _SessionDrawerChatState extends ConsumerState<SessionDrawerChat> {
  @override
  Widget build(BuildContext context) {
    SessionAIChatModel? model = ref.watch(sessionAIChatNotifierProvider);
    if (model == null) {
      return const Spacer();
    }

    return Column(
      children: [
        // 聊天内容
        Expanded(
          child: (model.llmAgents.agents.isEmpty)
              ? const SessionChatGuide()
              : const SessionChatMessages(),
        ),
        const SizedBox(height: kSpacingMedium),
        // 下方的输入框区域
        const SessionChatInputCard(),
        const SizedBox(height: kSpacingMedium),
      ],
    );
  }
}

class SessionChatInputCard extends ConsumerStatefulWidget {
  const SessionChatInputCard({Key? key}) : super(key: key);

  @override
  ConsumerState<SessionChatInputCard> createState() =>
      _SessionChatInputCardState();
}

class _SessionChatInputCardState extends ConsumerState<SessionChatInputCard> {
  void _onSearchChanged() {
    setState(() {});
  }

  bool _isTableSelected(SessionAIChatModel model, String tableName) {
    return model.chatModel.tables.containsKey(model.currentSchema ?? "") &&
        model.chatModel.tables[model.currentSchema ?? ""]!
            .containsKey(tableName);
  }

  bool _isAllTableSelected(SessionAIChatModel model) {
    return model.chatModel.tables.containsKey(model.currentSchema ?? "") &&
        model.chatModel.tables[model.currentSchema ?? ""]!.length ==
            model.metadata
                ?.getChildren(MetaType.schema, model.currentSchema ?? "")
                .where((e) => e.type == MetaType.table)
                .length;
  }

  Map<String, String> _allTableSelected(SessionAIChatModel model) {
    return model.metadata!
        .getChildren(MetaType.schema, model.currentSchema ?? "")
        .where((e) => e.type == MetaType.table)
        .fold({}, (acc, e) => {...acc, e.value: e.value});
  }

  Future<void> _sendMessage(
      AIChatId chatId, SessionAIChatModel chatModel) async {
    final text = SessionController.sessionController(chatModel.sessionId)
        .chatInputController
        .text
        .trim();
    SessionController.sessionController(chatModel.sessionId)
        .chatInputController
        .clear();

    // 调用AIChatService的chat方法
    await ref.read(aIChatServiceProvider.notifier).chat(
        chatId,
        chatModel.llmAgents.lastUsedLLMAgent!.id,
        genChatSystemPrompt(chatModel),
        message: text);

    final scrollController =
        SessionController.sessionController(chatModel.sessionId)
            .aiChatScrollController;

    // 滚动到底部
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SessionAIChatModel? model = ref.watch(sessionAIChatNotifierProvider);
    if (model == null) {
      return const Spacer();
    }
    final services = ref.read(aIChatServiceProvider.notifier);

    final chatInputController =
        SessionController.sessionController(model.sessionId)
            .chatInputController;
    final searchTextController =
        SessionController.sessionController(model.sessionId)
            .aiChatSearchTextController;

    // 模型选择工具栏
    final modelToolWidget = Container(
      constraints: const BoxConstraints(
        maxWidth: 120,
      ),
      padding: const EdgeInsets.fromLTRB(
          kSpacingSmall, kSpacingTiny, kSpacingSmall, kSpacingTiny),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 1,
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
        ),
      ),
      child: Text(
        model.llmAgents.lastUsedLLMAgent?.setting.name ?? "-",
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );

    // 表选择工具栏
    final tableToolWidget = IntrinsicWidth(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 80,
        ),
        padding: const EdgeInsets.fromLTRB(
            kSpacingSmall, kSpacingTiny, kSpacingSmall, kSpacingTiny),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 1,
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedTable,
              color: Theme.of(context).colorScheme.onSurface,
              size: kIconSizeTiny,
            ),
            const SizedBox(width: kSpacingTiny),
            Expanded(
              child: Text(
                "+${model.chatModel.tables[model.currentSchema ?? ""]?.length ?? 0}",
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(kSpacingMedium, 0, kSpacingMedium, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
            kSpacingSmall, kSpacingSmall, kSpacingSmall, kSpacingTiny),
        // 设置一个圆角
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // 输入框
            TextField(
              style: Theme.of(context).textTheme.bodyMedium,
              controller: chatInputController,
              minLines: 1,
              maxLines: 5,
              enabled: model.chatModel.state != AIChatState.waiting,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.ai_chat_input_tip,
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: kSpacingSmall, horizontal: kSpacingTiny),
              ),
              onSubmitted: (_) => model.canSendMessage()
                  ? _sendMessage(model.chatModel.id, model)
                  : null,
            ),

            const SizedBox(height: kSpacingSmall),

            // 工具栏
            Row(
              children: [
                const SizedBox(width: kSpacingTiny),
                // 模型选择
                OverlayMenu(
                  isAbove: true,
                  spacing: kSpacingTiny,
                  tabs: [
                    for (var agent in model.llmAgents.agents.values)
                      OverlayMenuItem(
                        height: 24,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                              kSpacingSmall, 0, kSpacingSmall, 0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              agent.setting.name,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                        onTabSelected: () {
                          ref
                              .read(lLMAgentServiceProvider.notifier)
                              .updateLastUsedLLMAgent(agent.id);
                        },
                      ),
                  ],
                  child: modelToolWidget,
                ),
                const SizedBox(width: kSpacingTiny),

                // 表选择
                (model.currentSchema != null && model.currentSchema != "")
                    ? OverlayMenu(
                        isAbove: true,
                        spacing: kSpacingTiny,
                        tabs: [
                          for (MetaDataNode table in model.metadata
                                  ?.getChildren(MetaType.schema,
                                      model.currentSchema ?? "")
                                  .where((e) => e.value
                                      .contains(searchTextController.text)) ??
                              [])
                            OverlayMenuItem(
                              height: 36,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    kSpacingSmall, 0, kSpacingSmall, 0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      // 如果table 在aichatmodel.tables 中，则显示选中状态
                                      _isTableSelected(model, table.value)
                                          ? const Icon(
                                              Icons.check_circle,
                                              size: kIconSizeTiny,
                                              color: Colors.green,
                                            )
                                          : const Icon(
                                              Icons.circle_outlined,
                                              size: kIconSizeTiny,
                                            ),
                                      const SizedBox(width: kSpacingTiny),
                                      Expanded(
                                        child: TooltipText(
                                            text: table.value,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              onTabSelected: () {
                                final newTables = Map<String, String>.from(model
                                        .chatModel
                                        .tables[model.currentSchema ?? ""] ??
                                    {});

                                if (_isTableSelected(model, table.value)) {
                                  // delete it
                                  newTables.remove(table.value);
                                  services.updateTables(model.chatModel.id,
                                      model.currentSchema ?? "", newTables);
                                  return;
                                } else {
                                  // 如果table 不在aichatmodel.tables 中，则添加
                                  newTables[table.value] = table.value;
                                  services.updateTables(model.chatModel.id,
                                      model.currentSchema ?? "", newTables);
                                }
                              },
                            ),
                        ],
                        footer: OverlayMenuFooter(
                          height: 36,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(kSpacingSmall,
                                kSpacingTiny, kSpacingSmall, kSpacingTiny),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    // 全选或者全取消操作
                                    if (_isAllTableSelected(model)) {
                                      // 全取消
                                      services.updateTables(model.chatModel.id,
                                          model.currentSchema ?? "", {});
                                    } else {
                                      // 全选
                                      services.updateTables(
                                        model.chatModel.id,
                                        model.currentSchema ?? "",
                                        _allTableSelected(model),
                                      );
                                    }
                                  },
                                  child: Icon(
                                    _isAllTableSelected(model)
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    size: kIconSizeTiny,
                                    color: _isAllTableSelected(model)
                                        ? Colors.green
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                  ),
                                ),
                                const SizedBox(width: kSpacingTiny),
                                Expanded(
                                  child: SearchBarTheme(
                                    data: SearchBarThemeData(
                                        textStyle: WidgetStatePropertyAll(
                                            Theme.of(context)
                                                .textTheme
                                                .bodySmall),
                                        backgroundColor: WidgetStatePropertyAll(
                                            Theme.of(context)
                                                .colorScheme
                                                .surfaceContainer),
                                        elevation:
                                            const WidgetStatePropertyAll(0),
                                        constraints: const BoxConstraints(
                                          minHeight: 24,
                                        )),
                                    child: SearchBar(
                                        controller: searchTextController,
                                        onChanged: (value) {
                                          _onSearchChanged();
                                        },
                                        trailing: const [
                                          Icon(Icons.search,
                                              size: kIconSizeTiny),
                                        ]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        child: tableToolWidget,
                      )
                    : OverlayMenu(
                        isAbove: true,
                        spacing: kSpacingTiny,
                        tabs: const [],
                        footer: OverlayMenuFooter(
                          height: 200,
                          child: Padding(
                            padding: const EdgeInsets.all(kSpacingSmall),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.info_outline,
                                    size: kIconSizeMedium,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                                const SizedBox(height: kSpacingSmall),
                                Text(
                                  AppLocalizations.of(context)!
                                      .ai_chat_table_tip,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        child: tableToolWidget,
                      ),
                const Spacer(),

                // 清空聊天记录
                IconButton(
                  iconSize: kIconSizeTiny,
                  icon: const Icon(Icons.cleaning_services),
                  onPressed: model.canClearMessage()
                      ? () => services.cleanMessages(model.chatModel.id)
                      : null,
                ),

                // 发送消息
                (model.chatModel.state == AIChatState.waiting)
                    ? const Loading.small()
                    : IconButton(
                        iconSize: kIconSizeTiny,
                        icon: const Icon(Icons.send),
                        onPressed: model.canSendMessage()
                            ? () => _sendMessage(model.chatModel.id, model)
                            : null,
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SqlChatField extends StatefulWidget {
  final Function(String)? onRun;
  final String codes;
  const SqlChatField({super.key, required this.codes, required this.onRun});

  @override
  State<SqlChatField> createState() => _SqlChatFieldState();
}

class _SqlChatFieldState extends State<SqlChatField> {
  bool _copied = false;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.onInverseSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8,
                ),
                child: Text("SQL"),
              ),
              const Spacer(),
              RectangleIconButton(
                iconSize: kIconSizeSmall,
                icon: Icons.play_circle_outline_rounded,
                iconColor: (widget.onRun != null) ? Colors.green : Colors.grey,
                onPressed: () {
                  widget.onRun?.call(widget.codes);
                },
              ),
              RectangleIconButton(
                iconSize: kIconSizeSmall,
                icon: (_copied) ? Icons.done : Icons.content_paste,
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: widget.codes),
                  ).then((value) {
                    setState(() {
                      _copied = true;
                    });
                  });
                  await Future.delayed(const Duration(seconds: 2));
                  setState(() {
                    _copied = false;
                  });
                },
              ),
              const SizedBox(width: kSpacingTiny),
            ],
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: RichText(
              text: getSQLHighlightTextSpan(widget.codes,
                  defalutStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface)),
            ),
          ),
        ],
      ),
    );
  }
}

class SessionChatMessages extends ConsumerWidget {
  const SessionChatMessages({super.key});

  void _retryMessage(BuildContext context, WidgetRef ref,
      SessionAIChatModel model, AIChatMessageModel message) {
    // 调用AIChatService的chat方法
    ref.read(aIChatServiceProvider.notifier).retryChat(
        model.chatModel.id,
        model.llmAgents.lastUsedLLMAgent!.id,
        genChatSystemPrompt(model),
        message);

    final scrollController =
        SessionController.sessionController(model.sessionId)
            .aiChatScrollController;

    // 滚动到底部
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessage(BuildContext context, WidgetRef ref,
      SessionAIChatModel model, AIChatMessageModel message) {
    switch (message.role) {
      case AIRole.user:
        return userMessageWidget(context, message);
      case AIRole.assistant:
        return assistantMessageWidget(context, ref, model, message);
    }
  }

  // 用户消息组件
  Widget userMessageWidget(BuildContext context, AIChatMessageModel message) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.content,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  // AI助手消息组件
  Widget assistantMessageWidget(BuildContext context, WidgetRef ref,
      SessionAIChatModel model, AIChatMessageModel message) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              if (message.error != null)
                Text(
                  message.error ?? "",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              if (message.thinking != null)
                RichText(
                  text: TextSpan(
                      text: message.thinking ?? "",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          )),
                ),
              GptMarkdownTheme(
                gptThemeData: GptMarkdownThemeData(
                  brightness: Theme.of(context).brightness,
                  h1: Theme.of(context).textTheme.titleLarge,
                  h2: Theme.of(context).textTheme.titleMedium,
                  h3: Theme.of(context).textTheme.titleSmall,
                  h4: Theme.of(context).textTheme.bodyLarge,
                  h5: Theme.of(context).textTheme.bodyMedium,
                  h6: Theme.of(context).textTheme.bodySmall,
                  hrLineThickness: 0.2,
                  highlightColor:
                      Theme.of(context).colorScheme.surfaceContainerLowest,
                ),
                child: GptMarkdown(
                  key: ValueKey(model),
                  message.content,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  codeBuilder: (context, name, code, closed) {
                    if (name == "sql") {
                      return SqlChatField(
                          codes: code,
                          onRun: SQLConnectState.isIdle(model.state)
                              ? (code) {
                                  // todo: 重复代码
                                  final sqlResultsServices = ref.read(
                                      sQLResultsServicesProvider.notifier);

                                  SQLResultModel? resultModel =
                                      sqlResultsServices
                                          .selectedSQLResult(model.sessionId);

                                  resultModel ??= sqlResultsServices
                                      .addSQLResult(model.sessionId);

                                  sqlResultsServices.loadFromQuery(
                                      resultModel.resultId, code);
                                }
                              : null);
                    } else {
                      return CodeField(name: name, codes: code);
                    }
                  },
                ),
              ),
              if (model.canSendMessage()) ...[
                const SizedBox(height: kSpacingTiny),
                Row(
                  children: [
                    RectangleIconButton(
                      size: kIconSizeSmall,
                      iconSize: kIconSizeTiny,
                      icon: Icons.refresh,
                      onPressed: () {
                        _retryMessage(context, ref, model, message);
                      },
                    ),
                  ],
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToBottom(SessionAIChatModel model) {
    final scrollController =
        SessionController.sessionController(model.sessionId)
            .aiChatScrollController;
    if (scrollController.hasClients) {
      final position = scrollController.position;
      final target = position.maxScrollExtent;
      // 如果已经很接近底部，直接跳转，避免多次动画导致抖动
      if ((position.pixels - target).abs() < 20) {
        scrollController.jumpTo(target);
      } else {
        scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SessionAIChatModel? model = ref.watch(sessionAIChatNotifierProvider);
    if (model == null) {
      return const Spacer();
    }
    final messages = model.chatModel.messages;
    // 简单实现：AIChatState.waiting时每帧都滚动到底部
    if (model.chatModel.state == AIChatState.waiting) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(model);
      });
    }
    return ListView.builder(
      controller: SessionController.sessionController(model.sessionId)
          .aiChatScrollController,
      itemCount: messages.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        return _buildMessage(context, ref, model, messages[index]);
      },
    );
  }
}

// 未配置模型的引导页面
class SessionChatGuide extends ConsumerWidget {
  const SessionChatGuide({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(AppLocalizations.of(context)!.ai_chat_guide_tip),
      const SizedBox(height: kSpacingSmall),
      LinkButton(
        text: AppLocalizations.of(context)!.ai_chat_guide_tip_add_model,
        onPressed: () {
          // 切换到模型设置tab
          ref
              .read(settingTabServiceProvider.notifier)
              .setSelectedSettingType(SettingType.llmApi);
          GoRouter.of(context).go('/settings');
        },
      ),
    ]));
  }
}
