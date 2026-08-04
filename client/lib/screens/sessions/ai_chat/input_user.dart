import 'package:client/l10n/app_localizations.dart';
import 'package:client/models/ai.dart';
import 'package:client/models/sessions.dart';
import 'package:client/services/ai/agent.dart';
import 'package:client/services/ai/chat.dart';
import 'package:client/services/ai/prompt.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:client/widgets/button.dart';
import 'package:client/widgets/code_auto_complete.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/menu.dart';
import 'package:client/widgets/mention_text.dart';
import 'package:client/widgets/sql_highlight.dart';
import 'package:client/widgets/tooltip.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sql_complete/sql_complete.dart';

class SessionChatInputCard extends ConsumerStatefulWidget {
  final SessionAIChatModel model;
  final MentionTextEditingController controller;
  final TextEditingController modelSearchTextController;
  final VoidCallback? onSendMessage;

  const SessionChatInputCard({
    super.key,
    required this.model,
    required this.controller,
    required this.modelSearchTextController,
    this.onSendMessage,
  });

  @override
  ConsumerState<SessionChatInputCard> createState() => _SessionChatInputCardState();
}

class _SessionChatInputCardState extends ConsumerState<SessionChatInputCard> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onInputChanged);
    super.dispose();
  }

  void _onInputChanged() {
    setState(() {});
  }

  bool _hasInputContent() {
    final text = widget.controller.displayText;
    return text.trim().isNotEmpty;
  }

  String _formatTokens(int v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return '$v';
  }

  String _buildBudgetTooltip(BuildContext context, AIChatProgressModel b) {
    final l10n = AppLocalizations.of(context)!;
    final loopLimit = b.loopLimit <= 0 ? '-' : '${b.loopLimit}';
    final lines = <String>[
      l10n.ai_chat_budget_tooltip_loop(
        b.loopUsed.toString(),
        loopLimit,
      ),
      l10n.ai_chat_budget_tooltip_context(
        _formatTokens(b.totalTokens),
        _formatTokens(b.contextTokenLimit),
      ),
    ];
    if (b.contextHardStopped) {
      lines.add(l10n.ai_chat_budget_context_hard_stopped);
    }
    return lines.join('\n');
  }

  Widget _buildBudgetIndicator(BuildContext context, AIChatProgressModel b) {
    final contextColor = b.contextHardStopped
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary; // 上下文进度条颜色

    return Tooltip(
      message: _buildBudgetTooltip(context, b),
      waitDuration: const Duration(milliseconds: 250),
      child: SizedBox(
        width: kIconSizeSmall,
        height: kIconSizeSmall,
        child: CircularProgressIndicator(
          value: b.contextProgress,
          strokeWidth: 3,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest, // 上下文进度条背景色
          valueColor: AlwaysStoppedAnimation(contextColor),
        ),
      ),
    );
  }

  String _buildTableRef(SessionAIChatModel chatModel, Iterable<String> mentionedTables) {
    if (chatModel.metadata == null || chatModel.currentSchema == null) {
      return '';
    }
    final schemaNode = getNodeByDatabaseRef(chatModel.metadata!.metadata, chatModel.currentSchema!);
    if (schemaNode == null || mentionedTables.isEmpty) {
      return '';
    }
    final b = StringBuffer();
    for (final tableName in mentionedTables) {
      final tableNode = schemaNode.getNode(MetaType.table, tableName);
      // 直接复用 MetaDataNode.toString() 的 JSON 序列化（见 db_driver_metadata.dart）
      if (tableNode != null) {
        b.writeln(tableNode.toString());
      }
    }
    return b.toString().trimRight();
  }

  Future<void> _sendMessage(AIChatId chatId, SessionAIChatModel chatModel) async {
    final text = widget.controller.displayText;
    if (text.trim().isEmpty) return;

    // 如果用户通过 @ 提及了表，则把表结构信息放到 ref 里
    final mentionedTables = widget.controller.segments.whereType<MentionSegment>().map((s) => s.label).toList();
    final refText = _buildTableRef(chatModel, mentionedTables);

    // 调用AIChatService的chat方法
    await ref
        .read(aIChatServiceProvider.notifier)
        .chat(
          chatId,
          chatModel.llmAgents.lastUsedLLMAgent!.id,
          genChatSystemPrompt(chatModel),
          message: text,
          refText: refText.isEmpty ? null : refText,
        );
    widget.onSendMessage?.call();
  }

  @override
  Widget build(BuildContext context) {
    final services = ref.read(aIChatServiceProvider.notifier);
    final progress = widget.model.chatOverviewModel.progress;
    final hardStopped = progress.contextHardStopped;

    return Padding(
      padding: const EdgeInsets.fromLTRB(kSpacingSmall - 5, 0, kSpacingSmall, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(kSpacingSmall, kSpacingSmall, kSpacingSmall, kSpacingTiny),
        // 设置一个圆角
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow, // 输入框背景色
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant, // 输入框边框颜色
          ),
        ),
        child: Column(
          children: [
            // 输入框
            ChatInputFieldWidget(
              model: widget.model,
              controller: widget.controller,
              onSubmitted: (widget.model.canSendMessage() && !hardStopped && _hasInputContent())
                  ? () => _sendMessage(widget.model.chatOverviewModel.id, widget.model)
                  : null,
              enabled: !hardStopped,
            ),

            const SizedBox(height: kSpacingSmall),

            // 工具栏
            Row(
              children: [
                const SizedBox(width: kSpacingTiny),
                // 模型选择
                ModelSelectorWidget(model: widget.model, modelSearchTextController: widget.modelSearchTextController),
                const SizedBox(width: kSpacingTiny),
                AIChatConfigBar(model: widget.model),
                const Spacer(),

                _buildBudgetIndicator(context, progress),
                const SizedBox(width: kSpacingTiny),

                // 清空聊天记录
                RectangleIconButton.small(
                  tooltip: AppLocalizations.of(context)!.button_tooltip_clear_chat,
                  icon: Icons.cleaning_services,
                  onPressed: widget.model.canClearMessage()
                      ? () => services.cleanMessages(widget.model.chatOverviewModel.id)
                      : null,
                ),

                // 发送消息 / 中止生成
                (widget.model.chatOverviewModel.state == AIChatState.waiting)
                    ? RectangleIconButton(
                        size: kIconButtonSizeSmall,
                        iconSize: kIconSizeMedium,
                        padding: 2,
                        tooltip: AppLocalizations.of(context)!.button_tooltip_stop_chat,
                        icon: Icons.stop_circle,
                        onPressed: () => services.cancelChat(widget.model.chatOverviewModel.id),
                      )
                    : RectangleIconButton.small(
                        tooltip: AppLocalizations.of(context)!.button_tooltip_send_message,
                        icon: Icons.send,
                        onPressed: (widget.model.canSendMessage() && !hardStopped && _hasInputContent())
                            ? () {
                                _sendMessage(widget.model.chatOverviewModel.id, widget.model);
                                widget.controller.clear();
                              }
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

/// AI 对话发送确认选项（与会话栏「查询选项」同风格的 Overlay）
class AIChatConfigBar extends ConsumerStatefulWidget {
  final SessionAIChatModel model;

  const AIChatConfigBar({super.key, required this.model});

  @override
  ConsumerState<AIChatConfigBar> createState() => _AIChatConfigBarState();
}

class _AIChatConfigBarState extends ConsumerState<AIChatConfigBar> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final header = OverlayMenuHeader.tile(
      icon: Icons.tune,
      title: l10n.ai_chat_config_title,
      subtitle: l10n.ai_chat_config_subtitle,
    );

    return OverlayMenu(
      closeOnSelectItem: false,
      spacing: kSpacingTiny,
      maxHeight: 400,
      maxWidth: 420,
      isAbove: true,
      header: header,
      footer: OverlayMenuFooter(height: kSpacingMedium, child: const SizedBox.shrink()),
      tabs: [
        OverlayConfigItem.checkbox(
          height: 84,
          title: l10n.ai_chat_config_ask_dql,
          description: l10n.ai_chat_config_ask_dql_desc,
          value: widget.model.config.askDQL,
          onChanged: (v) {
            setState(() {
              ref
                  .read(sessionsServicesProvider.notifier)
                  .updateSessionConfig(
                    widget.model.sessionId,
                    widget.model.config.copyWith(askDQL: v),
                  );
            });
          },
        ),
        OverlayConfigItem.checkbox(
          height: 84,
          title: l10n.ai_chat_config_ask_no_dql,
          description: l10n.ai_chat_config_ask_no_dql_desc,
          value: widget.model.config.askNoDQL,
          onChanged: (v) {
            setState(() {
              ref
                  .read(sessionsServicesProvider.notifier)
                  .updateSessionConfig(
                    widget.model.sessionId,
                    widget.model.config.copyWith(askNoDQL: v),
                  );
            });
          },
        ),
        OverlayConfigItem.checkbox(
          height: 84,
          title: l10n.ai_chat_config_ask_dangerous,
          description: l10n.ai_chat_config_ask_dangerous_desc,
          value: widget.model.config.askDangerousSQL,
          onChanged: (v) {
            setState(() {
              ref
                  .read(sessionsServicesProvider.notifier)
                  .updateSessionConfig(
                    widget.model.sessionId,
                    widget.model.config.copyWith(askDangerousSQL: v),
                  );
            });
          },
        ),
      ],
      child: RectangleIconButton.medium(
        tooltip: l10n.button_tooltip_ai_chat_config,
        icon: Icons.tune,
        onPressed: null,
        iconColor: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

/// 模型选择器组件
class ModelSelectorWidget extends ConsumerStatefulWidget {
  final SessionAIChatModel model;
  final TextEditingController modelSearchTextController;

  const ModelSelectorWidget({super.key, required this.model, required this.modelSearchTextController});

  @override
  ConsumerState<ModelSelectorWidget> createState() => _ModelSelectorWidgetState();
}

class _ModelSelectorWidgetState extends ConsumerState<ModelSelectorWidget> {
  void _onModelSearchChanged() {
    setState(() {});
  }

  List<LLMAgentModel> _filteredAgents(SessionAIChatModel model, String searchText) {
    if (searchText.isEmpty) {
      return model.llmAgents.agents.values.toList();
    }
    return model.llmAgents.agents.values
        .where((agent) => agent.setting.name.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
  }

  bool _isModelSelected(SessionAIChatModel model, LLMAgentModel agent) {
    return model.llmAgents.lastUsedLLMAgent?.id == agent.id;
  }

  @override
  Widget build(BuildContext context) {
    // 模型选择工具栏
    final modelToolWidget = Container(
      constraints: const BoxConstraints(
        maxWidth: 120,
      ),
      padding: const EdgeInsets.fromLTRB(kSpacingSmall, kSpacingTiny, kSpacingSmall, kSpacingTiny),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest, // 模型选择工具栏背景色, 父组件背景色是 surfaceContainer
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant, // 模型选择工具栏边框颜色
        ),
      ),
      child: Text(
        widget.model.llmAgents.lastUsedLLMAgent?.setting.name ?? "-",
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );

    return OverlayMenu(
      isAbove: true,
      spacing: kSpacingTiny,
      tabs: [
        for (var agent in _filteredAgents(widget.model, widget.modelSearchTextController.text))
          OverlayMenuItem(
            height: 24,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(kSpacingSmall, 0, kSpacingSmall, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    // 如果agent是当前选中的模型，则显示选中状态
                    _isModelSelected(widget.model, agent)
                        ? const Icon(
                            Icons.check_circle,
                            size: kIconSizeSmall,
                            color: Colors.green,
                          )
                        : const Icon(
                            Icons.circle_outlined,
                            size: kIconSizeSmall,
                          ),
                    const SizedBox(width: kSpacingTiny),
                    Expanded(
                      child: TooltipText(text: agent.setting.name, style: Theme.of(context).textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
            ),
            onTabSelected: () {
              ref.read(lLMAgentServiceProvider.notifier).updateLastUsedLLMAgent(agent.id);
            },
          ),
      ],
      header: OverlayMenuHeader(height: 10, child: SizedBox()), // 顶部空间
      footer: OverlayMenuFooter(
        height: 36,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(kSpacingSmall, kSpacingTiny, kSpacingSmall, kSpacingTiny),
          child: SearchBarTheme(
            data: SearchBarThemeData(
              textStyle: WidgetStatePropertyAll(Theme.of(context).textTheme.bodySmall),
              backgroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.surfaceContainerLowest,
              ), // 模型选择工具栏搜索框背景色
              elevation: const WidgetStatePropertyAll(0),
              constraints: const BoxConstraints(minHeight: 24),
            ),
            child: SearchBar(
              side: WidgetStatePropertyAll(
                BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant, // 模型选择工具栏搜索框边框颜色
                ),
              ),
              controller: widget.modelSearchTextController,
              onChanged: (value) {
                _onModelSearchChanged();
              },
              trailing: const [
                Icon(
                  Icons.search,
                  size: kIconSizeSmall,
                ),
              ],
            ),
          ),
        ),
      ),
      child: modelToolWidget,
    );
  }
}

/// 表提示类，复用 FuzzyMatchCodePrompt 的逻辑
class _TablePrompt extends FuzzyMatchCodePrompt {
  const _TablePrompt({required super.word});
}

/// 聊天输入框组件
class ChatInputFieldWidget extends ConsumerStatefulWidget {
  final SessionAIChatModel model;
  final MentionTextEditingController controller;
  final VoidCallback? onSubmitted;
  final bool enabled;

  const ChatInputFieldWidget({
    super.key,
    required this.model,
    required this.controller,
    this.onSubmitted,
    this.enabled = true,
  });

  @override
  ConsumerState<ChatInputFieldWidget> createState() => _ChatInputFieldWidgetState();
}

class _ChatInputFieldWidgetState extends ConsumerState<ChatInputFieldWidget> {
  List<String> _getTableNames() {
    if (widget.model.metadata == null || widget.model.currentSchema == null) {
      return [];
    }
    final tableNodes = getNodeByDatabaseRef(
      widget.model.metadata!.metadata,
      widget.model.currentSchema!,
    )?.getChildren(MetaType.table);
    if (tableNodes == null) {
      return [];
    }
    return tableNodes.map((e) => e.value).toList();
  }

  List<String> _filterAndSortTables(List<String> allTables, String query) {
    if (query.isEmpty) {
      return allTables;
    }

    // 使用模糊匹配进行过滤和排序
    final List<(String, double)> scoredTables = [];
    for (final table in allTables) {
      final result = FuzzyMatch.matchWithResult(query, table);
      if (result.matched) {
        scoredTables.add((table, result.score));
      }
    }

    // 按分数排序（降序）
    scoredTables.sort((a, b) => b.$2.compareTo(a.$2));
    return scoredTables.map((item) => item.$1).toList();
  }

  static TextStyle _tableTextBaseStyle(BuildContext context) => GoogleFonts.robotoMono(
    textStyle: Theme.of(context).textTheme.bodySmall,
    color: Theme.of(context).colorScheme.onSurface,
  );

  Widget _buildTableText(BuildContext context, String table, String query) {
    final baseStyle = _tableTextBaseStyle(context);
    if (query.isEmpty) {
      return Text(table, style: baseStyle, maxLines: 1, overflow: TextOverflow.ellipsis);
    }
    final textSpan = _TablePrompt(word: table).getTextSpan(context, query);
    final highlightStyle = baseStyle.copyWith(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.bold,
    );
    return Text.rich(
      _adjustTextSpanStyle(textSpan, baseStyle, highlightStyle),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 调整 TextSpan 样式以匹配表搜索的样式（bodySmall + primary 颜色）
  TextSpan _adjustTextSpanStyle(TextSpan textSpan, TextStyle baseStyle, TextStyle highlightStyle) {
    if (textSpan.children == null) {
      final isHighlight = textSpan.style?.color == SQLHighlightColor.keyword;
      return TextSpan(
        text: textSpan.text,
        style: isHighlight ? highlightStyle : (textSpan.style ?? baseStyle).copyWith(fontSize: baseStyle.fontSize),
      );
    }
    final adjustedChildren = textSpan.children!
        .map((span) => span is TextSpan ? _adjustTextSpanStyle(span, baseStyle, highlightStyle) : span)
        .toList();
    return TextSpan(
      children: adjustedChildren,
      style: textSpan.style?.copyWith(fontSize: baseStyle.fontSize) ?? baseStyle,
    );
  }

  List<MentionCandidate> _mentionCandidates(String query) {
    final names = _filterAndSortTables(_getTableNames(), query);
    return names.map((n) => MentionCandidate(label: n)).toList();
  }

  Widget _mentionItemBuilder(BuildContext context, MentionCandidate c, String query) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
      child: Row(
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedTable,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(width: kSpacingTiny),
          Expanded(
            child: _buildTableText(context, c.label, query),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MentionTextField(
      controller: widget.controller,
      style: Theme.of(context).textTheme.bodyMedium,
      textAlignVertical: TextAlignVertical.center,
      minLines: 1,
      maxLines: 5,
      enabled: widget.enabled && widget.model.chatOverviewModel.state != AIChatState.waiting,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.ai_chat_input_tip,
        border: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: kSpacingSmall, horizontal: kSpacingTiny),
      ),
      mentionCandidatesBuilder: _mentionCandidates,
      mentionItemBuilder: _mentionItemBuilder,
      onSubmitted: (_) {
        widget.onSubmitted?.call();
        widget.controller.clear();
      },
    );
  }
}
