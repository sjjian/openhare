import 'package:client/models/ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat.g.dart';

class AIChatRepoImpl extends AIChatRepo {
  final Map<AIChatId, AIChatModel> _aiChats = {};

  AIChatRepoImpl();

  @override
  AIChatModel create(AIChatModel model) {
    if (_aiChats.containsKey(model.id)) {
      return _aiChats[model.id]!;
    }
    _aiChats[model.id] = model;
    return model;
  }

  @override
  void updateMessages(AIChatId id, List<AIChatMessageModel> messages) {
    _aiChats[id] = _aiChats[id]!.copyWith(messages: messages);
  }

  @override
  void updateLLMAgent(AIChatId id, LLMAgentModel llmAgent) {
    _aiChats[id] = _aiChats[id]!.copyWith(llmAgent: llmAgent);
  }

  @override
  void updateState(AIChatId id, AIChatState state) {
    _aiChats[id] = _aiChats[id]!.copyWith(state: state);
  }

  @override
  void updateTables(AIChatId id, List<String> tables) {
    _aiChats[id] = _aiChats[id]!.copyWith(tables: tables);
  }

  @override
  void delete(AIChatId id) {
    _aiChats.remove(id);
  }

  @override
  AIChatModel? getAIChatById(AIChatId id) {
    return _aiChats[id];
  }
}

@Riverpod(keepAlive: true)
AIChatRepo aiChatRepo(Ref ref) {
  return AIChatRepoImpl();
}
