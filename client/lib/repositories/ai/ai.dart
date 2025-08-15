import 'package:client/models/ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai.g.dart';

class AIChatRepoImpl extends AIChatRepo {
  final Map<AIChatId, AIChatModel> _aiChats = {};

  AIChatRepoImpl();

  @override
  AIChatModel create(AIChatId id) {
    if (_aiChats.containsKey(id)) {
      return _aiChats[id]!;
    }
    final model = AIChatModel(
        id: id, messages: [], systemMessage: [], state: AIChatState.idle);
    _aiChats[id] = model;
    return model;
  }

  @override
  void update(AIChatModel model) {
    _aiChats[model.id] = model;
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
