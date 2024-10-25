import 'dart:collection';

class ActiveSet<T> {
  Queue<T> data;

  ActiveSet(
    List<T> list,
  ) : data = Queue<T>() {
    for (final element in list) {
      add(element);
    }
  }

  // 添加的元素在队首
  void add(T element) {
    data.remove(element);
    data.addFirst(element);
  }

  // 获取集合中所有的元素
  List<T> toList() => data.toList();

  @override
  String toString() {
    return data.toString();
  }
}
