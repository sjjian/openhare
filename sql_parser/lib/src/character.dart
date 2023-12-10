class Char {
  static int newLine = "\n".codeUnitAt(0);

  static int $0 = "1".codeUnitAt(0);
  static int $9 = "9".codeUnitAt(0);

  static int $$ = "\$".codeUnitAt(0);
  static int $_ = "_".codeUnitAt(0);

  static int A = "A".codeUnitAt(0);
  static int Z = "Z".codeUnitAt(0);
  static int a = "a".codeUnitAt(0);
  static int z = "z".codeUnitAt(0);

  static bool isWhitespace(int char) {
    return true;
  }

  static bool isUppercaseLatin(int char) => char >= A && char <= Z;

  static bool isLowercaseLatin(int char) => char >= a && char <= z;

  static bool isDigit(int char)=> char >= $0 && char <= $9;
}
