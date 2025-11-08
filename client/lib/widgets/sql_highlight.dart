import 'package:flutter/material.dart';
import 'package:sql_parser/parser.dart';

// 枚举类型颜色
class SQLHighlightColor {
  static const keyword = Color(0xffa626a4);
  static const comment = Color(0xffa0a1a7);
  static const singleQValue = Color(0xff50a14f);
  static const doubleQValue = Color(0xff50a14f);
  static const number = Color(0xff986801);
  static const ident = Color(0xff4078f2);
  static const backQValue = Color(0xff4078f2);
}

const sqlLightTheme = {
  TokenType.keyword: TextStyle(color: SQLHighlightColor.keyword),
  TokenType.comment: TextStyle(
    color: SQLHighlightColor.comment,
    fontStyle: FontStyle.italic,
  ),
  TokenType.singleQValue: TextStyle(color: SQLHighlightColor.singleQValue),
  TokenType.doubleQValue: TextStyle(color: SQLHighlightColor.doubleQValue),
  TokenType.number: TextStyle(color: SQLHighlightColor.number),
  TokenType.ident: TextStyle(color: SQLHighlightColor.ident),
  TokenType.backQValue: TextStyle(color: SQLHighlightColor.backQValue),
};

TextStyle? getStyle(TokenType type) {
  return sqlLightTheme[type];
}

TextSpan getSQLHighlightTextSpan(String text, {TextStyle? defalutStyle}) {
  return TextSpan(
      children: Lexer(text)
          .tokens()
          .map<TextSpan>((tok) => TextSpan(
              text: tok.content, style: getStyle(tok.id) ?? defalutStyle))
          .toList());
}
