import 'dart:math';
import 'package:flutter/material.dart';

class InstancesProvider extends DataTableSource {
  int _selectCount = 0; //当前选中的行数
  final List<Map<String, dynamic>> _sourceData = List.generate(
      200,
      (index) => {
            "avatar": 'assets/icons/mysql_icon.png',
            "id": (index + 1),
            "name": "Item Name ${(index + 1)}",
            "price": Random().nextInt(10000),
            "no.": Random().nextInt(10000),
            "address": "root",
            "selected": false
          });

  bool get isRowCountApproximate => false;

  int get rowCount => _sourceData.length;

  int get selectedRowCount => _selectCount;

  DataRow getRow(int index) => DataRow.byIndex(
          index: index,
          selected: _sourceData[index]["selected"],
          onSelectChanged: (selected) {
            _sourceData[index]["selected"] = selected;
            notifyListeners();
          },
          cells: [
            DataCell(CircleAvatar(
                backgroundImage: AssetImage(_sourceData[index]["avatar"]))),
            DataCell(Text(_sourceData[index]['id'].toString())),
            DataCell(Text(_sourceData[index]['name'])),
            DataCell(Text('\$ ${_sourceData[index]['price']}')),
            DataCell(Text(_sourceData[index]['no.'].toString())),
            DataCell(Text(_sourceData[index]['address'].toString()))
          ]);

  void sortData<T>(Comparable<T> getField(Map<String, dynamic> map), bool b) {
    _sourceData.sort((Map<String, dynamic> map1, Map<String, dynamic> map2) {
      if (!b) {
        //两个项进行交换
        final Map<String, dynamic> temp = map1;
        map1 = map2;
        map2 = temp;
      }
      final Comparable<T> s1Value = getField(map1);
      final Comparable<T> s2Value = getField(map2);
      return Comparable.compare(s1Value, s2Value);
    });
    notifyListeners();
  }

  void selectAll(bool checked) {
    _sourceData.forEach((data) => data["selected"] = checked);
    _selectCount = checked ? _sourceData.length : 0;
    notifyListeners(); //通知监听器去刷新
  }
}