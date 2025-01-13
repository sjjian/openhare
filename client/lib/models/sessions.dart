import 'package:client/core/connection/metadata.dart';
import 'package:client/core/connection/sql.dart';
import 'package:client/models/sql_result.dart';
import 'package:client/screens/sessions/session_drawer_body.dart';
import 'package:client/utils/reorder_list.dart';
import 'package:client/utils/sql_highlight.dart';
import 'package:client/widgets/split_view.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:re_editor/re_editor.dart';
import 'package:common/parser.dart';

class SessionsModel {
  ReorderSelectedList<SessionModel> data = ReorderSelectedList();

  // SessionsModel() {}
}

class SessionModel {
  // String id;

  SQLConnection? conn;

  SQLExecuteState? state;

  List<SchemaMeta>? metadata;

  SessionDrawerController metadataController = SessionDrawerController();

  ReorderSelectedList<SQLResultModel> sqlResults = ReorderSelectedList();

  final SplitViewController multiSplitViewCtrl =
      SplitViewController(Area(), Area(min: 35, size: 500));

  final SplitViewController metaDataSplitViewCtrl =
      SplitViewController(Area(min: 400), Area(size: 400, min: 400));

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

  SessionModel({this.conn});

  int genSQLResultId() {
    return sqlResults.isEmpty
        ? 0
        : sqlResults.fold(
                0,
                (previousId, element) =>
                    previousId < element.id ? element.id : previousId) +
            1;
  }
}
