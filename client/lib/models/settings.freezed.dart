// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SystemSettingModel {
  String get theme;
  String get language;

  /// Create a copy of SystemSettingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SystemSettingModelCopyWith<SystemSettingModel> get copyWith =>
      _$SystemSettingModelCopyWithImpl<SystemSettingModel>(
          this as SystemSettingModel, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SystemSettingModel &&
            (identical(other.theme, theme) || other.theme == theme) &&
            (identical(other.language, language) ||
                other.language == language));
  }

  @override
  int get hashCode => Object.hash(runtimeType, theme, language);

  @override
  String toString() {
    return 'SystemSettingModel(theme: $theme, language: $language)';
  }
}

/// @nodoc
abstract mixin class $SystemSettingModelCopyWith<$Res> {
  factory $SystemSettingModelCopyWith(
          SystemSettingModel value, $Res Function(SystemSettingModel) _then) =
      _$SystemSettingModelCopyWithImpl;
  @useResult
  $Res call({String theme, String language});
}

/// @nodoc
class _$SystemSettingModelCopyWithImpl<$Res>
    implements $SystemSettingModelCopyWith<$Res> {
  _$SystemSettingModelCopyWithImpl(this._self, this._then);

  final SystemSettingModel _self;
  final $Res Function(SystemSettingModel) _then;

  /// Create a copy of SystemSettingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? theme = null,
    Object? language = null,
  }) {
    return _then(_self.copyWith(
      theme: null == theme
          ? _self.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as String,
      language: null == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _SystemSettingModel implements SystemSettingModel {
  const _SystemSettingModel({required this.theme, required this.language});

  @override
  final String theme;
  @override
  final String language;

  /// Create a copy of SystemSettingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SystemSettingModelCopyWith<_SystemSettingModel> get copyWith =>
      __$SystemSettingModelCopyWithImpl<_SystemSettingModel>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SystemSettingModel &&
            (identical(other.theme, theme) || other.theme == theme) &&
            (identical(other.language, language) ||
                other.language == language));
  }

  @override
  int get hashCode => Object.hash(runtimeType, theme, language);

  @override
  String toString() {
    return 'SystemSettingModel(theme: $theme, language: $language)';
  }
}

/// @nodoc
abstract mixin class _$SystemSettingModelCopyWith<$Res>
    implements $SystemSettingModelCopyWith<$Res> {
  factory _$SystemSettingModelCopyWith(
          _SystemSettingModel value, $Res Function(_SystemSettingModel) _then) =
      __$SystemSettingModelCopyWithImpl;
  @override
  @useResult
  $Res call({String theme, String language});
}

/// @nodoc
class __$SystemSettingModelCopyWithImpl<$Res>
    implements _$SystemSettingModelCopyWith<$Res> {
  __$SystemSettingModelCopyWithImpl(this._self, this._then);

  final _SystemSettingModel _self;
  final $Res Function(_SystemSettingModel) _then;

  /// Create a copy of SystemSettingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? theme = null,
    Object? language = null,
  }) {
    return _then(_SystemSettingModel(
      theme: null == theme
          ? _self.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as String,
      language: null == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$SettingTabModel {
  SettingType get selectedSettingType;

  /// Create a copy of SettingTabModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SettingTabModelCopyWith<SettingTabModel> get copyWith =>
      _$SettingTabModelCopyWithImpl<SettingTabModel>(
          this as SettingTabModel, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SettingTabModel &&
            (identical(other.selectedSettingType, selectedSettingType) ||
                other.selectedSettingType == selectedSettingType));
  }

  @override
  int get hashCode => Object.hash(runtimeType, selectedSettingType);

  @override
  String toString() {
    return 'SettingTabModel(selectedSettingType: $selectedSettingType)';
  }
}

/// @nodoc
abstract mixin class $SettingTabModelCopyWith<$Res> {
  factory $SettingTabModelCopyWith(
          SettingTabModel value, $Res Function(SettingTabModel) _then) =
      _$SettingTabModelCopyWithImpl;
  @useResult
  $Res call({SettingType selectedSettingType});
}

/// @nodoc
class _$SettingTabModelCopyWithImpl<$Res>
    implements $SettingTabModelCopyWith<$Res> {
  _$SettingTabModelCopyWithImpl(this._self, this._then);

  final SettingTabModel _self;
  final $Res Function(SettingTabModel) _then;

  /// Create a copy of SettingTabModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedSettingType = null,
  }) {
    return _then(_self.copyWith(
      selectedSettingType: null == selectedSettingType
          ? _self.selectedSettingType
          : selectedSettingType // ignore: cast_nullable_to_non_nullable
              as SettingType,
    ));
  }
}

/// @nodoc

class _SettingTabModel implements SettingTabModel {
  const _SettingTabModel({required this.selectedSettingType});

  @override
  final SettingType selectedSettingType;

  /// Create a copy of SettingTabModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SettingTabModelCopyWith<_SettingTabModel> get copyWith =>
      __$SettingTabModelCopyWithImpl<_SettingTabModel>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SettingTabModel &&
            (identical(other.selectedSettingType, selectedSettingType) ||
                other.selectedSettingType == selectedSettingType));
  }

  @override
  int get hashCode => Object.hash(runtimeType, selectedSettingType);

  @override
  String toString() {
    return 'SettingTabModel(selectedSettingType: $selectedSettingType)';
  }
}

/// @nodoc
abstract mixin class _$SettingTabModelCopyWith<$Res>
    implements $SettingTabModelCopyWith<$Res> {
  factory _$SettingTabModelCopyWith(
          _SettingTabModel value, $Res Function(_SettingTabModel) _then) =
      __$SettingTabModelCopyWithImpl;
  @override
  @useResult
  $Res call({SettingType selectedSettingType});
}

/// @nodoc
class __$SettingTabModelCopyWithImpl<$Res>
    implements _$SettingTabModelCopyWith<$Res> {
  __$SettingTabModelCopyWithImpl(this._self, this._then);

  final _SettingTabModel _self;
  final $Res Function(_SettingTabModel) _then;

  /// Create a copy of SettingTabModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? selectedSettingType = null,
  }) {
    return _then(_SettingTabModel(
      selectedSettingType: null == selectedSettingType
          ? _self.selectedSettingType
          : selectedSettingType // ignore: cast_nullable_to_non_nullable
              as SettingType,
    ));
  }
}

/// @nodoc
mixin _$SettingModel {
  SettingTabModel get settingTab;
  SystemSettingModel get systemSetting;

  /// Create a copy of SettingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SettingModelCopyWith<SettingModel> get copyWith =>
      _$SettingModelCopyWithImpl<SettingModel>(
          this as SettingModel, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SettingModel &&
            (identical(other.settingTab, settingTab) ||
                other.settingTab == settingTab) &&
            (identical(other.systemSetting, systemSetting) ||
                other.systemSetting == systemSetting));
  }

  @override
  int get hashCode => Object.hash(runtimeType, settingTab, systemSetting);

  @override
  String toString() {
    return 'SettingModel(settingTab: $settingTab, systemSetting: $systemSetting)';
  }
}

/// @nodoc
abstract mixin class $SettingModelCopyWith<$Res> {
  factory $SettingModelCopyWith(
          SettingModel value, $Res Function(SettingModel) _then) =
      _$SettingModelCopyWithImpl;
  @useResult
  $Res call({SettingTabModel settingTab, SystemSettingModel systemSetting});

  $SettingTabModelCopyWith<$Res> get settingTab;
  $SystemSettingModelCopyWith<$Res> get systemSetting;
}

/// @nodoc
class _$SettingModelCopyWithImpl<$Res> implements $SettingModelCopyWith<$Res> {
  _$SettingModelCopyWithImpl(this._self, this._then);

  final SettingModel _self;
  final $Res Function(SettingModel) _then;

  /// Create a copy of SettingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? settingTab = null,
    Object? systemSetting = null,
  }) {
    return _then(_self.copyWith(
      settingTab: null == settingTab
          ? _self.settingTab
          : settingTab // ignore: cast_nullable_to_non_nullable
              as SettingTabModel,
      systemSetting: null == systemSetting
          ? _self.systemSetting
          : systemSetting // ignore: cast_nullable_to_non_nullable
              as SystemSettingModel,
    ));
  }

  /// Create a copy of SettingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SettingTabModelCopyWith<$Res> get settingTab {
    return $SettingTabModelCopyWith<$Res>(_self.settingTab, (value) {
      return _then(_self.copyWith(settingTab: value));
    });
  }

  /// Create a copy of SettingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SystemSettingModelCopyWith<$Res> get systemSetting {
    return $SystemSettingModelCopyWith<$Res>(_self.systemSetting, (value) {
      return _then(_self.copyWith(systemSetting: value));
    });
  }
}

/// @nodoc

class _SettingModel implements SettingModel {
  const _SettingModel({required this.settingTab, required this.systemSetting});

  @override
  final SettingTabModel settingTab;
  @override
  final SystemSettingModel systemSetting;

  /// Create a copy of SettingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SettingModelCopyWith<_SettingModel> get copyWith =>
      __$SettingModelCopyWithImpl<_SettingModel>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SettingModel &&
            (identical(other.settingTab, settingTab) ||
                other.settingTab == settingTab) &&
            (identical(other.systemSetting, systemSetting) ||
                other.systemSetting == systemSetting));
  }

  @override
  int get hashCode => Object.hash(runtimeType, settingTab, systemSetting);

  @override
  String toString() {
    return 'SettingModel(settingTab: $settingTab, systemSetting: $systemSetting)';
  }
}

/// @nodoc
abstract mixin class _$SettingModelCopyWith<$Res>
    implements $SettingModelCopyWith<$Res> {
  factory _$SettingModelCopyWith(
          _SettingModel value, $Res Function(_SettingModel) _then) =
      __$SettingModelCopyWithImpl;
  @override
  @useResult
  $Res call({SettingTabModel settingTab, SystemSettingModel systemSetting});

  @override
  $SettingTabModelCopyWith<$Res> get settingTab;
  @override
  $SystemSettingModelCopyWith<$Res> get systemSetting;
}

/// @nodoc
class __$SettingModelCopyWithImpl<$Res>
    implements _$SettingModelCopyWith<$Res> {
  __$SettingModelCopyWithImpl(this._self, this._then);

  final _SettingModel _self;
  final $Res Function(_SettingModel) _then;

  /// Create a copy of SettingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? settingTab = null,
    Object? systemSetting = null,
  }) {
    return _then(_SettingModel(
      settingTab: null == settingTab
          ? _self.settingTab
          : settingTab // ignore: cast_nullable_to_non_nullable
              as SettingTabModel,
      systemSetting: null == systemSetting
          ? _self.systemSetting
          : systemSetting // ignore: cast_nullable_to_non_nullable
              as SystemSettingModel,
    ));
  }

  /// Create a copy of SettingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SettingTabModelCopyWith<$Res> get settingTab {
    return $SettingTabModelCopyWith<$Res>(_self.settingTab, (value) {
      return _then(_self.copyWith(settingTab: value));
    });
  }

  /// Create a copy of SettingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SystemSettingModelCopyWith<$Res> get systemSetting {
    return $SystemSettingModelCopyWith<$Res>(_self.systemSetting, (value) {
      return _then(_self.copyWith(systemSetting: value));
    });
  }
}

// dart format on
