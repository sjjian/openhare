import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai.freezed.dart';

abstract class LLMAgentRepo {
  LLMAgentsModel getLLMAgents();
  void create(LLMAgentSettingModel setting);
  void delete(LLMAgentId id);
  LLMAgentModel? getLLMAgentById(LLMAgentId id);
  void updateStatus(LLMAgentId id, LLMAgentState state);
  void updateSetting(LLMAgentId id, LLMAgentSettingModel setting);
}

abstract class AIChatRepo {
  AIChatModel create(AIChatModel model);
  void delete(AIChatId id);
  void updateLLMAgent(AIChatId id, LLMAgentModel llmAgent);
  void updateMessages(AIChatId id, List<AIChatMessageModel> messages);
  void updateState(AIChatId id, AIChatState state);
  void updateTables(AIChatId id, List<String> tables);
  AIChatModel? getAIChatById(AIChatId id);
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
    required LLMAgentModel llmAgent,
    required List<String> tables,
    required List<AIChatMessageModel> messages,
    required AIChatState state,
  }) = _AIChatModel;
}

@freezed
abstract class AIChatMessageModel with _$AIChatMessageModel {
  const factory AIChatMessageModel({
    required AIRole role,
    required String content,
  }) = _AIChatMessageModel;
}
