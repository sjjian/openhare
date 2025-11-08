import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'const.dart';

class DataGridController extends ChangeNotifier {
  final List<DataGridColumn> columns;
  final List<DataGridRow> rows;

  Postion? selectedCellPostion;

  DataGridController(
      {required this.columns, required this.rows, this.selectedCellPostion});

  List<double> get columnWidths => columns.map((e) => e.size.width).toList();

  void updateColumnWidth(int index, double width) {
    if (index >= 0 && index < columns.length) {
      // 确保列宽在合理范围内
      final column = columns[index];
      final clampedWidth = width.clamp(
        column.size.minWidth ?? 50.0,
        column.size.maxWidth ?? double.infinity,
      );
      columns[index].size.width = clampedWidth;
      notifyListeners();
    }
  }

  void updateSelectedCell(Postion p) {
    selectedCellPostion = p;
    notifyListeners();
  }
}

class Postion {
  final int rowIndex;
  final int columnIndex;

  const Postion({required this.rowIndex, required this.columnIndex});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Postion &&
        other.rowIndex == rowIndex &&
        other.columnIndex == columnIndex;
  }

  @override
  int get hashCode => Object.hash(rowIndex, columnIndex);
}

class RowSize {
  /// 实际大小
  double width;

  /// 最小宽度
  final double? minWidth;

  /// 最大宽度
  final double? maxWidth;

  RowSize({
    required this.width,
    this.minWidth = 50.0,
    this.maxWidth = 500.0,
  });
}

/// 列定义
class DataGridColumn {
  final RowSize size;
  final Widget Function(BuildContext context) contentBuilder;

  const DataGridColumn({required this.contentBuilder, required this.size});
}

class DataGridRow {
  final List<DataGridCell> cells;

  const DataGridRow({
    required this.cells,
  });
}

class DataGridCell<T> {
  final Widget Function(BuildContext context) contentBuilder;

  const DataGridCell({
    required this.contentBuilder,
  });
}

/// 数据表格组件
class DataGrid extends StatefulWidget {
  /// 数据表格控制器
  final DataGridController controller;
  /// 表头的行高
  final double headerHeight;
  /// 数据行的行高
  final double rowHeight;

  /// 水平滚动控制器组，用于同步表头和数据体的水平滚动
  final LinkedScrollControllerGroup? horizontalScrollGroup;
  
  /// 垂直滚动控制器，用于数据行的垂直滚动
  final ScrollController? verticalController;

  /// 单元格点击回调
  final void Function(Postion position)? onCellTap;

  /// 单元格双击回调
  final void Function(Postion position)? onCellDoubleTap;

  const DataGrid({
    Key? key,
    required this.controller,
    this.rowHeight = 24.0,
    this.headerHeight = 32.0,
    this.horizontalScrollGroup,
    this.verticalController,
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
    _horizontalScrollGroup = widget.horizontalScrollGroup ?? LinkedScrollControllerGroup();
    _verticalController = widget.verticalController ?? ScrollController();
    _headerHorizontalController = _horizontalScrollGroup.addAndGet();
    _bodyHorizontalController = _horizontalScrollGroup.addAndGet();
  }

  @override
  void dispose() {
    // 清理滚动控制器
    if (widget.verticalController == null) {
      _verticalController.dispose();
    }
    _headerHorizontalController.dispose();
    _bodyHorizontalController.dispose();
    super.dispose();
  }

  /// 计算总宽度 - 确保不小于父组件宽度
  double _calculateTotalWidth(double parentWidth) {
    final contentWidth =
        widget.controller.columnWidths.fold(0.0, (sum, width) => sum + width);
    return (contentWidth + 12.0).clamp(parentWidth, double.infinity);
  }

  /// 计算总高度 - 确保不小于父组件高度（减去表头高度）
  double _calculateTotalHeight(double parentHeight) {
    final contentHeight = widget.controller.rows.length * widget.rowHeight;
    final minHeight = parentHeight - widget.headerHeight;
    return (contentHeight + 12.0).clamp(minHeight, double.infinity);
  }

  /// 更新列宽
  void _updateColumnWidth(int index, double width) {
    widget.controller.updateColumnWidth(index, width);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox.expand(
          child: AnimatedBuilder(
            animation: widget.controller,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, constraints.maxWidth),
                  Expanded(
                      child: _buildBody(context, constraints.maxWidth,
                          constraints.maxHeight)),
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// 构建表头
  Widget _buildHeader(BuildContext context, double parentWidth) {
    return SizedBox(
      height: widget.headerHeight,
      child: SingleChildScrollView(
        controller: _headerHorizontalController,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: SizedBox(
          width: _calculateTotalWidth(parentWidth),
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
      child: SizedBox(
        width: width,
        height: widget.headerHeight,
        child: Stack(
          children: [
            // 表头内容
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
              child: column.contentBuilder(context),
            ),
            // 拖动手柄
            if (index < widget.controller.columns.length)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: _ResizeHandle(
                  column: column,
                  currentWidth: width,
                  onResize: (delta) {
                    final newWidth = (width + delta).clamp(
                      column.size.minWidth ?? 50.0,
                      column.size.maxWidth ?? double.infinity,
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
  Widget _buildBody(
      BuildContext context, double parentWidth, double parentHeight) {
    return Stack(
      children: [
        Scrollbar(
          controller: _bodyHorizontalController,
          thumbVisibility: false,
          notificationPredicate: (notification) =>
              notification.metrics.axis == Axis.horizontal,
          child: Scrollbar(
            controller: _verticalController,
            thumbVisibility: false,
            notificationPredicate: (notification) =>
                notification.metrics.axis == Axis.vertical,
            child: SingleChildScrollView(
              controller: _verticalController,
              scrollDirection: Axis.vertical,
              physics: const ClampingScrollPhysics(),
              child: SingleChildScrollView(
                controller: _bodyHorizontalController,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: SizedBox(
                  width: _calculateTotalWidth(parentWidth),
                  height: _calculateTotalHeight(parentHeight),
                  child: _buildRow(context),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建数据内容
  Widget _buildRow(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < widget.controller.rows.length; i++)
          SizedBox(
            height: widget.rowHeight,
            child: Row(
              children: [
                for (int j = 0; j < widget.controller.columns.length; j++)
                  _buildCell(context, Postion(rowIndex: i, columnIndex: j)),
              ],
            ),
          ),
      ],
    );
  }

  /// 构建单元格
  Widget _buildCell(BuildContext context, Postion postion) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = widget.controller.columnWidths[postion.columnIndex];
    final cell =
        widget.controller.rows[postion.rowIndex].cells[postion.columnIndex];

    return DataGridCellWidget(
      selected: (widget.controller.selectedCellPostion != null)
          ? (widget.controller.selectedCellPostion == postion)
          : false,
      backgroundColor: (widget.controller.selectedCellPostion != null &&
              postion.rowIndex ==
                  widget.controller.selectedCellPostion!.rowIndex)
          ? colorScheme.surfaceContainerLow
          : null,
      child: SizedBox(
        width: width,
        height: widget.rowHeight,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget.controller.updateSelectedCell(postion);
            widget.onCellTap?.call(postion);
          },
          onDoubleTap: () {
            widget.controller.updateSelectedCell(postion);
            widget.onCellDoubleTap?.call(postion);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
            child: cell.contentBuilder(context),
          ),
        ),
      ),
    );
  }
}

/// 带边框的 Cell 组件
class DataGridCellWidget extends StatelessWidget {
  final double? borderWidth;
  final Color? borderColor;
  final Color? backgroundColor;
  final bool? selected;

  final Widget child;

  const DataGridCellWidget({
    super.key,
    required this.child,
    this.borderColor,
    this.borderWidth,
    this.selected,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _DataGridCellPainter(
          borderColor:
              borderColor ?? Theme.of(context).colorScheme.surfaceContainerHigh,
          borderWidth: borderWidth ?? 1,
          backgroundColor: backgroundColor,
          selected: selected ?? false,
          selectedBorderColor: Theme.of(context).colorScheme.primary,
        ),
        child: child,
      ),
    );
  }
}

/// Cell 边框绘制器 - 只绘制右边和下边,
/// 为什么不用container的边框，因为边框有抗锯齿的特性，线条会粗细不均.
class _DataGridCellPainter extends CustomPainter {
  /// 边框的宽度
  final double borderWidth;

  /// 边框的颜色
  final Color borderColor;

  /// 选中状态的内边框颜色
  final Color selectedBorderColor;

  /// 是否选中
  final bool selected;

  /// cell 的背景颜色
  final Color? backgroundColor;

  const _DataGridCellPainter({
    required this.borderColor,
    required this.borderWidth,
    required this.selected,
    required this.selectedBorderColor,
    this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundColor != null) {
      final backgroundPaint = Paint()
        ..color = backgroundColor!
        ..style = PaintingStyle.fill;

      // 先绘制背景色，避开边框区域，主要是右侧和下侧的边框.
      final backgroundRect = Rect.fromLTWH(
          0, 0, size.width - borderWidth, size.height - borderWidth);
      canvas.drawRect(backgroundRect, backgroundPaint);
    }

    // 再绘制边框
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..isAntiAlias = false; // 关闭抗锯齿

    // 绘制右边框
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width, size.height), paint);

    // 绘制下边框
    canvas.drawLine(
        Offset(0, size.height), Offset(size.width, size.height), paint);

    if (selected) {
      // 绘制选中状态的内边框
      final selectedPaint = Paint()
        ..color = selectedBorderColor
        ..strokeWidth = borderWidth
        ..style = PaintingStyle.stroke
        ..isAntiAlias = false;

      final selectedRect = Rect.fromLTWH(borderWidth, borderWidth,
          size.width - borderWidth * 2, size.height - borderWidth * 2);
      canvas.drawRect(selectedRect, selectedPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DataGridCellPainter oldDelegate) {
    return borderColor != oldDelegate.borderColor ||
        borderWidth != oldDelegate.borderWidth ||
        backgroundColor != oldDelegate.backgroundColor ||
        selected != oldDelegate.selected ||
        selectedBorderColor != oldDelegate.selectedBorderColor;
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
