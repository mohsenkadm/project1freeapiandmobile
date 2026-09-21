import 'package:freezed_annotation/freezed_annotation.dart';

part 'cash_count.freezed.dart';
part 'cash_count.g.dart';

@freezed
class CashCount with _$CashCount {
  const factory CashCount({
    required String id,
    required DateTime date,
    required double actualBalance,
    required DateTime createdAt,
  }) = _CashCount;

  factory CashCount.fromJson(Map<String, dynamic> json) =>
      _$CashCountFromJson(json);
}
