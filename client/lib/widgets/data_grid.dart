import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'const.dart';

// 样式常量
class _DataGridStyle {
  static const double defaultRowHeight = 24.0;
  static const double defaultHeaderHeight = 36.0;
  static const double defaultColumnWidth = 200.0;
  static const double minColumnWidth = 50.0;
  static const double resizeHandleWidth = 8.0;
  static const double borderWidth = 1;
  static const double scrollPadding = 10.0;
  static const EdgeInsets cellPadding =
      EdgeInsets.symmetric(horizontal: kSpacingSmall);
}

class DataGridController extends ChangeNotifier {
  final List<DataGridColumn> columns;
  final List<DataGridRow> rows;
  late List<double> _columnWidths;

  DataGridController({required this.columns, required this.rows}) {
    _columnWidths =
        List.generate(columns.length, (index) => columns[index].width);
  }

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
  final void Function(int rowIndex, int columnIndex, DataGridCell cell,
      List<DataGridCell> row)? onCellTap;

  /// 单元格双击回调
  final void Function(int rowIndex, int columnIndex, DataGridCell cell,
      List<DataGridCell> row)? onCellDoubleTap;

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
  // 滚动控制器管理
  late final LinkedScrollControllerGroup _horizontalScrollGroup;
  late final ScrollController _verticalController;
  late final ScrollController _headerHorizontalController;
  late final ScrollController _bodyHorizontalController;

  @override
  void initState() {
    super.initState();
    // 初始化滚动控制器
    _horizontalScrollGroup = LinkedScrollControllerGroup();
    _verticalController = ScrollController();
    _headerHorizontalController = _horizontalScrollGroup.addAndGet();
    _bodyHorizontalController = _horizontalScrollGroup.addAndGet();
  }

  @override
  void dispose() {
    // 清理滚动控制器
    _headerHorizontalController.dispose();
    _bodyHorizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  /// 计算总宽度
  double get _totalWidth =>
      widget.controller.columnWidths.fold(0.0, (sum, width) => sum + width) +
      _DataGridStyle.scrollPadding;

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: widget.headerHeight,
          child: ClipRect(
            child: SingleChildScrollView(
              controller: _headerHorizontalController,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                width: _totalWidth,
                child: AnimatedBuilder(
                  animation: widget.controller,
                  builder: (context, child) {
                    return RepaintBoundary(
                      child: Row(
                        children: [
                          for (int i = 0;
                              i < widget.controller.columns.length;
                              i++)
                            _buildHeaderCell(
                                context, widget.controller.columns[i], i),
                          const SizedBox(width: _DataGridStyle.scrollPadding),
                        ],
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
    final borderColor = Theme.of(context).colorScheme.outlineVariant;

    return _BorderedCell(
      borderColor: borderColor,
      borderWidth: _DataGridStyle.borderWidth,
      child: SizedBox(
        width: width,
        height: widget.headerHeight,
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
      ),
    );
  }

  /// 构建数据主体
  Widget _buildBody(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentHeight = widget.controller.rows.length * widget.rowHeight +
            _DataGridStyle.scrollPadding;
        final needsVerticalScroll = contentHeight > constraints.maxHeight;

        return Scrollbar(
          controller: _bodyHorizontalController,
          thumbVisibility: true,
          child: ClipRect(
            child: SingleChildScrollView(
              controller: _bodyHorizontalController,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                width: _totalWidth,
                child: needsVerticalScroll
                    ? Scrollbar(
                        controller: _verticalController,
                        thumbVisibility: true,
                        child: ClipRect(
                          child: SingleChildScrollView(
                            controller: _verticalController,
                            physics: const ClampingScrollPhysics(),
                            child: SizedBox(
                              height: contentHeight,
                              child: _buildDataContent(context),
                            ),
                          ),
                        ),
                      )
                    : SizedBox(
                        height: constraints.maxHeight,
                        child: _buildDataContent(context),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建数据内容
  Widget _buildDataContent(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return RepaintBoundary(
          child: Column(
            children: [
              for (int i = 0; i < widget.controller.rows.length; i++)
                _buildRow(context, widget.controller.rows[i], i),
            ],
          ),
        );
      },
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
  double? _dragStartX;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        onHorizontalDragStart: (details) {
          _dragStartX = details.globalPosition.dx;
        },
        onHorizontalDragUpdate: (details) {
          if (_dragStartX != null) {
            final delta = details.globalPosition.dx - _dragStartX!;
            widget.onResize(delta);
            _dragStartX = details.globalPosition.dx;
          }
        },
        onHorizontalDragEnd: (_) {
          _dragStartX = null;
        },
        child: Container(
          width: _DataGridStyle.resizeHandleWidth,
          color: Colors.transparent,
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
      child: SizedBox(
        height: widget.rowHeight,
        child: Row(
          children: [
            for (int i = 0; i < widget.controller.columns.length; i++)
              _buildCell(context, widget.controller.columns[i],
                  widget.row.cells[i], i),
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
      backgroundColor = colorScheme.surfaceContainer;
    }

    return _BorderedCell(
      borderColor: colorScheme.outlineVariant,
      borderWidth: _DataGridStyle.borderWidth,
      child: SizedBox(
        width: width,
        height: widget.rowHeight,
        child: GestureDetector(
          onTap: () => widget.onCellTap
              ?.call(widget.rowIndex, columnIndex, cell, widget.row.cells),
          onDoubleTap: () => widget.onCellDoubleTap
              ?.call(widget.rowIndex, columnIndex, cell, widget.row.cells),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            alignment: Alignment.centerLeft,
            padding: _DataGridStyle.cellPadding,
            color: backgroundColor,
            child: cell.content,
          ),
        ),
      ),
    );
  }
}

/// 带边框的 Cell 组件
class _BorderedCell extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final double borderWidth;

  const _BorderedCell({
    required this.child,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CellBorderPainter(
        color: borderColor,
        strokeWidth: borderWidth,
      ),
      child: child,
    );
  }
}

/// Cell 边框绘制器 - 只绘制右边和下边,
/// 为什么不用container的边框，因为边框有抗锯齿的特性，线条会粗细不均.
class _CellBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _CellBorderPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..isAntiAlias = false; // 关闭抗锯齿

    // 绘制右边框
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width, size.height), paint);

    // 绘制下边框
    canvas.drawLine(
        Offset(0, size.height), Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _CellBorderPainter oldDelegate) {
    return color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
  }
}
