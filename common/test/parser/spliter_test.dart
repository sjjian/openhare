import 'package:test/test.dart';
import 'package:common/parser.dart';

void main() {
  test('test split', () {
    expect(
      Splitter("SELECT * from t1;SELECT * from t2", ";").split(),
      List<String>.from(<String>["SELECT * from t1;", "SELECT * from t2"]),
    );
    expect(
      Splitter("SELECT * from t1;SELECT * from t2;", ";").split(),
      List<String>.from(<String>["SELECT * from t1;", "SELECT * from t2;"]),
    );
  });
}
