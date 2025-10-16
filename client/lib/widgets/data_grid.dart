import 'package:flutter/material.dart';
import 'const.dart';

// 样式常量
class _DataGridStyle {
  static const double defaultRowHeight = 28.0;
  static const double defaultHeaderHeight = 36.0;
  static const double defaultColumnWidth = 200.0;
  static const double minColumnWidth = 50.0;
  static const double resizeHandleWidth = 8.0;
  static const double borderWidth = 1.0;
  static const double borderRadius = 4.0;
  static const EdgeInsets cellPadding = EdgeInsets.symmetric(horizontal: kSpacingSmall);
}

class DataGridController extends ChangeNotifier {
  final List<DataGridColumn> columns;
  final List<DataGridRow> rows;
  late List<double> _columnWidths;
  int? _hoveredRowIndex;
  final ScrollController _headerHorizontalController = ScrollController();
  final ScrollController _bodyHorizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();
  bool _isUpdatingScroll = false;

  DataGridController({
    required this.columns, 
    required this.rows
  }) {
    _columnWidths = List.generate(columns.length, (index) => columns[index].width);
    _setupScrollLinkage();
  }

  void _setupScrollLinkage() {
    _headerHorizontalController.addListener(_onHeaderScroll);
    _bodyHorizontalController.addListener(_onBodyScroll);
  }

  void _onHeaderScroll() {
    if (!_isUpdatingScroll && _headerHorizontalController.hasClients) {
      _isUpdatingScroll = true;
      if (_bodyHorizontalController.hasClients) {
        _bodyHorizontalController.jumpTo(_headerHorizontalController.offset);
      }
      _isUpdatingScroll = false;
    }
  }

  void _onBodyScroll() {
    if (!_isUpdatingScroll && _bodyHorizontalController.hasClients) {
      _isUpdatingScroll = true;
      if (_headerHorizontalController.hasClients) {
        _headerHorizontalController.jumpTo(_bodyHorizontalController.offset);
      }
      _isUpdatingScroll = false;
    }
  }

  int? get hoveredRowIndex => _hoveredRowIndex;
  set hoveredRowIndex(int? value) {
    _hoveredRowIndex = value;
    notifyListeners();
  }
  
  ScrollController get headerHorizontalController => _headerHorizontalController;
  ScrollController get bodyHorizontalController => _bodyHorizontalController;
  ScrollController get verticalController => _verticalController;
  List<double> get columnWidths => _columnWidths;
  
  /// 更新列宽
  void updateColumnWidth(int index, double width) {
    _columnWidths[index] = width;
    notifyListeners();
  }

  @override
  void dispose() {
    _headerHorizontalController.removeListener(_onHeaderScroll);
    _bodyHorizontalController.removeListener(_onBodyScroll);
    _headerHorizontalController.dispose();
    _bodyHorizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }
}

/// 列定义
class DataGridColumn {
  final Widget label;

  /// 初始宽度
  final double width;

  /// 最小宽度
  final double minWidth;

  /// 最大宽度
  final double? maxWidth;

  /// 是否可以调整大小
  final bool resizable;

  /// 对齐方式
  final Alignment alignment;

  const DataGridColumn({
    required this.label,
    this.width = _DataGridStyle.defaultColumnWidth,
    this.minWidth = _DataGridStyle.minColumnWidth,
    this.maxWidth,
    this.resizable = true,
    this.alignment = Alignment.centerLeft,
  });
}

class DataGridRow {
  final List<DataGridCell> cells;

  const DataGridRow({
    required this.cells,
  });
}

class DataGridCell {
  final Widget content;
  final Alignment alignment;

  const DataGridCell({
    required this.content,
    this.alignment = Alignment.centerLeft,
  });
}

/// 数据表格组件
class DataGrid extends StatefulWidget {

  final DataGridController controller;

  /// 行高
  final double rowHeight;

  /// 表头高度
  final double headerHeight;

  /// 是否显示边框
  final bool showBorder;

  /// 是否显示分割线
  final bool showDivider;

  /// 是否显示斑马条纹
  final bool showStripes;

  /// 空数据占位符
  final Widget? emptyWidget;

  /// 单元格点击回调
  final void Function(int rowIndex, int columnIndex, DataGridCell cell, List<DataGridCell> row)? onCellTap;

  /// 单元格双击回调
  final void Function(int rowIndex, int columnIndex, DataGridCell cell, List<DataGridCell> row)? onCellDoubleTap;

  const DataGrid({
    Key? key,
    required this.controller,
    this.rowHeight = _DataGridStyle.defaultRowHeight,
    this.headerHeight = _DataGridStyle.defaultHeaderHeight,
    this.showBorder = true,
    this.showDivider = true,
    this.showStripes = true,
    this.emptyWidget,
    this.onCellTap,
    this.onCellDoubleTap,
  }) : super(key: key);

  @override
  State<DataGrid> createState() => _DataGridState();
}

class _DataGridState extends State<DataGrid> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  /// 更新列宽
  void _updateColumnWidth(int index, double width) {
    widget.controller.updateColumnWidth(index, width);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, child) {
          return SizedBox.expand(
            child: Container(
              decoration: widget.showBorder
                  ? BoxDecoration(
                      border: Border.all(
                        color: colorScheme.outlineVariant,
                        width: _DataGridStyle.borderWidth,
                      ),
                      borderRadius: BorderRadius.circular(_DataGridStyle.borderRadius),
                    )
                  : null,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.showBorder ? _DataGridStyle.borderRadius : 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 固定表头
                    _buildHeader(context),
                    // 数据行
                    Expanded(
                      child: _buildBody(context),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建表头
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final totalWidth = widget.controller.columnWidths.fold(0.0, (sum, width) => sum + width);

    return Container(
      height: widget.headerHeight,
      decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant,
              width: _DataGridStyle.borderWidth,
            ),
          ),
      ),
      child: SingleChildScrollView(
        controller: widget.controller.headerHorizontalController,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: SizedBox(
          width: totalWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < widget.controller.columns.length; i++)
                _buildHeaderCell(context, widget.controller.columns[i], i),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建表头单元格
  Widget _buildHeaderCell(
      BuildContext context, DataGridColumn column, int index) {
    final width = widget.controller.columnWidths[index];

    return SizedBox(
      width: width,
      child: Stack(
        children: [
          // 表头内容
          Container(
            alignment: column.alignment,
            padding: _DataGridStyle.cellPadding,
            child: column.label,
          ),
          // 分割线和拖动手柄
          if (column.resizable && index <= widget.controller.columns.length - 1)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: _ResizeHandle(
                column: column,
                currentWidth: width,
                onResize: (delta) {
                  final newWidth = (width + delta).clamp(
                    column.minWidth,
                    column.maxWidth ?? double.infinity,
                  );
                  _updateColumnWidth(index, newWidth);
                },
              ),
            ),
        ],
      ),
    );
  }

  /// 构建数据主体
  Widget _buildBody(BuildContext context) {
    final totalWidth = widget.controller.columnWidths.fold(0.0, (sum, width) => sum + width);
    
    return Scrollbar(
      controller: widget.controller.verticalController,
      thumbVisibility: false,
      child: SingleChildScrollView(
        controller: widget.controller.verticalController,
        physics: const ClampingScrollPhysics(),
        child: SizedBox(
          height: widget.controller.rows.length * widget.rowHeight,
          child: Scrollbar(
            controller: widget.controller.bodyHorizontalController,
            thumbVisibility: false,
            child: SingleChildScrollView(
              controller: widget.controller.bodyHorizontalController,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                width: totalWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < widget.controller.rows.length; i++)
                      _buildRow(context, widget.controller.rows[i], i),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建数据行
  Widget _buildRow(
      BuildContext context, DataGridRow row, int rowIndex) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isHovered = widget.controller.hoveredRowIndex == rowIndex;
    final isEvenRow = rowIndex % 2 == 0;

    Color? backgroundColor;
    if (isHovered) {
      backgroundColor = colorScheme.surfaceContainerHighest.withOpacity(0.5);
    } else if (widget.showStripes && !isEvenRow) {
      backgroundColor = colorScheme.surfaceContainerLow;
    }

    return MouseRegion(
      onHover: (_) {
        if (widget.controller.hoveredRowIndex != rowIndex) {
          widget.controller.hoveredRowIndex = rowIndex;
        }
      },
      onExit: (_) {
        if (widget.controller.hoveredRowIndex == rowIndex) {
          widget.controller.hoveredRowIndex = null;
        }
      },
      cursor: widget.onCellTap != null || widget.onCellDoubleTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        child: Container(
          height: widget.rowHeight,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: widget.showDivider
                ? Border(
                    bottom: BorderSide(
                      color: colorScheme.outlineVariant.withOpacity(0.5),
                      width: 0.5,
                    ),
                  )
                : null,
          ),
          child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < widget.controller.columns.length; i++)
                _buildCell(context, widget.controller.columns[i], row.cells[i], rowIndex, i),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建单元格
  Widget _buildCell(
    BuildContext context,
    DataGridColumn column,
    DataGridCell cell,
    int rowIndex,
    int columnIndex,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final width = widget.controller.columnWidths[columnIndex];

    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: () => widget.onCellTap?.call(rowIndex, columnIndex, cell, widget.controller.rows[rowIndex].cells),
        onDoubleTap: () => widget.onCellDoubleTap?.call(rowIndex, columnIndex, cell, widget.controller.rows[rowIndex].cells),
        child: Container(
          alignment: column.alignment,
          padding: _DataGridStyle.cellPadding,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: colorScheme.outlineVariant,
                width: _DataGridStyle.borderWidth,
              ),
              bottom: BorderSide(
                color: colorScheme.outlineVariant,
                width: _DataGridStyle.borderWidth,
              ),
            ),
          ),
          child: cell.content,
        ),
      ),
    );
  }
}

/// 列宽调整手柄
class _ResizeHandle extends StatefulWidget {
  final DataGridColumn column;
  final double currentWidth;
  final ValueChanged<double> onResize;

  const _ResizeHandle({
    required this.column,
    required this.currentWidth,
    required this.onResize,
  });

  @override
  State<_ResizeHandle> createState() => _ResizeHandleState();
}

class _ResizeHandleState extends State<_ResizeHandle> {
  bool _isHovered = false;
  bool _isDragging = false;
  double? _dragStartX;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onHover: (_) {
        if (!_isHovered) {
          setState(() => _isHovered = true);
        }
      },
      onExit: (_) {
        if (_isHovered) {
          setState(() => _isHovered = false);
        }
      },
      child: GestureDetector(
        onHorizontalDragStart: (details) {
          setState(() {
            _isDragging = true;
            _dragStartX = details.globalPosition.dx;
          });
        },
        onHorizontalDragUpdate: (details) {
          if (_dragStartX != null) {
            final delta = details.globalPosition.dx - _dragStartX!;
            widget.onResize(delta);
            _dragStartX = details.globalPosition.dx;
          }
        },
        onHorizontalDragEnd: (_) {
          setState(() {
            _isDragging = false;
            _dragStartX = null;
          });
        },
        child: Container(
          width: _DataGridStyle.resizeHandleWidth,
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: _DataGridStyle.borderWidth,
              color: _isHovered || _isDragging
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
            ),
          ),
        ),
      ),
    );
  }
}
