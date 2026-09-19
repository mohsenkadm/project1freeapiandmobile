// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cash_count.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CashCount _$CashCountFromJson(Map<String, dynamic> json) {
  return _CashCount.fromJson(json);
}

/// @nodoc
mixin _$CashCount {
  String get id => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  double get actualBalance => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CashCount to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CashCount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CashCountCopyWith<CashCount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CashCountCopyWith<$Res> {
  factory $CashCountCopyWith(CashCount value, $Res Function(CashCount) then) =
      _$CashCountCopyWithImpl<$Res, CashCount>;
  @useResult
  $Res call({
    String id,
    DateTime date,
    double actualBalance,
    DateTime createdAt,
  });
}

/// @nodoc
class _$CashCountCopyWithImpl<$Res, $Val extends CashCount>
    implements $CashCountCopyWith<$Res> {
  _$CashCountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CashCount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? actualBalance = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            actualBalance: null == actualBalance
                ? _value.actualBalance
                : actualBalance // ignore: cast_nullable_to_non_nullable
                      as double,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CashCountImplCopyWith<$Res>
    implements $CashCountCopyWith<$Res> {
  factory _$$CashCountImplCopyWith(
    _$CashCountImpl value,
    $Res Function(_$CashCountImpl) then,
  ) = __$$CashCountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    DateTime date,
    double actualBalance,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$CashCountImplCopyWithImpl<$Res>
    extends _$CashCountCopyWithImpl<$Res, _$CashCountImpl>
    implements _$$CashCountImplCopyWith<$Res> {
  __$$CashCountImplCopyWithImpl(
    _$CashCountImpl _value,
    $Res Function(_$CashCountImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CashCount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? actualBalance = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$CashCountImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        actualBalance: null == actualBalance
            ? _value.actualBalance
            : actualBalance // ignore: cast_nullable_to_non_nullable
                  as double,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CashCountImpl implements _CashCount {
  const _$CashCountImpl({
    required this.id,
    required this.date,
    required this.actualBalance,
    required this.createdAt,
  });

  factory _$CashCountImpl.fromJson(Map<String, dynamic> json) =>
      _$$CashCountImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime date;
  @override
  final double actualBalance;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'CashCount(id: $id, date: $date, actualBalance: $actualBalance, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CashCountImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.actualBalance, actualBalance) ||
                other.actualBalance == actualBalance) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, date, actualBalance, createdAt);

  /// Create a copy of CashCount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CashCountImplCopyWith<_$CashCountImpl> get copyWith =>
      __$$CashCountImplCopyWithImpl<_$CashCountImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CashCountImplToJson(this);
  }
}

abstract class _CashCount implements CashCount {
  const factory _CashCount({
    required final String id,
    required final DateTime date,
    required final double actualBalance,
    required final DateTime createdAt,
  }) = _$CashCountImpl;

  factory _CashCount.fromJson(Map<String, dynamic> json) =
      _$CashCountImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get date;
  @override
  double get actualBalance;
  @override
  DateTime get createdAt;

  /// Create a copy of CashCount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CashCountImplCopyWith<_$CashCountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
