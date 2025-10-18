import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'const.dart';

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
    this.width = 200.0,
    this.minWidth = 50.0,
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
    this.rowHeight = 24.0,
    this.headerHeight = 36.0,
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
      10.0;

  /// 计算总高度
  double get _totalHeight =>
      widget.controller.rows.length * widget.rowHeight + 10.0;

  /// 更新列宽
  void _updateColumnWidth(int index, double width) {
    widget.controller.updateColumnWidth(index, width);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              Expanded(child: _buildBody(context)),
            ],
          );
        },
      ),
    );
  }

  /// 构建表头
  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: widget.headerHeight,
      child: SingleChildScrollView(
        controller: _headerHorizontalController,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: SizedBox(
          width: _totalWidth,
          child: Row(
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

    return DataGridCellWidget(
      borderColor: Theme.of(context).colorScheme.outlineVariant,
      borderWidth: 1.0,
      child: SizedBox(
        width: width,
        height: widget.headerHeight,
        child: Stack(
          children: [
            // 表头内容
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
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
    return Scrollbar(
      controller: _bodyHorizontalController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _bodyHorizontalController,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: SizedBox(
          width: _totalWidth,
          child: Scrollbar(
            controller: _verticalController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _verticalController,
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                height: _totalHeight,
                child: _buildRow(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建数据内容
  Widget _buildRow(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < widget.controller.rows.length; i++)
          DataGridRowWidget(
            row: widget.controller.rows[i],
            rowIndex: i,
            controller: widget.controller,
            rowHeight: widget.rowHeight,
            onCellTap: widget.onCellTap,
            onCellDoubleTap: widget.onCellDoubleTap,
          ),
      ],
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
          width: 8.0,
          color: Colors.transparent,
        ),
      ),
    );
  }
}

/// 独立的数据网格行组件，管理自己的悬停状态
class DataGridRowWidget extends StatefulWidget {
  final DataGridRow row;
  final int rowIndex;
  final DataGridController controller;
  final double rowHeight;
  final Function(int, int, DataGridCell, List<DataGridCell>)? onCellTap;
  final Function(int, int, DataGridCell, List<DataGridCell>)? onCellDoubleTap;

  const DataGridRowWidget({
    super.key,
    required this.row,
    required this.rowIndex,
    required this.controller,
    required this.rowHeight,
    this.onCellTap,
    this.onCellDoubleTap,
  });

  @override
  State<DataGridRowWidget> createState() => DataGridRowWidgetState();
}

class DataGridRowWidgetState extends State<DataGridRowWidget> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.rowHeight,
      child: Row(
        children: [
          for (int i = 0; i < widget.controller.columns.length; i++)
            _buildCell(
                context, widget.controller.columns[i], widget.row.cells[i], i),
        ],
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
    if (backgroundColor == null && isSelected) {
      backgroundColor = colorScheme.surfaceContainer;
    }

    return DataGridCellWidget(
      borderColor: colorScheme.outlineVariant,
      borderWidth: 1.0,
      backgroundColor: backgroundColor,
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
            padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
            child: cell.content,
          ),
        ),
      ),
    );
  }
}

/// 带边框的 Cell 组件
class DataGridCellWidget extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final double borderWidth;
  final Color? backgroundColor;

  const DataGridCellWidget({
    super.key,
    required this.child,
    required this.borderColor,
    required this.borderWidth,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _DataGridCellPainter(
          color: borderColor,
          strokeWidth: borderWidth,
          backgroundColor: backgroundColor,
        ),
        child: child,
      ),
    );
  }
}

/// Cell 边框绘制器 - 只绘制右边和下边,
/// 为什么不用container的边框，因为边框有抗锯齿的特性，线条会粗细不均.
class _DataGridCellPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final Color? backgroundColor;

  const _DataGridCellPainter({
    required this.color,
    required this.strokeWidth,
    this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 先绘制背景色，完全避开边框区域
    if (backgroundColor != null) {
      final backgroundPaint = Paint()
        ..color = backgroundColor!
        ..style = PaintingStyle.fill;

      // 计算背景色区域，完全避开右边框和下边框
      // 使用 strokeWidth/2 的偏移来确保不重叠
      final halfStroke = strokeWidth / 2;
      final backgroundRect = Rect.fromLTWH(halfStroke, halfStroke,
          size.width - strokeWidth, size.height - strokeWidth);
      canvas.drawRect(backgroundRect, backgroundPaint);
    }

    // 再绘制边框
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
  bool shouldRepaint(covariant _DataGridCellPainter oldDelegate) {
    // 只有当颜色、线宽或背景色真正改变时才重绘
    return color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
