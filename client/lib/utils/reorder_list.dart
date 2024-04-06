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
        // 如果删除了选中的result，则默认选中前一个
    if (_selected == element) {
      if (_data.isEmpty) {
        _selected = null;
      } else {
        _selected = index > 0 ? _data[index - 1] : null;
      }
    }
    return element;
  }

  void select(int index) {
    final result = _data[index];
    _selected = result;
  }

  E? selected() {
    return _selected;
  }

  bool isSelected(E e) {
    return _selected == e;
  }
}
