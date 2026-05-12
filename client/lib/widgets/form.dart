import 'package:client/l10n/app_localizations.dart';
import 'package:client/widgets/button.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/menu.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sql_editor/re_editor.dart';

abstract final class FormFieldValidators {
  static String? requiredValue(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.field_val_msg_value_reqiured;
    }
    return null;
  }
}

class TrackedFormController extends ChangeNotifier {
  final Map<String, String> _invalidFieldGroups = {};
  final Map<String, GlobalKey<FormFieldState>> _lazyFormFieldKeys = {};

  String _groupIdForFieldName(String fieldName) => fieldName;

  GlobalKey<FormFieldState> _formFieldKey(String fieldName) {
    return _lazyFormFieldKeys.putIfAbsent(fieldName, () => GlobalKey<FormFieldState>());
  }

  void _reportField(String fieldName, bool valid, {String? groupId}) {
    final newGid = valid ? null : (groupId ?? _groupIdForFieldName(fieldName));
    final oldGid = _invalidFieldGroups[fieldName];
    if (newGid == oldGid) {
      return;
    }
    if (newGid == null) {
      _invalidFieldGroups.remove(fieldName);
    } else {
      _invalidFieldGroups[fieldName] = newGid;
    }
    notifyListeners();
  }

  bool _isGroupValid(String groupId) => !_invalidFieldGroups.containsValue(groupId);

  bool validate() {
    var ok = true;
    for (final key in _lazyFormFieldKeys.values) {
      if (key.currentState?.validate() != true) {
        ok = false;
      }
    }
    return ok;
  }

  void resetInvalidGroups() {
    if (_invalidFieldGroups.isEmpty) {
      return;
    }
    _invalidFieldGroups.clear();
    notifyListeners();
  }
}

/// 向子树注入 [TrackedFormController]
class TrackedFormScope extends InheritedWidget {
  const TrackedFormScope({
    super.key,
    required this.controller,
    required super.child,
  });

  final TrackedFormController controller;

  static TrackedFormController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TrackedFormScope>();
    assert(scope != null, 'TrackedFormScope not found');
    return scope!.controller;
  }

  @override
  bool updateShouldNotify(TrackedFormScope oldWidget) => !identical(oldWidget.controller, controller);
}

class TrackedForm extends StatelessWidget {
  const TrackedForm({
    super.key,
    required this.controller,
    required this.child,
  }) : children = null,
       tabLabels = const {};

  const TrackedForm.tabbed({
    super.key,
    required this.controller,
    this.tabLabels = const {},
    required this.children,
  }) : child = null;

  final TrackedFormController controller;
  final Widget? child;
  final List<Widget>? children;

  /// [groupId] -> Tab 标题；未出现的 [groupId] 使用 [groupId] 字符串本身。
  final Map<String, String> tabLabels;

  @override
  Widget build(BuildContext context) {
    if (children != null) {
      return TrackedFormScope(
        controller: controller,
        child: _TrackedFormTabbedLayout(
          controller: controller,
          tabLabels: tabLabels,
          children: children!,
        ),
      );
    }
    return TrackedFormScope(
      controller: controller,
      child: child!,
    );
  }
}

class _TrackedFormTabbedLayout extends StatefulWidget {
  const _TrackedFormTabbedLayout({
    required this.controller,
    required this.tabLabels,
    required this.children,
  });

  final TrackedFormController controller;
  final Map<String, String> tabLabels;
  final List<Widget> children;

  @override
  State<_TrackedFormTabbedLayout> createState() => _TrackedFormTabbedLayoutState();
}

class _TrackedFormTabbedLayoutState extends State<_TrackedFormTabbedLayout> {
  String? _selectedGroup;

  static String? _tabGroupId(Widget w, TrackedFormController c) {
    if (w is TrackedFormField) {
      return w.resolveGroupId(c);
    }
    if (w is TrackedHostPortFields) {
      return w.groupId ?? c._groupIdForFieldName(w.hostFieldName);
    }
    return null;
  }

  /// 单趟遍历：保持首次出现顺序，同时收集每个分组的 children。
  static ({List<String> order, Map<String, List<Widget>> byGroup}) _partition(
    List<Widget> children,
    TrackedFormController c,
  ) {
    final order = <String>[];
    final byGroup = <String, List<Widget>>{};
    for (final w in children) {
      final gid = _tabGroupId(w, c);
      if (gid == null) {
        continue;
      }
      final bucket = byGroup.putIfAbsent(gid, () {
        order.add(gid);
        return <Widget>[];
      });
      bucket.add(w);
    }
    return (order: order, byGroup: byGroup);
  }

  @override
  void initState() {
    super.initState();
    final order = _partition(widget.children, widget.controller).order;
    _selectedGroup = order.isNotEmpty ? order.first : null;
  }

  @override
  void didUpdateWidget(_TrackedFormTabbedLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    final order = _partition(widget.children, widget.controller).order;
    if (order.isEmpty) {
      if (_selectedGroup != null) {
        setState(() => _selectedGroup = null);
      }
      return;
    }
    if (_selectedGroup == null || !order.contains(_selectedGroup)) {
      setState(() => _selectedGroup = order.first);
    }
  }

  void _onSelectGroup(String section) {
    setState(() => _selectedGroup = section);
  }

  @override
  Widget build(BuildContext context) {
    final parts = _partition(widget.children, widget.controller);
    final order = parts.order;
    if (order.isEmpty) {
      return const SizedBox.shrink();
    }
    final byGroup = parts.byGroup;
    final selected = _selectedGroup;
    final index = selected == null ? 0 : order.indexOf(selected).clamp(0, order.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final section in order)
                Padding(
                  padding: const EdgeInsets.only(right: kSpacingTiny),
                  child: TextButton(
                    onPressed: () => _onSelectGroup(section),
                    style: TextButton.styleFrom(
                      backgroundColor: section == selected ? Theme.of(context).colorScheme.primaryContainer : null,
                    ),
                    child: Text(
                      widget.tabLabels[section] ?? section,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: !TrackedFormScope.of(context)._isGroupValid(section)
                            ? Theme.of(context).colorScheme.error
                            : null,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: kSpacingMedium),
        Expanded(
          child: IndexedStack(
            index: index,
            children: [
              for (final g in order)
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: byGroup[g] ?? const <Widget>[],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 与 [TrackedFormController] 联动的表单字段基类（依赖 [TrackedFormScope] 祖先）。
abstract class TrackedFormField extends StatefulWidget {
  /// 若为空，Tab 分组与校验汇总由控制器按 [fieldName] 回退。
  final String? groupId;

  /// 与业务 meta 名一致。
  final String fieldName;

  /// 为 true 时标签显示必填星号，且在校验链**最前**内置非空校验（与 [validator] 串行，先必填再自定义）。
  final bool isRequired;

  /// 自定义校验器。
  final FormFieldValidator? validator;

  const TrackedFormField({
    super.key,
    required this.fieldName,
    this.validator,
    this.isRequired = false,
    this.groupId,
  });

  /// [TrackedForm.tabbed] 用于合并到同一 Tab 的分组 id。
  String resolveGroupId(TrackedFormController controller) => groupId ?? controller._groupIdForFieldName(fieldName);

  FormFieldValidator? resolveValidator(BuildContext context) {
    FormFieldValidator? chain;
    if (isRequired) {
      chain = (value) => FormFieldValidators.requiredValue(context, value);
    }
    final inner = validator;
    if (inner != null) {
      final prev = chain;
      chain = (value) {
        if (prev != null) {
          final e = prev(value);
          if (e != null) {
            return e;
          }
        }
        return inner(value);
      };
    }
    final combined = chain;
    if (combined == null) {
      return null;
    }
    final form = TrackedFormScope.of(context);
    return (value) {
      final err = combined(value);
      form._reportField(fieldName, err == null, groupId: groupId);
      return err;
    };
  }

  static InputDecoration outlineDecoration({
    required BuildContext context,
    required String label,
    bool isRequired = false,
    EdgeInsetsGeometry? contentPadding,
    String? helperText,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      label: isRequired
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label),
                Text('*', style: TextStyle(color: theme.colorScheme.error)),
              ],
            )
          : null,
      labelText: isRequired ? null : label,
      contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: kSpacingSmall),
      helperText: helperText,
      suffixIcon: suffixIcon,
    );
  }
}

class TrackedTextFormField extends TrackedFormField {
  final String label;
  final TextEditingController controller;
  final bool readOnly;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget Function(BuildContext context)? suffixIconBuilder;
  final EdgeInsetsGeometry? contentPadding;
  final double minHeight;

  const TrackedTextFormField({
    super.key,
    required super.fieldName,
    super.validator,
    super.isRequired,
    super.groupId,
    required this.label,
    required this.controller,
    this.readOnly = false,
    this.obscureText = false,
    this.suffixIcon,
    this.suffixIconBuilder,
    this.contentPadding,
    this.minHeight = 80,
  });

  @override
  State<TrackedTextFormField> createState() => _TrackedTextFormFieldState();
}

class _TrackedTextFormFieldState extends State<TrackedTextFormField> {
  @override
  Widget build(BuildContext context) {
    final form = TrackedFormScope.of(context);
    final suffix = widget.suffixIcon ?? widget.suffixIconBuilder?.call(context);
    return Container(
      constraints: BoxConstraints(minHeight: widget.minHeight),
      child: TextFormField(
        key: form._formFieldKey(widget.fieldName),
        readOnly: widget.readOnly,
        obscureText: widget.obscureText,
        autovalidateMode: AutovalidateMode.onUnfocus,
        controller: widget.controller,
        validator: widget.resolveValidator(context),
        decoration: TrackedFormField.outlineDecoration(
          context: context,
          label: widget.label,
          isRequired: widget.isRequired,
          contentPadding: widget.contentPadding,
          suffixIcon: suffix,
        ),
      ),
    );
  }
}

class TrackedFilePathFormField extends TrackedFormField {
  const TrackedFilePathFormField({
    super.key,
    required super.fieldName,
    super.validator,
    super.isRequired,
    super.groupId,
    required this.label,
    required this.controller,
    required this.pickTooltip,
    this.allowedExtensions = const ['db', 'sqlite', 'sqlite3'],
    this.minHeight = 80,
  });

  final String label;
  final TextEditingController controller;
  final String pickTooltip;
  final List<String> allowedExtensions;
  final double minHeight;

  @override
  State<TrackedFilePathFormField> createState() => _TrackedFilePathFormFieldState();
}

class _TrackedFilePathFormFieldState extends State<TrackedFilePathFormField> {
  Future<void> _pickFile() async {
    final ctrl = widget.controller;
    final currentPath = ctrl.text.trim();
    final result = await FilePicker.platform.pickFiles(
      initialDirectory: currentPath.isNotEmpty ? p.dirname(currentPath) : null,
      type: FileType.custom,
      allowedExtensions: widget.allowedExtensions,
    );
    if (!mounted) {
      return;
    }
    final files = result?.files;
    final filePath = (files != null && files.isNotEmpty) ? files.first.path : null;
    if (filePath != null && filePath.isNotEmpty) {
      ctrl.text = filePath;
      TrackedFormScope.of(context)._formFieldKey(widget.fieldName).currentState?.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TrackedTextFormField(
      fieldName: widget.fieldName,
      validator: widget.validator,
      groupId: widget.groupId,
      isRequired: widget.isRequired,
      label: widget.label,
      controller: widget.controller,
      contentPadding: const EdgeInsets.all(kSpacingSmall),
      minHeight: widget.minHeight,
      suffixIconBuilder: (context) => Padding(
        padding: const EdgeInsets.only(right: kSpacingTiny),
        child: RectangleIconButton.medium(
          icon: Icons.folder_open,
          tooltip: widget.pickTooltip,
          iconColor: Theme.of(context).colorScheme.primary,
          onPressed: _pickFile,
        ),
      ),
    );
  }
}

class TrackedCodeEditorFormField extends TrackedFormField {
  const TrackedCodeEditorFormField({
    super.key,
    required super.fieldName,
    super.validator,
    super.isRequired,
    super.groupId,
    required this.codeController,
    required this.child,
  });

  final CodeLineEditingController codeController;
  final Widget child;

  @override
  State<TrackedCodeEditorFormField> createState() => _TrackedCodeEditorFormFieldState();
}

class _TrackedCodeEditorFormFieldState extends State<TrackedCodeEditorFormField> {
  @override
  void initState() {
    super.initState();
    widget.codeController.addListener(_sync);
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void didUpdateWidget(TrackedCodeEditorFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.codeController != widget.codeController) {
      oldWidget.codeController.removeListener(_sync);
      widget.codeController.addListener(_sync);
    }
  }

  @override
  void dispose() {
    widget.codeController.removeListener(_sync);
    super.dispose();
  }

  void _sync() {
    if (!mounted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      TrackedFormScope.of(context)._formFieldKey(widget.fieldName).currentState?.didChange(widget.codeController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final form = TrackedFormScope.of(context);
    return FormField<String>(
      key: form._formFieldKey(widget.fieldName),
      initialValue: widget.codeController.text,
      autovalidateMode: AutovalidateMode.onUnfocus,
      validator: widget.resolveValidator(context),
      builder: (_) => widget.child,
    );
  }
}

/// multi field, 主机 + 端口
class TrackedHostPortFields extends StatelessWidget {
  const TrackedHostPortFields({
    super.key,
    required this.hostFieldName,
    required this.hostController,
    this.hostValidator,
    required this.hostLabel,
    this.hostRequired = false,
    this.portFieldName,
    this.portController,
    this.portValidator,
    this.portLabel,
    this.portRequired = false,
    this.groupId,
  }) : assert(
         (portFieldName == null) == (portController == null && portLabel == null),
       );

  final String? groupId;

  final String hostFieldName;
  final TextEditingController hostController;
  final FormFieldValidator? hostValidator;
  final String hostLabel;
  final bool hostRequired;
  final String? portFieldName;
  final TextEditingController? portController;
  final FormFieldValidator? portValidator;
  final String? portLabel;
  final bool portRequired;

  @override
  Widget build(BuildContext context) {
    final hostField = TrackedTextFormField(
      fieldName: hostFieldName,
      validator: hostValidator,
      groupId: groupId,
      label: hostLabel,
      isRequired: hostRequired,
      controller: hostController,
    );
    final pk = portFieldName;
    final pc = portController;
    final pv = portValidator;
    final pl = portLabel;
    if (pk == null) {
      return hostField;
    }
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: hostField),
          const SizedBox(width: kSpacingSmall),
          Container(
            constraints: const BoxConstraints(maxWidth: 132),
            child: TrackedTextFormField(
              fieldName: pk,
              validator: pv,
              groupId: groupId,
              label: pl!,
              isRequired: portRequired,
              controller: pc!,
            ),
          ),
        ],
      ),
    );
  }
}

class TrackedPasswordFormField extends TrackedTextFormField {
  const TrackedPasswordFormField({
    super.key,
    required super.fieldName,
    super.validator,
    super.groupId,
    required super.label,
    super.isRequired,
    required super.controller,
    super.suffixIcon,
    super.suffixIconBuilder,
    super.contentPadding,
    super.minHeight,
  }) : super(
         readOnly: false,
         obscureText: true,
       );
}

class TrackedMultilineFormField extends TrackedFormField {
  final String label;
  final TextEditingController controller;
  final int? maxLength;
  final int maxLines;
  final EdgeInsetsGeometry? contentPadding;
  final double minHeight;

  const TrackedMultilineFormField({
    super.key,
    required super.fieldName,
    super.validator,
    super.isRequired,
    super.groupId,
    required this.label,
    required this.controller,
    this.maxLength = 50,
    this.maxLines = 4,
    this.contentPadding,
    this.minHeight = 120,
  });

  @override
  State<TrackedMultilineFormField> createState() => _TrackedMultilineFormFieldState();
}

class _TrackedMultilineFormFieldState extends State<TrackedMultilineFormField> {
  @override
  Widget build(BuildContext context) {
    final form = TrackedFormScope.of(context);
    return Container(
      constraints: BoxConstraints(minHeight: widget.minHeight),
      child: TextFormField(
        key: form._formFieldKey(widget.fieldName),
        controller: widget.controller,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        autovalidateMode: AutovalidateMode.onUnfocus,
        validator: widget.resolveValidator(context),
        decoration: TrackedFormField.outlineDecoration(
          context: context,
          label: widget.label,
          isRequired: widget.isRequired,
          contentPadding: widget.contentPadding ?? const EdgeInsets.all(12),
        ),
      ),
    );
  }
}

class TrackedDescFormField extends TrackedMultilineFormField {
  const TrackedDescFormField({
    super.key,
    required super.fieldName,
    super.validator,
    super.groupId,
    required super.label,
    super.isRequired,
    required super.controller,
    super.maxLength = 100,
    super.maxLines = 2,
    super.minHeight = 100,
  }) : super(
         contentPadding: const EdgeInsets.all(kSpacingSmall),
       );
}

class TrackedEnumFormField extends TrackedFormField {
  final String label;
  final TextEditingController controller;
  final List<String> enumValues;
  final String? defaultValue;
  final String? helperText;

  const TrackedEnumFormField({
    super.key,
    required super.fieldName,
    super.validator,
    super.isRequired,
    super.groupId,
    required this.label,
    required this.controller,
    required this.enumValues,
    this.defaultValue,
    this.helperText,
  });

  @override
  State<TrackedEnumFormField> createState() => _TrackedEnumFormFieldState();
}

class _TrackedEnumFormFieldState extends State<TrackedEnumFormField> {
  static String _effectiveValue(
    List<String> opts,
    String current,
    String? defaultValue,
  ) {
    if (opts.isEmpty) {
      return current;
    }
    if (opts.contains(current)) {
      return current;
    }
    if (defaultValue != null && opts.contains(defaultValue)) {
      return defaultValue;
    }
    return opts.first;
  }

  InputDecoration _decorationForState(BuildContext context, FormFieldState<String> fieldState) {
    final base = TrackedFormField.outlineDecoration(
      context: context,
      label: widget.label,
      isRequired: widget.isRequired,
      helperText: widget.helperText,
    );
    if (!fieldState.hasError) {
      return base;
    }
    final cs = Theme.of(context).colorScheme;
    final errBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide(color: cs.error),
    );
    return base.copyWith(
      errorText: fieldState.errorText,
      errorBorder: errBorder,
      focusedErrorBorder: errBorder,
      border: errBorder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final opts = widget.enumValues;
    if (opts.isEmpty) {
      return TrackedTextFormField(
        fieldName: widget.fieldName,
        validator: widget.validator,
        groupId: widget.groupId,
        label: widget.label,
        isRequired: widget.isRequired,
        controller: widget.controller,
      );
    }
    final effective = _effectiveValue(
      opts,
      widget.controller.text,
      widget.defaultValue,
    );
    if (widget.controller.text != effective) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.controller.text != effective) {
          widget.controller.text = effective;
        }
      });
    }
    final form = TrackedFormScope.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final itemHeight = 40.0;
    final menuMaxHeight = opts.length * itemHeight + kSpacingSmall * 2;
    final cappedMenuHeight = menuMaxHeight > 280 ? 280.0 : menuMaxHeight;

    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      child: FormField<String>(
        key: form._formFieldKey(widget.fieldName),
        initialValue: effective,
        autovalidateMode: AutovalidateMode.onUnfocus,
        validator: widget.resolveValidator(context),
        builder: (fieldState) {
          final display = _effectiveValue(opts, widget.controller.text, widget.defaultValue);
          if (fieldState.value != display) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                fieldState.didChange(display);
              }
            });
          }

          return InputDecorator(
            decoration: _decorationForState(context, fieldState),
            isEmpty: false,
            child: OverlayMenu(
              alignmentInset: const EdgeInsets.symmetric(horizontal: kSpacingSmall, vertical: kSpacingSmall),
              maxWidth: 400,
              maxHeight: cappedMenuHeight,
              spacing: kSpacingTiny,
              header: OverlayMenuHeader(height: kSpacingSmall, child: SizedBox.shrink()),
              footer: OverlayMenuFooter(height: kSpacingSmall, child: SizedBox.shrink()),
              tabs: [
                for (final e in opts)
                  OverlayMenuItem(
                    height: itemHeight,
                    onTabSelected: () {
                      widget.controller.text = e;
                      fieldState.didChange(e);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              e,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: e == display ? FontWeight.w600 : FontWeight.normal,
                                color: e == display ? cs.primary : null,
                              ),
                            ),
                          ),
                          if (e == display) Icon(Icons.check, size: 18, color: cs.primary),
                        ],
                      ),
                    ),
                  ),
              ],
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: SizedBox(
                  width: double.infinity,
                  height: 24,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          display,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                      Icon(Icons.expand_more, color: cs.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
