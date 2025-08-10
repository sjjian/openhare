import 'package:test/test.dart';
import 'package:client/utils/active_set.dart';

void main() {
  group('ActiveSet', () {
    test('add elements and maintain order', () {
      final set = ActiveSet<int>([]);
      set.add(1);
      set.add(2);
      set.add(3);
      expect(set.toList(), [3, 2, 1]);
    });

    test('add duplicate moves to front', () {
      final set = ActiveSet<int>([1, 2, 3]);
      set.add(2);
      expect(set.toList(), [2, 1, 3]);
    });

    test('maxLength is respected', () {
      final set = ActiveSet<int>([], maxLength: 3);
      set.add(1);
      set.add(2);
      set.add(3);
      set.add(4);
      expect(set.toList(), [4, 3, 2]);
      expect(set.toList().length, 3);
    });

    test('remove element', () {
      final set = ActiveSet<int>([1, 2, 3]);
      final removed = set.remove(2);
      expect(removed, true);
      expect(set.toList(), [1, 3]);
    });

    test('remove non-existent element returns false', () {
      final set = ActiveSet<int>([1, 2, 3]);
      final removed = set.remove(4);
      expect(removed, false);
      expect(set.toList(), [1, 2, 3]);
    });

    test('toString returns correct string', () {
      final set = ActiveSet<int>([1, 2]);
      expect(set.toString(), contains('1'));
      expect(set.toString(), contains('2'));
    });

    test('constructor with initial list', () {
      final set = ActiveSet<int>([1, 2, 3]);
      expect(set.toList(), [1, 2, 3]);
    });

    test('add more than maxLength removes last', () {
      final set = ActiveSet<int>([], maxLength: 2);
      set.add(1);
      set.add(2);
      set.add(3);
      expect(set.toList(), [3, 2]);
    });
  });
}
