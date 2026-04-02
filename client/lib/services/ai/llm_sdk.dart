import 'dart:convert';

import 'package:client/models/ai.dart';
import 'package:http/http.dart' as http;
import 'package:openai_dart/openai_dart.dart';

import 'package:client/services/ai/tool.dart';

const String defaultOpenAIBaseUrl = 'https://api.openai.com/v1';

String normalizeLLMBaseUrl(String raw) {
  var value = raw.trim();
  if (value.isEmpty) {
    return value;
  }

  while (value.endsWith('/')) {
    value = value.substring(0, value.length - 1);
  }

  for (final suffix in const ['/chat/completions', '/models']) {
    if (value.endsWith(suffix)) {
      value = value.substring(0, value.length - suffix.length);
    }
  }

  final uri = Uri.tryParse(value);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    throw const FormatException('Invalid Base URL');
  }

  if (!value.endsWith('/v1')) {
    value = '$value/v1';
  }

  return value;
}

bool isOfficialOpenAIBaseUrl(String raw) {
  try {
    return normalizeLLMBaseUrl(raw) == defaultOpenAIBaseUrl;
  } on FormatException {
    return false;
  }
}

String buildDefaultLLMAgentName({
  required String baseUrl,
  required String modelName,
}) {
  final trimmedModelName = modelName.trim();
  if (trimmedModelName.isEmpty) {
    return '';
  }

  return isOfficialOpenAIBaseUrl(baseUrl) ? 'OpenAI / $trimmedModelName' : 'Custom / $trimmedModelName';
}

Future<List<String>> fetchModelsForSetting(LLMAgentSettingModel setting) async {
  final normalizedBaseUrl = normalizeLLMBaseUrl(setting.baseUrl);
  final client = OpenAIClient(
    apiKey: setting.apiKey.trim(),
    baseUrl: normalizedBaseUrl,
  );

  try {
    try {
      final response = await client.listModels();
      return response.data.map((model) => model.id.trim()).where((id) => id.isNotEmpty).toSet().toList()..sort();
    } catch (_) {
      final response = await http.get(
        Uri.parse('$normalizedBaseUrl/models'),
        headers: {
          'Authorization': 'Bearer ${setting.apiKey.trim()}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authentication failed');
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to fetch models (${response.statusCode})');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['data'];
      if (data is! List) {
        return const [];
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map((item) => (item['id'] ?? '').toString().trim())
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
    }
  } finally {
    client.endSession();
  }
}

Future<void> pingDraftSetting(LLMAgentSettingModel setting) async {
  final llmSdk = LLMProvider.create(
    setting.copyWith(baseUrl: normalizeLLMBaseUrl(setting.baseUrl)),
    '',
  );

  try {
    final result = await llmSdk.call([
      AIChatMessageItem.userMessage(
        AIChatUserMessageModel(id: AIChatMessageId.generate(), content: 'Reply with OK only.'),
      ),
    ]);

    if (result.content.trim().isEmpty) {
      throw Exception('The selected model returned an empty response');
    }
  } finally {
    llmSdk.dispose();
  }
}

/// 跨 Provider 的 usage 统一结构
class ChatUsage {
  final int? promptTokens;
  final int? completionTokens;
  final int? totalTokens;

  const ChatUsage({
    this.promptTokens,
    this.completionTokens,
    this.totalTokens,
  });
}

/// AI 工具调用适配器类
///
/// 用于将不同 LLM 提供者的工具调用转换为统一的格式
class AIChatMessageToolCall {
  final String name;
  final Map<String, dynamic> arguments;

  AIChatMessageToolCall({
    required this.name,
    required this.arguments,
  });
}

/// OpenAI Chat Result 封装类
///
/// 为了兼容原有接口，封装 OpenAI 的响应
class ChatResult {
  /// 思考过程，可能来自 reasoning_content（DeepSeek R1、vLLM）或 reasoning（OpenRouter）
  final String? thinking;
  final String content;
  final List<AIChatMessageToolCall>? toolCalls;
  final ChatUsage? usage;

  ChatResult({
    required this.content,
    this.toolCalls,
    this.thinking,
    this.usage,
  });

  /// 合并两个 ChatResult，用于流式响应累积
  ChatResult concat(ChatResult other) {
    final combinedThinking = (thinking ?? '') + (other.thinking ?? '');
    return ChatResult(
      content: content + other.content,
      toolCalls: other.toolCalls ?? toolCalls,
      thinking: combinedThinking.isNotEmpty ? combinedThinking : null,
      usage: other.usage ?? usage,
    );
  }
}

/// LLM Provider 通用接口
///
/// 定义所有 LLM 提供者必须实现的接口
abstract class LLMProvider {
  /// 流式调用 LLM
  ///
  /// [messages] 聊天消息列表
  ///
  /// 返回流式的 ChatResult，每次 yield 累积后的完整结果
  Stream<ChatResult> stream(List<AIChatMessageItem> messages);

  /// 同步调用 LLM
  ///
  /// [messages] 聊天消息列表
  ///
  /// 返回 AI 响应的 ChatResult（与 stream 一致）
  Future<ChatResult> call(List<AIChatMessageItem> messages);

  /// 释放资源
  void dispose();

  /// 工厂方法：根据配置创建对应的 LLM Provider
  ///
  /// [setting] LLM Agent 配置
  /// [systemMessage] 系统消息
  /// [temperature] 温度参数，默认 0.7
  /// [tools] 可选的工具列表，用于 function calling（使用 AITool 接口）
  ///
  /// 目前默认使用 OpenAI Provider，后续可以根据配置选择不同的 Provider
  static LLMProvider create(
    LLMAgentSettingModel setting,
    String systemMessage, {
    double temperature = 0.7,
    List<AITool>? tools,
  }) {
    return OpenAIProvider(
      setting,
      systemMessage,
      temperature: temperature,
      tools: tools,
    );
  }
}

/// OpenAI Provider 实现
///
/// 基于 openai_dart 实现 OpenAI API 的调用
class OpenAIProvider implements LLMProvider {
  final OpenAIClient _client;
  final String systemMessage;
  final String modelName;
  final double temperature;
  final List<ChatCompletionTool>? tools;

  /// 初始化 OpenAI Provider
  ///
  /// [setting] LLM Agent 配置
  /// [systemMessage] 系统消息
  /// [temperature] 温度参数，默认 0.7
  /// [tools] 可选的工具列表，用于 function calling（使用 AITool 接口）
  OpenAIProvider(
    LLMAgentSettingModel setting,
    this.systemMessage, {
    this.temperature = 0.7,
    List<AITool>? tools,
  }) : _client = OpenAIClient(
         apiKey: setting.apiKey,
         baseUrl: setting.baseUrl.isNotEmpty ? normalizeLLMBaseUrl(setting.baseUrl) : null,
       ),
       modelName = setting.modelName,
       tools = tools?.map((tool) => _convertToolToOpenAI(tool)).toList();

  /// 将 AITool 转换为 OpenAI 的 ChatCompletionTool 对象
  ///
  /// 这是 OpenAI Provider 特有的转换逻辑，不应该放在 AITool 接口中
  /// 这样可以避免 AITool 依赖 OpenAI 的具体类型，符合依赖倒置原则
  static ChatCompletionTool _convertToolToOpenAI(AITool tool) {
    return ChatCompletionTool(
      type: ChatCompletionToolType.function,
      function: FunctionObject(
        name: tool.name,
        description: tool.description,
        parameters: tool.inputJsonSchema,
      ),
    );
  }

  /// 将 AIChatMessageItem 列表转换为 ChatCompletionMessage 列表
  ///
  /// 使用各个模型类型的 toMessage 方法进行转换
  List<ChatCompletionMessage> _buildChatMessages(List<AIChatMessageItem> items) {
    final chatMessages = <ChatCompletionMessage>[];
    if (systemMessage.trim().isNotEmpty) {
      chatMessages.add(ChatCompletionMessage.system(content: systemMessage));
    }
    for (final item in items) {
      item.map(
        userMessage: (v) {
          final s = v.message.toMessage();
          chatMessages.add(
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string(s),
            ),
          );
        },
        assistantMessage: (v) {
          final s = v.message.toMessage();
          chatMessages.add(ChatCompletionMessage.assistant(content: s));
        },
        toolsResult: (v) {
          final s = v.toolsResult.toMessage();
          if (s.isNotEmpty) {
            chatMessages.add(
              ChatCompletionMessage.user(
                content: ChatCompletionUserMessageContent.string(s),
              ),
            );
          }
        },
      );
    }
    return chatMessages;
  }

  /// 处理工具调用累积并转换为 AIChatMessageToolCall 列表
  ///
  /// [toolCalls] 流式响应中的工具调用 chunk 列表
  /// [toolCallAccumulators] 工具调用累积器 Map，key 是 index，value 是包含 id、name、arguments 的 Map
  ///
  /// 返回转换后的工具调用列表，如果没有完成的工具调用则返回 null
  List<AIChatMessageToolCall>? _buildToolCalls(
    dynamic toolCalls,
    Map<int, Map<String, String>> toolCallAccumulators,
  ) {
    if (toolCalls == null || toolCalls.isEmpty) {
      return null;
    }

    // 累积工具调用数据
    for (final toolCallChunk in toolCalls) {
      final index = toolCallChunk.index ?? 0;

      if (!toolCallAccumulators.containsKey(index)) {
        toolCallAccumulators[index] = {
          'id': '',
          'name': '',
          'arguments': '',
        };
      }

      final accumulator = toolCallAccumulators[index]!;

      // 累积工具调用数据
      if (toolCallChunk.id != null) {
        accumulator['id'] = toolCallChunk.id!;
      }
      if (toolCallChunk.function?.name != null) {
        accumulator['name'] = toolCallChunk.function!.name!;
      }
      if (toolCallChunk.function?.arguments != null) {
        accumulator['arguments'] = accumulator['arguments']! + toolCallChunk.function!.arguments!;
      }
    }

    // 如果有工具调用数据，转换为 AIChatMessageToolCall
    if (toolCallAccumulators.isEmpty) {
      return null;
    }

    final convertedToolCalls = toolCallAccumulators.values
        .where((acc) => acc['name']!.isNotEmpty) // 只包含已完成的工具调用
        .map((acc) {
          try {
            final arguments = jsonDecode(acc['arguments']!) as Map<String, dynamic>;
            return AIChatMessageToolCall(
              name: acc['name']!,
              arguments: arguments,
            );
          } catch (e) {
            // 如果解析失败，返回空 arguments
            return AIChatMessageToolCall(
              name: acc['name']!,
              arguments: {},
            );
          }
        })
        .toList();

    return convertedToolCalls.isNotEmpty ? convertedToolCalls : null;
  }

  /// 从流式响应的 delta 构建增量 ChatResult
  ///
  /// [delta] 流式响应的增量数据
  /// [toolCallAccumulators] 工具调用累积器 Map，key 是 index，value 是包含 id、name、arguments 的 Map
  ///
  /// 返回增量 ChatResult，如果没有新数据则返回 null
  ChatResult? _buildChatResult(
    ChatCompletionStreamResponseDelta delta,
    Map<int, Map<String, String>> toolCallAccumulators,
  ) {
    // 提取增量内容
    String? incrementalContent;
    String? incrementalThinking;

    // 累积思考过程：可能来自 reasoning_content（DeepSeek R1、vLLM）或 reasoning（OpenRouter）
    incrementalThinking = delta.reasoningContent ?? delta.reasoning;

    // 累积内容
    if (delta.content != null) {
      incrementalContent = delta.content!;
    }

    // 处理工具调用
    final convertedToolCalls = _buildToolCalls(delta.toolCalls, toolCallAccumulators);

    // 只要有新的 delta（content、thinking 或 toolCalls），就返回增量结果
    final hasNewData =
        incrementalContent != null ||
        incrementalThinking != null ||
        (delta.toolCalls != null && delta.toolCalls!.isNotEmpty);

    if (!hasNewData) {
      return null;
    }

    return ChatResult(
      content: incrementalContent ?? '',
      toolCalls: convertedToolCalls,
      thinking: incrementalThinking,
    );
  }

  @override
  Stream<ChatResult> stream(List<AIChatMessageItem> messages) async* {
    try {
      final request = CreateChatCompletionRequest(
        model: ChatCompletionModel.modelId(modelName),
        messages: _buildChatMessages(messages),
        temperature: temperature,
        tools: tools,
        stream: true,
        streamOptions: const ChatCompletionStreamOptions(includeUsage: true),
      );

      final stream = _client.createChatCompletionStream(request: request);

      // 累积的完整结果
      ChatResult accumulatedResult = ChatResult(content: '');
      // 用于累积工具调用的 Map，key 是 index，value 是包含 id、name、arguments 的 Map
      final Map<int, Map<String, String>> toolCallAccumulators = {};

      await for (final response in stream) {
        // usage：当 include_usage=true 时，最后会额外推一个仅含 usage 的 chunk（choices 为空）
        if (response.usage != null) {
          accumulatedResult = accumulatedResult.concat(
            ChatResult(
              content: '',
              usage: ChatUsage(
                promptTokens: response.usage?.promptTokens,
                completionTokens: response.usage?.completionTokens,
                totalTokens: response.usage?.totalTokens,
              ),
            ),
          );
          yield accumulatedResult;
        }

        if (response.choices != null && response.choices!.isNotEmpty) {
          final choice = response.choices!.first;

          if (choice.delta != null) {
            // 使用 _buildChatResult 方法构建增量结果
            final incrementalResult = _buildChatResult(choice.delta!, toolCallAccumulators);

            if (incrementalResult != null) {
              // 使用 concat 合并增量结果（会自动处理 content、thinking 和 toolCalls 的累积）
              accumulatedResult = accumulatedResult.concat(incrementalResult);

              yield accumulatedResult;
            }
          }
        }
      }
    } catch (e, st) {
      yield* Stream.error(e, st);
    }
  }

  /// 将非流式响应的 message 转为 ChatResult
  ChatResult _messageToChatResult(ChatCompletionAssistantMessage msg) {
    final toolCalls = msg.toolCalls?.map((tc) {
      try {
        final args = jsonDecode(tc.function.arguments) as Map<String, dynamic>;
        return AIChatMessageToolCall(name: tc.function.name, arguments: args);
      } catch (_) {
        return AIChatMessageToolCall(name: tc.function.name, arguments: <String, dynamic>{});
      }
    }).toList();
    return ChatResult(
      content: msg.content ?? '',
      toolCalls: toolCalls?.isNotEmpty == true ? toolCalls : null,
      // 思考过程可能来自 reasoning_content（DeepSeek R1、vLLM）或 reasoning（OpenRouter）
      thinking: msg.reasoningContent ?? msg.reasoning,
    );
  }

  @override
  Future<ChatResult> call(List<AIChatMessageItem> messages) async {
    final request = CreateChatCompletionRequest(
      model: ChatCompletionModel.modelId(modelName),
      messages: _buildChatMessages(messages),
      temperature: temperature,
      tools: tools,
    );

    final response = await _client.createChatCompletion(request: request);
    if (response.choices.isNotEmpty) {
      return _messageToChatResult(response.choices.first.message);
    }

    if (response.choices.isEmpty) {
      return ChatResult(content: '');
    }

    return ChatResult(content: '');
  }

  @override
  void dispose() {
    _client.endSession();
  }
}
