extension ListLimit<E> on List<E> {
  List<E> limit(int offset, int limit) {
    if (length <= offset) {
      return List.empty();
    } else if (length <= (offset + limit)) {
      return sublist(offset);
    } else {
      return sublist(offset, offset + limit);
    }
  }
}
