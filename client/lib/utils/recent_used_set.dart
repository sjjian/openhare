import 'dart:collection';

class RecentlyUsedSet<T> {
  final LinkedHashSet<T> data;

  RecentlyUsedSet(List<T> data) : data = LinkedHashSet<T>.from(data);

  // 添加元素
  void add(T element) {
    // 如果元素已经存在，先移除，再添加到末尾
    if (data.contains(element)) {
      data.remove(element);
    }
    data.add(element);
  }

  // 访问元素，并将其移到前面
  T? access(T element) {
    if (data.contains(element)) {
      data.remove(element); // 移除已有的元素
      data.add(element); // 再添加回末尾
      return element;
    }
    return null; // 如果元素不存在
  }

  // 获取集合中所有的元素
  List<T> get elements => data.toList();

  @override
  String toString() {
    return data.toString();
  }
}
