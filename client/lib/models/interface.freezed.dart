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
mixin _$SessionConnModel implements DiagnosticableTreeMixin {
  SessionConn get conn;

  /// Create a copy of SessionConnModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SessionConnModelCopyWith<SessionConnModel> get copyWith =>
      _$SessionConnModelCopyWithImpl<SessionConnModel>(
          this as SessionConnModel, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionConnModel'))
      ..add(DiagnosticsProperty('conn', conn));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SessionConnModel &&
            (identical(other.conn, conn) || other.conn == conn));
  }

  @override
  int get hashCode => Object.hash(runtimeType, conn);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionConnModel(conn: $conn)';
  }
}

/// @nodoc
abstract mixin class $SessionConnModelCopyWith<$Res> {
  factory $SessionConnModelCopyWith(
          SessionConnModel value, $Res Function(SessionConnModel) _then) =
      _$SessionConnModelCopyWithImpl;
  @useResult
  $Res call({SessionConn conn});
}

/// @nodoc
class _$SessionConnModelCopyWithImpl<$Res>
    implements $SessionConnModelCopyWith<$Res> {
  _$SessionConnModelCopyWithImpl(this._self, this._then);

  final SessionConnModel _self;
  final $Res Function(SessionConnModel) _then;

  /// Create a copy of SessionConnModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conn = null,
  }) {
    return _then(_self.copyWith(
      conn: null == conn
          ? _self.conn
          : conn // ignore: cast_nullable_to_non_nullable
              as SessionConn,
    ));
  }
}

/// @nodoc

class _SessionConnModel
    with DiagnosticableTreeMixin
    implements SessionConnModel {
  const _SessionConnModel({required this.conn});

  @override
  final SessionConn conn;

  /// Create a copy of SessionConnModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SessionConnModelCopyWith<_SessionConnModel> get copyWith =>
      __$SessionConnModelCopyWithImpl<_SessionConnModel>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionConnModel'))
      ..add(DiagnosticsProperty('conn', conn));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SessionConnModel &&
            (identical(other.conn, conn) || other.conn == conn));
  }

  @override
  int get hashCode => Object.hash(runtimeType, conn);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionConnModel(conn: $conn)';
  }
}

/// @nodoc
abstract mixin class _$SessionConnModelCopyWith<$Res>
    implements $SessionConnModelCopyWith<$Res> {
  factory _$SessionConnModelCopyWith(
          _SessionConnModel value, $Res Function(_SessionConnModel) _then) =
      __$SessionConnModelCopyWithImpl;
  @override
  @useResult
  $Res call({SessionConn conn});
}

/// @nodoc
class __$SessionConnModelCopyWithImpl<$Res>
    implements _$SessionConnModelCopyWith<$Res> {
  __$SessionConnModelCopyWithImpl(this._self, this._then);

  final _SessionConnModel _self;
  final $Res Function(_SessionConnModel) _then;

  /// Create a copy of SessionConnModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? conn = null,
  }) {
    return _then(_SessionConnModel(
      conn: null == conn
          ? _self.conn
          : conn // ignore: cast_nullable_to_non_nullable
              as SessionConn,
    ));
  }
}

/// @nodoc
mixin _$CurrentSessionDrawer implements DiagnosticableTreeMixin {
  DrawerPage get drawerPage;
  BaseQueryValue? get sqlResult;
  BaseQueryColumn? get sqlColumn;
  bool get showRecord;
  bool get isRightPageOpen;

  /// Create a copy of CurrentSessionDrawer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CurrentSessionDrawerCopyWith<CurrentSessionDrawer> get copyWith =>
      _$CurrentSessionDrawerCopyWithImpl<CurrentSessionDrawer>(
          this as CurrentSessionDrawer, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CurrentSessionDrawer'))
      ..add(DiagnosticsProperty('drawerPage', drawerPage))
      ..add(DiagnosticsProperty('sqlResult', sqlResult))
      ..add(DiagnosticsProperty('sqlColumn', sqlColumn))
      ..add(DiagnosticsProperty('showRecord', showRecord))
      ..add(DiagnosticsProperty('isRightPageOpen', isRightPageOpen));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CurrentSessionDrawer &&
            (identical(other.drawerPage, drawerPage) ||
                other.drawerPage == drawerPage) &&
            (identical(other.sqlResult, sqlResult) ||
                other.sqlResult == sqlResult) &&
            (identical(other.sqlColumn, sqlColumn) ||
                other.sqlColumn == sqlColumn) &&
            (identical(other.showRecord, showRecord) ||
                other.showRecord == showRecord) &&
            (identical(other.isRightPageOpen, isRightPageOpen) ||
                other.isRightPageOpen == isRightPageOpen));
  }

  @override
  int get hashCode => Object.hash(runtimeType, drawerPage, sqlResult, sqlColumn,
      showRecord, isRightPageOpen);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CurrentSessionDrawer(drawerPage: $drawerPage, sqlResult: $sqlResult, sqlColumn: $sqlColumn, showRecord: $showRecord, isRightPageOpen: $isRightPageOpen)';
  }
}

/// @nodoc
abstract mixin class $CurrentSessionDrawerCopyWith<$Res> {
  factory $CurrentSessionDrawerCopyWith(CurrentSessionDrawer value,
          $Res Function(CurrentSessionDrawer) _then) =
      _$CurrentSessionDrawerCopyWithImpl;
  @useResult
  $Res call(
      {DrawerPage drawerPage,
      BaseQueryValue? sqlResult,
      BaseQueryColumn? sqlColumn,
      bool showRecord,
      bool isRightPageOpen});
}

/// @nodoc
class _$CurrentSessionDrawerCopyWithImpl<$Res>
    implements $CurrentSessionDrawerCopyWith<$Res> {
  _$CurrentSessionDrawerCopyWithImpl(this._self, this._then);

  final CurrentSessionDrawer _self;
  final $Res Function(CurrentSessionDrawer) _then;

  /// Create a copy of CurrentSessionDrawer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? drawerPage = null,
    Object? sqlResult = freezed,
    Object? sqlColumn = freezed,
    Object? showRecord = null,
    Object? isRightPageOpen = null,
  }) {
    return _then(_self.copyWith(
      drawerPage: null == drawerPage
          ? _self.drawerPage
          : drawerPage // ignore: cast_nullable_to_non_nullable
              as DrawerPage,
      sqlResult: freezed == sqlResult
          ? _self.sqlResult
          : sqlResult // ignore: cast_nullable_to_non_nullable
              as BaseQueryValue?,
      sqlColumn: freezed == sqlColumn
          ? _self.sqlColumn
          : sqlColumn // ignore: cast_nullable_to_non_nullable
              as BaseQueryColumn?,
      showRecord: null == showRecord
          ? _self.showRecord
          : showRecord // ignore: cast_nullable_to_non_nullable
              as bool,
      isRightPageOpen: null == isRightPageOpen
          ? _self.isRightPageOpen
          : isRightPageOpen // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _CurrentSessionDrawer
    with DiagnosticableTreeMixin
    implements CurrentSessionDrawer {
  const _CurrentSessionDrawer(
      {required this.drawerPage,
      required this.sqlResult,
      required this.sqlColumn,
      required this.showRecord,
      required this.isRightPageOpen});

  @override
  final DrawerPage drawerPage;
  @override
  final BaseQueryValue? sqlResult;
  @override
  final BaseQueryColumn? sqlColumn;
  @override
  final bool showRecord;
  @override
  final bool isRightPageOpen;

  /// Create a copy of CurrentSessionDrawer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CurrentSessionDrawerCopyWith<_CurrentSessionDrawer> get copyWith =>
      __$CurrentSessionDrawerCopyWithImpl<_CurrentSessionDrawer>(
          this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CurrentSessionDrawer'))
      ..add(DiagnosticsProperty('drawerPage', drawerPage))
      ..add(DiagnosticsProperty('sqlResult', sqlResult))
      ..add(DiagnosticsProperty('sqlColumn', sqlColumn))
      ..add(DiagnosticsProperty('showRecord', showRecord))
      ..add(DiagnosticsProperty('isRightPageOpen', isRightPageOpen));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CurrentSessionDrawer &&
            (identical(other.drawerPage, drawerPage) ||
                other.drawerPage == drawerPage) &&
            (identical(other.sqlResult, sqlResult) ||
                other.sqlResult == sqlResult) &&
            (identical(other.sqlColumn, sqlColumn) ||
                other.sqlColumn == sqlColumn) &&
            (identical(other.showRecord, showRecord) ||
                other.showRecord == showRecord) &&
            (identical(other.isRightPageOpen, isRightPageOpen) ||
                other.isRightPageOpen == isRightPageOpen));
  }

  @override
  int get hashCode => Object.hash(runtimeType, drawerPage, sqlResult, sqlColumn,
      showRecord, isRightPageOpen);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CurrentSessionDrawer(drawerPage: $drawerPage, sqlResult: $sqlResult, sqlColumn: $sqlColumn, showRecord: $showRecord, isRightPageOpen: $isRightPageOpen)';
  }
}

/// @nodoc
abstract mixin class _$CurrentSessionDrawerCopyWith<$Res>
    implements $CurrentSessionDrawerCopyWith<$Res> {
  factory _$CurrentSessionDrawerCopyWith(_CurrentSessionDrawer value,
          $Res Function(_CurrentSessionDrawer) _then) =
      __$CurrentSessionDrawerCopyWithImpl;
  @override
  @useResult
  $Res call(
      {DrawerPage drawerPage,
      BaseQueryValue? sqlResult,
      BaseQueryColumn? sqlColumn,
      bool showRecord,
      bool isRightPageOpen});
}

/// @nodoc
class __$CurrentSessionDrawerCopyWithImpl<$Res>
    implements _$CurrentSessionDrawerCopyWith<$Res> {
  __$CurrentSessionDrawerCopyWithImpl(this._self, this._then);

  final _CurrentSessionDrawer _self;
  final $Res Function(_CurrentSessionDrawer) _then;

  /// Create a copy of CurrentSessionDrawer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? drawerPage = null,
    Object? sqlResult = freezed,
    Object? sqlColumn = freezed,
    Object? showRecord = null,
    Object? isRightPageOpen = null,
  }) {
    return _then(_CurrentSessionDrawer(
      drawerPage: null == drawerPage
          ? _self.drawerPage
          : drawerPage // ignore: cast_nullable_to_non_nullable
              as DrawerPage,
      sqlResult: freezed == sqlResult
          ? _self.sqlResult
          : sqlResult // ignore: cast_nullable_to_non_nullable
              as BaseQueryValue?,
      sqlColumn: freezed == sqlColumn
          ? _self.sqlColumn
          : sqlColumn // ignore: cast_nullable_to_non_nullable
              as BaseQueryColumn?,
      showRecord: null == showRecord
          ? _self.showRecord
          : showRecord // ignore: cast_nullable_to_non_nullable
              as bool,
      isRightPageOpen: null == isRightPageOpen
          ? _self.isRightPageOpen
          : isRightPageOpen // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$CurrentSessionSplitView implements DiagnosticableTreeMixin {
  SplitViewController get multiSplitViewCtrl;
  SplitViewController get metaDataSplitViewCtrl;

  /// Create a copy of CurrentSessionSplitView
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CurrentSessionSplitViewCopyWith<CurrentSessionSplitView> get copyWith =>
      _$CurrentSessionSplitViewCopyWithImpl<CurrentSessionSplitView>(
          this as CurrentSessionSplitView, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CurrentSessionSplitView'))
      ..add(DiagnosticsProperty('multiSplitViewCtrl', multiSplitViewCtrl))
      ..add(
          DiagnosticsProperty('metaDataSplitViewCtrl', metaDataSplitViewCtrl));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CurrentSessionSplitView &&
            (identical(other.multiSplitViewCtrl, multiSplitViewCtrl) ||
                other.multiSplitViewCtrl == multiSplitViewCtrl) &&
            (identical(other.metaDataSplitViewCtrl, metaDataSplitViewCtrl) ||
                other.metaDataSplitViewCtrl == metaDataSplitViewCtrl));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, multiSplitViewCtrl, metaDataSplitViewCtrl);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CurrentSessionSplitView(multiSplitViewCtrl: $multiSplitViewCtrl, metaDataSplitViewCtrl: $metaDataSplitViewCtrl)';
  }
}

/// @nodoc
abstract mixin class $CurrentSessionSplitViewCopyWith<$Res> {
  factory $CurrentSessionSplitViewCopyWith(CurrentSessionSplitView value,
          $Res Function(CurrentSessionSplitView) _then) =
      _$CurrentSessionSplitViewCopyWithImpl;
  @useResult
  $Res call(
      {SplitViewController multiSplitViewCtrl,
      SplitViewController metaDataSplitViewCtrl});
}

/// @nodoc
class _$CurrentSessionSplitViewCopyWithImpl<$Res>
    implements $CurrentSessionSplitViewCopyWith<$Res> {
  _$CurrentSessionSplitViewCopyWithImpl(this._self, this._then);

  final CurrentSessionSplitView _self;
  final $Res Function(CurrentSessionSplitView) _then;

  /// Create a copy of CurrentSessionSplitView
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? multiSplitViewCtrl = null,
    Object? metaDataSplitViewCtrl = null,
  }) {
    return _then(_self.copyWith(
      multiSplitViewCtrl: null == multiSplitViewCtrl
          ? _self.multiSplitViewCtrl
          : multiSplitViewCtrl // ignore: cast_nullable_to_non_nullable
              as SplitViewController,
      metaDataSplitViewCtrl: null == metaDataSplitViewCtrl
          ? _self.metaDataSplitViewCtrl
          : metaDataSplitViewCtrl // ignore: cast_nullable_to_non_nullable
              as SplitViewController,
    ));
  }
}

/// @nodoc

class _CurrentSessionSplitView
    with DiagnosticableTreeMixin
    implements CurrentSessionSplitView {
  const _CurrentSessionSplitView(
      {required this.multiSplitViewCtrl, required this.metaDataSplitViewCtrl});

  @override
  final SplitViewController multiSplitViewCtrl;
  @override
  final SplitViewController metaDataSplitViewCtrl;

  /// Create a copy of CurrentSessionSplitView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CurrentSessionSplitViewCopyWith<_CurrentSessionSplitView> get copyWith =>
      __$CurrentSessionSplitViewCopyWithImpl<_CurrentSessionSplitView>(
          this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CurrentSessionSplitView'))
      ..add(DiagnosticsProperty('multiSplitViewCtrl', multiSplitViewCtrl))
      ..add(
          DiagnosticsProperty('metaDataSplitViewCtrl', metaDataSplitViewCtrl));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CurrentSessionSplitView &&
            (identical(other.multiSplitViewCtrl, multiSplitViewCtrl) ||
                other.multiSplitViewCtrl == multiSplitViewCtrl) &&
            (identical(other.metaDataSplitViewCtrl, metaDataSplitViewCtrl) ||
                other.metaDataSplitViewCtrl == metaDataSplitViewCtrl));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, multiSplitViewCtrl, metaDataSplitViewCtrl);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CurrentSessionSplitView(multiSplitViewCtrl: $multiSplitViewCtrl, metaDataSplitViewCtrl: $metaDataSplitViewCtrl)';
  }
}

/// @nodoc
abstract mixin class _$CurrentSessionSplitViewCopyWith<$Res>
    implements $CurrentSessionSplitViewCopyWith<$Res> {
  factory _$CurrentSessionSplitViewCopyWith(_CurrentSessionSplitView value,
          $Res Function(_CurrentSessionSplitView) _then) =
      __$CurrentSessionSplitViewCopyWithImpl;
  @override
  @useResult
  $Res call(
      {SplitViewController multiSplitViewCtrl,
      SplitViewController metaDataSplitViewCtrl});
}

/// @nodoc
class __$CurrentSessionSplitViewCopyWithImpl<$Res>
    implements _$CurrentSessionSplitViewCopyWith<$Res> {
  __$CurrentSessionSplitViewCopyWithImpl(this._self, this._then);

  final _CurrentSessionSplitView _self;
  final $Res Function(_CurrentSessionSplitView) _then;

  /// Create a copy of CurrentSessionSplitView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? multiSplitViewCtrl = null,
    Object? metaDataSplitViewCtrl = null,
  }) {
    return _then(_CurrentSessionSplitView(
      multiSplitViewCtrl: null == multiSplitViewCtrl
          ? _self.multiSplitViewCtrl
          : multiSplitViewCtrl // ignore: cast_nullable_to_non_nullable
              as SplitViewController,
      metaDataSplitViewCtrl: null == metaDataSplitViewCtrl
          ? _self.metaDataSplitViewCtrl
          : metaDataSplitViewCtrl // ignore: cast_nullable_to_non_nullable
              as SplitViewController,
    ));
  }
}

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

/// @nodoc
mixin _$CurrentSessionEditor implements DiagnosticableTreeMixin {
  CodeLineEditingController get code;

  /// Create a copy of CurrentSessionEditor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CurrentSessionEditorCopyWith<CurrentSessionEditor> get copyWith =>
      _$CurrentSessionEditorCopyWithImpl<CurrentSessionEditor>(
          this as CurrentSessionEditor, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CurrentSessionEditor'))
      ..add(DiagnosticsProperty('code', code));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CurrentSessionEditor &&
            (identical(other.code, code) || other.code == code));
  }

  @override
  int get hashCode => Object.hash(runtimeType, code);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CurrentSessionEditor(code: $code)';
  }
}

/// @nodoc
abstract mixin class $CurrentSessionEditorCopyWith<$Res> {
  factory $CurrentSessionEditorCopyWith(CurrentSessionEditor value,
          $Res Function(CurrentSessionEditor) _then) =
      _$CurrentSessionEditorCopyWithImpl;
  @useResult
  $Res call({CodeLineEditingController code});
}

/// @nodoc
class _$CurrentSessionEditorCopyWithImpl<$Res>
    implements $CurrentSessionEditorCopyWith<$Res> {
  _$CurrentSessionEditorCopyWithImpl(this._self, this._then);

  final CurrentSessionEditor _self;
  final $Res Function(CurrentSessionEditor) _then;

  /// Create a copy of CurrentSessionEditor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
  }) {
    return _then(_self.copyWith(
      code: null == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as CodeLineEditingController,
    ));
  }
}

/// @nodoc

class _CurrentSessionEditor
    with DiagnosticableTreeMixin
    implements CurrentSessionEditor {
  const _CurrentSessionEditor({required this.code});

  @override
  final CodeLineEditingController code;

  /// Create a copy of CurrentSessionEditor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CurrentSessionEditorCopyWith<_CurrentSessionEditor> get copyWith =>
      __$CurrentSessionEditorCopyWithImpl<_CurrentSessionEditor>(
          this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CurrentSessionEditor'))
      ..add(DiagnosticsProperty('code', code));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CurrentSessionEditor &&
            (identical(other.code, code) || other.code == code));
  }

  @override
  int get hashCode => Object.hash(runtimeType, code);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CurrentSessionEditor(code: $code)';
  }
}

/// @nodoc
abstract mixin class _$CurrentSessionEditorCopyWith<$Res>
    implements $CurrentSessionEditorCopyWith<$Res> {
  factory _$CurrentSessionEditorCopyWith(_CurrentSessionEditor value,
          $Res Function(_CurrentSessionEditor) _then) =
      __$CurrentSessionEditorCopyWithImpl;
  @override
  @useResult
  $Res call({CodeLineEditingController code});
}

/// @nodoc
class __$CurrentSessionEditorCopyWithImpl<$Res>
    implements _$CurrentSessionEditorCopyWith<$Res> {
  __$CurrentSessionEditorCopyWithImpl(this._self, this._then);

  final _CurrentSessionEditor _self;
  final $Res Function(_CurrentSessionEditor) _then;

  /// Create a copy of CurrentSessionEditor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? code = null,
  }) {
    return _then(_CurrentSessionEditor(
      code: null == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as CodeLineEditingController,
    ));
  }
}

/// @nodoc
mixin _$SelectedSessionId implements DiagnosticableTreeMixin {
  int get sessionId;
  int? get instanceId;

  /// Create a copy of SelectedSessionId
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SelectedSessionIdCopyWith<SelectedSessionId> get copyWith =>
      _$SelectedSessionIdCopyWithImpl<SelectedSessionId>(
          this as SelectedSessionId, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SelectedSessionId'))
      ..add(DiagnosticsProperty('sessionId', sessionId))
      ..add(DiagnosticsProperty('instanceId', instanceId));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SelectedSessionId &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.instanceId, instanceId) ||
                other.instanceId == instanceId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sessionId, instanceId);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SelectedSessionId(sessionId: $sessionId, instanceId: $instanceId)';
  }
}

/// @nodoc
abstract mixin class $SelectedSessionIdCopyWith<$Res> {
  factory $SelectedSessionIdCopyWith(
          SelectedSessionId value, $Res Function(SelectedSessionId) _then) =
      _$SelectedSessionIdCopyWithImpl;
  @useResult
  $Res call({int sessionId, int? instanceId});
}

/// @nodoc
class _$SelectedSessionIdCopyWithImpl<$Res>
    implements $SelectedSessionIdCopyWith<$Res> {
  _$SelectedSessionIdCopyWithImpl(this._self, this._then);

  final SelectedSessionId _self;
  final $Res Function(SelectedSessionId) _then;

  /// Create a copy of SelectedSessionId
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? instanceId = freezed,
  }) {
    return _then(_self.copyWith(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as int,
      instanceId: freezed == instanceId
          ? _self.instanceId
          : instanceId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _SelectedSessionId
    with DiagnosticableTreeMixin
    implements SelectedSessionId {
  const _SelectedSessionId({required this.sessionId, this.instanceId});

  @override
  final int sessionId;
  @override
  final int? instanceId;

  /// Create a copy of SelectedSessionId
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SelectedSessionIdCopyWith<_SelectedSessionId> get copyWith =>
      __$SelectedSessionIdCopyWithImpl<_SelectedSessionId>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SelectedSessionId'))
      ..add(DiagnosticsProperty('sessionId', sessionId))
      ..add(DiagnosticsProperty('instanceId', instanceId));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SelectedSessionId &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.instanceId, instanceId) ||
                other.instanceId == instanceId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sessionId, instanceId);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SelectedSessionId(sessionId: $sessionId, instanceId: $instanceId)';
  }
}

/// @nodoc
abstract mixin class _$SelectedSessionIdCopyWith<$Res>
    implements $SelectedSessionIdCopyWith<$Res> {
  factory _$SelectedSessionIdCopyWith(
          _SelectedSessionId value, $Res Function(_SelectedSessionId) _then) =
      __$SelectedSessionIdCopyWithImpl;
  @override
  @useResult
  $Res call({int sessionId, int? instanceId});
}

/// @nodoc
class __$SelectedSessionIdCopyWithImpl<$Res>
    implements _$SelectedSessionIdCopyWith<$Res> {
  __$SelectedSessionIdCopyWithImpl(this._self, this._then);

  final _SelectedSessionId _self;
  final $Res Function(_SelectedSessionId) _then;

  /// Create a copy of SelectedSessionId
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? sessionId = null,
    Object? instanceId = freezed,
  }) {
    return _then(_SelectedSessionId(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as int,
      instanceId: freezed == instanceId
          ? _self.instanceId
          : instanceId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
mixin _$SessionTab implements DiagnosticableTreeMixin {
  ReorderSelectedList<SessionStorage> get sessions;

  /// Create a copy of SessionTab
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SessionTabCopyWith<SessionTab> get copyWith =>
      _$SessionTabCopyWithImpl<SessionTab>(this as SessionTab, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionTab'))
      ..add(DiagnosticsProperty('sessions', sessions));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SessionTab &&
            const DeepCollectionEquality().equals(other.sessions, sessions));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(sessions));

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionTab(sessions: $sessions)';
  }
}

/// @nodoc
abstract mixin class $SessionTabCopyWith<$Res> {
  factory $SessionTabCopyWith(
          SessionTab value, $Res Function(SessionTab) _then) =
      _$SessionTabCopyWithImpl;
  @useResult
  $Res call({ReorderSelectedList<SessionStorage> sessions});
}

/// @nodoc
class _$SessionTabCopyWithImpl<$Res> implements $SessionTabCopyWith<$Res> {
  _$SessionTabCopyWithImpl(this._self, this._then);

  final SessionTab _self;
  final $Res Function(SessionTab) _then;

  /// Create a copy of SessionTab
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessions = null,
  }) {
    return _then(_self.copyWith(
      sessions: null == sessions
          ? _self.sessions
          : sessions // ignore: cast_nullable_to_non_nullable
              as ReorderSelectedList<SessionStorage>,
    ));
  }
}

/// @nodoc

class _SessionTab with DiagnosticableTreeMixin implements SessionTab {
  const _SessionTab({required this.sessions});

  @override
  final ReorderSelectedList<SessionStorage> sessions;

  /// Create a copy of SessionTab
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SessionTabCopyWith<_SessionTab> get copyWith =>
      __$SessionTabCopyWithImpl<_SessionTab>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SessionTab'))
      ..add(DiagnosticsProperty('sessions', sessions));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SessionTab &&
            const DeepCollectionEquality().equals(other.sessions, sessions));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(sessions));

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SessionTab(sessions: $sessions)';
  }
}

/// @nodoc
abstract mixin class _$SessionTabCopyWith<$Res>
    implements $SessionTabCopyWith<$Res> {
  factory _$SessionTabCopyWith(
          _SessionTab value, $Res Function(_SessionTab) _then) =
      __$SessionTabCopyWithImpl;
  @override
  @useResult
  $Res call({ReorderSelectedList<SessionStorage> sessions});
}

/// @nodoc
class __$SessionTabCopyWithImpl<$Res> implements _$SessionTabCopyWith<$Res> {
  __$SessionTabCopyWithImpl(this._self, this._then);

  final _SessionTab _self;
  final $Res Function(_SessionTab) _then;

  /// Create a copy of SessionTab
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? sessions = null,
  }) {
    return _then(_SessionTab(
      sessions: null == sessions
          ? _self.sessions
          : sessions // ignore: cast_nullable_to_non_nullable
              as ReorderSelectedList<SessionStorage>,
    ));
  }
}

/// @nodoc
mixin _$SQLResultsModel implements DiagnosticableTreeMixin {
  int get sessionId;
  ReorderSelectedList<SQLResult> get sqlResults;

  /// Create a copy of SQLResultsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SQLResultsModelCopyWith<SQLResultsModel> get copyWith =>
      _$SQLResultsModelCopyWithImpl<SQLResultsModel>(
          this as SQLResultsModel, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SQLResultsModel'))
      ..add(DiagnosticsProperty('sessionId', sessionId))
      ..add(DiagnosticsProperty('sqlResults', sqlResults));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SQLResultsModel &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            const DeepCollectionEquality()
                .equals(other.sqlResults, sqlResults));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, sessionId, const DeepCollectionEquality().hash(sqlResults));

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SQLResultsModel(sessionId: $sessionId, sqlResults: $sqlResults)';
  }
}

/// @nodoc
abstract mixin class $SQLResultsModelCopyWith<$Res> {
  factory $SQLResultsModelCopyWith(
          SQLResultsModel value, $Res Function(SQLResultsModel) _then) =
      _$SQLResultsModelCopyWithImpl;
  @useResult
  $Res call({int sessionId, ReorderSelectedList<SQLResult> sqlResults});
}

/// @nodoc
class _$SQLResultsModelCopyWithImpl<$Res>
    implements $SQLResultsModelCopyWith<$Res> {
  _$SQLResultsModelCopyWithImpl(this._self, this._then);

  final SQLResultsModel _self;
  final $Res Function(SQLResultsModel) _then;

  /// Create a copy of SQLResultsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? sqlResults = null,
  }) {
    return _then(_self.copyWith(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as int,
      sqlResults: null == sqlResults
          ? _self.sqlResults
          : sqlResults // ignore: cast_nullable_to_non_nullable
              as ReorderSelectedList<SQLResult>,
    ));
  }
}

/// @nodoc

class _SQLResultsModel with DiagnosticableTreeMixin implements SQLResultsModel {
  const _SQLResultsModel({required this.sessionId, required this.sqlResults});

  @override
  final int sessionId;
  @override
  final ReorderSelectedList<SQLResult> sqlResults;

  /// Create a copy of SQLResultsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SQLResultsModelCopyWith<_SQLResultsModel> get copyWith =>
      __$SQLResultsModelCopyWithImpl<_SQLResultsModel>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SQLResultsModel'))
      ..add(DiagnosticsProperty('sessionId', sessionId))
      ..add(DiagnosticsProperty('sqlResults', sqlResults));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SQLResultsModel &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            const DeepCollectionEquality()
                .equals(other.sqlResults, sqlResults));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, sessionId, const DeepCollectionEquality().hash(sqlResults));

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SQLResultsModel(sessionId: $sessionId, sqlResults: $sqlResults)';
  }
}

/// @nodoc
abstract mixin class _$SQLResultsModelCopyWith<$Res>
    implements $SQLResultsModelCopyWith<$Res> {
  factory _$SQLResultsModelCopyWith(
          _SQLResultsModel value, $Res Function(_SQLResultsModel) _then) =
      __$SQLResultsModelCopyWithImpl;
  @override
  @useResult
  $Res call({int sessionId, ReorderSelectedList<SQLResult> sqlResults});
}

/// @nodoc
class __$SQLResultsModelCopyWithImpl<$Res>
    implements _$SQLResultsModelCopyWith<$Res> {
  __$SQLResultsModelCopyWithImpl(this._self, this._then);

  final _SQLResultsModel _self;
  final $Res Function(_SQLResultsModel) _then;

  /// Create a copy of SQLResultsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? sessionId = null,
    Object? sqlResults = null,
  }) {
    return _then(_SQLResultsModel(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as int,
      sqlResults: null == sqlResults
          ? _self.sqlResults
          : sqlResults // ignore: cast_nullable_to_non_nullable
              as ReorderSelectedList<SQLResult>,
    ));
  }
}

/// @nodoc
mixin _$SQLResultModel implements DiagnosticableTreeMixin {
  int get sessionId;
  SQLResult get result;

  /// Create a copy of SQLResultModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SQLResultModelCopyWith<SQLResultModel> get copyWith =>
      _$SQLResultModelCopyWithImpl<SQLResultModel>(
          this as SQLResultModel, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SQLResultModel'))
      ..add(DiagnosticsProperty('sessionId', sessionId))
      ..add(DiagnosticsProperty('result', result));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SQLResultModel &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.result, result) || other.result == result));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sessionId, result);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SQLResultModel(sessionId: $sessionId, result: $result)';
  }
}

/// @nodoc
abstract mixin class $SQLResultModelCopyWith<$Res> {
  factory $SQLResultModelCopyWith(
          SQLResultModel value, $Res Function(SQLResultModel) _then) =
      _$SQLResultModelCopyWithImpl;
  @useResult
  $Res call({int sessionId, SQLResult result});
}

/// @nodoc
class _$SQLResultModelCopyWithImpl<$Res>
    implements $SQLResultModelCopyWith<$Res> {
  _$SQLResultModelCopyWithImpl(this._self, this._then);

  final SQLResultModel _self;
  final $Res Function(SQLResultModel) _then;

  /// Create a copy of SQLResultModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? result = null,
  }) {
    return _then(_self.copyWith(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as int,
      result: null == result
          ? _self.result
          : result // ignore: cast_nullable_to_non_nullable
              as SQLResult,
    ));
  }
}

/// @nodoc

class _SQLResultModel with DiagnosticableTreeMixin implements SQLResultModel {
  const _SQLResultModel({required this.sessionId, required this.result});

  @override
  final int sessionId;
  @override
  final SQLResult result;

  /// Create a copy of SQLResultModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SQLResultModelCopyWith<_SQLResultModel> get copyWith =>
      __$SQLResultModelCopyWithImpl<_SQLResultModel>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SQLResultModel'))
      ..add(DiagnosticsProperty('sessionId', sessionId))
      ..add(DiagnosticsProperty('result', result));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SQLResultModel &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.result, result) || other.result == result));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sessionId, result);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SQLResultModel(sessionId: $sessionId, result: $result)';
  }
}

/// @nodoc
abstract mixin class _$SQLResultModelCopyWith<$Res>
    implements $SQLResultModelCopyWith<$Res> {
  factory _$SQLResultModelCopyWith(
          _SQLResultModel value, $Res Function(_SQLResultModel) _then) =
      __$SQLResultModelCopyWithImpl;
  @override
  @useResult
  $Res call({int sessionId, SQLResult result});
}

/// @nodoc
class __$SQLResultModelCopyWithImpl<$Res>
    implements _$SQLResultModelCopyWith<$Res> {
  __$SQLResultModelCopyWithImpl(this._self, this._then);

  final _SQLResultModel _self;
  final $Res Function(_SQLResultModel) _then;

  /// Create a copy of SQLResultModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? sessionId = null,
    Object? result = null,
  }) {
    return _then(_SQLResultModel(
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as int,
      result: null == result
          ? _self.result
          : result // ignore: cast_nullable_to_non_nullable
              as SQLResult,
    ));
  }
}

// dart format on
