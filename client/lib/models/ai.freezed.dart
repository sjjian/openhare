// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AIChatId {
  int get value;

  /// Create a copy of AIChatId
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AIChatIdCopyWith<AIChatId> get copyWith =>
      _$AIChatIdCopyWithImpl<AIChatId>(this as AIChatId, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AIChatId &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() {
    return 'AIChatId(value: $value)';
  }
}

/// @nodoc
abstract mixin class $AIChatIdCopyWith<$Res> {
  factory $AIChatIdCopyWith(AIChatId value, $Res Function(AIChatId) _then) =
      _$AIChatIdCopyWithImpl;
  @useResult
  $Res call({int value});
}

/// @nodoc
class _$AIChatIdCopyWithImpl<$Res> implements $AIChatIdCopyWith<$Res> {
  _$AIChatIdCopyWithImpl(this._self, this._then);

  final AIChatId _self;
  final $Res Function(AIChatId) _then;

  /// Create a copy of AIChatId
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
  }) {
    return _then(_self.copyWith(
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _AIChatId implements AIChatId {
  const _AIChatId({required this.value});

  @override
  final int value;

  /// Create a copy of AIChatId
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AIChatIdCopyWith<_AIChatId> get copyWith =>
      __$AIChatIdCopyWithImpl<_AIChatId>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AIChatId &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() {
    return 'AIChatId(value: $value)';
  }
}

/// @nodoc
abstract mixin class _$AIChatIdCopyWith<$Res>
    implements $AIChatIdCopyWith<$Res> {
  factory _$AIChatIdCopyWith(_AIChatId value, $Res Function(_AIChatId) _then) =
      __$AIChatIdCopyWithImpl;
  @override
  @useResult
  $Res call({int value});
}

/// @nodoc
class __$AIChatIdCopyWithImpl<$Res> implements _$AIChatIdCopyWith<$Res> {
  __$AIChatIdCopyWithImpl(this._self, this._then);

  final _AIChatId _self;
  final $Res Function(_AIChatId) _then;

  /// Create a copy of AIChatId
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? value = null,
  }) {
    return _then(_AIChatId(
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$AIChatModel {
  AIChatId get id;
  List<AIChatMessageModel>? get systemMessage;
  List<AIChatMessageModel> get messages;
  AIChatState get state;

  /// Create a copy of AIChatModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AIChatModelCopyWith<AIChatModel> get copyWith =>
      _$AIChatModelCopyWithImpl<AIChatModel>(this as AIChatModel, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AIChatModel &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality()
                .equals(other.systemMessage, systemMessage) &&
            const DeepCollectionEquality().equals(other.messages, messages) &&
            (identical(other.state, state) || other.state == state));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      const DeepCollectionEquality().hash(systemMessage),
      const DeepCollectionEquality().hash(messages),
      state);

  @override
  String toString() {
    return 'AIChatModel(id: $id, systemMessage: $systemMessage, messages: $messages, state: $state)';
  }
}

/// @nodoc
abstract mixin class $AIChatModelCopyWith<$Res> {
  factory $AIChatModelCopyWith(
          AIChatModel value, $Res Function(AIChatModel) _then) =
      _$AIChatModelCopyWithImpl;
  @useResult
  $Res call(
      {AIChatId id,
      List<AIChatMessageModel>? systemMessage,
      List<AIChatMessageModel> messages,
      AIChatState state});

  $AIChatIdCopyWith<$Res> get id;
}

/// @nodoc
class _$AIChatModelCopyWithImpl<$Res> implements $AIChatModelCopyWith<$Res> {
  _$AIChatModelCopyWithImpl(this._self, this._then);

  final AIChatModel _self;
  final $Res Function(AIChatModel) _then;

  /// Create a copy of AIChatModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? systemMessage = freezed,
    Object? messages = null,
    Object? state = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as AIChatId,
      systemMessage: freezed == systemMessage
          ? _self.systemMessage
          : systemMessage // ignore: cast_nullable_to_non_nullable
              as List<AIChatMessageModel>?,
      messages: null == messages
          ? _self.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<AIChatMessageModel>,
      state: null == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as AIChatState,
    ));
  }

  /// Create a copy of AIChatModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AIChatIdCopyWith<$Res> get id {
    return $AIChatIdCopyWith<$Res>(_self.id, (value) {
      return _then(_self.copyWith(id: value));
    });
  }
}

/// @nodoc

class _AIChatModel implements AIChatModel {
  const _AIChatModel(
      {required this.id,
      required final List<AIChatMessageModel>? systemMessage,
      required final List<AIChatMessageModel> messages,
      required this.state})
      : _systemMessage = systemMessage,
        _messages = messages;

  @override
  final AIChatId id;
  final List<AIChatMessageModel>? _systemMessage;
  @override
  List<AIChatMessageModel>? get systemMessage {
    final value = _systemMessage;
    if (value == null) return null;
    if (_systemMessage is EqualUnmodifiableListView) return _systemMessage;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<AIChatMessageModel> _messages;
  @override
  List<AIChatMessageModel> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  final AIChatState state;

  /// Create a copy of AIChatModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AIChatModelCopyWith<_AIChatModel> get copyWith =>
      __$AIChatModelCopyWithImpl<_AIChatModel>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AIChatModel &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality()
                .equals(other._systemMessage, _systemMessage) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.state, state) || other.state == state));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      const DeepCollectionEquality().hash(_systemMessage),
      const DeepCollectionEquality().hash(_messages),
      state);

  @override
  String toString() {
    return 'AIChatModel(id: $id, systemMessage: $systemMessage, messages: $messages, state: $state)';
  }
}

/// @nodoc
abstract mixin class _$AIChatModelCopyWith<$Res>
    implements $AIChatModelCopyWith<$Res> {
  factory _$AIChatModelCopyWith(
          _AIChatModel value, $Res Function(_AIChatModel) _then) =
      __$AIChatModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {AIChatId id,
      List<AIChatMessageModel>? systemMessage,
      List<AIChatMessageModel> messages,
      AIChatState state});

  @override
  $AIChatIdCopyWith<$Res> get id;
}

/// @nodoc
class __$AIChatModelCopyWithImpl<$Res> implements _$AIChatModelCopyWith<$Res> {
  __$AIChatModelCopyWithImpl(this._self, this._then);

  final _AIChatModel _self;
  final $Res Function(_AIChatModel) _then;

  /// Create a copy of AIChatModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? systemMessage = freezed,
    Object? messages = null,
    Object? state = null,
  }) {
    return _then(_AIChatModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as AIChatId,
      systemMessage: freezed == systemMessage
          ? _self._systemMessage
          : systemMessage // ignore: cast_nullable_to_non_nullable
              as List<AIChatMessageModel>?,
      messages: null == messages
          ? _self._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<AIChatMessageModel>,
      state: null == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as AIChatState,
    ));
  }

  /// Create a copy of AIChatModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AIChatIdCopyWith<$Res> get id {
    return $AIChatIdCopyWith<$Res>(_self.id, (value) {
      return _then(_self.copyWith(id: value));
    });
  }
}

/// @nodoc
mixin _$AIChatMessageModel {
  AIRole get role;
  String get content;

  /// Create a copy of AIChatMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AIChatMessageModelCopyWith<AIChatMessageModel> get copyWith =>
      _$AIChatMessageModelCopyWithImpl<AIChatMessageModel>(
          this as AIChatMessageModel, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AIChatMessageModel &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content));
  }

  @override
  int get hashCode => Object.hash(runtimeType, role, content);

  @override
  String toString() {
    return 'AIChatMessageModel(role: $role, content: $content)';
  }
}

/// @nodoc
abstract mixin class $AIChatMessageModelCopyWith<$Res> {
  factory $AIChatMessageModelCopyWith(
          AIChatMessageModel value, $Res Function(AIChatMessageModel) _then) =
      _$AIChatMessageModelCopyWithImpl;
  @useResult
  $Res call({AIRole role, String content});
}

/// @nodoc
class _$AIChatMessageModelCopyWithImpl<$Res>
    implements $AIChatMessageModelCopyWith<$Res> {
  _$AIChatMessageModelCopyWithImpl(this._self, this._then);

  final AIChatMessageModel _self;
  final $Res Function(AIChatMessageModel) _then;

  /// Create a copy of AIChatMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
    Object? content = null,
  }) {
    return _then(_self.copyWith(
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as AIRole,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _AIChatMessageModel implements AIChatMessageModel {
  const _AIChatMessageModel({required this.role, required this.content});

  @override
  final AIRole role;
  @override
  final String content;

  /// Create a copy of AIChatMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AIChatMessageModelCopyWith<_AIChatMessageModel> get copyWith =>
      __$AIChatMessageModelCopyWithImpl<_AIChatMessageModel>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AIChatMessageModel &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content));
  }

  @override
  int get hashCode => Object.hash(runtimeType, role, content);

  @override
  String toString() {
    return 'AIChatMessageModel(role: $role, content: $content)';
  }
}

/// @nodoc
abstract mixin class _$AIChatMessageModelCopyWith<$Res>
    implements $AIChatMessageModelCopyWith<$Res> {
  factory _$AIChatMessageModelCopyWith(
          _AIChatMessageModel value, $Res Function(_AIChatMessageModel) _then) =
      __$AIChatMessageModelCopyWithImpl;
  @override
  @useResult
  $Res call({AIRole role, String content});
}

/// @nodoc
class __$AIChatMessageModelCopyWithImpl<$Res>
    implements _$AIChatMessageModelCopyWith<$Res> {
  __$AIChatMessageModelCopyWithImpl(this._self, this._then);

  final _AIChatMessageModel _self;
  final $Res Function(_AIChatMessageModel) _then;

  /// Create a copy of AIChatMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? role = null,
    Object? content = null,
  }) {
    return _then(_AIChatMessageModel(
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as AIRole,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
