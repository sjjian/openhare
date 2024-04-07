import 'package:client/models/connection.dart';
import 'package:client/models/sql_result.dart';
import 'package:client/utils/reorder_list.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/sql.dart';
import 'package:flutter_highlight/themes/a11y-light.dart';

class SessionsModel {
  ReorderSelectedList<SessionModel> data = ReorderSelectedList();

  SessionsModel() {
    data.add(SessionModel(
        1,
        SQLConnModel(
            SQLConnMetaModel("10.186.62.16", 3306, "root", "mysqlpass"))));
    data.add(SessionModel(
        2,
        SQLConnModel(
            SQLConnMetaModel("10.187.72.16", 3306, "root", "mysqlpass"))));
    data.select(0);
  }
}

class SessionModel {
  int id;

  SQLConnModel conn;

  SQLExecuteState? state;

  ReorderSelectedList<SQLResultModel> sqlResults = ReorderSelectedList();

  CodeController code = CodeController(
    text: "",
    language: sql,
  );

  SessionModel(this.id, this.conn);

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
