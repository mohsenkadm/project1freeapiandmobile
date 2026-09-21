// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_count.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CashCountImpl _$$CashCountImplFromJson(Map<String, dynamic> json) =>
    _$CashCountImpl(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      actualBalance: (json['actualBalance'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$CashCountImplToJson(_$CashCountImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'actualBalance': instance.actualBalance,
      'createdAt': instance.createdAt.toIso8601String(),
    };
