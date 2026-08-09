import 'package:client/models/instances.dart';
import 'package:client/services/instances/instances.dart';
import 'package:client/widgets/const.dart';
import 'package:client/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:db_driver/db_driver.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:sql_parser/parser.dart';
import 'package:client/l10n/app_localizations.dart';
import 'package:client/widgets/dialog.dart';
import 'package:client/widgets/loading.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:client/widgets/anchor_tab_scroll.dart';
import 'package:client/widgets/form.dart';
import 'package:client/widgets/sql_highlight.dart';

const _sshTunnelFieldNames = [
  settingMetaNameSshTunnel,
  settingMetaNameSshTunnelHost,
  settingMetaNameSshTunnelPort,
  settingMetaNameSshTunnelUser,
  settingMetaNameSshTunnelAuthMethod,
  settingMetaNameSshTunnelPassword,
  settingMetaNameSshTunnelPrivateKeyPath,
  settingMetaNameSshTunnelPrivateKeyPassphrase,
];

Map<String, String> fieldToGroupFor(DatabaseType type) {
  final map = <String, String>{};
  for (final meta in getConnMetas(type)) {
    switch (meta) {
      case NameMeta():
        map[settingMetaNameName] = meta.group;
      case TargetNetworkMeta():
        map[settingMetaNameTargetNetworkHost] = meta.group;
        map[settingMetaNameTargetNetworkPort] = meta.group;
      case SshTunnelMeta():
        for (final name in _sshTunnelFieldNames) {
          map[name] = meta.group;
        }
      case TargetDBFileMeta():
        map[settingMetaNameTargetDBFile] = meta.group;
      case UserMeta():
        map[settingMetaNameUser] = meta.group;
      case PasswordMeta():
        map[settingMetaNamePassword] = meta.group;
      case DescMeta():
        map[settingMetaNameDesc] = meta.group;
      case CustomMeta():
        map[meta.name] = meta.group;
    }
  }
  map[settingMetaGroupInitQuery] = settingMetaGroupInitQuery;
  return map;
}

void applySshTunnelFields(
  Map<String, TextEditingController> fields, {
  required SshTunnelMeta meta,
  SshTunnelConfig? config,
}) {
  final template = config ?? meta.template;
  fields[settingMetaNameSshTunnel]?.text = template.enabled ? "true" : "false";
  fields[settingMetaNameSshTunnelHost]?.text = template.host;
  fields[settingMetaNameSshTunnelPort]?.text = template.port.toString();
  fields[settingMetaNameSshTunnelUser]?.text = template.user;
  fields[settingMetaNameSshTunnelAuthMethod]?.text = sshTunnelAuthMethodToValue(resolveSshTunnelAuthMethod(template));
  fields[settingMetaNameSshTunnelPassword]?.text = template.password ?? "";
  fields[settingMetaNameSshTunnelPrivateKeyPath]?.text = template.privateKeyPath ?? "";
  fields[settingMetaNameSshTunnelPrivateKeyPassphrase]?.text = template.privateKeyPassphrase ?? "";
}

class DatabaseFormController {
  final DatabaseType databaseType;
  final Map<String, String> fieldToGroup;
  final Map<String, TextEditingController> fieldControllers = {};
  final TrackedFormValidationController formValidation = TrackedFormValidationController();
  late final SqlHighlightTextEditingController initQueryController;

  DatabaseFormController(this.databaseType) : fieldToGroup = fieldToGroupFor(databaseType) {
    for (final meta in connectionMetaMap[databaseType]!.connMeta) {
      if (meta is TargetNetworkMeta) {
        fieldControllers[settingMetaNameTargetNetworkHost] = TextEditingController(text: meta.defaultValue ?? "");
        fieldControllers[settingMetaNameTargetNetworkPort] = TextEditingController(text: meta.defaultPort ?? "");
      } else if (meta is SshTunnelMeta) {
        fieldControllers[settingMetaNameSshTunnel] = TextEditingController();
        fieldControllers[settingMetaNameSshTunnelHost] = TextEditingController();
        fieldControllers[settingMetaNameSshTunnelPort] = TextEditingController();
        fieldControllers[settingMetaNameSshTunnelUser] = TextEditingController();
        fieldControllers[settingMetaNameSshTunnelAuthMethod] = TextEditingController();
        fieldControllers[settingMetaNameSshTunnelPassword] = TextEditingController();
        fieldControllers[settingMetaNameSshTunnelPrivateKeyPath] = TextEditingController();
        fieldControllers[settingMetaNameSshTunnelPrivateKeyPassphrase] = TextEditingController();
        applySshTunnelFields(fieldControllers, meta: meta);
      } else {
        fieldControllers[meta.name] = TextEditingController(text: meta.defaultValue ?? "");
      }
    }
    initQueryController = SqlHighlightTextEditingController(
      dialectType: databaseType.dialectType,
      text: connectionMetaMap[databaseType]!.initQueryText(),
    );
  }

  void dispose() {
    for (final c in fieldControllers.values) {
      c.dispose();
    }
    initQueryController.dispose();
    formValidation.dispose();
  }

  void reset() {
    for (final meta in connectionMetaMap[databaseType]!.connMeta) {
      if (meta is TargetNetworkMeta) {
        fieldControllers[settingMetaNameTargetNetworkHost]?.text = meta.defaultValue ?? "";
        fieldControllers[settingMetaNameTargetNetworkPort]?.text = meta.defaultPort ?? "";
      } else if (meta is SshTunnelMeta) {
        applySshTunnelFields(fieldControllers, meta: meta);
      } else {
        fieldControllers[meta.name]?.text = meta.defaultValue ?? "";
      }
    }
    initQueryController.text = connectionMetaMap[databaseType]!.initQueryText();
    formValidation.clearInvalidFields();
  }

  bool isGroupInvalid(String groupId) => formValidation.invalidFieldNames.any((name) => fieldToGroup[name] == groupId);
}

class AddInstanceController extends ChangeNotifier {
  final Map<DatabaseType, DatabaseFormController> databaseFormControllers = {};

  DatabaseType selectedDatabaseType = connectionMetas.first.type;

  DatabaseFormController get selectedDatabaseFormController => databaseFormControllers[selectedDatabaseType]!;

  bool validateForm() => selectedDatabaseFormController.formValidation.validate();

  @override
  void dispose() {
    for (final f in databaseFormControllers.values) {
      f.dispose();
    }
    super.dispose();
  }

  // 数据库连接测试的状态
  bool? isDatabaseConnectable;
  bool isDatabasePingDoing = false;
  String? databaseConnectError;

  // 向导步骤
  int _wizardStep = 0;
  int get wizardStep => _wizardStep;

  void setWizardStep(int step) {
    final s = step.clamp(0, 1);
    if (_wizardStep == s) {
      return;
    }
    _wizardStep = s;
    notifyListeners();
  }

  void onDatabaseTypeChange(DatabaseType type) {
    if (selectedDatabaseType == type) {
      return;
    }
    selectedDatabaseType = type;
    isDatabasePingDoing = false;
    isDatabaseConnectable = null;
    databaseConnectError = null;
    notifyListeners();
  }

  void clear() {
    for (final f in databaseFormControllers.values) {
      f.reset();
    }
    _wizardStep = 0;
    isDatabasePingDoing = false;
    isDatabaseConnectable = null;
    databaseConnectError = null;
    notifyListeners();
  }

  SshTunnelConfig? _parseSshTunnel(
    Map<String, TextEditingController> fields, {
    SshTunnelMeta? meta,
  }) {
    final template = meta?.template ?? kDefaultSshTunnelTemplate;
    final authMethod = sshTunnelAuthMethodFromValue(
      fields[settingMetaNameSshTunnelAuthMethod]?.text,
    );
    final password = fields[settingMetaNameSshTunnelPassword]?.text ?? "";
    final privateKeyPath = fields[settingMetaNameSshTunnelPrivateKeyPath]?.text.trim() ?? "";
    final privateKeyPassphrase = fields[settingMetaNameSshTunnelPrivateKeyPassphrase]?.text ?? "";
    return SshTunnelConfig(
      enabled: fields[settingMetaNameSshTunnel]?.text.trim().toLowerCase() == "true",
      host: fields[settingMetaNameSshTunnelHost]?.text.trim() ?? template.host,
      port: int.tryParse(fields[settingMetaNameSshTunnelPort]?.text.trim() ?? "") ?? template.port,
      user: fields[settingMetaNameSshTunnelUser]?.text.trim() ?? template.user,
      authMethod: authMethod,
      password: authMethod == SshTunnelAuthMethod.password && password.isNotEmpty ? password : null,
      privateKeyPath: authMethod == SshTunnelAuthMethod.privateKey && privateKeyPath.isNotEmpty ? privateKeyPath : null,
      privateKeyPassphrase: authMethod == SshTunnelAuthMethod.privateKey && privateKeyPassphrase.isNotEmpty
          ? privateKeyPassphrase
          : null,
    );
  }

  ConnectValue getConnectValue() {
    String name = "";
    String addr = "";
    String dbFile = "";
    int? port;
    String user = "";
    String password = "";
    String desc = "";
    Map<String, String> custom = {};

    final controller = selectedDatabaseFormController;
    final initQuery = controller.initQueryController;
    final fields = controller.fieldControllers;
    for (final meta in getConnMetas(selectedDatabaseType)) {
      switch (meta) {
        case NameMeta():
          name = fields[meta.name]!.text;
        case TargetNetworkMeta():
          addr = fields[settingMetaNameTargetNetworkHost]!.text;
          port = int.tryParse(fields[settingMetaNameTargetNetworkPort]!.text.trim());
        case TargetDBFileMeta():
          final text = fields[meta.name]!.text;
          dbFile = text;
          addr = dbFile;
        case SshTunnelMeta():
          break;
        case UserMeta():
          user = fields[meta.name]!.text;
        case PasswordMeta():
          password = fields[meta.name]!.text;
        case DescMeta():
          desc = fields[meta.name]!.text;
        case CustomMeta():
          custom[meta.name] = fields[meta.name]!.text;
      }
    }
    List<String> querys = splitSQL(
      selectedDatabaseType.dialectType,
      initQuery.text.trim(),
    ).map((e) => e.content.trim()).whereNot((e) => e.trim() == "").toList();
    final sshMeta = getConnMetas(selectedDatabaseType).whereType<SshTunnelMeta>().firstOrNull;
    final sshTunnel = dbFile.isEmpty ? _parseSshTunnel(fields, meta: sshMeta) : null;
    final target = dbFile.isNotEmpty
        ? ConnectTarget.dbFile(dbFile: dbFile)
        : ConnectTarget.network(host: addr, port: port ?? 0);
    return ConnectValue(
      name: name,
      target: target,
      user: user,
      password: password,
      desc: desc,
      custom: custom,
      initQuerys: querys,
      sshTunnel: sshTunnel,
    );
  }

  Future<void> databasePing() async {
    final connectValue = getConnectValue();
    BaseConnection? conn;
    try {
      isDatabasePingDoing = true;
      notifyListeners();
      conn = await ConnectionWrapper.open(type: selectedDatabaseType, meta: connectValue);
      isDatabaseConnectable = true;
      databaseConnectError = null;
      conn.close();
    } catch (e) {
      isDatabaseConnectable = false;
      databaseConnectError = e.toString();
      print(e);
    } finally {
      isDatabasePingDoing = false;
      notifyListeners();
    }
  }

  InstanceModel getInstanceModel() {
    final connectValue = getConnectValue();
    return InstanceModel(
      id: const InstanceId(value: 0),
      dbType: selectedDatabaseType,
      name: connectValue.name,
      target: connectValue.target,
      sshTunnel: connectValue.sshTunnel,
      user: connectValue.user,
      password: connectValue.password,
      desc: connectValue.desc,
      custom: connectValue.custom,
      initQuerys: connectValue.initQuerys,
      activeSchemas: [],
      createdAt: DateTime.now(),
      latestOpenAt: DateTime.now(),
    );
  }

  AddInstanceController() {
    for (final cm in connectionMetas) {
      databaseFormControllers[cm.type] = DatabaseFormController(cm.type);
    }
  }
}

AddInstanceController addInstanceController = AddInstanceController();

Future<void> showAddInstanceDialog(BuildContext context) async {
  addInstanceController.clear();
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => _AddInstanceWizardDialog(),
  );
}

void _addInstanceWizardSubmitAndClose(WidgetRef ref, BuildContext context, {required bool closeToList}) {
  if (!addInstanceController.validateForm()) {
    return;
  }
  ref.read(instancesServicesProvider.notifier).addInstance(addInstanceController.getInstanceModel());
  addInstanceController.clear();
  ref.read(instancesProvider.notifier).changePage("");
  if (!context.mounted) {
    return;
  }
  Navigator.of(context).pop();
  if (closeToList && context.mounted) {
    GoRouter.of(context).go('/instances/list');
  }
}

class _AddInstanceWizardDialog extends ConsumerStatefulWidget {
  const _AddInstanceWizardDialog();

  @override
  ConsumerState<_AddInstanceWizardDialog> createState() => _AddInstanceWizardDialogState();
}

class _AddInstanceWizardDialogState extends ConsumerState<_AddInstanceWizardDialog> {
  @override
  void initState() {
    super.initState();
    addInstanceController.addListener(_onCtrl);
  }

  @override
  void dispose() {
    addInstanceController.removeListener(_onCtrl);
    super.dispose();
  }

  void _onCtrl() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = addInstanceController.wizardStep;
    return Dialog(
      child: step == 0 ? _AddInstanceWizardStep1() : _AddInstanceWizardStep2(),
    );
  }
}

/// 向导弹窗步骤 1：选择数据源
class _AddInstanceWizardStep1 extends StatelessWidget {
  static const double _tileWidth = 104;
  static const double _tileHeight = 92;

  const _AddInstanceWizardStep1();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CustomDialogWidget(
      title: l10n.add_db_instance,
      titleIcon: HugeIcon(
        icon: HugeIcons.strokeRoundedDatabase,
        color: Theme.of(context).colorScheme.onSurfaceVariant, // navigation rail 默认icon颜色
      ),
      subtitle: l10n.add_instance_wizard_step1_subtitle,
      maxWidth: 960,
      maxHeight: 720,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: kSpacingSmall),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Wrap(
                spacing: kSpacingTiny,
                runSpacing: kSpacingTiny,
                children: [
                  for (final meta in connectionMetas)
                    SizedBox(
                      width: _tileWidth,
                      height: _tileHeight,
                      child: DatabaseTypeCard(
                        name: meta.displayName,
                        type: meta.type,
                        logoPath: meta.logoAssertPath,
                        onTap: () {
                          addInstanceController.onDatabaseTypeChange(meta.type);
                          addInstanceController.setWizardStep(1);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [],
    );
  }
}

class _AddInstanceWizardStep2 extends ConsumerWidget {
  const _AddInstanceWizardStep2();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return CustomDialogWidget(
      title: l10n.add_db_instance,
      titleIcon: Image.asset(
        connectionMetaMap[addInstanceController.selectedDatabaseType]!.logoAssertPath,
        width: kIconSizeMedium,
        height: kIconSizeMedium,
      ),
      subtitle: l10n.add_instance_wizard_step2_subtitle,
      maxWidth: 960,
      maxHeight: 720,
      footerLeading: DbInstanceConnectionTestWidget(
        isDatabasePingDoing: addInstanceController.isDatabasePingDoing,
        isDatabaseConnectable: addInstanceController.isDatabaseConnectable,
        databaseConnectError: addInstanceController.databaseConnectError,
        onTestConnection: () => addInstanceController.databasePing(),
      ),
      body: ListenableBuilder(
        listenable: addInstanceController,
        builder: (context, _) => ListenableBuilder(
          listenable: addInstanceController.selectedDatabaseFormController.formValidation,
          builder: (context, _) => InstanceFormWidget.forAddInstanceWizard(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => addInstanceController.setWizardStep(0),
          child: Text(l10n.wizard_previous),
        ),
        SizedBox(width: kSpacingSmall),
        FilledButton(
          onPressed: () => _addInstanceWizardSubmitAndClose(ref, context, closeToList: true),
          child: Text(l10n.submit),
        ),
      ],
    );
  }
}

class DatabaseTypeCard extends StatefulWidget {
  final DatabaseType type;
  final String name;
  final String logoPath;
  final VoidCallback? onTap;

  const DatabaseTypeCard({
    super.key,
    required this.type,
    required this.name,
    required this.logoPath,
    this.onTap,
  });

  @override
  State<DatabaseTypeCard> createState() => _DatabaseTypeCardState();
}

class _DatabaseTypeCardState extends State<DatabaseTypeCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Container(
        constraints: const BoxConstraints(minHeight: 84, minWidth: 100),
        decoration: BoxDecoration(
          color: _hovering ? Theme.of(context).colorScheme.surfaceContainer : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: widget.onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(kSpacingTiny, kSpacingSmall, kSpacingTiny, kSpacingTiny),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: Image.asset(
                    widget.logoPath,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(kSpacingTiny, kSpacingTiny, kSpacingTiny, kSpacingSmall),
                child: Text(widget.name),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InstanceFormWidget extends StatelessWidget {
  final AddInstanceController controller;

  const InstanceFormWidget({
    super.key,
    required this.controller,
  });

  factory InstanceFormWidget.forAddInstanceWizard() {
    return InstanceFormWidget(controller: addInstanceController);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = controller;
    final fc = c.selectedDatabaseFormController;
    final sections = <String, List<Widget>>{};
    void addSectionWidget(String sectionId, Widget widget) {
      sections.putIfAbsent(sectionId, () => []);
      sections[sectionId]!.add(widget);
    }

    final sectionTabLabels = {
      settingMetaGroupBase: l10n.db_base_config,
      settingMetaGroupSshTunnel: l10n.db_instance_ssh_tunnel,
      settingMetaGroupParams: l10n.db_conn_params,
      settingMetaGroupInitQuery: l10n.db_conn_init_query,
    };
    final sectionTabDescriptions = {
      settingMetaGroupBase: l10n.db_base_config_desc,
      settingMetaGroupSshTunnel: l10n.db_instance_ssh_tunnel_summary,
      settingMetaGroupParams: l10n.db_conn_params_desc,
      settingMetaGroupInitQuery: l10n.db_conn_init_query_desc,
    };
    for (final meta in getConnMetas(c.selectedDatabaseType)) {
      switch (meta) {
        case NameMeta():
          addSectionWidget(
            meta.group,
            TrackedTextFormField(
              validationController: fc.formValidation,
              fieldName: settingMetaNameName,
              label: l10n.db_instance_name,
              isRequired: true,
              controller: c.selectedDatabaseFormController.fieldControllers[settingMetaNameName]!,
            ),
          );
        case TargetNetworkMeta():
          addSectionWidget(
            meta.group,
            TrackedHostPortFields(
              validationController: fc.formValidation,
              hostFieldName: settingMetaNameTargetNetworkHost,
              hostController: c.selectedDatabaseFormController.fieldControllers[settingMetaNameTargetNetworkHost]!,
              hostLabel: l10n.db_instance_host,
              hostRequired: true,
              portFieldName: settingMetaNameTargetNetworkPort,
              portController: c.selectedDatabaseFormController.fieldControllers[settingMetaNameTargetNetworkPort]!,
              portLabel: l10n.db_instance_port,
              portRequired: true,
            ),
          );
        case SshTunnelMeta():
          addSectionWidget(
            meta.group,
            _InstanceSshTunnelFields(
              validationController: fc.formValidation,
              fields: c.selectedDatabaseFormController.fieldControllers,
            ),
          );
        case TargetDBFileMeta():
          addSectionWidget(
            meta.group,
            TrackedFilePathFormField(
              validationController: fc.formValidation,
              fieldName: settingMetaNameTargetDBFile,
              isRequired: true,
              label: 'Path',
              controller: c.selectedDatabaseFormController.fieldControllers[settingMetaNameTargetDBFile]!,
              pickTooltip: l10n.tooltip_select_directory,
            ),
          );
        case UserMeta():
          addSectionWidget(
            meta.group,
            TrackedTextFormField(
              validationController: fc.formValidation,
              fieldName: settingMetaNameUser,
              label: l10n.db_instance_user,
              controller: c.selectedDatabaseFormController.fieldControllers[settingMetaNameUser]!,
            ),
          );
        case PasswordMeta():
          addSectionWidget(
            meta.group,
            TrackedPasswordFormField(
              validationController: fc.formValidation,
              fieldName: settingMetaNamePassword,
              label: l10n.db_instance_password,
              controller: c.selectedDatabaseFormController.fieldControllers[settingMetaNamePassword]!,
            ),
          );
        case DescMeta():
          addSectionWidget(
            meta.group,
            TrackedDescFormField(
              validationController: fc.formValidation,
              fieldName: settingMetaNameDesc,
              label: l10n.db_instance_desc,
              controller: c.selectedDatabaseFormController.fieldControllers[settingMetaNameDesc]!,
            ),
          );
        case CustomMeta():
          final useEnum =
              meta.type == SettingMetaType.enumValue && meta.enumValues != null && meta.enumValues!.isNotEmpty;
          addSectionWidget(
            meta.group,
            useEnum
                ? TrackedEnumFormField(
                    validationController: fc.formValidation,
                    fieldName: meta.name,
                    isRequired: meta.isRequired,
                    label: meta.name,
                    controller: c.selectedDatabaseFormController.fieldControllers[meta.name]!,
                    enumValues: meta.enumValues!,
                    defaultValue: meta.defaultValue,
                    helperText: meta.comment,
                  )
                : TrackedTextFormField(
                    validationController: fc.formValidation,
                    fieldName: meta.name,
                    isRequired: meta.isRequired,
                    label: meta.name,
                    controller: c.selectedDatabaseFormController.fieldControllers[meta.name]!,
                  ),
          );
      }
    }
    addSectionWidget(
      settingMetaGroupInitQuery,
      TrackedTextFormField(
        validationController: fc.formValidation,
        fieldName: settingMetaGroupInitQuery,
        label: l10n.db_conn_init_query,
        controller: fc.initQueryController,
        maxLines: 24,
        minHeight: 360,
        contentPadding: const EdgeInsets.all(kSpacingSmall),
      ),
    );
    final cs = Theme.of(context).colorScheme;
    return AnchorTabScrollLayout(
      sections: [
        for (final id in sections.keys)
          AnchorTabSection(
            id: id,
            label: sectionTabLabels[id]!,
            description: sectionTabDescriptions[id],
            labelColor: fc.isGroupInvalid(id) ? cs.error : null,
            children: sections[id]!,
          ),
      ],
    );
  }
}

class _InstanceSshTunnelFields extends StatefulWidget {
  const _InstanceSshTunnelFields({
    required this.validationController,
    required this.fields,
  });

  final TrackedFormValidationController validationController;
  final Map<String, TextEditingController> fields;

  @override
  State<_InstanceSshTunnelFields> createState() => _InstanceSshTunnelFieldsState();
}

class _InstanceSshTunnelFieldsState extends State<_InstanceSshTunnelFields> {
  late final TextEditingController _enabledCtrl;
  late final TextEditingController _authMethodCtrl;

  @override
  void initState() {
    super.initState();
    _enabledCtrl = widget.fields[settingMetaNameSshTunnel]!;
    _authMethodCtrl = widget.fields[settingMetaNameSshTunnelAuthMethod]!;
    _enabledCtrl.addListener(_onInteractionChanged);
    _authMethodCtrl.addListener(_onInteractionChanged);
  }

  @override
  void dispose() {
    _enabledCtrl.removeListener(_onInteractionChanged);
    _authMethodCtrl.removeListener(_onInteractionChanged);
    super.dispose();
  }

  void _onInteractionChanged() => setState(() {});

  bool get _sshEnabled => _enabledCtrl.text.trim().toLowerCase() == "true";

  bool get _sshPasswordAuth => sshTunnelAuthMethodFromValue(_authMethodCtrl.text) == SshTunnelAuthMethod.password;

  bool get _sshKeyAuth => !_sshPasswordAuth;

  String? _sshRequired(dynamic value) =>
      _sshEnabled ? FormFieldValidators.requiredValue(context, value as String?) : null;

  String? _sshPasswordRequired(dynamic value) =>
      _sshEnabled && _sshPasswordAuth ? FormFieldValidators.requiredValue(context, value as String?) : null;

  String? _sshKeyPathRequired(dynamic value) =>
      _sshEnabled && _sshKeyAuth ? FormFieldValidators.requiredValue(context, value as String?) : null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fields = widget.fields;
    final validationController = widget.validationController;
    final sshReadOnly = !_sshEnabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TrackedSwitchFormField(
          validationController: validationController,
          fieldName: settingMetaNameSshTunnel,
          label: l10n.db_instance_ssh_tunnel_enabled,
          controller: _enabledCtrl,
          revalidateFieldNamesOnChange: const [
            settingMetaNameSshTunnelHost,
            settingMetaNameSshTunnelPort,
            settingMetaNameSshTunnelUser,
            settingMetaNameSshTunnelAuthMethod,
            settingMetaNameSshTunnelPassword,
            settingMetaNameSshTunnelPrivateKeyPath,
            settingMetaNameSshTunnelPrivateKeyPassphrase,
          ],
        ),
        TrackedHostPortFields(
          validationController: validationController,
          readOnly: sshReadOnly,
          hostFieldName: settingMetaNameSshTunnelHost,
          hostController: fields[settingMetaNameSshTunnelHost]!,
          hostLabel: l10n.db_instance_ssh_tunnel_host,
          hostValidator: _sshRequired,
          portFieldName: settingMetaNameSshTunnelPort,
          portController: fields[settingMetaNameSshTunnelPort]!,
          portLabel: l10n.db_instance_ssh_tunnel_port,
          portValidator: _sshRequired,
        ),
        TrackedTextFormField(
          validationController: validationController,
          fieldName: settingMetaNameSshTunnelUser,
          label: l10n.db_instance_ssh_tunnel_user,
          validator: _sshRequired,
          controller: fields[settingMetaNameSshTunnelUser]!,
          readOnly: sshReadOnly,
        ),
        TrackedEnumFormField(
          validationController: validationController,
          fieldName: settingMetaNameSshTunnelAuthMethod,
          label: l10n.db_instance_ssh_tunnel_auth_method,
          controller: _authMethodCtrl,
          enumValues: const [kSshTunnelAuthMethodPassword, kSshTunnelAuthMethodPrivateKey],
          labels: {
            kSshTunnelAuthMethodPassword: l10n.db_instance_ssh_tunnel_auth_password,
            kSshTunnelAuthMethodPrivateKey: l10n.db_instance_ssh_tunnel_auth_private_key,
          },
          defaultValue: kSshTunnelAuthMethodPassword,
          validator: _sshRequired,
          readOnly: sshReadOnly,
        ),
        if (_sshPasswordAuth)
          TrackedPasswordFormField(
            validationController: validationController,
            fieldName: settingMetaNameSshTunnelPassword,
            label: l10n.db_instance_ssh_tunnel_password,
            validator: _sshPasswordRequired,
            controller: fields[settingMetaNameSshTunnelPassword]!,
            readOnly: sshReadOnly,
          ),
        if (_sshKeyAuth) ...[
          TrackedFilePathFormField(
            validationController: validationController,
            fieldName: settingMetaNameSshTunnelPrivateKeyPath,
            label: l10n.db_instance_ssh_tunnel_private_key,
            controller: fields[settingMetaNameSshTunnelPrivateKeyPath]!,
            pickTooltip: l10n.tooltip_select_private_key_file,
            allowedExtensions: const ['pem', 'key', 'ppk', 'rsa', 'ed25519'],
            validator: _sshKeyPathRequired,
            readOnly: sshReadOnly,
          ),
          TrackedPasswordFormField(
            validationController: validationController,
            fieldName: settingMetaNameSshTunnelPrivateKeyPassphrase,
            label: l10n.db_instance_ssh_tunnel_private_key_passphrase,
            controller: fields[settingMetaNameSshTunnelPrivateKeyPassphrase]!,
            readOnly: sshReadOnly,
          ),
        ],
      ],
    );
  }
}

class DbInstanceConnectionTestWidget extends StatelessWidget {
  final bool isDatabasePingDoing;
  final bool? isDatabaseConnectable;
  final String? databaseConnectError;
  final VoidCallback onTestConnection;

  const DbInstanceConnectionTestWidget({
    super.key,
    required this.isDatabasePingDoing,
    required this.isDatabaseConnectable,
    this.databaseConnectError,
    required this.onTestConnection,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LinkButton(
          text: l10n.db_instance_test,
          onPressed: isDatabasePingDoing ? null : onTestConnection,
        ),
        const SizedBox(width: kSpacingSmall),
        if (isDatabasePingDoing)
          const Loading.medium()
        else if (isDatabaseConnectable == true)
          Icon(
            Icons.check_circle,
            size: kIconSizeSmall,
            color: Colors.green,
          )
        else if (isDatabaseConnectable == false) ...[
          Icon(
            Icons.error,
            size: kIconSizeSmall,
            color: cs.error,
          ),
          const SizedBox(width: kSpacingTiny),
          Expanded(
            child: Text(
              databaseConnectError ?? '',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.error),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}
