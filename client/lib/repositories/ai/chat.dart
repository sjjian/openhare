import 'package:client/models/ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat.g.dart';

class AIChatRepoImpl extends AIChatRepo {
  final Map<AIChatId, AIChatModel> _aiChats = {};

  AIChatRepoImpl();

  @override
  AIChatListModel getAIChatList() {
    return AIChatListModel(chats: _aiChats);
  }

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
  void updateState(AIChatId id, AIChatState state) {
    _aiChats[id] = _aiChats[id]!.copyWith(state: state);
  }

  @override
  void delete(AIChatId id) {
    _aiChats.remove(id);
  }

  @override
  AIChatModel? getAIChatById(AIChatId id) {
    return _aiChats[id];
  }

  @override
  void updateTables(AIChatId id, String schema, Map<String, String> tables) {
    final allTables = _aiChats[id]!.tables;
    final newTables = Map<String, Map<String, String>>.from(allTables);
    newTables[schema] = tables;
    _aiChats[id] = _aiChats[id]!.copyWith(tables: newTables);
  }
}

@Riverpod(keepAlive: true)
AIChatRepo aiChatRepo(Ref ref) {
  return AIChatRepoImpl();
}
