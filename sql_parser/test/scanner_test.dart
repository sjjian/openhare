import 'package:test/test.dart';
import 'package:sql_parser/src/scanner.dart';

void main() {
  test('test next', () {
    Scanner s = Scanner("test");
    
    expect(true, s.next());
    expect("t".codeUnitAt(0), s.curChar());

    expect(true, s.next());
    expect("e".codeUnitAt(0), s.curChar());

    expect(true, s.next());
    expect("s".codeUnitAt(0), s.curChar());

    expect(true, s.next());
    expect("t".codeUnitAt(0), s.curChar());

    expect(false, s.next());
  });

  test('test next n', () {
    Scanner s = Scanner("test next n");
    expect(true, s.nextN(1));
    expect("t".codeUnitAt(0), s.curChar());

    expect(true, s.nextN(2));
    expect("s".codeUnitAt(0), s.curChar());

    expect(true, s.nextN(8));
    expect("n".codeUnitAt(0), s.curChar());

    expect(false, s.next());
  });
}
