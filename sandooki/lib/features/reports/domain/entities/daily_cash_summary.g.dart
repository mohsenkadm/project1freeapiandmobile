// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_cash_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyCashSummaryImpl _$$DailyCashSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$DailyCashSummaryImpl(
  date: DateTime.parse(json['date'] as String),
  openingBalance: (json['openingBalance'] as num).toDouble(),
  totalSales: (json['totalSales'] as num).toDouble(),
  totalExpenses: (json['totalExpenses'] as num).toDouble(),
  totalPayments: (json['totalPayments'] as num).toDouble(),
  totalWithdrawals: (json['totalWithdrawals'] as num).toDouble(),
  expectedBalance: (json['expectedBalance'] as num).toDouble(),
  actualBalance: (json['actualBalance'] as num?)?.toDouble(),
  difference: (json['difference'] as num?)?.toDouble(),
);

Map<String, dynamic> _$$DailyCashSummaryImplToJson(
  _$DailyCashSummaryImpl instance,
) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'openingBalance': instance.openingBalance,
  'totalSales': instance.totalSales,
  'totalExpenses': instance.totalExpenses,
  'totalPayments': instance.totalPayments,
  'totalWithdrawals': instance.totalWithdrawals,
  'expectedBalance': instance.expectedBalance,
  'actualBalance': instance.actualBalance,
  'difference': instance.difference,
};
