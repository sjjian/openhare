import 'dart:collection';

class ActiveSet<T> {
  Queue<T> data;
  int maxLength;

  ActiveSet(List<T> list, {this.maxLength = 5}) : data = Queue<T>() {
    for (final element in list) {
      add(element);
    }
  }

  // 添加的元素在队首
  void add(T element) {
    data.remove(element);
    if (data.length >= 5) data.removeLast();
    data.addFirst(element);
  }

  bool remove(T element) {
    return data.remove(element);
  }

  // 获取集合中所有的元素
  List<T> toList() => data.toList();

  @override
  String toString() {
    return data.toString();
  }
}
