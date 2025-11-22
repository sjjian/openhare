import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai.freezed.dart';
part 'ai.g.dart';

abstract class LLMAgentRepo {
  LLMAgentsModel getLLMAgents();
  LLMAgentModel? getLastUsedLLMAgent();
  void updateLastUsedLLMAgent(LLMAgentId id);
  void create(LLMAgentSettingModel setting);
  void delete(LLMAgentId id);
  LLMAgentModel? getLLMAgentById(LLMAgentId id);
  void updateStatus(LLMAgentId id, LLMAgentStatusModel status);
  void updateSetting(LLMAgentId id, LLMAgentSettingModel setting);
}

abstract class AIChatRepo {
  AIChatListModel getAIChatList();
  AIChatModel create(AIChatModel model);
  void delete(AIChatId id);
  void updateMessages(AIChatId id, List<AIChatMessageModel> messages);
  void updateState(AIChatId id, AIChatState state);
  AIChatModel? getAIChatById(AIChatId id);
  void updateTables(AIChatId id, String schema, Map<String, String> tables);
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
}

@freezed
abstract class AIChatId with _$AIChatId {
  const factory AIChatId({
    required int value,
  }) = _AIChatId;
}

@freezed
abstract class AIChatModel with _$AIChatModel {
  const factory AIChatModel({
    required AIChatId id,
    required Map<String, Map<String, String>> tables,
    required List<AIChatMessageModel> messages,
    required AIChatState state,
  }) = _AIChatModel;
}

@freezed
abstract class AIChatMessageModel with _$AIChatMessageModel {
  const factory AIChatMessageModel({
    required AIRole role,
    required String content,
    String? thinking,
    String? error,
  }) = _AIChatMessageModel;
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

  factory ExportFileNameResult.fromJson(Map<String, dynamic> json) =>
      _$ExportFileNameResultFromJson(json);
}