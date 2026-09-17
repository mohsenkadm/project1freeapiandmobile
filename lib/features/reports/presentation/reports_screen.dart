import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../domain/entities/reports_summary.dart';

final reportsSummaryProvider = StreamProvider<ReportsSummary>((ref) {
  return ref.watch(reportsRepositoryProvider).watchSummary();
});

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(reportsSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reports)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.errorGeneric)),
        data: (summary) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              SoftCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.totalDebts,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    AnimatedMoneyText(
                      amount: summary.totalDebtsRemaining,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.debt,
                              ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, _) {
                                  final labels = [
                                    l10n.totalDebts,
                                    l10n.totalPayments,
                                    l10n.todaysPayments,
                                  ];
                                  final i = value.toInt();
                                  if (i < 0 || i >= labels.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      labels[i],
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: summary.totalDebtsRemaining
                                      .toDouble()
                                      .clamp(1, double.infinity),
                                  color: AppColors.debt,
                                  width: 22,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  toY: summary.totalPayments
                                      .toDouble()
                                      .clamp(1, double.infinity),
                                  color: AppColors.success,
                                  width: 22,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 2,
                              barRods: [
                                BarChartRodData(
                                  toY: summary.todaysPaymentsAmount
                                      .toDouble()
                                      .clamp(1, double.infinity),
                                  color: AppColors.primary,
                                  width: 22,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SoftCard(
                      child: _Stat(
                        label: l10n.debtorCustomers,
                        value: '${summary.debtorCustomerCount}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SoftCard(
                      child: _Stat(
                        label: l10n.overdueDebts,
                        value: '${summary.overdueDebtCount}',
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SoftCard(
                child: _Stat(
                  label: l10n.todaysPayments,
                  value:
                      '${summary.todaysPaymentsCount} · ${MoneyFormatter.format(summary.todaysPaymentsAmount)}',
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.topDebtors,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              if (summary.topDebtors.isEmpty)
                SoftCard(child: Text(l10n.emptyDebtsTitle))
              else
                ...summary.topDebtors.asMap().entries.map((entry) {
                  final i = entry.key;
                  final debtor = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SoftCard(
                      onTap: () =>
                          context.push('/customers/${debtor.customerId}'),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                AppColors.debt.withValues(alpha: 0.12),
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(
                                color: AppColors.debt,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              debtor.customerName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Text(
                            MoneyFormatter.format(debtor.remaining),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.debt,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: (40 * i).ms),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: color,
              ),
        ),
      ],
    );
  }
}
