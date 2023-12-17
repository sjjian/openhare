import 'package:sql_parser/sql_parser.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    final awesome = Lexer("abc");

    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () {
      expect(awesome.isAwesome, isTrue);
    });
  });
}
