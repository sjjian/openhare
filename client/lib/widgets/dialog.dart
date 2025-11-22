import 'dart:math';
import 'package:flutter/material.dart';
import 'package:client/l10n/app_localizations.dart';
import 'package:client/widgets/const.dart';

// 二次确认的对话框，确认后执行onConfirm, 点击取消或关闭对话框则不执行
void doActionDialog(
  BuildContext context,
  String title,
  String message,
  Function onConfirm, {
  Icon? icon,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        title: Row(
          children: [
            if (icon != null) ...[
              icon,
              const SizedBox(width: 8),
            ],
            Text(title, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        content: SizedBox(
          width: 300,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.of(context).pop();
            },
            child: Text(
              AppLocalizations.of(context)!.confirm,
              style: TextStyle(
                  color: icon?.color ?? Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      );
    },
  );
}

// 通用的自定义对话框组件
class CustomDialog extends StatelessWidget {
  final String title;
  final Widget? titleIcon;
  final Widget content;
  final List<Widget>? actions;
  final double? maxWidth;
  final double? maxHeight;

  const CustomDialog({
    super.key,
    required this.title,
    this.titleIcon,
    required this.content,
    this.actions,
    this.maxWidth = 640,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? 640,
          maxHeight: maxHeight ??
              min(
                MediaQuery.of(context).size.height -
                    tabbarHeight -
                    bottomBarHeight -
                    10,
                800,
              ), // 高度不能超出屏幕高度，且不能覆盖顶部和底部状态栏
        ),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.fromLTRB(
            kSpacingMedium,
            kSpacingLarge,
            kSpacingMedium,
            kSpacingMedium,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (titleIcon != null) ...[
                    titleIcon!,
                    const SizedBox(width: kSpacingTiny),
                  ],
                  Text(title, style: textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: kSpacingMedium),
              Expanded(child: content),
              if (actions != null) ...[
                const SizedBox(height: kSpacingMedium),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
