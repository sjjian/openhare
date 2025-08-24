import 'package:client/models/ai.dart';
import 'package:client/repositories/ai/chat.dart';
import 'package:client/services/ai/agent.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:llm_dart/llm_dart.dart';

part 'chat.g.dart';

@Riverpod(keepAlive: true)
class AIChatService extends _$AIChatService {
  @override
  AIChatListModel build() {
    return ref.watch(aiChatRepoProvider).getAIChatList();
  }

  void create(AIChatModel model) {
    ref.read(aiChatRepoProvider).create(model);
    // ref.invalidateSelf();
  }

  List<AIChatMessageModel> _getChatMessage(AIChatId id) {
    return state.chats[id]!.messages;
  }

  void _updateLastMessage(AIChatId id, AIChatMessageModel message) {
    final repo = ref.read(aiChatRepoProvider);
    final model = repo.getAIChatById(id);
    if (model == null) {
      return;
    }
    // todo: 感觉替换的方式有点重，不太优雅。
    List<AIChatMessageModel> messages;
    // 先移除最后一条assistant消息（如果有）
    if (model.messages.isNotEmpty &&
        model.messages.last.role == AIRole.assistant) {
      messages = model.messages.sublist(0, model.messages.length - 1);
    } else {
      messages = List.from(model.messages);
    }
    // 添加新的assistant消息
    messages.add(message);
    ref.read(aiChatRepoProvider).updateMessages(id, messages);
    // 刷新state
    ref.invalidateSelf();
  }

  /// 进行AI对话，请求接口，存储消息并刷新
  /// 不再返回流，直接通过provider刷新state，UI通过监听state变化获取最新消息
  Future<void> chat(AIChatId id, LLMAgentId agentId, String systemPrompt,
      String message) async {
    final repo = ref.read(aiChatRepoProvider);
    final model = repo.getAIChatById(id);
    if (model == null) {
      return;
    }
    // 1.更新用户提问的消息
    ref.read(aiChatRepoProvider).updateMessages(id, [
      ..._getChatMessage(id),
      AIChatMessageModel(role: AIRole.user, content: message)
    ]);
    ref.read(aiChatRepoProvider).updateState(id, AIChatState.waiting);

    ref.invalidateSelf();

    // 2. 调用LLM接口
    final agent = ref.read(lLMAgentServiceProvider.notifier);
    final chatStream =
        agent.callStream(agentId, systemPrompt, _getChatMessage(id));

    // 3. 更新消息
    AIChatMessageModel? lastMessage = const AIChatMessageModel(
      role: AIRole.assistant,
      content: '',
      thinking: null,
    );

    await for (final event in chatStream) {
      switch (event) {
        case TextDeltaEvent(delta: final delta):
          lastMessage =
              lastMessage!.copyWith(content: lastMessage.content + delta);
          _updateLastMessage(id, lastMessage);
          break;

        case ThinkingDeltaEvent(delta: final delta):
          lastMessage = lastMessage!
              .copyWith(thinking: (lastMessage.thinking ?? "") + delta);
          _updateLastMessage(id, lastMessage);
          break;

        case CompletionEvent():
          ref.read(aiChatRepoProvider).updateState(id, AIChatState.idle);
          ref.invalidateSelf();
          break;

        case ErrorEvent(error: final error):
          print('Error: $error'); // todo: 支持错误处理
          break;

        case ToolCallDeltaEvent(toolCall: final toolCall):
          print('ToolCallDeltaEvent: $toolCall');
          break;
      }
    }
  }

  void cleanMessages(AIChatId id) {
    final List<AIChatMessageModel> messages = [];
    ref.read(aiChatRepoProvider).updateMessages(id, messages);
    ref.invalidateSelf();
  }

  void updateTables(AIChatId id, String schema, Map<String, String> tables) {
    ref.read(aiChatRepoProvider).updateTables(id, schema, tables);
    ref.invalidateSelf();
  }

  void delete(AIChatId id) {
    ref.read(aiChatRepoProvider).delete(id);
    ref.invalidateSelf();
  }
}
