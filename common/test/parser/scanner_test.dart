import 'package:test/test.dart';
import 'package:common/src/parser/scanner.dart';

void main() {
  test('test next', () {
    Scanner s = Scanner("test");
    expect("t".codeUnitAt(0), s.curChar());
    expect(s.nextChar(), "e".codeUnitAt(0));
    expect(s.nextCharN(3), "t".codeUnitAt(0));
    expect(s.nextCharN(4), 0);

    expect(s.hasNext(), true);
    expect(s.next(), true);
    expect(s.curChar(), "e".codeUnitAt(0));
    expect(s.nextChar(), "s".codeUnitAt(0));

    expect(s.hasNext(), true);
    expect(true, s.next());
    expect(s.curChar(), "s".codeUnitAt(0));

    expect(s.hasNext(), true);
    expect(true, s.next());
    expect(s.curChar(), "t".codeUnitAt(0));

    expect(s.hasNext(), false);
    expect(s.next(), false);
  });

  test('test next n', () {
    Scanner s = Scanner("test next n");
    expect(s.curChar(), "t".codeUnitAt(0));

    expect(s.hasNextN(2), true);
    expect(s.nextN(2), true);
    expect(s.curChar(), "s".codeUnitAt(0));

    expect(s.hasNextN(7), true);
    expect(s.hasNextN(8), true);
    expect(s.hasNextN(9), false);

    expect(s.nextN(8), true);
    expect(s.curChar(), "n".codeUnitAt(0));

    expect(s.hasNext(), false);
    expect(s.hasNextN(1), false);
    expect(s.hasNextN(2), false);
    expect(s.next(), false);
  });

  test('test seek', () {
    Scanner s = Scanner("test seek");
    expect(s.curChar(), "t".codeUnitAt(0));

    s.seek(Pos(1, 0, 1));
    expect(s.curChar(), "e".codeUnitAt(0));

    s.seek(Pos(2, 0, 2));
    expect(s.curChar(), "s".codeUnitAt(0));

    s.seek(Pos(8, 0, 8));
    expect(s.curChar(), "k".codeUnitAt(0));

    s.seek(Pos(9, 0, 9));
    expect(s.curChar(), 0); // eof

    s.seek(Pos.init());
    expect(s.curChar(), "t".codeUnitAt(0));
    expect(s.hasNextN(8), true);
    expect(s.hasNextN(9), false);
  });

  test('test sub string', () {
    Scanner s = Scanner("test sub string");
    expect(s.subString(Pos(0, 0, 0), Pos(0, 0, 0)), "t");
    expect(s.subString(Pos(1, 0, 0), Pos(1, 0, 0)), "e");
    expect(s.subString(Pos(14, 0, 0), Pos(14, 0, 0)), "g");
    expect(s.subString(Pos(0, 0, 0), Pos(1, 0, 1)), "te");
    expect(s.subString(Pos(0, 0, 0), Pos(14, 0, 14)), "test sub string");

    expect(s.subString(Pos(0, 0, 0), Pos(15, 0, 0)), "");
    expect(s.subString(Pos(15, 0, 0), Pos(14, 0, 0)), "");
    expect(s.subString(Pos(4, 0, 0), Pos(3, 0, 0)), "");
  });
}
