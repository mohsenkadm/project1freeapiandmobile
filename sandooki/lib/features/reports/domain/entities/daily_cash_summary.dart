import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_cash_summary.freezed.dart';
part 'daily_cash_summary.g.dart';

@freezed
class DailyCashSummary with _$DailyCashSummary {
  const factory DailyCashSummary({
    required DateTime date,
    required double openingBalance,
    required double totalSales,
    required double totalExpenses,
    required double totalPayments,
    required double totalWithdrawals,
    required double expectedBalance,
    double? actualBalance,
    double? difference,
  }) = _DailyCashSummary;

  factory DailyCashSummary.fromJson(Map<String, dynamic> json) =>
      _$DailyCashSummaryFromJson(json);
}

extension DailyCashSummaryX on DailyCashSummary {
  bool get hasCount => actualBalance != null;

  bool get isMatched =>
      hasCount && difference != null && difference!.abs() < 0.0001;

  bool get isShortage => hasCount && (difference ?? 0) < 0;

  bool get isSurplus => hasCount && (difference ?? 0) > 0;
}
