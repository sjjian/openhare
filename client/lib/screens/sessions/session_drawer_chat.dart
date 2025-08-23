import 'dart:async';

import 'package:client/models/sessions.dart';
import 'package:client/services/ai/prompt.dart';
import 'package:client/services/sessions/session_sql_result.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:client/utils/sql_highlight.dart';
import 'package:client/widgets/button.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/menu.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/services/ai/chat.dart';
import 'package:client/models/ai.dart';
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
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String systemPrompt(SessionAIChatModel model) {
    String prompt = chatTemplate;
    if (model.dbType != null) {
      prompt = prompt.replaceAll("{dbType}", model.dbType!.name);
    }
    final tables = model.chatModel.tables[model.currentSchema ?? ""];
    // 通过metadata build table 信息
    final schema =
        model.metadata?.getChildren(MetaType.schema, model.currentSchema ?? "");

    if (tables == null || tables.isEmpty || schema == null) {
      return prompt.replaceAll("{tables}", "");
    }

    final tableInfos = schema.where((e) {
      if (e.type == MetaType.table && tables.containsKey(e.value)) {
        return true;
      }
      return false;
    });

    return prompt.replaceAll(
        "{tables}", tableInfos.map((e) => e.toString()).join("\n"));
  }

  Future<void> _sendMessage(
      AIChatId chatId, SessionAIChatModel chatModel) async {
    final text = _controller.text.trim();
    _controller.clear();

    // 调用AIChatService的chat方法
    await ref
        .read(aIChatServiceProvider.notifier)
        .chat(chatId, systemPrompt(chatModel), text);

    // 滚动到底部
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildMessage(
      WidgetRef ref, SessionAIChatModel model, AIChatMessageModel message) {
    switch (message.role) {
      case AIRole.user:
        return userMessageWidget(content: message.content);
      case AIRole.assistant:
        return assistantMessageWidget(ref, model, content: message.content);
    }
  }

  // 用户消息组件
  Widget userMessageWidget({required String content}) {
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
            content,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  // AI助手消息组件
  Widget assistantMessageWidget(WidgetRef ref, SessionAIChatModel model,
      {required String content}) {
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
          child: GptMarkdownTheme(
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
              content,
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
                              final sqlResultsServices =
                                  ref.read(sQLResultsServicesProvider.notifier);

                              SQLResultModel? resultModel = sqlResultsServices
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
        ),
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      final position = _scrollController.position;
      final target = position.maxScrollExtent;
      // 如果已经很接近底部，直接跳转，避免多次动画导致抖动
      if ((position.pixels - target).abs() < 20) {
        _scrollController.jumpTo(target);
      } else {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
        );
      }
    }
  }

  bool _isTableSelected(SessionAIChatModel model, String tableName) {
    return model.chatModel.tables.containsKey(model.currentSchema ?? "") &&
        model.chatModel.tables[model.currentSchema ?? ""]!
            .containsKey(tableName);
  }

  @override
  Widget build(BuildContext context) {
    SessionAIChatModel? model = ref.watch(sessionAIChatNotifierProvider);
    if (model == null) {
      return const Spacer();
    }
    final messages = model.chatModel.messages;
    final services = ref.read(aIChatServiceProvider.notifier);

    // 简单实现：AIChatState.waiting时每帧都滚动到底部
    if (model.chatModel.state == AIChatState.waiting) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
    return Column(
      children: [
        // 聊天内容
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: messages.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              return _buildMessage(ref, model, messages[index]);
            },
          ),
        ),
        const SizedBox(height: kSpacingMedium),
        // 输入框
        Padding(
          padding:
              const EdgeInsets.fromLTRB(kSpacingMedium, 0, kSpacingMedium, 0),
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
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: Theme.of(context).textTheme.bodyMedium,
                        controller: _controller,
                        minLines: 1,
                        maxLines: 5,
                        enabled: model.chatModel.state != AIChatState.waiting,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText:
                              AppLocalizations.of(context)!.ai_chat_input_tip,
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: kSpacingSmall,
                              horizontal: kSpacingTiny),
                        ),
                        onSubmitted: (_) =>
                            _sendMessage(model.chatModel.id, model),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: kSpacingSmall),
                Row(
                  children: [
                    const SizedBox(width: kSpacingTiny),
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
                              services.updateAgent(
                                  model.chatModel.id, agent.id);
                            },
                          ),
                      ],
                      child: Container(
                        constraints: const BoxConstraints(
                          maxWidth: 120,
                        ),
                        padding: const EdgeInsets.fromLTRB(kSpacingSmall,
                            kSpacingTiny, kSpacingSmall, kSpacingTiny),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 1,
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHigh,
                          ),
                        ),
                        child: Text(
                          model.llmAgents.agents[model.chatModel.llmAgentId]
                                  ?.setting.name ??
                              "-",
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                    const SizedBox(width: kSpacingTiny),
                    OverlayMenu(
                      isAbove: true,
                      spacing: kSpacingTiny,
                      tabs: [
                        for (MetaDataNode table in model.metadata?.getChildren(
                                MetaType.schema, model.currentSchema ?? "") ??
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
                                    Text(
                                      table.value,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
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
                      child: IntrinsicWidth(
                        child: Container(
                          constraints: const BoxConstraints(
                            maxWidth: 80,
                          ),
                          padding: const EdgeInsets.fromLTRB(kSpacingSmall,
                              kSpacingTiny, kSpacingSmall, kSpacingTiny),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              width: 1,
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHigh,
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
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      iconSize: kIconSizeTiny,
                      icon: const Icon(Icons.cleaning_services),
                      onPressed: () {
                        services.cleanMessages(model.chatModel.id);
                      },
                    ),
                    IconButton(
                      iconSize: kIconSizeTiny,
                      icon: const Icon(Icons.send),
                      onPressed: model.chatModel.state == AIChatState.waiting
                          ? null
                          : () => _sendMessage(model.chatModel.id, model),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: kSpacingMedium),
      ],
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
