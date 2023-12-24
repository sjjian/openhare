import 'package:flutter/material.dart';

class CountNotifier with ChangeNotifier {
  int count = 0;

  void increment() {
    count++;
    notifyListeners();
  }
}

class PageNotifier with ChangeNotifier {
  int page = 0;

  void toSettingPage() {
    page = 1;
    print(page);
    notifyListeners();
  }

  void toHome() {
    page = 0;
    print(page);
    notifyListeners();
  }
}
