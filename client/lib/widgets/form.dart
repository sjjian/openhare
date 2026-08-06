import 'package:client/l10n/app_localizations.dart';
import 'package:client/widgets/button.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/menu.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

abstract final class FormFieldValidators {
  static String? requiredValue(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.field_val_msg_value_reqiured;
    }
    return null;
  }
}

/// 管理 Tracked field 子树内的校验状态与 [GlobalKey] 注册（非 [TextEditingController]）。
class TrackedFormValidationController extends ChangeNotifier {
  final Map<String, GlobalKey<FormFieldState>> _lazyFormFieldKeys = {};
  final Set<String> _invalidFieldNames = {};

  /// 当前校验未通过的 [fieldName] 集合；分组对应关系由业务层自行维护。
  Set<String> get invalidFieldNames => Set.unmodifiable(_invalidFieldNames);

  GlobalKey<FormFieldState> _formFieldKey(String fieldName) {
    return _lazyFormFieldKeys.putIfAbsent(fieldName, () => GlobalKey<FormFieldState>());
  }

  void _reportField(String fieldName, bool valid) {
    if (valid) {
      if (_invalidFieldNames.remove(fieldName)) {
        notifyListeners();
      }
      return;
    }
    if (_invalidFieldNames.add(fieldName)) {
      notifyListeners();
    }
  }

  bool validate() {
    var ok = true;
    _invalidFieldNames.clear();
    for (final entry in _lazyFormFieldKeys.entries) {
      final state = entry.value.currentState;
      if (state == null) {
        continue;
      }
      if (state.validate() != true) {
        ok = false;
        _invalidFieldNames.add(entry.key);
      }
    }
    notifyListeners();
    return ok;
  }

  void clearInvalidFields() {
    if (_invalidFieldNames.isEmpty) {
      return;
    }
    _invalidFieldNames.clear();
    notifyListeners();
  }

  /// 按字段名重新校验（条件显隐/只读切换后清掉陈旧错误）。
  void revalidateFields(Iterable<String> fieldNames) {
    for (final name in fieldNames) {
      final state = _lazyFormFieldKeys[name]?.currentState;
      if (state != null) {
        _reportField(name, state.validate() == true);
      } else {
        _reportField(name, true);
      }
    }
  }
}

/// 字段元数据与校验；由 [TrackedFormFieldWidget] 提供实现。
mixin TrackedFieldMixin {
  TrackedFormValidationController get validationController;

  String get fieldName;
  bool get isRequired;
  FormFieldValidator? get validator;

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
    final form = validationController;
    return (value) {
      final err = combined(value);
      form._reportField(fieldName, err == null);
      return err;
    };
  }
}

/// 无状态 field 公共元数据；子类用 `super.fieldName` 等转发，不必重复声明字段。
abstract class TrackedFormFieldWidget extends StatelessWidget with TrackedFieldMixin {
  const TrackedFormFieldWidget({
    super.key,
    required this.validationController,
    required this.fieldName,
    this.validator,
    this.isRequired = false,
  });

  @override
  final TrackedFormValidationController validationController;
  @override
  final String fieldName;
  @override
  final bool isRequired;
  @override
  final FormFieldValidator? validator;
}

class TrackedTextFormField extends TrackedFormFieldWidget {
  const TrackedTextFormField({
    super.key,
    required super.validationController,
    required super.fieldName,
    super.validator,
    super.isRequired = false,
    required this.label,
    required this.controller,
    this.readOnly = false,
    this.obscureText = false,
    this.suffixIcon,
    this.suffixIconBuilder,
    this.contentPadding,
    this.minHeight = 0,
    this.hideLabel = false,
    this.hintText,
    this.maxLength,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final bool readOnly;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget Function(BuildContext context)? suffixIconBuilder;
  final EdgeInsetsGeometry? contentPadding;
  final double minHeight;
  final bool hideLabel;
  final String? hintText;
  final int? maxLength;
  final int maxLines;

  Widget? buildSuffix(BuildContext context) => suffixIcon ?? suffixIconBuilder?.call(context);

  /// 紧凑输入框装饰（标签由左侧 [labeledRow] 承担）。
  static InputDecoration _denseInputDecoration(
    BuildContext context, {
    EdgeInsetsGeometry? contentPadding,
    String? helperText,
    String? hintText,
    Widget? suffixIcon,
  }) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(4);
    final enabledBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: cs.outlineVariant),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: cs.primary),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: cs.error),
    );
    return InputDecoration(
      isDense: true,
      isCollapsed: false,
      filled: true,
      fillColor: cs.surfaceContainerLow,
      hintText: hintText,
      contentPadding: contentPadding,
      helperText: helperText,
      suffixIcon: suffixIcon,
      border: enabledBorder,
      enabledBorder: enabledBorder,
      focusedBorder: focusedBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
    );
  }

  static Widget labeledRow({
    required BuildContext context,
    required String label,
    required bool isRequired,
    required Widget child,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          SizedBox(
            width: 148,
            child: Padding(
              padding: const EdgeInsets.only(right: kSpacingSmall),
              child: Text.rich(
                TextSpan(
                  text: label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.2,
                  ),
                  children: isRequired
                      ? [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: cs.error),
                          ),
                        ]
                      : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      key: validationController._formFieldKey(fieldName),
      enabled: !readOnly,
      readOnly: readOnly,
      obscureText: obscureText,
      maxLength: maxLength,
      maxLines: maxLines,
      autovalidateMode: AutovalidateMode.onUnfocus,
      controller: controller,
      validator: resolveValidator(context),
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: _denseInputDecoration(
        context,
        contentPadding: contentPadding,
        hintText: hintText,
        suffixIcon: buildSuffix(context),
      ),
    );
    final multiline = maxLines > 1;
    final row = hideLabel
        ? field
        : labeledRow(
            context: context,
            label: label,
            isRequired: isRequired,
            crossAxisAlignment: multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            child: field,
          );
    if (minHeight <= 0) {
      return row;
    }
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      alignment: Alignment.centerLeft,
      child: row,
    );
  }
}

class TrackedPasswordFormField extends TrackedTextFormField {
  const TrackedPasswordFormField({
    super.key,
    required super.validationController,
    required super.fieldName,
    super.validator,
    required super.label,
    super.isRequired,
    required super.controller,
    super.suffixIcon,
    super.suffixIconBuilder,
    super.contentPadding,
    super.minHeight,
    super.readOnly,
  }) : super(obscureText: true);
}

class TrackedDescFormField extends TrackedTextFormField {
  const TrackedDescFormField({
    super.key,
    required super.validationController,
    required super.fieldName,
    super.validator,
    required super.label,
    super.isRequired,
    required super.controller,
    super.readOnly,
  }) : super(
         maxLength: 100,
         maxLines: 2,
         minHeight: 100,
         contentPadding: const EdgeInsets.all(kSpacingSmall),
       );
}

class TrackedFilePathFormField extends TrackedTextFormField {
  const TrackedFilePathFormField({
    super.key,
    required super.validationController,
    required super.fieldName,
    super.validator,
    super.isRequired,
    required super.label,
    required super.controller,
    required this.pickTooltip,
    this.allowedExtensions = const ['db', 'sqlite', 'sqlite3', 'duckdb'],
    super.readOnly,
  });

  final String pickTooltip;
  final List<String> allowedExtensions;

  Future<void> _pickFile(BuildContext context) async {
    final currentPath = controller.text.trim();
    final result = await FilePicker.platform.pickFiles(
      initialDirectory: currentPath.isNotEmpty ? p.dirname(currentPath) : null,
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );
    if (!context.mounted) {
      return;
    }
    final files = result?.files;
    final filePath = (files != null && files.isNotEmpty) ? files.first.path : null;
    if (filePath != null && filePath.isNotEmpty) {
      controller.text = filePath;
      validationController._formFieldKey(fieldName).currentState?.validate();
    }
  }

  @override
  Widget? buildSuffix(BuildContext context) {
    if (readOnly) {
      return null;
    }
    return RectangleIconButton(
      size: kIconButtonSizeSmall,
      iconSize: kIconSizeSmall,
      padding: 6,
      icon: Icons.folder_open,
      tooltip: pickTooltip,
      iconColor: Theme.of(context).colorScheme.primary,
      onPressed: () => _pickFile(context),
    );
  }
}

class TrackedEnumFormField extends TrackedFormFieldWidget {
  const TrackedEnumFormField({
    super.key,
    required super.validationController,
    required super.fieldName,
    super.validator,
    super.isRequired = false,
    required this.label,
    required this.controller,
    required this.enumValues,
    this.labels,
    this.defaultValue,
    this.helperText,
    this.readOnly = false,
  });

  final String label;
  final TextEditingController controller;
  final List<String> enumValues;
  final Map<String, String>? labels;
  final String? defaultValue;
  final String? helperText;
  final bool readOnly;

  static String _labelFor(Map<String, String>? labels, String value) => labels?[value] ?? value;

  static String _effectiveValue(List<String> opts, String current, String? defaultValue) {
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

  static InputDecoration _fieldDecoration(
    BuildContext context,
    FormFieldState<String> fieldState, {
    String? helperText,
  }) {
    final base = TrackedTextFormField._denseInputDecoration(context, helperText: helperText);
    if (!fieldState.hasError) {
      return base;
    }
    return base.copyWith(errorText: fieldState.errorText);
  }

  @override
  Widget build(BuildContext context) {
    final opts = enumValues;
    final effective = _effectiveValue(opts, controller.text, defaultValue);
    if (controller.text != effective) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          return;
        }
        if (controller.text != effective) {
          controller.text = effective;
        }
      });
    }
    final form = validationController;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    const itemHeight = 40.0;
    final menuMaxHeight = opts.length * itemHeight + kSpacingSmall * 2;
    final cappedMenuHeight = menuMaxHeight > 280 ? 280.0 : menuMaxHeight;

    return TrackedTextFormField.labeledRow(
      context: context,
      label: label,
      isRequired: isRequired,
      child: FormField<String>(
        key: form._formFieldKey(fieldName),
        initialValue: effective,
        autovalidateMode: AutovalidateMode.onUnfocus,
        validator: resolveValidator(context),
        builder: (fieldState) {
          final display = _effectiveValue(opts, controller.text, defaultValue);
          if (fieldState.value != display) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) {
                return;
              }
              fieldState.didChange(display);
            });
          }

          if (readOnly) {
            return InputDecorator(
              decoration: _fieldDecoration(context, fieldState, helperText: helperText).copyWith(enabled: false),
              isEmpty: false,
              child: Text(
                _labelFor(labels, display),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            );
          }

          return InputDecorator(
            decoration: _fieldDecoration(context, fieldState, helperText: helperText),
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
                      controller.text = e;
                      fieldState.didChange(e);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: kSpacingSmall),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _labelFor(labels, e),
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
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _labelFor(labels, display),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Icon(Icons.expand_more, size: 20, color: cs.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class TrackedHostPortFields extends StatelessWidget {
  const TrackedHostPortFields({
    super.key,
    required this.validationController,
    required this.hostFieldName,
    required this.hostController,
    this.hostValidator,
    required this.hostLabel,
    this.hostRequired = false,
    required this.portFieldName,
    required this.portController,
    this.portValidator,
    required this.portLabel,
    this.portRequired = false,
    this.readOnly = false,
  });

  final TrackedFormValidationController validationController;
  final String hostFieldName;
  final TextEditingController hostController;
  final FormFieldValidator? hostValidator;
  final String hostLabel;
  final bool hostRequired;
  final String portFieldName;
  final TextEditingController portController;
  final FormFieldValidator? portValidator;
  final String portLabel;
  final bool portRequired;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final hostField = TrackedTextFormField(
      validationController: validationController,
      fieldName: hostFieldName,
      validator: hostValidator,
      label: hostLabel,
      isRequired: hostRequired,
      controller: hostController,
      readOnly: readOnly,
      hideLabel: true,
      hintText: hostLabel,
    );
    return TrackedTextFormField.labeledRow(
      context: context,
      label: hostLabel,
      isRequired: hostRequired || portRequired,
      crossAxisAlignment: CrossAxisAlignment.start,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: hostField),
          const SizedBox(width: kSpacingTiny),
          SizedBox(
            width: 96,
            child: TrackedTextFormField(
              validationController: validationController,
              fieldName: portFieldName,
              validator: portValidator,
              label: portLabel,
              isRequired: portRequired,
              controller: portController,
              readOnly: readOnly,
              hideLabel: true,
              hintText: portLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class TrackedSwitchFormField extends TrackedFormFieldWidget {
  const TrackedSwitchFormField({
    super.key,
    required super.validationController,
    required super.fieldName,
    super.validator,
    super.isRequired = false,
    required this.label,
    required this.controller,
    this.revalidateFieldNamesOnChange,
  });

  final String label;
  final TextEditingController controller;
  final List<String>? revalidateFieldNamesOnChange;

  static bool _parseEnabled(String value) => value.trim().toLowerCase() == "true";

  void _setValue(
    BuildContext context,
    FormFieldState<String> state,
    TrackedFormValidationController form,
    bool value,
  ) {
    controller.text = value ? "true" : "false";
    state.didChange(controller.text);
    form._reportField(fieldName, true);
    if (value) {
      return;
    }
    final names = revalidateFieldNamesOnChange;
    if (names == null || names.isEmpty) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }
      form.revalidateFields(names);
    });
  }

  @override
  Widget build(BuildContext context) {
    final form = validationController;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final enabled = _parseEnabled(controller.text);
        return FormField<String>(
          key: form._formFieldKey(fieldName),
          initialValue: controller.text,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: resolveValidator(context),
          builder: (state) {
            return TrackedTextFormField.labeledRow(
              context: context,
              label: label,
              isRequired: isRequired,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 36,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Switch(
                        value: enabled,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (value) => _setValue(context, state, form, value),
                      ),
                    ),
                  ),
                  if (state.hasError && state.errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        state.errorText!,
                        style: theme.textTheme.bodySmall?.copyWith(color: cs.error),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
