import 'package:equatable/equatable.dart';

class CustomerStatement extends Equatable {
  const CustomerStatement({
    required this.customerName,
    required this.totalDebt,
    required this.paid,
    required this.remaining,
    this.lastPaymentAmount,
  });

  final String customerName;
  final int totalDebt;
  final int paid;
  final int remaining;
  final int? lastPaymentAmount;

  String toShareText() {
    final buffer = StringBuffer()
      ..writeln('كشف حساب الزبون')
      ..writeln('الاسم: $customerName')
      ..writeln('إجمالي الدين: ${_fmt(totalDebt)}')
      ..writeln('المدفوع: ${_fmt(paid)}')
      ..writeln('المتبقي: ${_fmt(remaining)}');
    if (lastPaymentAmount != null) {
      buffer.writeln('آخر دفعة: ${_fmt(lastPaymentAmount!)}');
    }
    buffer.writeln('شكراً لتعاملك معنا.');
    return buffer.toString();
  }

  static String _fmt(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final fromEnd = s.length - i;
      buf.write(s[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(',');
    }
    return '$buf د.ع';
  }

  @override
  List<Object?> get props =>
      [customerName, totalDebt, paid, remaining, lastPaymentAmount];
}
