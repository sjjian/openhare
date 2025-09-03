import 'package:client/widgets/button.dart';
import 'package:flutter/material.dart';

class TablePaginatedBar extends StatefulWidget {
  final int count;
  final int pageSize;
  final int pageNumber;
  final void Function(int pageNumber) onChange;

  const TablePaginatedBar(
      {Key? key,
      required this.count,
      required this.pageSize,
      required this.pageNumber,
      required this.onChange})
      : super(key: key);

  @override
  State<TablePaginatedBar> createState() => _PaginatedBarState();
}

class _PaginatedBarState extends State<TablePaginatedBar> {
  void _onChange(int pageNumber) {
    setState(() {
      widget.onChange(pageNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalPageNumber = (widget.count / widget.pageSize).ceil();
    bool isFirstPage = (widget.pageNumber <= 1);
    bool isLastPage = (widget.pageNumber == totalPageNumber);
    return Container(
      padding: const EdgeInsets.only(top: 15, bottom: 15, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text("${widget.pageNumber}/$totalPageNumber"),
          ),
          RectangleIconButton.medium(
            icon: Icons.first_page,
            onPressed: isFirstPage ? null : () => _onChange(1),
          ),
          RectangleIconButton.medium(
            icon: Icons.keyboard_arrow_left,
            onPressed:
                isFirstPage ? null : () => _onChange(widget.pageNumber - 1),
          ),
          RectangleIconButton.medium(
            icon: Icons.keyboard_arrow_right_outlined,
            onPressed:
                isLastPage ? null : () => _onChange(widget.pageNumber + 1),
          ),
          RectangleIconButton.medium(
            icon: Icons.last_page,
            onPressed: isLastPage ? null : () => _onChange(totalPageNumber),
          ),
        ],
      ),
    );
  }
}
