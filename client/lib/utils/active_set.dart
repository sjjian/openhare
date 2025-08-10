import 'dart:collection';

class ActiveSet<T> {
  final Queue<T> data;
  final int maxLength;

  // 通过list导入，例如[1,2,3]，顺序保持为[1,2,3]（队首到队尾）
  ActiveSet(List<T> list, {this.maxLength = 5}) : data = Queue<T>() {
    // 保证导入时顺序为list[0]为队首，list[last]为队尾
    for (final element in list) {
      if (!data.contains(element)) {
        data.addLast(element);
        if (data.length > maxLength) {
          data.removeFirst();
        }
      }
    }
  }

  // 添加的元素在队首
  void add(T element) {
    data.remove(element);
    data.addFirst(element);
    while (data.length > maxLength) {
      data.removeLast();
    }
  }

  bool remove(T element) {
    return data.remove(element);
  }

  // 获取集合中所有的元素，顺序为队首到队尾
  List<T> toList() {
    return data.toList();
  }

  @override
  String toString() {
    return data.toString();
  }
}
