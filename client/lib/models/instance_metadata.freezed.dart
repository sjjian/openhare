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
  InstanceId get instanceId;
  MetaDataNode? get metadata;

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
      ..add(DiagnosticsProperty('instanceId', instanceId))
      ..add(DiagnosticsProperty('metadata', metadata));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InstanceMetadataModel &&
            (identical(other.instanceId, instanceId) ||
                other.instanceId == instanceId) &&
            (identical(other.metadata, metadata) ||
                other.metadata == metadata));
  }

  @override
  int get hashCode => Object.hash(runtimeType, instanceId, metadata);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'InstanceMetadataModel(instanceId: $instanceId, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class $InstanceMetadataModelCopyWith<$Res> {
  factory $InstanceMetadataModelCopyWith(InstanceMetadataModel value,
          $Res Function(InstanceMetadataModel) _then) =
      _$InstanceMetadataModelCopyWithImpl;
  @useResult
  $Res call({InstanceId instanceId, MetaDataNode? metadata});

  $InstanceIdCopyWith<$Res> get instanceId;
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
    Object? instanceId = null,
    Object? metadata = freezed,
  }) {
    return _then(_self.copyWith(
      instanceId: null == instanceId
          ? _self.instanceId
          : instanceId // ignore: cast_nullable_to_non_nullable
              as InstanceId,
      metadata: freezed == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as MetaDataNode?,
    ));
  }

  /// Create a copy of InstanceMetadataModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InstanceIdCopyWith<$Res> get instanceId {
    return $InstanceIdCopyWith<$Res>(_self.instanceId, (value) {
      return _then(_self.copyWith(instanceId: value));
    });
  }
}

/// @nodoc

class _InstanceMetadataModel
    with DiagnosticableTreeMixin
    implements InstanceMetadataModel {
  const _InstanceMetadataModel({required this.instanceId, this.metadata});

  @override
  final InstanceId instanceId;
  @override
  final MetaDataNode? metadata;

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
      ..add(DiagnosticsProperty('instanceId', instanceId))
      ..add(DiagnosticsProperty('metadata', metadata));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _InstanceMetadataModel &&
            (identical(other.instanceId, instanceId) ||
                other.instanceId == instanceId) &&
            (identical(other.metadata, metadata) ||
                other.metadata == metadata));
  }

  @override
  int get hashCode => Object.hash(runtimeType, instanceId, metadata);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'InstanceMetadataModel(instanceId: $instanceId, metadata: $metadata)';
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
  $Res call({InstanceId instanceId, MetaDataNode? metadata});

  @override
  $InstanceIdCopyWith<$Res> get instanceId;
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
    Object? instanceId = null,
    Object? metadata = freezed,
  }) {
    return _then(_InstanceMetadataModel(
      instanceId: null == instanceId
          ? _self.instanceId
          : instanceId // ignore: cast_nullable_to_non_nullable
              as InstanceId,
      metadata: freezed == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as MetaDataNode?,
    ));
  }

  /// Create a copy of InstanceMetadataModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InstanceIdCopyWith<$Res> get instanceId {
    return $InstanceIdCopyWith<$Res>(_self.instanceId, (value) {
      return _then(_self.copyWith(instanceId: value));
    });
  }
}

// dart format on
