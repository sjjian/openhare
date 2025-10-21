import 'package:flutter/material.dart';


/// 像素级分割线，取消抗锯齿效果
/// 与Flutter标准库Divider定义一致，但提供更清晰的线条渲染
class PixelDivider extends StatelessWidget {
  /// 分割线的高度
  final double? height;
  
  /// 分割线的厚度
  final double? thickness;
  
  /// 分割线的缩进
  final double? indent;
  
  /// 分割线的结束缩进
  final double? endIndent;
  
  /// 分割线的颜色
  final Color? color;
  

  const PixelDivider({
    super.key,
    this.height,
    this.thickness,
    this.indent,
    this.endIndent,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerTheme = theme.dividerTheme;
    
    final height = this.height ?? dividerTheme.space ?? 1.0;
    final thickness = this.thickness ?? dividerTheme.thickness ?? 1.0;
    final indent = this.indent ?? dividerTheme.indent ?? 0.0;
    final endIndent = this.endIndent ?? dividerTheme.endIndent ?? 0.0;
    final color = this.color ?? theme.dividerColor;

    return SizedBox(
      height: height,
      child: Center(
        child: Container(
          height: thickness,
          margin: EdgeInsetsDirectional.only(
            start: indent,
            end: endIndent,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return CustomPaint(
                painter: PixelLinePainter(color: color, thickness: thickness),
                size: Size(constraints.maxWidth, thickness),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 像素级垂直分割线
class PixelVerticalDivider extends StatelessWidget {
  /// 分割线的宽度
  final double? width;
  
  /// 分割线的厚度
  final double? thickness;
  
  /// 分割线的缩进
  final double? indent;
  
  /// 分割线的结束缩进
  final double? endIndent;
  
  /// 分割线的颜色
  final Color? color;
  

  const PixelVerticalDivider({
    super.key,
    this.width,
    this.thickness,
    this.indent,
    this.endIndent,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerTheme = theme.dividerTheme;
    
    final width = this.width ?? dividerTheme.space ?? 1.0;
    final thickness = this.thickness ?? dividerTheme.thickness ?? 1.0;
    final indent = this.indent ?? dividerTheme.indent ?? 0.0;
    final endIndent = this.endIndent ?? dividerTheme.endIndent ?? 0.0;
    final color = this.color ?? theme.dividerColor;

    return SizedBox(
      width: width,
      child: Center(
        child: Container(
          width: thickness,
          margin: EdgeInsets.only(
            top: indent,
            bottom: endIndent,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return CustomPaint(
                painter: PixelLinePainter(
                  color: color, 
                  thickness: thickness,
                  orientation: Axis.vertical,
                ),
                size: Size(thickness, constraints.maxHeight),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 像素级线条绘制器，取消抗锯齿
/// 支持水平和垂直两种方向的线条绘制
class PixelLinePainter extends CustomPainter {
  final Color color;
  final double thickness;
  final Axis orientation;

  PixelLinePainter({
    required this.color, 
    this.thickness = 1.0,
    this.orientation = Axis.horizontal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..isAntiAlias = false; // 取消抗锯齿

    if (orientation == Axis.horizontal) {
      // 绘制水平线，确保在容器中心
      final centerY = size.height / 2;
      canvas.drawLine(
        Offset(0, centerY),
        Offset(size.width, centerY),
        paint,
      );
    } else {
      // 绘制垂直线，确保在容器中心
      final centerX = size.width / 2;
      canvas.drawLine(
        Offset(centerX, 0),
        Offset(centerX, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is PixelLinePainter && 
           (oldDelegate.color != color || 
            oldDelegate.thickness != thickness ||
            oldDelegate.orientation != orientation);
  }
}
