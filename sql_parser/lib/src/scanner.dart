class Pos {
  int cursor = -1;
  int line = 1;
  int row = 0;

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

  bool hasNext() {
    return pos.cursor < length - 1;
  }

  bool next() {
    var yes = hasNext();
    pos.offset(1);
    return yes;
  }

  int curChar() {
    if (pos.cursor == -1 || pos.cursor > length -1) {
      return 0;
    }
    return buf.codeUnitAt(pos.cursor);
  }

  int nextChar() {
    if (pos.cursor + 1 >= length) {
      return 0;
    }
    return buf.codeUnitAt(pos.cursor + 1);
  }

  seek(Pos pos) {
    if (pos.cursor <= length) {
      this.pos = pos;
    }
  }

  String subString(Pos start, Pos end) {
    if (start.cursor >= end.cursor) {
      return "";
    }
    return buf.substring(start.cursor, end.cursor + 1);
  }
}
