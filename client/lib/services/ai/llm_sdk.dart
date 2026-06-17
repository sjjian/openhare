import 'package:client/models/ai.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:client/services/ai/tool.dart';

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
  Stream<ChatResult> stream(Iterable<AIChatMessageItem> messages);

  /// 同步调用 LLM
  ///
  /// [messages] 聊天消息列表
  ///
  /// 返回 AI 响应的 ChatResult（与 stream 一致）
  Future<ChatResult> call(Iterable<AIChatMessageItem> messages);

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
  final List<Tool>? tools;

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
  }) : _client = OpenAIClient.withApiKey(
         setting.apiKey,
         baseUrl: setting.baseUrl.isNotEmpty ? setting.baseUrl : null,
       ),
       modelName = setting.modelName,
       tools = tools
           ?.map(
             (tool) => Tool.function(
               name: tool.name,
               description: tool.description,
               parameters: tool.inputJsonSchema,
             ),
           )
           .toList();

  /// 将 AIChatMessageItem 列表转换为 ChatMessage 列表
  List<ChatMessage> _buildChatMessages(Iterable<AIChatMessageItem> items) {
    final chatMessages = <ChatMessage>[];
    if (systemMessage.trim().isNotEmpty) {
      chatMessages.add(ChatMessage.system(systemMessage));
    }
    for (final item in items) {
      item.map(
        userMessage: (v) {
          final s = v.message.toMessage();
          chatMessages.add(ChatMessage.user(s));
        },
        assistantMessage: (v) {
          final s = v.message.toMessage();
          chatMessages.add(ChatMessage.assistant(content: s));
        },
        toolsResult: (v) {
          final s = v.toolsResult.toMessage();
          if (s.isNotEmpty) {
            chatMessages.add(ChatMessage.user(s));
          }
        },
      );
    }
    return chatMessages;
  }

  List<AIChatMessageToolCall>? _convertToolCalls(List<ToolCall> toolCalls) {
    if (toolCalls.isEmpty) {
      return null;
    }
    final converted = toolCalls.map((tc) {
      try {
        return AIChatMessageToolCall(
          name: tc.function.name,
          arguments: tc.function.argumentsMap,
        );
      } catch (_) {
        return AIChatMessageToolCall(
          name: tc.function.name,
          arguments: <String, dynamic>{},
        );
      }
    }).toList();
    return converted.isNotEmpty ? converted : null;
  }

  ChatUsage? _toChatUsage(Usage? usage) {
    if (usage == null) {
      return null;
    }
    return ChatUsage(
      promptTokens: usage.promptTokens,
      completionTokens: usage.completionTokens,
      totalTokens: usage.totalTokens,
    );
  }

  String? _extractThinking(AssistantMessage msg) {
    return msg.reasoningContent ?? msg.reasoning;
  }

  String? _extractThinkingFromAccumulator(ChatStreamAccumulator accumulator) {
    if (accumulator.hasReasoningContent) {
      final reasoning = accumulator.reasoningContent;
      if (reasoning.isNotEmpty) {
        return reasoning;
      }
      final summary = accumulator.reasoning;
      if (summary.isNotEmpty) {
        return summary;
      }
    }
    return null;
  }

  ChatResult _accumulatorToChatResult(ChatStreamAccumulator accumulator) {
    return ChatResult(
      content: accumulator.content,
      toolCalls: accumulator.hasToolCalls ? _convertToolCalls(accumulator.toolCalls) : null,
      thinking: _extractThinkingFromAccumulator(accumulator),
      usage: _toChatUsage(accumulator.usage),
    );
  }

  ChatResult _messageToChatResult(AssistantMessage msg) {
    return ChatResult(
      content: msg.content ?? '',
      toolCalls: msg.hasToolCalls ? _convertToolCalls(msg.toolCalls!) : null,
      thinking: _extractThinking(msg),
    );
  }

  ChatCompletionCreateRequest _buildRequest(
    Iterable<AIChatMessageItem> messages, {
    bool includeStreamUsage = false,
  }) {
    return ChatCompletionCreateRequest(
      model: modelName,
      messages: _buildChatMessages(messages),
      temperature: temperature,
      tools: tools,
      streamOptions: includeStreamUsage ? const StreamOptions(includeUsage: true) : null,
    );
  }

  @override
  Stream<ChatResult> stream(Iterable<AIChatMessageItem> messages) async* {
    try {
      final stream = _client.chat.completions.createStream(
        _buildRequest(messages, includeStreamUsage: true),
      );
      final accumulator = ChatStreamAccumulator();

      await for (final event in stream) {
        accumulator.add(event);
        yield _accumulatorToChatResult(accumulator);
      }
    } catch (e, st) {
      yield* Stream.error(e, st);
    }
  }

  @override
  Future<ChatResult> call(Iterable<AIChatMessageItem> messages) async {
    try {
      final response = await _client.chat.completions.create(_buildRequest(messages));
      if (response.choices.isNotEmpty) {
        final result = _messageToChatResult(response.choices.first.message);
        return ChatResult(
          content: result.content,
          toolCalls: result.toolCalls,
          thinking: result.thinking,
          usage: _toChatUsage(response.usage),
        );
      }
      return ChatResult(content: '');
    } catch (e) {
      return ChatResult(content: '');
    }
  }

  @override
  void dispose() {
    _client.close();
  }
}
