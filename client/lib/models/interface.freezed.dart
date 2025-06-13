// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'interface.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CurrentSessionMetadata implements DiagnosticableTreeMixin {
  MetaDataNode? get metadata;
  TreeController<DataNode>? get metadataController;

  /// Create a copy of CurrentSessionMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CurrentSessionMetadataCopyWith<CurrentSessionMetadata> get copyWith =>
      _$CurrentSessionMetadataCopyWithImpl<CurrentSessionMetadata>(
          this as CurrentSessionMetadata, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CurrentSessionMetadata'))
      ..add(DiagnosticsProperty('metadata', metadata))
      ..add(DiagnosticsProperty('metadataController', metadataController));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CurrentSessionMetadata &&
            (identical(other.metadata, metadata) ||
                other.metadata == metadata) &&
            (identical(other.metadataController, metadataController) ||
                other.metadataController == metadataController));
  }

  @override
  int get hashCode => Object.hash(runtimeType, metadata, metadataController);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CurrentSessionMetadata(metadata: $metadata, metadataController: $metadataController)';
  }
}

/// @nodoc
abstract mixin class $CurrentSessionMetadataCopyWith<$Res> {
  factory $CurrentSessionMetadataCopyWith(CurrentSessionMetadata value,
          $Res Function(CurrentSessionMetadata) _then) =
      _$CurrentSessionMetadataCopyWithImpl;
  @useResult
  $Res call(
      {MetaDataNode? metadata, TreeController<DataNode>? metadataController});
}

/// @nodoc
class _$CurrentSessionMetadataCopyWithImpl<$Res>
    implements $CurrentSessionMetadataCopyWith<$Res> {
  _$CurrentSessionMetadataCopyWithImpl(this._self, this._then);

  final CurrentSessionMetadata _self;
  final $Res Function(CurrentSessionMetadata) _then;

  /// Create a copy of CurrentSessionMetadata
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

class _CurrentSessionMetadata
    with DiagnosticableTreeMixin
    implements CurrentSessionMetadata {
  const _CurrentSessionMetadata({this.metadata, this.metadataController});

  @override
  final MetaDataNode? metadata;
  @override
  final TreeController<DataNode>? metadataController;

  /// Create a copy of CurrentSessionMetadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CurrentSessionMetadataCopyWith<_CurrentSessionMetadata> get copyWith =>
      __$CurrentSessionMetadataCopyWithImpl<_CurrentSessionMetadata>(
          this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CurrentSessionMetadata'))
      ..add(DiagnosticsProperty('metadata', metadata))
      ..add(DiagnosticsProperty('metadataController', metadataController));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CurrentSessionMetadata &&
            (identical(other.metadata, metadata) ||
                other.metadata == metadata) &&
            (identical(other.metadataController, metadataController) ||
                other.metadataController == metadataController));
  }

  @override
  int get hashCode => Object.hash(runtimeType, metadata, metadataController);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CurrentSessionMetadata(metadata: $metadata, metadataController: $metadataController)';
  }
}

/// @nodoc
abstract mixin class _$CurrentSessionMetadataCopyWith<$Res>
    implements $CurrentSessionMetadataCopyWith<$Res> {
  factory _$CurrentSessionMetadataCopyWith(_CurrentSessionMetadata value,
          $Res Function(_CurrentSessionMetadata) _then) =
      __$CurrentSessionMetadataCopyWithImpl;
  @override
  @useResult
  $Res call(
      {MetaDataNode? metadata, TreeController<DataNode>? metadataController});
}

/// @nodoc
class __$CurrentSessionMetadataCopyWithImpl<$Res>
    implements _$CurrentSessionMetadataCopyWith<$Res> {
  __$CurrentSessionMetadataCopyWithImpl(this._self, this._then);

  final _CurrentSessionMetadata _self;
  final $Res Function(_CurrentSessionMetadata) _then;

  /// Create a copy of CurrentSessionMetadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? metadata = freezed,
    Object? metadataController = freezed,
  }) {
    return _then(_CurrentSessionMetadata(
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
