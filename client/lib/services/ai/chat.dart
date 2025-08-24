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

  void _updateState(AIChatId id, AIChatState state) {
    ref.read(aiChatRepoProvider).updateState(id, state);
    ref.invalidateSelf();
  }

  /// 进行AI对话，请求接口，存储消息并刷新使用 provider 来动态刷新页面
  Future<void> chat(AIChatId id, LLMAgentId agentId, String systemPrompt,
      {String? message}) async {
    final repo = ref.read(aiChatRepoProvider);
    final model = repo.getAIChatById(id);
    if (model == null) {
      return;
    }

    // 1.如果有则更新用户提问的消息
    if (message != null) {
      ref.read(aiChatRepoProvider).updateMessages(id, [
        ..._getChatMessage(id),
        AIChatMessageModel(role: AIRole.user, content: message)
      ]);
    }

    _updateState(id, AIChatState.waiting);

    final agent = ref.read(lLMAgentServiceProvider.notifier);

    AIChatMessageModel? lastMessage = const AIChatMessageModel(
      role: AIRole.assistant,
      content: '',
      thinking: null,
    );

    try {
      // 2. 调用LLM接口
      final chatStream =
          agent.callStream(agentId, systemPrompt, _getChatMessage(id));

      // 3. 更新消息
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
            break;

          case ErrorEvent(error: final error):
            lastMessage = lastMessage!.copyWith(error: error.toString());
            _updateLastMessage(id, lastMessage);
            break;

          case ToolCallDeltaEvent(toolCall: final toolCall):
            print('warning: $toolCall');
            break;
        }
      }
    } catch (e) {
      lastMessage = lastMessage!.copyWith(error: e.toString());
      _updateLastMessage(id, lastMessage);
    } finally {
      _updateState(id, AIChatState.idle);
    }
  }

  void retryChat(AIChatId id, LLMAgentId agentId, String systemPrompt,
      AIChatMessageModel retryMessage) {
    // 先把当前及其后面的message 删除, 然后重新chat
    final messages = _getChatMessage(id);
    final index = messages.indexOf(retryMessage);
    if (index == -1) {
      return;
    }
    // 更新 message
    ref.read(aiChatRepoProvider).updateMessages(id, messages.sublist(0, index));
    ref.invalidateSelf();
    // 重新 chat
    chat(id, agentId, systemPrompt);
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
