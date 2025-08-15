import 'package:client/models/ai.dart';
import 'package:client/repositories/ai/ai.dart';
import 'package:client/services/settings/settings.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_chat.g.dart';

@Riverpod(keepAlive: true)
class AIChatService extends _$AIChatService {
  @override
  AIChatModel build(AIChatId id) {
    return ref.watch(aiChatRepoProvider).create(id);
  }

  /// 进行AI对话，请求接口，存储消息并刷新
  /// 不再返回流，直接通过provider刷新state，UI通过监听state变化获取最新消息
  Future<void> chat(AIChatId id, String message) async {
    // 先用第一个
    final llmApiSetting = ref.watch(lLMApiSettingServiceProvider).first;
    // 1. 先将用户消息加入本地消息列表
    final userMsg = AIChatMessageModel(role: AIRole.user, content: message);
    state = state.copyWith(
        messages: [...state.messages, userMsg],
        state: AIChatState.waiting,
        systemMessage: [
          const AIChatMessageModel(
              role: AIRole.assistant,
              content:
                  "You are a helpful assistant. You are talking to a user who is using a database tool. You are helping the user to answer questions about the database.")
        ]);

    // freezed的list对象不可变，不能直接add，需新建list
    // state = state.copyWith(messages: [...state.messages, userMsg]);
    ref.read(aiChatRepoProvider).update(state);
    // 通知刷新
    state = state;

    // 2. 构造OpenAI请求
    OpenAI.baseUrl = llmApiSetting.baseUrl;
    OpenAI.apiKey = llmApiSetting.apiKey;

    // 3. 创建流式请求
    final chatStream = OpenAI.instance.chat.createStream(
      model: llmApiSetting.modelName,
      messages: [
        if (state.systemMessage != null) ...[
          for (var systemMessage in state.systemMessage!)
            OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  systemMessage.content,
                ),
              ],
            ),
        ],
        for (var message in state.messages)
          OpenAIChatCompletionChoiceMessageModel(
            role: message.role == AIRole.user
                ? OpenAIChatMessageRole.user
                : OpenAIChatMessageRole.assistant,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                message.content,
              ),
            ],
          ),
      ],
      seed: 423,
      n: 1,
    );

    // 4. 监听流并拼接AI回复，每次有新内容就刷新state
    String aiReply = '';
    await for (final streamChatCompletion in chatStream) {
      final content = streamChatCompletion.choices.first.delta.content;
      if (content != null && content.isNotEmpty) {
        final text = content.first?.text ?? '';
        aiReply += text;
        // 先移除最后一条assistant消息（如果有）
        if (state.messages.isNotEmpty &&
            state.messages.last.role == AIRole.assistant) {
          state = state.copyWith(
              messages: state.messages.sublist(0, state.messages.length - 1));
        }
        // 添加新的assistant消息
        final aiMsg =
            AIChatMessageModel(role: AIRole.assistant, content: aiReply);
        state = state.copyWith(messages: [...state.messages, aiMsg]);
        // 通知刷新
        state = state;
      }
    }

    // 5. AI回复结束，存储AI消息（移除临时消息，加入正式消息）
    if (aiReply.isNotEmpty) {
      // 移除最后一条assistant消息（如果有）
      if (state.messages.isNotEmpty &&
          state.messages.last.role == AIRole.assistant) {
        state = state.copyWith(
            messages: state.messages.sublist(0, state.messages.length - 1));
      }
      // 添加正式assistant消息
      final aiMsg =
          AIChatMessageModel(role: AIRole.assistant, content: aiReply);
      state = state.copyWith(
          messages: [...state.messages, aiMsg], state: AIChatState.idle);
      ref.read(aiChatRepoProvider).update(state);
      // 通知刷新
      state = state;
    }
  }
}
