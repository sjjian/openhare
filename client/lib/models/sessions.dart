import 'package:client/models/connection.dart';
import 'package:client/models/sql_result.dart';
import 'package:client/utils/reorder_list.dart';

class SessionsModel {
  SessionModel? current;
  List<SessionModel> data = [];

  SessionsModel() {
    data.add(SessionModel(1, SQLConnModel(
        SQLConnMetaModel("10.186.62.16", 3306, "root", "mysqlpass"))));
    data.add(SessionModel(2, SQLConnModel(
        SQLConnMetaModel("10.187.72.16", 3306, "root", "mysqlpass"))));
    selectSessionByIndex(0);
  }

  void selectSessionByIndex(int index) {
    final result = data[index];
    current = result;
  }

  SessionModel? getCurrentSession() {
    return current;
  }
}

class SessionModel {
  int id;

  SQLConnModel conn;

  SQLExecuteState? state;

  ReorderSelectedList<SQLResultModel> sqlResults = ReorderSelectedList();

  // SQLResultModel? currentResult;

  SessionModel(this.id, this.conn);

  // void deleteResultByIndex(int index) {
  //   final result = results.removeAt(index);

  //   // 如果删除了选中的result，则默认选中前一个
  //   if (currentResult == result) {
  //     if (results.isEmpty) {
  //       currentResult = null;
  //     } else {
  //       currentResult = index > 0 ? results[index - 1] : null;
  //     }
  //   }
  // }

  // void selectResultByIndex(int index) {
  //   final result = results[index];
  //   currentResult = result;
  // }

  // void reorderResult(int oldIndex, int newIndex) {
  //   if (oldIndex < newIndex) {
  //     // removing the item at oldIndex will shorten the list by 1.
  //     newIndex -= 1;
  //   }
  //   final SQLResultModel element = results.removeAt(oldIndex);
  //   results.insert(newIndex, element);
  // }

  // SQLResultModel? getCurrentSQLResult() {
  //   return currentResult;
  // }

  int genSQLResultId() {
    return sqlResults.isEmpty
        ? 0
        : sqlResults.fold(
                0,
                (previousId, element) =>
                    previousId < element.id ? element.id : previousId) +
            1;
  }

  // void addSQLResult(SQLResultModel result) {
  //   results.add(result);
  //   currentResult = result;
  // }
}
