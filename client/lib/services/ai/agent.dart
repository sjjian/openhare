import 'dart:convert';

import 'package:client/models/ai.dart';
import 'package:client/models/tasks.dart';
import 'package:client/repositories/ai/agent.dart';
import 'package:client/services/ai/llm_sdk.dart';
import 'package:client/services/ai/prompt.dart';
import 'package:client/services/settings/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'agent.g.dart';

@Riverpod(keepAlive: true)
class LLMAgentService extends _$LLMAgentService {
  @override
  LLMAgentsModel build() {
    final repo = ref.watch(lLMAgentRepoProvider);
    return repo.getLLMAgents();
  }

  LLMAgentId create(LLMAgentSettingModel setting, {LLMAgentStatusModel? status}) {
    final id = ref.read(lLMAgentRepoProvider).create(setting, status: status);
    ref.invalidateSelf();
    return id;
  }

  void delete(LLMAgentId id) {
    ref.read(lLMAgentRepoProvider).delete(id);
    ref.invalidateSelf();
  }

  void updateLastUsedLLMAgent(LLMAgentId id) {
    ref.read(lLMAgentRepoProvider).updateLastUsedLLMAgent(id);
    ref.invalidateSelf();
  }

  void updateSetting(LLMAgentId id, LLMAgentSettingModel setting, {LLMAgentStatusModel? status}) {
    ref.read(lLMAgentRepoProvider).updateSetting(id, setting, status: status);
    ref.invalidateSelf();
  }

  void updateStatus(LLMAgentId id, LLMAgentStatusModel status) {
    ref.read(lLMAgentRepoProvider).updateStatus(id, status);
    ref.invalidateSelf();
  }

  Future<void> ping(LLMAgentId id) async {
    try {
      final model = ref.read(lLMAgentRepoProvider).getLLMAgentById(id);
      if (model == null) {
        return;
      }
      final repo = ref.read(lLMAgentRepoProvider);
      repo.updateStatus(id, const LLMAgentStatusModel(state: LLMAgentState.testing));
      ref.invalidateSelf();
      final llmSdk = LLMProvider.create(model.setting, '');
      final result = await (() async {
        try {
          return await llmSdk.call([
            AIChatMessageItem.userMessage(
              AIChatUserMessageModel(id: AIChatMessageId.generate(), content: testTemplate),
            ),
          ]);
        } finally {
          llmSdk.dispose();
        }
      })();

      final available = result.content.isNotEmpty;
      repo.updateStatus(
        id,
        available
            ? const LLMAgentStatusModel(state: LLMAgentState.available)
            : const LLMAgentStatusModel(state: LLMAgentState.unavailable, error: "api has return 0 tokens"),
      );
    } catch (e) {
      ref
          .read(lLMAgentRepoProvider)
          .updateStatus(
            id,
            LLMAgentStatusModel(
              state: LLMAgentState.unavailable,
              error: e.toString(),
            ),
          );
    } finally {
      ref.invalidateSelf();
    }
  }

  Future<List<String>> fetchModelsDraft(LLMAgentSettingModel setting) async {
    if (setting.baseUrl.trim().isEmpty) {
      throw Exception('Base URL is required');
    }
    if (setting.apiKey.trim().isEmpty) {
      throw Exception('API Key is required');
    }

    return fetchModelsForSetting(setting);
  }

  Future<void> pingDraft(LLMAgentSettingModel setting) async {
    if (setting.baseUrl.trim().isEmpty) {
      throw Exception('Base URL is required');
    }
    if (setting.apiKey.trim().isEmpty) {
      throw Exception('API Key is required');
    }
    if (setting.modelName.trim().isEmpty) {
      throw Exception('Model is required');
    }

    await pingDraftSetting(setting);
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
    final jsonBlockMatch = RegExp(r'```(?:json)?\s*(\{[\s\S]*?\})\s*```').firstMatch(jsonString);
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
    final model = ref.read(lLMAgentRepoProvider).getLLMAgentById(id);
    if (model == null) {
      throw Exception('LLM Agent not found');
    }
    // 获取语言设置
    final settings = ref.read(systemSettingServiceProvider);
    final language = settings.language;

    // 生成prompt
    final prompt = getExportDataFileRenamePrompt(parameters, language);

    final llmSdk = LLMProvider.create(model.setting, '');
    // 调用AI
    final chatResult = await (() async {
      try {
        return await llmSdk.call([
          AIChatMessageItem.userMessage(
            AIChatUserMessageModel(id: AIChatMessageId.generate(), content: prompt),
          ),
        ]);
      } finally {
        llmSdk.dispose();
      }
    })();

    // 检查响应是否为空
    if (chatResult.content.isEmpty) {
      throw Exception('AI服务返回空响应');
    }

    // 提取JSON字符串（去掉markdown代码块标记）
    final jsonString = extractJsonString(chatResult.content);

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
