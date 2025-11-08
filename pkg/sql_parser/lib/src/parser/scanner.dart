import "character.dart";

class Pos {
  int cursor = 0; // 记录偏移值，对应字符串文本的数组下标, 从0开始
  int line = 1; // 记录偏移的行数
  int row = 1; // 记录当前行的真实位置, 非下标.

  Pos.init();

  Pos.none() : this(-1, -1, -1);

  Pos(this.cursor, this.line, this.row);

  Pos copy() {
    return Pos(cursor, line, row);
  }

  // 实现一个between 函数, 判断是否在两个Pos之间, 
  // 基于line 和 row, 当line 等于start 的line时，row 必须小于等于start 的row, 
  // 当line 等于end 的line时，row 必须大于等于end 的row.
  bool between(Pos start, Pos end) {
    return line >= start.line &&
        line <= end.line &&
        (line == start.line ? row >= start.row : true) &&
        (line == end.line ? row <= end.row : true);
  }
}

class Scanner {
  final String buf;
  final int length;

  Pos pos = Pos.init();

  Scanner(final String content)
      : buf = content,
        length = content.length;

  bool hasNextN(int count) {
    return pos.cursor + count <= length - 1;
  }

  bool hasNext() {
    return hasNextN(1);
  }

  void _next() {
    // 当前字符为 \n 换行, 当前字符为 \r 换行, 如果后面两个字符为 \r\n 时则下一个字符\r不换行, 等到下下个字符\n时换行.
    if (curChar() == Char.$n ||
        (curChar() == Char.$r && nextChar() != Char.$n)) {
      pos.line++;
      pos.row = 1;
    } else {
      pos.row++;
    }
    pos.cursor++;
  }

  bool nextN(int count) {
    if (!hasNextN(count)) return false;
    for (int i = 0; i < count; i++) {
      _next();
    }
    return true;
  }

  bool next() {
    if (hasNextN(1)) {
      _next();
      return true;
    } else {
      return false;
    }
  }

  int curChar() {
    if (pos.cursor > length - 1) {
      return 0;
    }
    return buf.codeUnitAt(pos.cursor);
  }

  int nextCharN(int count) {
    if (hasNextN(count)) {
      return buf.codeUnitAt(pos.cursor + count);
    }
    return 0;
  }

  int nextChar() {
    return nextCharN(1);
  }

  bool startWith(String prefix) {
    if (prefix.isEmpty) {
      return false;
    }
    if (prefix.length == 1 || hasNextN(prefix.length - 1)) {
      var sub = buf.substring(pos.cursor, pos.cursor + prefix.length);
      return (sub == prefix);
    } else {
      return false;
    }
  }

  seek(Pos pos) {
    if (pos.cursor <= length) {
      this.pos = pos.copy();
    }
  }

  String subString(Pos start, Pos end) {
    if (start.cursor > length - 1 ||
        end.cursor > length - 1 ||
        start.cursor > end.cursor) {
      return "";
    }
    return buf.substring(start.cursor, end.cursor + 1);
  }
}
