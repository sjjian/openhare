import 'package:quiver/collection.dart';

class ReorderSelectedList<E> extends DelegatingList<E> {
  final List<E> _data = [];
  E? _selected;

  ReorderSelectedList();

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
        _selected = index == _data.length - 1 ? _data[index] : _data[index - 1];
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
}
