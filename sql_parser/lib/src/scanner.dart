class Pos {
  int cursor = 0; // 记录偏移值，对应字符串文本的数组下标
  int line = 1; // 记录偏移的行数
  int row = 0; // 记录当前行的偏移值

  Pos.init();

  Pos(this.cursor, this.line, this.row);

  Pos copy() {
    return Pos(cursor, line, row);
  }

  offset(int length) {
    cursor += length;
    row += length;
  }

  newline() {
    line++;
    row = 0;
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

  bool nextN(int count) {
    var yes = hasNextN(count);
    pos.offset(count);
    return yes;
  }

  bool hasNext() {
    return hasNextN(1);
  }

  bool next() {
    return nextN(1);
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
    if (start.cursor > length - 1 || start.cursor > end.cursor) {
      return "";
    }
    return buf.substring(start.cursor, end.cursor + 1);
  }
}
