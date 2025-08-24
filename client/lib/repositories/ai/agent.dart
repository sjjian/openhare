import 'package:client/models/ai.dart';
import 'package:client/repositories/repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:client/repositories/objectbox.g.dart';
import 'package:objectbox/objectbox.dart';

part 'agent.g.dart';

@Entity()
class LLMApiSettingStorage {
  @Id(assignable: true)
  int id;

  String name;
  String baseUrl;
  String apiKey;
  String modelName;

  @Property(type: PropertyType.dateNano)
  DateTime createdAt;

  @Property(type: PropertyType.dateNano)
  DateTime lastChatUsedAt;

  LLMApiSettingStorage({
    this.id = 0,
    required this.name,
    required this.baseUrl,
    required this.apiKey,
    required this.modelName,
    DateTime? createdAt,
    DateTime? lastChatUsedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastChatUsedAt = lastChatUsedAt ?? DateTime(1970, 1, 1);
}

class LLMAgentRepoImpl implements LLMAgentRepo {
  final ObjectBox ob;
  final Box<LLMApiSettingStorage> _llmAgentSettingBox;
  final Map<LLMAgentId, LLMAgentStatusModel> _status = {};

  LLMAgentRepoImpl(this.ob) : _llmAgentSettingBox = ob.store.box();

  LLMAgentStatusModel _getStatus(LLMAgentId id) {
    if (!_status.containsKey(id)) {
      _status[id] = const LLMAgentStatusModel(state: LLMAgentState.unknown);
    }
    return _status[id]!;
  }

  LLMAgentModel _toModel(LLMApiSettingStorage setting) {
    return LLMAgentModel(
        id: LLMAgentId(value: setting.id),
        setting: LLMAgentSettingModel(
          name: setting.name,
          baseUrl: setting.baseUrl,
          apiKey: setting.apiKey,
          modelName: setting.modelName,
        ),
        status: _getStatus(
          LLMAgentId(value: setting.id),
        ));
  }

  @override
  LLMAgentsModel getLLMAgents() {
    final agents = _llmAgentSettingBox.getAll();
    return LLMAgentsModel(
      agents: agents
          .map((e) => _toModel(e))
          .fold<Map<LLMAgentId, LLMAgentModel>>(
              {}, (acc, e) => acc..[e.id] = e),
      lastUsedLLMAgent: getLastUsedLLMAgent(),
    );
  }

  @override
  LLMAgentModel? getLastUsedLLMAgent() {
    final agent = _llmAgentSettingBox
        .query()
        .order(LLMApiSettingStorage_.lastChatUsedAt, flags: Order.descending)
        .build()
        .findFirst();
    return agent != null ? _toModel(agent) : null;
  }

  @override
  void updateLastUsedLLMAgent(LLMAgentId id) {
    final agent = _llmAgentSettingBox.get(id.value);
    if (agent == null) {
      return;
    }
    agent.lastChatUsedAt = DateTime.now();
    _llmAgentSettingBox.put(agent);
  }

  @override
  void create(LLMAgentSettingModel setting) {
    final model = _llmAgentSettingBox.put(LLMApiSettingStorage(
        name: setting.name,
        baseUrl: setting.baseUrl,
        apiKey: setting.apiKey,
        modelName: setting.modelName));

    _status[LLMAgentId(value: model)] =
        const LLMAgentStatusModel(state: LLMAgentState.unknown);
  }

  @override
  void delete(LLMAgentId id) {
    _llmAgentSettingBox.remove(id.value);
    _status.remove(id);
  }

  @override
  LLMAgentModel? getLLMAgentById(LLMAgentId id) {
    final setting = _llmAgentSettingBox.get(id.value);
    if (setting == null) {
      return null;
    }
    return _toModel(setting);
  }

  @override
  void updateStatus(LLMAgentId id, LLMAgentState state) {
    _status[id] = LLMAgentStatusModel(state: state);
  }

  @override
  void updateSetting(LLMAgentId id, LLMAgentSettingModel setting) {
    _llmAgentSettingBox.put(LLMApiSettingStorage(
        id: id.value,
        name: setting.name,
        baseUrl: setting.baseUrl,
        apiKey: setting.apiKey,
        modelName: setting.modelName));

    // 更新setting后，状态重置为unknown
    _status[id] = const LLMAgentStatusModel(state: LLMAgentState.unknown);
  }
}

@Riverpod(keepAlive: true)
LLMAgentRepo lLMAgentRepo(Ref ref) {
  ObjectBox ob = ref.watch(objectboxProvider);
  return LLMAgentRepoImpl(ob);
}
