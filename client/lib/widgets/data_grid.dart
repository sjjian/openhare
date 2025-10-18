import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'const.dart';

/// 自定义表格分割线绘制器
class _DataGridBorderPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final List<double> columnWidths;
  final double rowHeight;
  final int rowCount;
  final bool showVerticalBorders;
  final bool showHorizontalBorders;
  final double contentWidth;
  final bool skipFirstRowTopBorder;

  const _DataGridBorderPainter({
    required this.borderColor,
    required this.borderWidth,
    required this.columnWidths,
    required this.rowHeight,
    required this.rowCount,
    required this.contentWidth,
    this.showVerticalBorders = true,
    this.showHorizontalBorders = true,
    this.skipFirstRowTopBorder = false,
  });


  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..isAntiAlias = false;

    // 计算实际内容高度（不包含scrollPadding）
    final contentHeight = rowCount * rowHeight;
    
    // 获取可用的绘制区域大小，确保不超出组件边界
    final availableWidth = size.width;
    final availableHeight = size.height;

    // 使用Path一次性绘制完整网格
    final path = Path();

    // 绘制垂直分割线
    if (showVerticalBorders) {
      double x = 0;
      for (int i = 0; i < columnWidths.length; i++) {
        x += columnWidths[i];
        // 确保垂直分割线不超出可视区域，并且不超过内容宽度
        final clampedX = math.min(x, math.min(contentWidth, availableWidth));
        if (clampedX > 0 && clampedX < availableWidth) {
          path.moveTo(clampedX, 0);
          path.lineTo(clampedX, math.min(contentHeight, availableHeight));
        }
      }
    }

    // 绘制水平分割线
    if (showHorizontalBorders) {
      for (int i = 0; i <= rowCount; i++) {
        // 如果设置了跳过第一行顶部边框，则跳过第一条水平线
        if (skipFirstRowTopBorder && i == 0) {
          continue;
        }
        final y = i * rowHeight;
        // 确保水平分割线不超出可视区域
        if (y >= 0 && y <= availableHeight) {
          path.moveTo(0, y);
          path.lineTo(math.min(contentWidth, availableWidth), y);
        }
      }
    }

    // 一次性绘制所有线条
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DataGridBorderPainter oldDelegate) {
    return borderColor != oldDelegate.borderColor ||
        borderWidth != oldDelegate.borderWidth ||
        !_listEquals(columnWidths, oldDelegate.columnWidths) ||
        rowHeight != oldDelegate.rowHeight ||
        rowCount != oldDelegate.rowCount ||
        contentWidth != oldDelegate.contentWidth ||
        showVerticalBorders != oldDelegate.showVerticalBorders ||
        showHorizontalBorders != oldDelegate.showHorizontalBorders ||
        skipFirstRowTopBorder != oldDelegate.skipFirstRowTopBorder;
  }

  /// 比较两个double列表是否相等
  bool _listEquals(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}


// 样式常量
class _DataGridStyle {
  static const double defaultRowHeight = 24.0;
  static const double defaultHeaderHeight = 36.0;
  static const double defaultColumnWidth = 200.0;
  static const double minColumnWidth = 50.0;
  static const double resizeHandleWidth = 8.0;
  static const double borderWidth = 1;
  static const double scrollPadding = 10.0;
  static const EdgeInsets cellPadding = EdgeInsets.symmetric(horizontal: kSpacingSmall);
}

class DataGridController extends ChangeNotifier {
  final List<DataGridColumn> columns;
  final List<DataGridRow> rows;
  late List<double> _columnWidths;
  
  // 使用 LinkedScrollControllerGroup 来管理水平滚动联动
  final LinkedScrollControllerGroup _horizontalScrollGroup = LinkedScrollControllerGroup();
  final ScrollController _verticalController = ScrollController();
  
  // 延迟初始化的滚动控制器
  ScrollController? _headerHorizontalController;
  ScrollController? _headerBorderHorizontalController;
  ScrollController? _bodyHorizontalController;

  DataGridController({
    required this.columns, 
    required this.rows
  }) {
    _columnWidths = List.generate(columns.length, (index) => columns[index].width);
  }

  
  ScrollController get headerHorizontalController {
    _headerHorizontalController ??= _horizontalScrollGroup.addAndGet();
    return _headerHorizontalController!;
  }
  
  ScrollController get headerBorderHorizontalController {
    _headerBorderHorizontalController ??= _horizontalScrollGroup.addAndGet();
    return _headerBorderHorizontalController!;
  }
  
  ScrollController get bodyHorizontalController {
    _bodyHorizontalController ??= _horizontalScrollGroup.addAndGet();
    return _bodyHorizontalController!;
  }
  
  ScrollController get verticalController => _verticalController;
  List<double> get columnWidths => _columnWidths;
  
  /// 更新列宽
  void updateColumnWidth(int index, double width) {
    if (index >= 0 && index < _columnWidths.length) {
      // 确保列宽在合理范围内
      final column = columns[index];
      final clampedWidth = width.clamp(
        column.minWidth,
        column.maxWidth ?? double.infinity,
      );
      _columnWidths[index] = clampedWidth;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _headerHorizontalController?.dispose();
    _headerBorderHorizontalController?.dispose();
    _bodyHorizontalController?.dispose();
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
    // 注意：不要在这里调用 controller.dispose()，因为控制器可能被其他地方使用
    // widget.controller.dispose();
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
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  /// 构建表头
  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: widget.headerHeight,
          child: ClipRect(
            child: SingleChildScrollView(
              controller: widget.controller.headerHorizontalController,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                width: _totalWidth,
                child: AnimatedBuilder(
                  animation: widget.controller,
                  builder: (context, child) {
                    return _DataGridBorderWidget(
                      borderColor: Theme.of(context).colorScheme.outlineVariant,
                      borderWidth: _DataGridStyle.borderWidth,
                      columnWidths: widget.controller.columnWidths,
                      rowHeight: widget.headerHeight,
                      rowCount: 1,
                      contentWidth: _contentWidth,
                      showVerticalBorders: true,
                      showHorizontalBorders: false,
                      child: RepaintBoundary(
                        child: Row(
                          children: [
                            for (int i = 0; i < widget.controller.columns.length; i++)
                              _buildHeaderCell(context, widget.controller.columns[i], i),
                            const SizedBox(width: _DataGridStyle.scrollPadding),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        // 表头底部分割线
        SizedBox(
          height: _DataGridStyle.borderWidth,
          child: ClipRect(
            child: SingleChildScrollView(
              controller: widget.controller.headerBorderHorizontalController,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                width: _totalWidth,
                child: AnimatedBuilder(
                  animation: widget.controller,
                  builder: (context, child) {
                    return _DataGridBorderWidget(
                      borderColor: colorScheme.outlineVariant,
                      borderWidth: _DataGridStyle.borderWidth,
                      columnWidths: widget.controller.columnWidths,
                      rowHeight: _DataGridStyle.borderWidth,
                      rowCount: 1,
                      contentWidth: _contentWidth,
                      showVerticalBorders: false,
                      showHorizontalBorders: true,
                      skipFirstRowTopBorder: false,
                      child: Container(
                        height: _DataGridStyle.borderWidth,
                        color: Colors.transparent,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
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
            alignment: Alignment.centerLeft,
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
      thumbVisibility: true,
      child: ClipRect(
        child: SingleChildScrollView(
          controller: widget.controller.verticalController,
          physics: const ClampingScrollPhysics(),
          child: SizedBox(
            height: widget.controller.rows.length * widget.rowHeight + _DataGridStyle.scrollPadding,
            child: Scrollbar(
              controller: widget.controller.bodyHorizontalController,
              thumbVisibility: true,
              child: ClipRect(
                child: SingleChildScrollView(
                  controller: widget.controller.bodyHorizontalController,
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: SizedBox(
                    width: _totalWidth,
                    child: AnimatedBuilder(
                      animation: widget.controller,
                      builder: (context, child) {
                        return _DataGridBorderWidget(
                          borderColor: Theme.of(context).colorScheme.outlineVariant,
                          borderWidth: _DataGridStyle.borderWidth,
                          columnWidths: widget.controller.columnWidths,
                          rowHeight: widget.rowHeight,
                          rowCount: widget.controller.rows.length,
                          contentWidth: _contentWidth,
                          showVerticalBorders: true,
                          showHorizontalBorders: true,
                          skipFirstRowTopBorder: true,
                          child: RepaintBoundary(
                            child: Column(
                              children: [
                                for (int i = 0; i < widget.controller.rows.length; i++)
                                  _buildRow(context, widget.controller.rows[i], i),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
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
    return _DataGridRowWidget(
      row: row,
      rowIndex: rowIndex,
      controller: widget.controller,
      rowHeight: widget.rowHeight,
      onCellTap: widget.onCellTap,
      onCellDoubleTap: widget.onCellDoubleTap,
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

/// 独立的数据网格行组件，管理自己的悬停状态
class _DataGridRowWidget extends StatefulWidget {
  final DataGridRow row;
  final int rowIndex;
  final DataGridController controller;
  final double rowHeight;
  final Function(int, int, DataGridCell, List<DataGridCell>)? onCellTap;
  final Function(int, int, DataGridCell, List<DataGridCell>)? onCellDoubleTap;

  const _DataGridRowWidget({
    required this.row,
    required this.rowIndex,
    required this.controller,
    required this.rowHeight,
    this.onCellTap,
    this.onCellDoubleTap,
  });

  @override
  State<_DataGridRowWidget> createState() => _DataGridRowWidgetState();
}

class _DataGridRowWidgetState extends State<_DataGridRowWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onCellTap != null || widget.onCellDoubleTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: Container(
        height: widget.rowHeight,
        child: Row(
          children: [
            for (int i = 0; i < widget.controller.columns.length; i++)
              _buildCell(context, widget.controller.columns[i], widget.row.cells[i], i),
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
    int columnIndex,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = widget.controller.columnWidths[columnIndex];

    // 确定单元格背景色：优先级为 cell.backgroundColor > 悬停
    Color? backgroundColor = cell.backgroundColor;
    if (backgroundColor == null && _isHovered) {
      backgroundColor = colorScheme.surfaceContainerHighest.withOpacity(0.5);
    }

    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: () => widget.onCellTap?.call(widget.rowIndex, columnIndex, cell, widget.row.cells),
        onDoubleTap: () => widget.onCellDoubleTap?.call(widget.rowIndex, columnIndex, cell, widget.row.cells),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.centerLeft,
          padding: _DataGridStyle.cellPadding,
          color: backgroundColor,
          child: cell.content,
        ),
      ),
    );
  }
}

/// 独立的边框绘制组件，避免不必要的重绘
class _DataGridBorderWidget extends StatelessWidget {
  final Color borderColor;
  final double borderWidth;
  final List<double> columnWidths;
  final double rowHeight;
  final int rowCount;
  final double contentWidth;
  final bool showVerticalBorders;
  final bool showHorizontalBorders;
  final bool skipFirstRowTopBorder;
  final Widget child;

  const _DataGridBorderWidget({
    required this.borderColor,
    required this.borderWidth,
    required this.columnWidths,
    required this.rowHeight,
    required this.rowCount,
    required this.contentWidth,
    required this.showVerticalBorders,
    required this.showHorizontalBorders,
    required this.child,
    this.skipFirstRowTopBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DataGridBorderPainter(
        borderColor: borderColor,
        borderWidth: borderWidth,
        columnWidths: columnWidths,
        rowHeight: rowHeight,
        rowCount: rowCount,
        contentWidth: contentWidth,
        showVerticalBorders: showVerticalBorders,
        showHorizontalBorders: showHorizontalBorders,
        skipFirstRowTopBorder: skipFirstRowTopBorder,
      ),
      child: child,
    );
  }
}
