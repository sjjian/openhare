import 'package:flutter/material.dart';

class TablePaginatedBar extends StatefulWidget {
  // int count;
  // int pageSize;
  // int pageNumber;
  // late int totalPageNumber;
  TablePageController controller;

  // Function(int limit, int offset) onChange;

  TablePaginatedBar({Key? key, required this.controller}) : super(key: key);
  //     {
  //   // totalPageNumber = (count / pageSize).ceil(); // 向上取整, 总得出页数.
  // }

  @override
  State<TablePaginatedBar> createState() => _PaginatedBarState();
}

class _PaginatedBarState extends State<TablePaginatedBar> {
  @override
  Widget build(BuildContext context) {
    int totalPageNumber =
        (widget.controller.count / widget.controller.pageSize).ceil();
    bool isFirstPage = (widget.controller.pageNumber <= 1);
    bool isLastPage = (widget.controller.pageNumber == totalPageNumber);
    return Container(
      padding: const EdgeInsets.only(top: 15, bottom: 15, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text("${widget.controller.pageNumber}/$totalPageNumber"),
          ),
          IconButton(
              onPressed: isFirstPage
                  ? null
                  : () {
                      setState(() {
                        widget.controller.onChange(1);
                      });
                    },
              icon: const Icon(Icons.first_page)),
          IconButton(
              onPressed: isFirstPage
                  ? null
                  : () {
                      setState(() {
                        widget.controller
                            .onChange(widget.controller.pageNumber - 1);
                      });
                      // widget.onChange(widget.pageSize, widget.pageNumber);
                    },
              icon: const Icon(Icons.keyboard_arrow_left)),
          IconButton(
              onPressed: isLastPage
                  ? null
                  : () {
                      setState(() {
                        widget.controller
                            .onChange(widget.controller.pageNumber + 1);
                      });
                      // widget.onChange(widget.pageSize, widget.pageNumber);
                    },
              icon: const Icon(Icons.keyboard_arrow_right_outlined)),
          IconButton(
              onPressed: isLastPage
                  ? null
                  : () {
                      setState(() {
                        widget.controller.onChange(totalPageNumber);
                        // widget.pageNumber = widget.totalPageNumber;
                      });
                      // widget.onChange(widget.pageSize, widget.pageNumber);
                    },
              icon: const Icon(Icons.last_page)),
        ],
      ),
    );
  }
}

abstract class TablePageController {
  void onChange(int pageNumber);
  int get count;
  int get pageSize;
  int get pageNumber;
}
