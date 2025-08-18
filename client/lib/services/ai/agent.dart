import 'package:client/models/ai.dart';
import 'package:client/repositories/ai/agent.dart';
import 'package:client/services/ai/prompt.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:llm_dart/llm_dart.dart';

part 'agent.g.dart';

@Riverpod(keepAlive: true)
class LLMAgentService extends _$LLMAgentService {
  @override
  LLMAgentsModel build() {
    final repo = ref.watch(lLMAgentRepoProvider);
    return repo.getLLMAgents();
  }

  void create(LLMAgentSettingModel setting) {
    ref.read(lLMAgentRepoProvider).create(setting);
    ref.invalidateSelf();
  }

  void delete(LLMAgentId id) {
    ref.read(lLMAgentRepoProvider).delete(id);
    ref.invalidateSelf();
  }

  void updateSetting(LLMAgentId id, LLMAgentSettingModel setting) {
    ref.read(lLMAgentRepoProvider).updateSetting(id, setting);
    ref.invalidateSelf();
  }

  void updateStatus(LLMAgentId id, LLMAgentState state) {
    ref.read(lLMAgentRepoProvider).updateStatus(id, state);
    ref.invalidateSelf();
  }

  Stream<ChatStreamEvent> callStream(LLMAgentId id, String systemMessage,
      List<AIChatMessageModel> messages) async* {
    final model = ref.read(lLMAgentRepoProvider).getLLMAgentById(id);
    if (model == null) {
      return;
    }
    final provider = await ai()
        .deepseek()
        .baseUrl(model.setting.baseUrl)
        .apiKey(model.setting.apiKey)
        .model(model.setting.modelName)
        .temperature(0.7)
        .build();

    final chatMessages = [
      ChatMessage.system(systemMessage),
      for (var message in messages)
        message.role == AIRole.user
            ? ChatMessage.user(message.content)
            : ChatMessage.assistant(message.content)
    ];

    yield* provider.chatStream(chatMessages);
  }

  Future<String> call(LLMAgentId id, String systemMessage,
      List<AIChatMessageModel> messages) async {
    final model = ref.read(lLMAgentRepoProvider).getLLMAgentById(id);
    if (model == null) {
      return '';
    }
    final provider = await ai()
        .deepseek()
        .baseUrl(model.setting.baseUrl)
        .apiKey(model.setting.apiKey)
        .model(model.setting.modelName)
        .temperature(0.7)
        .build();

    final chatMessages = [
      ChatMessage.system(systemMessage),
      for (var message in messages)
        message.role == AIRole.user
            ? ChatMessage.user(message.content)
            : ChatMessage.assistant(message.content)
    ];
    final response = await provider.chat(chatMessages);
    return response.text ?? '';
  }

  Future<void> ping(LLMAgentId id) async {
    try {
      final model = ref.read(lLMAgentRepoProvider).getLLMAgentById(id);
      if (model == null) {
        return;
      }
      final repo = ref.read(lLMAgentRepoProvider);
      repo.updateStatus(id, LLMAgentState.testing);
      ref.invalidateSelf();

      final provider = await ai()
          .deepseek()
          .baseUrl(model.setting.baseUrl)
          .apiKey(model.setting.apiKey)
          .model(model.setting.modelName)
          .temperature(0.7)
          .build();

      final response = await provider.chat([ChatMessage.user(testTemplate)]);

      // 如果token为0，则认为接口不可用
      final available = (response.usage?.totalTokens ?? 0) > 0;
      repo.updateStatus(
          id, available ? LLMAgentState.available : LLMAgentState.unavailable);
    } catch (e) {
      ref
          .read(lLMAgentRepoProvider)
          .updateStatus(id, LLMAgentState.unavailable);
    } finally {
      ref.invalidateSelf();
    }
  }
}

@Riverpod(keepAlive: true)
class LLMAgentNotifier extends _$LLMAgentNotifier {
  @override
  LLMAgentsModel build() {
    return ref.watch(lLMAgentServiceProvider);
  }
}
