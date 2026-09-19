import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/amount_card.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/bottom_action_sheet.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/qayd_promo_card.dart';
import '../../reports/domain/entities/daily_cash_summary.dart';
import '../../transactions/domain/entities/transaction.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dailySummaryProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final txsAsync = ref.watch(transactionsForSelectedDateProvider);

    return Scaffold(
      body: SafeArea(
        child: summaryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => EmptyState(
            title: 'حدث خطأ، حاول مرة أخرى.',
            subtitle: 'ما كدرنا نحمّل بيانات الصندوق.',
            actionLabel: 'إعادة المحاولة',
            onAction: () => ref.invalidate(dailySummaryProvider),
          ),
          data: (summary) {
            final settings = settingsAsync.asData?.value;
            final showPromo = summary.hasCount &&
                !(settings?.qaydPromoDismissed ?? false);

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(transactionsForSelectedDateProvider);
                ref.invalidate(cashCountForSelectedDateProvider);
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  120,
                ),
                children: [
                  Text(
                    DateFormatter.greeting(DateTime.now()),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ).animate().fadeIn().slideY(begin: 0.08),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'خلّينا نراجع صندوقك اليوم',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _DateSelector(
                    date: selectedDate,
                    onPick: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 1)),
                      );
                      if (picked != null) {
                        ref.read(selectedDateProvider.notifier).state =
                            DateFormatter.dateOnly(picked);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AmountCard(
                    title: 'الرصيد المتوقع',
                    amount: summary.expectedBalance,
                    subtitle: 'حسب الحركات المسجلة',
                    large: true,
                    gradient: AppColors.expectedGradient,
                  ).animate().fadeIn().scale(begin: const Offset(0.98, 0.98)),
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الرصيد الفعلي',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        if (summary.hasCount) ...[
                          Text(
                            MoneyFormatter.format(summary.actualBalance!),
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            summary.isMatched
                                ? 'الصندوق مطابق ✓'
                                : summary.isShortage
                                    ? 'يوجد نقص ${MoneyFormatter.format(summary.difference!.abs())}'
                                    : 'يوجد فائض ${MoneyFormatter.format(summary.difference!.abs())}',
                            style: TextStyle(
                              color: summary.isMatched
                                  ? AppColors.success
                                  : summary.isShortage
                                      ? AppColors.danger
                                      : AppColors.warning,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          OutlinedButton(
                            onPressed: () => context.push('/cash-count'),
                            child: const Text('إعادة الجرد'),
                          ),
                        ] else ...[
                          Text(
                            'لم يتم الجرد بعد',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          PrimaryButton(
                            label: 'ابدأ جرد الصندوق',
                            icon: Icons.fact_check_rounded,
                            onPressed: () => context.push('/cash-count'),
                          ),
                        ],
                      ],
                    ),
                  ).animate().fadeIn(delay: 80.ms),
                  const SizedBox(height: AppSpacing.xxl),
                  const SectionTitle(title: 'إجراءات سريعة'),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickAction(
                          label: 'مبيعات',
                          icon: Icons.add_rounded,
                          color: AppColors.success,
                          onTap: () => showTransactionSheet(
                            context,
                            type: TransactionType.sale,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _QuickAction(
                          label: 'مصروف',
                          icon: Icons.remove_rounded,
                          color: AppColors.danger,
                          onTap: () => showTransactionSheet(
                            context,
                            type: TransactionType.expense,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickAction(
                          label: 'دفعة',
                          icon: Icons.swap_horiz_rounded,
                          color: AppColors.warning,
                          onTap: () => showTransactionSheet(
                            context,
                            type: TransactionType.payment,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _QuickAction(
                          label: 'سحب',
                          icon: Icons.payments_outlined,
                          color: const Color(0xFFFF8A65),
                          onTap: () => showTransactionSheet(
                            context,
                            type: TransactionType.withdrawal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  SectionTitle(
                    title: 'آخر الحركات',
                    trailing: TextButton(
                      onPressed: () => context.go('/transactions'),
                      child: const Text('الكل'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  txsAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (txs) {
                      if (txs.isEmpty) {
                        return EmptyState(
                          title: 'لسه ما سجلت أي حركة اليوم 👋',
                          subtitle:
                              'ابدأ بأول حركة حتى نعرف وين تروح فلوسك.',
                          actionLabel: 'إضافة حركة',
                          onAction: () => showTransactionSheet(
                            context,
                            type: TransactionType.sale,
                          ),
                        );
                      }
                      return Column(
                        children: [
                          for (var i = 0; i < txs.take(4).length; i++)
                            AppCard(
                              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                              padding: EdgeInsets.zero,
                              child: ListTile(
                                title: Text(
                                  txs[i].description.isEmpty
                                      ? txs[i].type.arabicLabel
                                      : txs[i].description,
                                ),
                                subtitle: Text(txs[i].type.arabicLabel),
                                trailing: Text(
                                  MoneyFormatter.format(
                                    txs[i].type.isIncome
                                        ? txs[i].amount
                                        : -txs[i].amount,
                                    showSign: true,
                                  ),
                                  style: TextStyle(
                                    color: txs[i].type.isIncome
                                        ? AppColors.success
                                        : AppColors.danger,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ).animate(delay: (40 * i).ms).fadeIn().slideX(begin: 0.04),
                        ],
                      );
                    },
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
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({required this.date, required this.onPick});

  final DateTime date;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onPick,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              DateFormatter.fullFriendly(date),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Icon(Icons.expand_more_rounded),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(label, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}
