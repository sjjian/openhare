import 'package:flutter/material.dart';
import 'package:common/parser.dart';

const sqlLightTheme = {
  TokenType.keyword: TextStyle(color: Color(0xffa626a4)),
  TokenType.comment:
      TextStyle(color: Color(0xffa0a1a7), fontStyle: FontStyle.italic),
  TokenType.singleQValue: TextStyle(color: Color(0xff50a14f)),
  TokenType.doubleQValue: TextStyle(color: Color(0xff50a14f)),
  TokenType.number: TextStyle(color: Color(0xff986801)),
  TokenType.ident: TextStyle(color: Color(0xff4078f2)),
  TokenType.backQValue: TextStyle(color: Color(0xff4078f2)),
};

TextStyle? getStyle(TokenType type) {
  return sqlLightTheme[type];
}
