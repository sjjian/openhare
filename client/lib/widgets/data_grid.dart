import 'package:flutter/material.dart';
import 'const.dart';

// 样式常量
class _DataGridStyle {
  static const double defaultRowHeight = 24.0;
  static const double defaultHeaderHeight = 36.0;
  static const double defaultColumnWidth = 200.0;
  static const double minColumnWidth = 50.0;
  static const double resizeHandleWidth = 8.0;
  static const double borderWidth = 1.0;
  static const double scrollPadding = 10.0;
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
    _syncScroll(_headerHorizontalController, _bodyHorizontalController);
  }

  void _onBodyScroll() {
    _syncScroll(_bodyHorizontalController, _headerHorizontalController);
  }

  void _syncScroll(ScrollController source, ScrollController target) {
    if (!_isUpdatingScroll && source.hasClients && target.hasClients) {
      _isUpdatingScroll = true;
      target.jumpTo(source.offset);
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
  final Color? backgroundColor;

  const DataGridCell({
    required this.content,
    this.alignment = Alignment.centerLeft,
    this.backgroundColor,
  });
}

/// 数据表格组件
class DataGrid extends StatefulWidget {

  final DataGridController controller;

  /// 行高
  final double rowHeight;

  /// 表头高度
  final double headerHeight;

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
    this.emptyWidget,
    this.onCellTap,
    this.onCellDoubleTap,
  }) : super(key: key);

  @override
  State<DataGrid> createState() => _DataGridState();
}

class _DataGridState extends State<DataGrid> {
  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  /// 计算总宽度
  double get _totalWidth => widget.controller.columnWidths.fold(0.0, (sum, width) => sum + width) + _DataGridStyle.scrollPadding;
  
  /// 计算内容宽度
  double get _contentWidth => widget.controller.columnWidths.fold(0.0, (sum, width) => sum + width);

  /// 更新列宽
  void _updateColumnWidth(int index, double width) {
    widget.controller.updateColumnWidth(index, width);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, child) {
          return SizedBox.expand(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                Expanded(child: _buildBody(context)),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 构建表头
  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: widget.headerHeight,
      child: SingleChildScrollView(
        controller: widget.controller.headerHorizontalController,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: SizedBox(
          width: _totalWidth,
          child: Row(
            children: [
              Container(
                width: _contentWidth,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outlineVariant,
                      width: _DataGridStyle.borderWidth,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    for (int i = 0; i < widget.controller.columns.length; i++)
                      _buildHeaderCell(context, widget.controller.columns[i], i),
                  ],
                ),
              ),
              const SizedBox(width: _DataGridStyle.scrollPadding),
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
          // 拖动手柄
          if (column.resizable && index < widget.controller.columns.length)
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
    return Scrollbar(
      controller: widget.controller.verticalController,
      thumbVisibility: false,
      child: SingleChildScrollView(
        controller: widget.controller.verticalController,
        physics: const ClampingScrollPhysics(),
        child: SizedBox(
          height: widget.controller.rows.length * widget.rowHeight + _DataGridStyle.scrollPadding,
          child: Scrollbar(
            controller: widget.controller.bodyHorizontalController,
            thumbVisibility: false,
            child: SingleChildScrollView(
              controller: widget.controller.bodyHorizontalController,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                width: _totalWidth,
                child: Column(
                  children: [
                    for (int i = 0; i < widget.controller.rows.length; i++)
                      _buildRow(context, widget.controller.rows[i], i),
                    const SizedBox(height: _DataGridStyle.scrollPadding),
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
  Widget _buildRow(BuildContext context, DataGridRow row, int rowIndex) {
    return MouseRegion(
      onHover: (_) => widget.controller.hoveredRowIndex = rowIndex,
      onExit: (_) => widget.controller.hoveredRowIndex = null,
      cursor: widget.onCellTap != null || widget.onCellDoubleTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: Container(
        height: widget.rowHeight,
        child: Row(
          children: [
            for (int i = 0; i < widget.controller.columns.length; i++)
              _buildCell(context, widget.controller.columns[i], row.cells[i], rowIndex, i),
            const SizedBox(width: _DataGridStyle.scrollPadding),
          ],
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
    final colorScheme = Theme.of(context).colorScheme;
    final width = widget.controller.columnWidths[columnIndex];
    final rowCells = widget.controller.rows[rowIndex].cells;
    final isHovered = widget.controller.hoveredRowIndex == rowIndex;

    // 确定单元格背景色：优先级为 cell.backgroundColor > 悬停
    Color? backgroundColor = cell.backgroundColor;
    if (backgroundColor == null && isHovered) {
      backgroundColor = colorScheme.surfaceContainerHighest.withOpacity(0.5);
    }

    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: () => widget.onCellTap?.call(rowIndex, columnIndex, cell, rowCells),
        onDoubleTap: () => widget.onCellDoubleTap?.call(rowIndex, columnIndex, cell, rowCells),
        child: Container(
          alignment: column.alignment,
          padding: _DataGridStyle.cellPadding,
          decoration: BoxDecoration(
            color: backgroundColor,
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
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = _isHovered || _isDragging;

    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onHover: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
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
              color: isActive ? colorScheme.primary : colorScheme.outlineVariant,
            ),
          ),
        ),
      ),
    );
  }
}
