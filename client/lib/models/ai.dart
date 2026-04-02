import 'dart:convert';

import 'package:db_driver/db_driver.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:client/utils/state_value.dart';
import 'package:client/utils/time_format.dart';
import 'package:uuid/uuid.dart';

part 'ai.freezed.dart';
part 'ai.g.dart';

abstract class LLMAgentRepo {
  LLMAgentsModel getLLMAgents();
  LLMAgentModel? getLastUsedLLMAgent();
  void updateLastUsedLLMAgent(LLMAgentId id);
  LLMAgentId create(LLMAgentSettingModel setting, {LLMAgentStatusModel? status});
  void delete(LLMAgentId id);
  LLMAgentModel? getLLMAgentById(LLMAgentId id);
  void updateStatus(LLMAgentId id, LLMAgentStatusModel status);
  void updateSetting(LLMAgentId id, LLMAgentSettingModel setting, {LLMAgentStatusModel? status});
}

abstract class AIChatRepo {
  AIChatListModel getAIChatList();
  AIChatModel create(AIChatModel model);
  AIChatModel? getAIChatById(AIChatId id);
  void delete(AIChatId id);
  AIChatMessageItem? getMessageById(AIChatId id, AIChatMessageId messageId);
  void updateMessages(AIChatId id, List<AIChatMessageItem> messages);
  void addMessage(AIChatId id, AIChatMessageItem message);
  void updateState(AIChatId id, AIChatState state);
  void updateMessageById(AIChatId chatId, AIChatMessageId messageId, AIChatMessageItem message);
  void updateProgress(AIChatId id, AIChatProgressModel progress);
  bool isCancel(AIChatId id);
}

enum LLMAgentState {
  unknown,
  testing,
  available,
  unavailable,
}

@freezed
abstract class LLMAgentId with _$LLMAgentId {
  const factory LLMAgentId({
    required int value,
  }) = _LLMAgentId;
}

@freezed
abstract class LLMAgentSettingModel with _$LLMAgentSettingModel {
  const factory LLMAgentSettingModel({
    required String name,
    required String baseUrl,
    required String apiKey,
    required String modelName,
  }) = _LLMAgentSettingModel;
}

@freezed
abstract class LLMAgentStatusModel with _$LLMAgentStatusModel {
  const factory LLMAgentStatusModel({
    required LLMAgentState state,
    String? error,
  }) = _LLMAgentStatusModel;
}

@freezed
abstract class LLMAgentModel with _$LLMAgentModel {
  const factory LLMAgentModel({
    required LLMAgentId id,
    required LLMAgentSettingModel setting,
    required LLMAgentStatusModel status,
  }) = _LLMAgentModel;
}

@freezed
abstract class LLMAgentsModel with _$LLMAgentsModel {
  const factory LLMAgentsModel({
    required Map<LLMAgentId, LLMAgentModel> agents,
    required LLMAgentModel? lastUsedLLMAgent,
  }) = _LLMAgentsModel;
}

enum AIRole {
  user,
  assistant,
}

enum AIChatState {
  idle,
  waiting,
  error,
  cancel,
}

@freezed
abstract class AIChatId with _$AIChatId {
  const factory AIChatId({
    required int value,
  }) = _AIChatId;
}

@freezed
abstract class AIChatMessageId with _$AIChatMessageId {
  const factory AIChatMessageId({
    required String value,
  }) = _AIChatMessageId;

  /// 创建一个新的 AIChatMessageId，自动生成 UUID
  factory AIChatMessageId.generate() => AIChatMessageId(value: const Uuid().v4());
}

@freezed
abstract class AIChatProgressModel with _$AIChatProgressModel {
  const AIChatProgressModel._();

  const factory AIChatProgressModel({
    @Default(0) int loopUsed,
    @Default(50) int loopLimit,

    /// 真实 usage：total tokens（prompt + completion）
    @Default(0) int totalTokens,

    /// 上下文硬上限
    @Default(100000) int contextTokenLimit,
  }) = _AIChatProgressModel;

  /// 是否因为 loop 次数达到上限而停止
  bool get loopStopped => loopLimit > 0 && loopUsed >= loopLimit;

  /// 是否因为上下文达到硬上限而停止（硬停后不可继续）
  bool get contextHardStopped => contextTokenLimit > 0 && totalTokens >= contextTokenLimit;

  double get loopProgress {
    if (loopLimit <= 0) return 0;
    final v = loopUsed / loopLimit;
    if (v < 0) return 0;
    if (v > 1) return 1;
    return v;
  }

  double get contextProgress {
    if (contextTokenLimit <= 0) return 0;
    final v = totalTokens / contextTokenLimit;
    if (v < 0) return 0;
    if (v > 1) return 1;
    return v;
  }
}

@freezed
abstract class AIChatModel with _$AIChatModel {
  const factory AIChatModel({
    required AIChatId id,
    required List<AIChatMessageItem> messages,
    required AIChatState state,
    @Default(AIChatProgressModel()) AIChatProgressModel progress,
  }) = _AIChatModel;
}

// user message
@freezed
abstract class AIChatUserMessageModel with _$AIChatUserMessageModel {
  const AIChatUserMessageModel._();

  const factory AIChatUserMessageModel({
    required AIChatMessageId id,
    required String content,
    String? ref,
  }) = _AIChatUserMessageModel;

  String toMessage() {
    final refText = ref?.trim() ?? '';
    if (refText.isEmpty) return content;
    // ref 作为“额外上下文”，拼到 user message 里供 LLM 使用，但 UI 仍可只展示 content。
    return '$content\n\nref:\n$refText';
  }
}

@freezed
abstract class AIChatAssistantMessageModel with _$AIChatAssistantMessageModel {
  const AIChatAssistantMessageModel._();

  const factory AIChatAssistantMessageModel({
    required AIChatMessageId id,
    required String content,
    String? thinking, // reason_content from OpenAI API
    String? error,
    @Default(State.running) State status,
  }) = _AIChatAssistantMessageModel;

  String toMessage() {
    if (thinking != null && thinking!.isNotEmpty) {
      return '<think>\n$thinking\n</think>\n$content';
    }
    return content;
  }

  /// 判断思考是否结束
  /// 当 content 有值或者状态为完成时，思考结束
  bool get isThinkingCompleted {
    return content.isNotEmpty || status == State.done;
  }
}

enum AIChatToolQueryState {
  /// 初始化
  initializing,

  /// 等待用户在聊天内确认
  awaitingUserConfirm,

  /// 用户拒绝执行该 SQL
  rejected,

  /// 用户确认执行该 SQL
  approved,

  /// 已确认且正在向数据库发起请求
  running,

  /// 执行成功（[queryResult] 有值）
  finished,

  /// 执行失败或空结果（[errorMessage] 有值）
  failed,
}

@freezed
abstract class AIChatMessageToolCallQueryModel with _$AIChatMessageToolCallQueryModel {
  const AIChatMessageToolCallQueryModel._();

  const factory AIChatMessageToolCallQueryModel({
    required String query,

    /// 执行成功时的查询结果；仅 [finished] 时有值。
    BaseQueryResult? queryResult,

    /// 执行失败或空结果时的说明；仅 [failed] 时有值。
    String? errorMessage,
    Duration? executeTime,
    @Default(AIChatToolQueryState.running) AIChatToolQueryState execState,
  }) = _AIChatMessageToolCallQueryModel;

  bool get isAwaitingUserConfirm => execState == AIChatToolQueryState.awaitingUserConfirm;

  bool get isRejected => execState == AIChatToolQueryState.rejected;
  bool get isApproved => execState == AIChatToolQueryState.approved;
  bool get isFinished => execState == AIChatToolQueryState.finished;
  bool get isFailed => execState == AIChatToolQueryState.failed;
}

@freezed
abstract class AIChatMessageToolCallsModel with _$AIChatMessageToolCallsModel {
  const AIChatMessageToolCallsModel._();

  const factory AIChatMessageToolCallsModel({
    required AIChatMessageId id,
    required AIChatMessageToolCallQueryModel toolCall,
  }) = _AIChatMessageToolCallsModel;

  String toMessage() {
    final m = <String, dynamic>{
      'query': toolCall.query,
      'status': toolCall.execState.name,
    };

    switch (toolCall.execState) {
      case AIChatToolQueryState.failed:
        m['error'] = toolCall.errorMessage ?? '';
        break;
      case AIChatToolQueryState.finished:
        final result = toolCall.queryResult;
        if (result != null) {
          final executeTimeStr = toolCall.executeTime?.format() ?? '';
          final columns = result.columns
              .map(
                (c) => {
                  'name': c.name,
                  'type': c.dataType().name,
                },
              )
              .toList();
          final rows = result.rows.map((row) {
            final rowMap = <String, dynamic>{};
            for (var i = 0; i < row.values.length && i < result.columns.length; i++) {
              final column = result.columns[i];
              final value = row.values[i];
              rowMap[column.name] = value.getString();
            }
            return rowMap;
          }).toList();
          m['affectedRows'] = result.affectedRows.toString();
          m['executeTime'] = executeTimeStr;
          m['columns'] = columns;
          m['rows'] = rows;
        }
        break;
      case AIChatToolQueryState.initializing:
      case AIChatToolQueryState.awaitingUserConfirm:
      case AIChatToolQueryState.rejected:
      case AIChatToolQueryState.approved:
      case AIChatToolQueryState.running:
        break;
    }

    return jsonEncode(m);
  }
}

/// 消息项联合类型，可以存储消息或工具调用结果
@freezed
abstract class AIChatMessageItem with _$AIChatMessageItem {
  const factory AIChatMessageItem.userMessage(AIChatUserMessageModel message) = _AIChatMessageItemUserMessage;
  const factory AIChatMessageItem.assistantMessage(AIChatAssistantMessageModel message) =
      _AIChatMessageItemAssistantMessage;
  const factory AIChatMessageItem.toolsResult(AIChatMessageToolCallsModel toolsResult) = _AIChatMessageItemToolResult;
}

@freezed
abstract class AIChatListModel with _$AIChatListModel {
  const factory AIChatListModel({
    required Map<AIChatId, AIChatModel> chats,
  }) = _AIChatListModel;
}

/// AI生成的文件名和描述结果
@freezed
abstract class ExportFileNameResult with _$ExportFileNameResult {
  const factory ExportFileNameResult({
    required String fileName,
    String? desc,
  }) = _ExportFileNameResult;

  factory ExportFileNameResult.fromJson(Map<String, dynamic> json) => _$ExportFileNameResultFromJson(json);
}
