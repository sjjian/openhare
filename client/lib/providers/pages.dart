import 'package:flutter/material.dart';

class PageProvider with ChangeNotifier {
  int value = 0;

  void toPage(int value) {
    this.value = value;
    notifyListeners();
  }
}
