import 'package:client/core/connection/metadata.dart';
import 'package:client/core/connection/sql.dart';
import 'package:client/models/sql_result.dart';
import 'package:client/utils/reorder_list.dart';
import 'package:client/widgets/data_tree.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/sql.dart';
import 'package:flutter_highlight/themes/a11y-light.dart';

class SessionsModel {
  ReorderSelectedList<SessionModel> data = ReorderSelectedList();

  // SessionsModel() {}
}

class SessionModel {
  // String id;

  SQLConnection? conn;

  SQLExecuteState? state;

  List<SchemaMeta>? metadata;

  List<TableColumnMeta>? columns;

  ReorderSelectedList<SQLResultModel> sqlResults = ReorderSelectedList();

  CodeController code = CodeController(
    text: "",
    language: sql,
  );

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
