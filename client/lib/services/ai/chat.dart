import 'package:client/models/ai.dart';
import 'package:client/repositories/ai/chat.dart';
import 'package:client/services/ai/agent.dart';
import 'package:client/services/ai/prompt.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:llm_dart/llm_dart.dart';

part 'chat.g.dart';

@Riverpod(keepAlive: true)
class AIChatService extends _$AIChatService {
  @override
  AIChatModel build(AIChatId id) {
    // 获取第一个agent
    final agent = ref.watch(lLMAgentServiceProvider).agents.values.first;
    // 先创建一个空的AIChatModel
    final model = AIChatModel(
        id: id,
        messages: [],
        state: AIChatState.idle,
        llmAgent: agent,
        tables: []);
    // 如果不存在则创建一个
    if (ref.watch(aiChatRepoProvider).getAIChatById(id) == null) {
      ref.watch(aiChatRepoProvider).create(model);
    }
    return ref.watch(aiChatRepoProvider).getAIChatById(id)!;
  }

  /// 进行AI对话，请求接口，存储消息并刷新
  /// 不再返回流，直接通过provider刷新state，UI通过监听state变化获取最新消息
  Future<void> chat(AIChatId id, String message) async {
    // 先用第一个
    final agent = ref.read(lLMAgentServiceProvider.notifier);

    final currentMessages = [
      ...state.messages,
      AIChatMessageModel(role: AIRole.user, content: message)
    ];

    state =
        state.copyWith(messages: currentMessages, state: AIChatState.waiting);

    ref.read(aiChatRepoProvider).updateState(id, AIChatState.waiting);
    ref.read(aiChatRepoProvider).updateMessages(id, currentMessages);

    // 2. 构造OpenAI请求
    final chatStream = agent.callStream(
        state.llmAgent.id,
        chatTemplate.replaceAll('{tables}', state.tables.join('\n')),
        currentMessages);

    String tmpReply = '';
    await for (final event in chatStream) {
      switch (event) {
        case TextDeltaEvent(delta: final delta):
          tmpReply += delta;
          // 先移除最后一条assistant消息（如果有）
          if (state.messages.isNotEmpty &&
              state.messages.last.role == AIRole.assistant) {
            state = state.copyWith(
                messages: state.messages.sublist(0, state.messages.length - 1));
          }
          // 添加新的assistant消息
          final aiMsg =
              AIChatMessageModel(role: AIRole.assistant, content: tmpReply);
          state = state.copyWith(messages: [...state.messages, aiMsg]);

          print('delta: $delta');
          break;
        case ThinkingDeltaEvent(delta: final delta):
          print('thinking delta: $delta');
          break;
        case CompletionEvent(response: final response):
          print('\n✅ Completed');

          if (state.messages.isNotEmpty &&
              state.messages.last.role == AIRole.assistant) {
            state = state.copyWith(
                messages: state.messages.sublist(0, state.messages.length - 1));
          }
          // 添加正式assistant消息
          final aiMsg =
              AIChatMessageModel(role: AIRole.assistant, content: tmpReply);
          state = state.copyWith(
              messages: [...state.messages, aiMsg], state: AIChatState.idle);

          ref.read(aiChatRepoProvider).updateMessages(id, state.messages);
          ref.read(aiChatRepoProvider).updateState(id, state.state);

          break;
        case ErrorEvent(error: final error):
          print('Error: $error');
          break;
        case ToolCallDeltaEvent():
          // TODO: Handle this case.
          print('ToolCallDeltaEvent: $event');
          break;
      }
    }
  }

  void updateAgent(LLMAgentId agentId) {
    final agent = ref.read(lLMAgentServiceProvider).agents[agentId];
    if (agent == null) {
      return;
    }
    state = state.copyWith(llmAgent: agent);
  }

  void cleanMessages() {
    final List<AIChatMessageModel> messages = [];
    ref.read(aiChatRepoProvider).updateMessages(state.id, messages);
    state = state.copyWith(messages: messages);
  }
}
