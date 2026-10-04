import 'package:flutter/material.dart';

import '../utils/money_formatter.dart';

/// Smoothly animates numeric money/percent values.
class AnimatedMoney extends StatelessWidget {
  const AnimatedMoney({
    super.key,
    required this.value,
    this.style,
    this.currencySuffix,
    this.withCurrency = true,
    this.asPercent = false,
    this.duration = const Duration(milliseconds: 420),
  });

  final double value;
  final TextStyle? style;
  final String? currencySuffix;
  final bool withCurrency;
  final bool asPercent;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) {
        final text = asPercent
            ? MoneyFormatter.percent(animated)
            : MoneyFormatter.format(
                animated,
                currencySuffix: currencySuffix,
                withCurrency: withCurrency,
              );
        return Text(
          text,
          style: style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
