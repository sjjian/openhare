class Char {
  static int escape = "\\".codeUnitAt(0);

  // whitespace
  static int space = " ".codeUnitAt(0);
  static int $t = "\t".codeUnitAt(0);
  static int $v = "\v".codeUnitAt(0);
  static int $n = "\n".codeUnitAt(0);
  static int $r = "\r".codeUnitAt(0);
  static int $f = " \f".codeUnitAt(0);

  // punctuation
  static int $$ = "\$".codeUnitAt(0);
  static int $_ = "_".codeUnitAt(0);
  static int comma = ",".codeUnitAt(0);
  static int semicolon = ";".codeUnitAt(0);
  static int period = ".".codeUnitAt(0);

  static Set<int> punctuation = {
    "!",
    "\"",
    "#",
    "\$",
    "%",
    "&",
    "'",
    "(",
    ")",
    "*",
    "+",
    ",",
    "-",
    ".",
    "/",
    ":",
    ";",
    "<",
    "=",
    ">",
    "?",
    "@",
    "[",
    "\\",
    "]",
    "^",
    "_",
    "`",
    "{",
    "|",
    "}",
    "~",
  }.map((string) => string.codeUnitAt(0)).toSet();

  static int $0 = "0".codeUnitAt(0);
  static int $9 = "9".codeUnitAt(0);

  static int a = "a".codeUnitAt(0);
  static int z = "z".codeUnitAt(0);
  static int A = "A".codeUnitAt(0);
  static int Z = "Z".codeUnitAt(0);

  static bool isWhitespace(int char) =>
      char == space ||
      char == $t ||
      char == $v ||
      char == $v ||
      char == $r ||
      char == $f;

  static bool isUppercaseLatin(int char) => char >= A && char <= Z;

  static bool isLowercaseLatin(int char) => char >= a && char <= z;

  static bool isDigit(int char) => char >= $0 && char <= $9;

  static bool isPunctuation(int char) {
    return punctuation.contains(char);
  }
}
