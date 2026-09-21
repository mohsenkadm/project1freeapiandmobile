import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/qayd_promo_card.dart';
import '../domain/entities/cash_count.dart';

class CashCountScreen extends ConsumerStatefulWidget {
  const CashCountScreen({super.key});

  @override
  ConsumerState<CashCountScreen> createState() => _CashCountScreenState();
}

class _CashCountScreenState extends ConsumerState<CashCountScreen> {
  final _controller = TextEditingController();
  bool _calculated = false;
  double? _actual;
  double? _expected;
  double? _difference;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    final amount = AmountInput.parseAmount(_controller.text);
    if (amount == null || amount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال مبلغ صحيح.')),
      );
      return;
    }

    final summary = ref.read(dailySummaryProvider).asData?.value;
    if (summary == null) return;

    final diffCalc = ref.read(calculateDifferenceProvider);
    final expected = summary.expectedBalance;
    final actual = amount.toDouble();
    final difference = diffCalc(
      actualBalance: actual,
      expectedBalance: expected,
    );

    setState(() {
      _actual = actual;
      _expected = expected;
      _difference = difference;
      _calculated = true;
    });

    HapticFeedback.mediumImpact();
  }

  Future<void> _saveCount() async {
    if (_actual == null) return;
    setState(() => _saving = true);
    try {
      final date = ref.read(selectedDateProvider);
      await ref.read(cashRepositoryProvider).save(
            CashCount(
              id: const Uuid().v4(),
              date: DateFormatter.dateOnly(date),
              actualBalance: _actual!,
              createdAt: DateTime.now(),
            ),
          );
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      ref.invalidate(historySummariesProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ جرد الصندوق')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ، حاول مرة أخرى.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).asData?.value;
    final showPromo =
        _calculated && !(settings?.qaydPromoDismissed ?? false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('جرد نهاية اليوم'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xxxl,
        ),
        children: [
          Text(
            'كم موجود فعلياً بالصندوق؟',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xl),
          AmountInput(
            controller: _controller,
            label: '',
            large: true,
            autofocus: !_calculated,
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: 'احسب الفرق',
            onPressed: _calculate,
            icon: Icons.calculate_rounded,
          ),
          if (_calculated) ...[
            const SizedBox(height: AppSpacing.xxl),
            _ResultBlock(
              expected: _expected!,
              actual: _actual!,
              difference: _difference!,
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: _saving ? 'جارٍ الحفظ...' : 'حفظ الجرد',
              onPressed: _saving ? null : _saveCount,
            ),
            if (showPromo) ...[
              const SizedBox(height: AppSpacing.xl),
              QaydPromoCard(
                onDismiss: () async {
                  final repo = ref.read(settingsRepositoryProvider);
                  final current = await repo.get();
                  await repo.save(
                    current.copyWith(qaydPromoDismissed: true),
                  );
                },
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _ResultBlock extends StatelessWidget {
  const _ResultBlock({
    required this.expected,
    required this.actual,
    required this.difference,
  });

  final double expected;
  final double actual;
  final double difference;

  @override
  Widget build(BuildContext context) {
    final matched = difference.abs() < 0.0001;
    final shortage = difference < 0;
    final color = matched
        ? AppColors.success
        : shortage
            ? AppColors.danger
            : AppColors.warning;
    final title = matched
        ? 'الصندوق مطابق'
        : shortage
            ? 'يوجد فرق في الصندوق'
            : 'يوجد فائض';
    final body = matched
        ? 'المبلغ المتوقع يطابق المبلغ الفعلي.'
        : shortage
            ? 'يوجد نقص قدره ${MoneyFormatter.format(difference.abs())}'
            : 'يوجد فائض قدره ${MoneyFormatter.format(difference.abs())}';

    return Column(
      children: [
        AppCard(
          child: Column(
            children: [
              Icon(
                matched
                    ? Icons.check_circle_rounded
                    : shortage
                        ? Icons.error_rounded
                        : Icons.trending_up_rounded,
                color: color,
                size: 56,
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
              const SizedBox(height: AppSpacing.md),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                body,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ).animate().fadeIn(),
        const SizedBox(height: AppSpacing.lg),
        _Line(label: 'المتوقع', value: expected)
            .animate()
            .fadeIn(delay: 120.ms)
            .slideX(begin: 0.05),
        _Line(label: 'الفعلي', value: actual)
            .animate()
            .fadeIn(delay: 220.ms)
            .slideX(begin: 0.05),
        _Line(
          label: 'الفرق',
          value: difference,
          emphasize: true,
          color: color,
          showSign: true,
        ).animate().fadeIn(delay: 320.ms).slideX(begin: 0.05),
        if (!matched) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            'راجع الحركات المسجلة اليوم لمعرفة السبب.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.color,
    this.showSign = false,
  });

  final String label;
  final double value;
  final bool emphasize;
  final Color? color;
  final bool showSign;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            MoneyFormatter.format(value, showSign: showSign),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
