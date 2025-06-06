import 'package:client/repositories/instances.dart';
import 'package:db_driver/db_driver.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'sessions.freezed.dart';

@freezed
abstract class SessionModel with _$SessionModel {
  const factory SessionModel({
    required int sessionId,
    int? instanceId,
    String? instanceName,
    DatabaseType? dbType,
  }) = _SessionModel;
}

@freezed
abstract class SessionListModel with _$SessionListModel {
  const factory SessionListModel({
    required List<SessionModel> sessions,
    SessionModel? selectedSession,
  }) = _SessionListModel;
}

@freezed
abstract class SessionOpBarModel with _$SessionOpBarModel {
  const factory SessionOpBarModel({
    required int sessionId,
    required bool canQuery,
    required String currentSchema,
    required bool isRightPageOpen,
  }) = _SessionOpBarModel;
}

abstract class SessionRepo {
  SessionListModel getSessions();
  SessionModel? getSession(int sessionId);
  Future<SessionModel> newSession();
  Future<void> updateSession(
      SessionModel model, InstanceModel instance, String currentSchema);
  Future<void> deleteSession(SessionModel model);
  void selectSessionByIndex(int index);
  void reorderSession(int oldIndex, int newIndex);
}
