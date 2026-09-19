import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_spacing.dart';
import '../utils/money_formatter.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.prefix,
    this.inputFormatters,
    this.onChanged,
    this.textAlign = TextAlign.start,
    this.style,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final Widget? prefix;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final TextAlign textAlign;
  final TextStyle? style;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          textAlign: textAlign,
          style: style,
          autofocus: autofocus,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefix,
          ),
        ),
      ],
    );
  }
}

class AmountInput extends StatelessWidget {
  const AmountInput({
    super.key,
    required this.controller,
    this.label = 'المبلغ',
    this.autofocus = false,
    this.large = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final bool autofocus;
  final bool large;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      hint: '0',
      autofocus: autofocus,
      keyboardType: TextInputType.number,
      textAlign: large ? TextAlign.center : TextAlign.start,
      style: large
          ? Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
              )
          : null,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _ThousandsSeparatorFormatter(),
      ],
      onChanged: onChanged,
    );
  }

  static int? parseAmount(String text) => MoneyFormatter.parse(text);
}

class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) {
      return newValue.copyWith(text: '');
    }
    final number = int.parse(digits);
    final formatted = MoneyFormatter.format(number, suffix: '').trim();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
