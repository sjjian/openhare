import 'dart:async';

import 'package:client/models/sessions.dart';
import 'package:client/services/sessions/session_sql_result.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:client/widgets/button.dart';
import 'package:client/widgets/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/services/ai/chat.dart';
import 'package:client/models/ai.dart';
import 'package:gpt_markdown/custom_widgets/code_field.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:flutter/services.dart';

class SessionDrawerChat extends ConsumerStatefulWidget {
  const SessionDrawerChat({Key? key}) : super(key: key);

  @override
  ConsumerState<SessionDrawerChat> createState() => _SessionDrawerChatState();
}

class _SessionDrawerChatState extends ConsumerState<SessionDrawerChat> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Future<void> _sendMessage(AIChatId chatId) async {
    final text = _controller.text.trim();
    _controller.clear();

    // 调用AIChatService的chat方法
    await ref.read(aIChatServiceProvider(chatId).notifier).chat(chatId, text);

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
        alignment: Alignment.centerRight,
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
            ),
            child: GptMarkdown(
              content,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              codeBuilder: (context, name, code, closed) {
                if (name == "sql") {
                  return SqlChatField(
                      codes: code,
                      onRun: (code) {
                        final sqlResultsServices =
                            ref.read(sQLResultsServicesProvider.notifier);

                        SQLResultModel? resultModel = sqlResultsServices
                            .selectedSQLResult(model.sessionId);

                        resultModel ??=
                            sqlResultsServices.addSQLResult(model.sessionId);

                        sqlResultsServices.loadFromQuery(
                            resultModel.resultId, code);
                      });
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

  @override
  Widget build(BuildContext context) {
    SessionAIChatModel? model = ref.watch(sessionAIChatNotifierProvider);
    if (model == null) {
      return const Spacer();
    }
    final messages = model.chatModel.messages;

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
            padding: const EdgeInsets.all(kSpacingSmall),
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
                        decoration: const InputDecoration(
                          hintText: "请输入你的问题...",
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                        ),
                        onSubmitted: (_) => _sendMessage(model.chatModel.id),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // 下拉菜单button 可以选择agent
                    Text(
                      model.chatModel.llmAgent.setting.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      iconSize: kIconSizeTiny,
                      icon: const Icon(Icons.send),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: model.chatModel.state == AIChatState.waiting
                          ? null
                          : () => _sendMessage(model.chatModel.id),
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
  final Function(String) onRun;
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
                // iconColor: connIsIdle(model) ? Colors.green : Colors.grey,
                onPressed: () {
                  widget.onRun(widget.codes);
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
            child: Text(
              widget.codes,
            ),
          ),
        ],
      ),
    );
  }
}
