import 'package:flutter/material.dart';

import '../utils/money_formatter.dart';

/// Count-up animation for financial amounts.
class AnimatedAmount extends StatelessWidget {
  const AnimatedAmount({
    super.key,
    required this.amount,
    this.style,
    this.duration = const Duration(milliseconds: 700),
    this.showSign = false,
    this.suffix,
  });

  final double amount;
  final TextStyle? style;
  final Duration duration;
  final bool showSign;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: amount),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Text(
          MoneyFormatter.format(value, showSign: showSign, suffix: suffix ?? 'د.ع'),
          style: style,
        );
      },
    );
  }
}
