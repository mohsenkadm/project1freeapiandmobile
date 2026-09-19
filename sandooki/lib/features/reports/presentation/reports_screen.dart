import 'package:fl_chart/fl_chart.dart';
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
import '../../../core/widgets/empty_state.dart';
import '../../reports/domain/entities/daily_cash_summary.dart';
import '../../transactions/domain/entities/transaction.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(dailySummaryProvider);
    final historyAsync = ref.watch(historySummariesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('التقارير')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          120,
        ),
        children: [
          Text('تقرير اليوم', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          todayAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('حدث خطأ، حاول مرة أخرى.'),
            data: (summary) => _TodayReport(summary: summary),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          const SectionTitle(title: 'الأيام السابقة'),
          const SizedBox(height: AppSpacing.md),
          historyAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
            data: (items) {
              final previous = items
                  .where(
                    (s) =>
                        DateFormatter.dayKey(s.date) !=
                        DateFormatter.dayKey(DateTime.now()),
                  )
                  .toList();
              if (previous.isEmpty) {
                return const EmptyState(
                  title: 'ماكو أيام سابقة بعد',
                  subtitle: 'لما تسجّل حركات بأيام ثانية تظهر هنا.',
                  icon: Icons.history_rounded,
                );
              }
              return Column(
                children: [
                  for (var i = 0; i < previous.length; i++)
                    _HistoryDayCard(summary: previous[i])
                        .animate(delay: (40 * i).ms)
                        .fadeIn()
                        .slideY(begin: 0.05),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TodayReport extends StatelessWidget {
  const _TodayReport({required this.summary});

  final DailyCashSummary summary;

  @override
  Widget build(BuildContext context) {
    final totalOut = summary.totalExpenses +
        summary.totalPayments +
        summary.totalWithdrawals;
    final chartTotal = summary.totalSales + totalOut;

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: chartTotal <= 0
              ? AppCard(
                  child: Center(
                    child: Text(
                      'ماكو بيانات كافية للرسم بعد',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                )
              : PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 42,
                    sections: [
                      PieChartSectionData(
                        value: summary.totalSales,
                        color: AppColors.success,
                        title: '',
                        radius: 48,
                      ),
                      PieChartSectionData(
                        value: summary.totalExpenses,
                        color: AppColors.danger,
                        title: '',
                        radius: 48,
                      ),
                      PieChartSectionData(
                        value: summary.totalPayments,
                        color: AppColors.warning,
                        title: '',
                        radius: 48,
                      ),
                      PieChartSectionData(
                        value: summary.totalWithdrawals,
                        color: const Color(0xFFFF8A65),
                        title: '',
                        radius: 48,
                      ),
                    ],
                  ),
                ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
        ),
        const SizedBox(height: AppSpacing.lg),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1.55,
          children: [
            StatCard(
              label: 'إجمالي المبيعات',
              amount: summary.totalSales,
              color: AppColors.success,
              icon: Icons.trending_up_rounded,
            ),
            StatCard(
              label: 'إجمالي المصاريف',
              amount: summary.totalExpenses,
              color: AppColors.danger,
              icon: Icons.shopping_bag_outlined,
            ),
            StatCard(
              label: 'إجمالي السحوبات',
              amount: summary.totalWithdrawals,
              color: const Color(0xFFFF8A65),
              icon: Icons.payments_outlined,
            ),
            StatCard(
              label: 'إجمالي الدفعات',
              amount: summary.totalPayments,
              color: AppColors.warning,
              icon: Icons.swap_horiz_rounded,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AmountCard(
          title: 'الرصيد المتوقع',
          amount: summary.expectedBalance,
          gradient: AppColors.expectedGradient,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الرصيد الفعلي',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      summary.hasCount
                          ? MoneyFormatter.format(summary.actualBalance!)
                          : 'لم يتم الجرد',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('الفرق', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 4),
                  Text(
                    summary.difference == null
                        ? '—'
                        : MoneyFormatter.format(
                            summary.difference!,
                            showSign: true,
                          ),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: summary.difference == null
                              ? AppColors.textSecondary
                              : summary.difference! < 0
                                  ? AppColors.danger
                                  : AppColors.success,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HistoryDayCard extends ConsumerWidget {
  const _HistoryDayCard({required this.summary});

  final DailyCashSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitle = !summary.hasCount
        ? 'بدون جرد'
        : summary.isMatched
            ? 'مطابق ✓'
            : 'فرق الصندوق: ${MoneyFormatter.format(summary.difference!, showSign: true)}';

    final color = !summary.hasCount
        ? AppColors.textSecondary
        : summary.isMatched
            ? AppColors.success
            : summary.isShortage
                ? AppColors.danger
                : AppColors.warning;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      onTap: () {
        ref.read(selectedDateProvider.notifier).state =
            DateFormatter.dateOnly(summary.date);
        context.push('/day-detail');
      },
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormatter.dayMonth(summary.date),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: color)),
              ],
            ),
          ),
          const Icon(Icons.chevron_left_rounded),
        ],
      ),
    );
  }
}

class DayDetailScreen extends ConsumerWidget {
  const DayDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dailySummaryProvider);
    final txsAsync = ref.watch(transactionsForSelectedDateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل اليوم'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const EmptyState(
          title: 'حدث خطأ، حاول مرة أخرى.',
          subtitle: '',
        ),
        data: (summary) => ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Text(
              DateFormatter.fullFriendly(summary.date),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            _TodayReport(summary: summary),
            const SizedBox(height: AppSpacing.xxl),
            const SectionTitle(title: 'الحركات'),
            const SizedBox(height: AppSpacing.md),
            txsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
              data: (txs) {
                if (txs.isEmpty) {
                  return const Text('ماكو حركات بهاليوم.');
                }
                return Column(
                  children: [
                    for (final tx in txs)
                      AppCard(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        padding: EdgeInsets.zero,
                        child: ListTile(
                          title: Text(
                            tx.description.isEmpty
                                ? tx.type.arabicLabel
                                : tx.description,
                          ),
                          subtitle: Text(
                            '${DateFormatter.timeOfDay(tx.createdAt)} • ${tx.type.arabicLabel}',
                          ),
                          trailing: Text(
                            MoneyFormatter.format(
                              tx.type.isIncome ? tx.amount : -tx.amount,
                              showSign: true,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
