import 'dart:convert';

import 'package:client/models/ai.dart';
import 'package:client/models/tasks.dart';
import 'package:client/repositories/ai/agent.dart';
import 'package:client/services/ai/prompt.dart';
import 'package:client/services/settings/settings.dart';
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

  void updateLastUsedLLMAgent(LLMAgentId id) {
    ref.read(lLMAgentRepoProvider).updateLastUsedLLMAgent(id);
    ref.invalidateSelf();
  }

  void updateSetting(LLMAgentId id, LLMAgentSettingModel setting) {
    ref.read(lLMAgentRepoProvider).updateSetting(id, setting);
    ref.invalidateSelf();
  }

  void updateStatus(LLMAgentId id, LLMAgentStatusModel status) {
    ref.read(lLMAgentRepoProvider).updateStatus(id, status);
    ref.invalidateSelf();
  }

  Stream<ChatStreamEvent> callStream(LLMAgentId id, String systemMessage,
      List<AIChatMessageModel> messages) async* {
    final model = ref.read(lLMAgentRepoProvider).getLLMAgentById(id);
    if (model == null) {
      return;
    }
    final provider = await ai()
        .openai()
        .baseUrl(model.setting.baseUrl)
        .apiKey(model.setting.apiKey)
        .model(model.setting.modelName)
        .temperature(0.7)
        .build();

    // 构造初始消息
    List<ChatMessage> chatMessages = [
      ChatMessage.system(systemMessage),
      for (var message in messages)
        switch (message.role) {
          AIRole.user => ChatMessage.user(message.content),
          AIRole.assistant => ChatMessage.assistant(message.content),
        }
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
      repo.updateStatus(
          id, const LLMAgentStatusModel(state: LLMAgentState.testing));
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
          id,
          available
              ? const LLMAgentStatusModel(state: LLMAgentState.available)
              : const LLMAgentStatusModel(
                  state: LLMAgentState.unavailable,
                  error: "api has return 0 tokens"));
    } catch (e) {
      ref.read(lLMAgentRepoProvider).updateStatus(
          id,
          LLMAgentStatusModel(
              state: LLMAgentState.unavailable, error: e.toString()));
    } finally {
      ref.invalidateSelf();
    }
  }

  /// 从AI响应中提取JSON字符串（去掉markdown代码块标记）
  ///
  /// 支持以下格式：
  /// - Markdown代码块格式：```json {...} ``` 或 ``` {...} ```
  /// - 纯JSON对象：{...}
  ///
  /// 返回清理后的JSON字符串
  String extractJsonString(String response) {
    String jsonString = response.trim();

    // 如果包含```json或```，提取其中的JSON
    final jsonBlockMatch =
        RegExp(r'```(?:json)?\s*(\{[\s\S]*?\})\s*```').firstMatch(jsonString);
    if (jsonBlockMatch != null) {
      jsonString = jsonBlockMatch.group(1)!;
    } else {
      // 如果没有代码块，尝试直接查找JSON对象
      final jsonStart = jsonString.indexOf('{');
      final jsonEnd = jsonString.lastIndexOf('}');
      if (jsonStart >= 0 && jsonEnd > jsonStart) {
        jsonString = jsonString.substring(jsonStart, jsonEnd + 1);
      }
    }

    return jsonString;
  }

  /// 生成导出文件的文件名和描述
  ///
  /// 接收LLM Agent ID和导出参数，调用AI生成合适的文件名和描述
  /// 返回包含fileName和desc的结果对象
  Future<ExportFileNameResult> generateExportFileName(
    LLMAgentId id,
    ExportDataParameters parameters,
  ) async {
    // 获取语言设置
    final settings = ref.read(systemSettingServiceProvider);
    final language = settings.language;

    // 生成prompt
    final prompt = getExportDataFileRenamePrompt(parameters, language);

    // 调用AI
    final response = await call(
      id,
      '', // 空系统消息
      [
        AIChatMessageModel(
          role: AIRole.user,
          content: prompt,
        ),
      ],
    );

    // 检查响应是否为空
    if (response.isEmpty) {
      throw Exception('AI服务返回空响应');
    }

    // 提取JSON字符串（去掉markdown代码块标记）
    final jsonString = extractJsonString(response);

    // 解析JSON并创建对象
    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
    final result = ExportFileNameResult.fromJson(jsonData);

    if (result.fileName.isEmpty) {
      throw Exception('AI返回的文件名为空');
    }

    return result;
  }
}

@Riverpod(keepAlive: true)
class LLMAgentNotifier extends _$LLMAgentNotifier {
  @override
  LLMAgentsModel build() {
    return ref.watch(lLMAgentServiceProvider);
  }
}
