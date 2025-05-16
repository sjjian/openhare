import 'package:client/models/instances.dart';
import 'package:client/models/interface.dart';
import 'package:objectbox/objectbox.dart';
import 'package:client/utils/reorder_list.dart';
import 'package:client/models/session_sql_result.dart';
import 'package:db_driver/db_driver.dart';
import 'package:flutter/material.dart';
import 'package:sql_editor/re_editor.dart';
import 'package:client/utils/sql_highlight.dart';
import 'package:client/widgets/split_view.dart';
import 'package:client/widgets/data_tree.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:sql_parser/parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sessions.g.dart';

@Entity()
class SessionStorage {
  @Id()
  int id;

  final instance = ToOne<InstanceModel>();

  String? text;

  String? currentSchema;

  SessionStorage({
    this.id = 0,
    this.text,
    this.currentSchema,
  });
}

enum SQLConnectState { pending, connecting, connected, failed }

enum DrawerPage {
  metadataTree,
  sqlResult,
}

sealed class BaseSession {}

class UnInitSession extends BaseSession {}

class SessionsCache implements SessionRepo {
  ReorderSelectedList<BaseSession> data = ReorderSelectedList();

  SessionsCache() {
    print("data hash code1: ${data.hashCode}");
    data.add(UnInitSession());
    print("data hash code2: ${data.hashCode}");
  }
  @override
  ReorderSelectedList<BaseSession> getSessions() {
    return data;
  }

  @override
  CurrentSession? currentSession() {
    BaseSession? session = data.selected();
    if (session is UnInitSession) {
      return null;
    }
    return CurrentSession(
      model: (session as Session).model,
      conn2: session.conn2,
      state: session.connState,
      text: session.code.text,
      currentSchema: null,
    );
  }

  @override
  SessionStorage getSession(int sessionId) {
    for (final s in data) {
      if (s is Session && s.model.id == sessionId) {
        return s.model;
      }
    }
    return SessionStorage();
  }
}

class SessionDrawer {}

class Session extends BaseSession {
  // session model
  SessionStorage model;
  // connection
  BaseConnection? conn2;
  SQLConnectState connState = SQLConnectState.pending;
  void Function()? _onClose;
  void Function(String)? _onSchemaChanged;
  SQLExecuteState? queryState;

  // metadata
  MetaDataNode? metadata;
  TreeController<DataNode>? metadataController;

  // sql results
  ReorderSelectedList<SQLResultModel> sqlResults = ReorderSelectedList();

  int genSQLResultId() {
    return sqlResults.isEmpty
        ? 0
        : sqlResults.fold(
                0,
                (previousId, element) =>
                    previousId < element.id ? element.id : previousId) +
            1;
  }

  // split view
  final SplitViewController multiSplitViewCtrl =
      SplitViewController(Area(), Area(min: 35, size: 500));

  final SplitViewController metaDataSplitViewCtrl =
      SplitViewController(Area(flex: 7, min: 3), Area(flex: 3, min: 3));

  // sql editor
  CodeLineEditingController code = CodeLineEditingController(
      spanBuilder: ({required codeLines, required context, required style}) {
    return TextSpan(
        children: Lexer(codeLines.asString(TextLineBreak.lf))
            .tokens()
            .map<TextSpan>((tok) => TextSpan(
                text: tok.content,
                style: style.merge(getStyle(tok.id) ?? style)))
            .toList());
  });

  // session drawer
  // bool isRightPageOpen = true;
  // DrawerPage drawerPage = DrawerPage.metadataTree;
  // BaseQueryValue? sqlResult;
  // BaseQueryColumn? sqlColumn;
  // bool showRecord = true;

  Session(this.model) {
    code.text = model.text ?? "";
  }

  Future<void> connect() async {
    try {
      conn2 = await ConnectionFactory.open(
          type: model.instance.target!.dbType,
          meta: model.instance.target!.connectValue,
          schema: model.currentSchema,
          onCloseCallback: onConnClose,
          onSchemaChangedCallback: onSchemaChanged);
      connState = SQLConnectState.connected;
    } catch (e, s) {
      print("conn error: ${e}; ${s}");
      connState = SQLConnectState.failed;
    }
  }

  Future<void> close() async {
    if (conn2 == null || connState != SQLConnectState.connected) {
      return;
    }
    try {
      conn2!.close();
      connState = SQLConnectState.pending;
      conn2 = null;
    } catch (e) {
      // todo: handler error;
    }
  }

  bool canQuery() {
    return (queryState != SQLExecuteState.executing &&
        connState == SQLConnectState.connected);
  }

  void init(SessionStorage model) {
    this.model = model;
    code.text = model.text ?? "";
  }

  String? get currentSchema {
    return model.currentSchema;
  }

  Future<List<String>> getSchemas() async {
    List<String> schemas = await conn2!.schemas();
    return schemas;
  }

  MetaDataNode? getMetadata() {
    if (metadata == null) {
      return null;
    }
    return metadata;
  }

  List<SQLResultModel>? getAllSQLResult() {
    return sqlResults;
  }

  SQLResultModel? getCurrentSQLResult() {
    return sqlResults.selected();
  }

  CodeLineEditingController getSQLEditCode() => code;

  void onConnClose() {
    connState = SQLConnectState.pending;
    _onClose?.call();
  }

  void onSchemaChanged(String schema) {
    model.currentSchema = schema;
    _onSchemaChanged?.call(schema);
  }

  void listenCallBack(
      void Function() onClose, void Function(String) onSchemaChanged) {
    _onClose = onClose;
    _onSchemaChanged = onSchemaChanged;
  }

  void unListenCallBack() {
    _onClose = null;
    _onSchemaChanged = null;
  }
}

@Riverpod(keepAlive: true)
SessionRepo sessionRepo(Ref ref) {
  print("sessionsProvider rebuild");
  return SessionsCache();
}

@Riverpod(keepAlive: true)
CurrentSession? currentSession(Ref ref) {
  return ref.watch(sessionRepoProvider).currentSession();
}

@Riverpod(keepAlive: true)
CurrentSessionDrawer? sessionDrawerState(Ref ref, int sessionId) {
  return const CurrentSessionDrawer(
      drawerPage: DrawerPage.metadataTree,
      sqlResult: null,
      sqlColumn: null,
      showRecord: false,
      isRightPageOpen: true);
}

@Riverpod(keepAlive: true)
SessionConn sessionConn(Ref ref, int sessionId) {
  SessionStorage model = ref.watch(sessionRepoProvider).getSession(sessionId);
  return SessionConn(
      model: model,
      conn2: null,
      state: SQLConnectState.pending,
      currentSchema: null);
}
