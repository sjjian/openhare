import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai.freezed.dart';

abstract class AIChatRepo {
  AIChatModel create(AIChatId id); // todo
  void update(AIChatModel model);
  void delete(AIChatId id);
  AIChatModel? getAIChatById(AIChatId id);
}

enum AIRole {
  user,
  assistant,
}

enum AIChatState {
  idle,
  waiting,
  error,
}

@freezed
abstract class AIChatId with _$AIChatId {
  const factory AIChatId({
    required int value,
  }) = _AIChatId;
}

@freezed
abstract class AIChatModel with _$AIChatModel {
  const factory AIChatModel({
    required AIChatId id,
    required List<AIChatMessageModel>? systemMessage,
    required List<AIChatMessageModel> messages,
    required AIChatState state,
  }) = _AIChatModel;
}

@freezed
abstract class AIChatMessageModel with _$AIChatMessageModel {
  const factory AIChatMessageModel({
    required AIRole role,
    required String content,
  }) = _AIChatMessageModel;
}
