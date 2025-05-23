import 'package:quiver/collection.dart';

class ReorderSelectedList<E> extends DelegatingList<E> {
  final List<E> _data;
  E? _selected;

  ReorderSelectedList({List<E> data = const [], E? selected}) : _data = data{
    _selected = selected ?? (data.isNotEmpty? data[0] : null);
  }

  ReorderSelectedList.copyWith(ReorderSelectedList<E> origin)
      : _data = List<E>.from(origin._data),
        _selected = origin._selected;

  @override
  List<E> get delegate => _data;

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      // removing the item at oldIndex will shorten the list by 1.
      newIndex -= 1;
    }
    final E element = _data.removeAt(oldIndex);
    _data.insert(newIndex, element);
  }

  @override
  void add(E value) {
    _data.add(value);
    _selected = value;
  }

  @override
  E removeAt(int index) {
    final element = _data.removeAt(index);
    if (_selected == element) {
      if (_data.isEmpty) {
        _selected = null;
      } else {
        // 删除的元素是当前选中的，则要切换选中元素；
        _selected = index <= _data.length - 1 ? _data[index] : _data[index - 1];
      }
    }
    return element;
  }

  bool select(int index) {
    final result = _data[index];
    if (_selected == result) {
      return false;
    } else {
      _selected = result;
      return true;
    }
  }

  E? selected() {
    return _selected;
  }

  bool isSelected(E e) {
    return _selected == e;
  }

  replace(E origin, E target) {
    int index = _data.indexOf(origin);
    // 如果不存在则 add, 如果存在, 则下标替换
    index == -1 ? _data.add(target) : _data[index] = target;

    // 如果替换的是selected 元素, 则selected 标记为 target 元素
    _selected = _selected == origin ? target : _selected;
  }
}
