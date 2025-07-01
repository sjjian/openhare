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
          IconButton(
              onPressed: isFirstPage
                  ? null
                  : () {
                      setState(() {
                        widget.onChange(1);
                      });
                    },
              icon: const Icon(Icons.first_page)),
          IconButton(
              onPressed: isFirstPage
                  ? null
                  : () {
                      setState(() {
                        widget.onChange(widget.pageNumber - 1);
                      });
                    },
              icon: const Icon(Icons.keyboard_arrow_left)),
          IconButton(
              onPressed: isLastPage
                  ? null
                  : () {
                      setState(() {
                        widget.onChange(widget.pageNumber + 1);
                      });
                    },
              icon: const Icon(Icons.keyboard_arrow_right_outlined)),
          IconButton(
              onPressed: isLastPage
                  ? null
                  : () {
                      setState(() {
                        widget.onChange(totalPageNumber);
                      });
                    },
              icon: const Icon(Icons.last_page)),
        ],
      ),
    );
  }
}

// abstract class TablePageController {
//   void onChange(int pageNumber);
//   int get count;
//   int get pageSize;
//   int get pageNumber;
// }
