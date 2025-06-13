// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'instance_metadata.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InstanceMetadataModel implements DiagnosticableTreeMixin {
  MetaDataNode? get metadata;
  TreeController<DataNode>? get metadataController;

  /// Create a copy of InstanceMetadataModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InstanceMetadataModelCopyWith<InstanceMetadataModel> get copyWith =>
      _$InstanceMetadataModelCopyWithImpl<InstanceMetadataModel>(
          this as InstanceMetadataModel, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'InstanceMetadataModel'))
      ..add(DiagnosticsProperty('metadata', metadata))
      ..add(DiagnosticsProperty('metadataController', metadataController));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InstanceMetadataModel &&
            (identical(other.metadata, metadata) ||
                other.metadata == metadata) &&
            (identical(other.metadataController, metadataController) ||
                other.metadataController == metadataController));
  }

  @override
  int get hashCode => Object.hash(runtimeType, metadata, metadataController);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'InstanceMetadataModel(metadata: $metadata, metadataController: $metadataController)';
  }
}

/// @nodoc
abstract mixin class $InstanceMetadataModelCopyWith<$Res> {
  factory $InstanceMetadataModelCopyWith(InstanceMetadataModel value,
          $Res Function(InstanceMetadataModel) _then) =
      _$InstanceMetadataModelCopyWithImpl;
  @useResult
  $Res call(
      {MetaDataNode? metadata, TreeController<DataNode>? metadataController});
}

/// @nodoc
class _$InstanceMetadataModelCopyWithImpl<$Res>
    implements $InstanceMetadataModelCopyWith<$Res> {
  _$InstanceMetadataModelCopyWithImpl(this._self, this._then);

  final InstanceMetadataModel _self;
  final $Res Function(InstanceMetadataModel) _then;

  /// Create a copy of InstanceMetadataModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? metadata = freezed,
    Object? metadataController = freezed,
  }) {
    return _then(_self.copyWith(
      metadata: freezed == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as MetaDataNode?,
      metadataController: freezed == metadataController
          ? _self.metadataController
          : metadataController // ignore: cast_nullable_to_non_nullable
              as TreeController<DataNode>?,
    ));
  }
}

/// @nodoc

class _InstanceMetadataModel
    with DiagnosticableTreeMixin
    implements InstanceMetadataModel {
  const _InstanceMetadataModel({this.metadata, this.metadataController});

  @override
  final MetaDataNode? metadata;
  @override
  final TreeController<DataNode>? metadataController;

  /// Create a copy of InstanceMetadataModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$InstanceMetadataModelCopyWith<_InstanceMetadataModel> get copyWith =>
      __$InstanceMetadataModelCopyWithImpl<_InstanceMetadataModel>(
          this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'InstanceMetadataModel'))
      ..add(DiagnosticsProperty('metadata', metadata))
      ..add(DiagnosticsProperty('metadataController', metadataController));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _InstanceMetadataModel &&
            (identical(other.metadata, metadata) ||
                other.metadata == metadata) &&
            (identical(other.metadataController, metadataController) ||
                other.metadataController == metadataController));
  }

  @override
  int get hashCode => Object.hash(runtimeType, metadata, metadataController);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'InstanceMetadataModel(metadata: $metadata, metadataController: $metadataController)';
  }
}

/// @nodoc
abstract mixin class _$InstanceMetadataModelCopyWith<$Res>
    implements $InstanceMetadataModelCopyWith<$Res> {
  factory _$InstanceMetadataModelCopyWith(_InstanceMetadataModel value,
          $Res Function(_InstanceMetadataModel) _then) =
      __$InstanceMetadataModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {MetaDataNode? metadata, TreeController<DataNode>? metadataController});
}

/// @nodoc
class __$InstanceMetadataModelCopyWithImpl<$Res>
    implements _$InstanceMetadataModelCopyWith<$Res> {
  __$InstanceMetadataModelCopyWithImpl(this._self, this._then);

  final _InstanceMetadataModel _self;
  final $Res Function(_InstanceMetadataModel) _then;

  /// Create a copy of InstanceMetadataModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? metadata = freezed,
    Object? metadataController = freezed,
  }) {
    return _then(_InstanceMetadataModel(
      metadata: freezed == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as MetaDataNode?,
      metadataController: freezed == metadataController
          ? _self.metadataController
          : metadataController // ignore: cast_nullable_to_non_nullable
              as TreeController<DataNode>?,
    ));
  }
}

// dart format on
