import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../orders/domain/entities/order.dart';
import '../../orders/domain/entities/order_status.dart';
import '../../orders/domain/repositories/order_repository.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);
    final customersAsync = ref.watch(customersProvider);
    final computeCustomer = ref.watch(computeCustomerTotalsProvider);
    final computeProducts = ref.watch(computeProductOrderCountsProvider);
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (orders) {
          if (orders.isEmpty) {
            return const EmptyState(
              title: 'ماكو بيانات تقارير بعد',
              subtitle: 'أنشئ طلبات لتظهر قيمة الطلبات هنا.',
              icon: Icons.bar_chart_rounded,
            );
          }

          final now = DateTime.now();
          final today = orders.forDay(now);
          final weekStart = now.subtract(Duration(days: now.weekday % 7));
          final week = orders
              .where((o) => o.createdAt.isAfter(
                    DateTime(weekStart.year, weekStart.month, weekStart.day),
                  ))
              .toList();
          final month = orders
              .where((o) =>
                  o.createdAt.year == now.year && o.createdAt.month == now.month)
              .toList();

          final delivered =
              orders.where((o) => o.status == OrderStatus.delivered).length;
          final cancelled =
              orders.where((o) => o.status == OrderStatus.cancelled).length;

          final productCounts = computeProducts(orders);
          final products = productsAsync.asData?.value ?? [];
          final topProducts = productCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final customers = customersAsync.asData?.value ?? [];
          final topCustomers = customers
              .map((c) => MapEntry(c, computeCustomer(orders, c.id)))
              .where((e) => e.value.orderCount > 0)
              .toList()
            ..sort(
              (a, b) => b.value.totalValue.compareTo(a.value.totalValue),
            );

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              _sectionTitle(context, 'ملخص سريع'),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  _metric(context, 'طلبات اليوم', '${today.length}'),
                  _metric(
                    context,
                    'قيمة اليوم',
                    MoneyFormatter.format(today.totalValue),
                  ),
                  _metric(context, 'طلبات الأسبوع', '${week.length}'),
                  _metric(
                    context,
                    'قيمة الأسبوع',
                    MoneyFormatter.format(week.totalValue),
                  ),
                  _metric(context, 'طلبات الشهر', '${month.length}'),
                  _metric(
                    context,
                    'قيمة الشهر',
                    MoneyFormatter.format(month.totalValue),
                  ),
                  _metric(context, 'مكتملة', '$delivered'),
                  _metric(context, 'ملغاة', '$cancelled'),
                ],
              ).animate().fadeIn(),
              const SizedBox(height: AppSpacing.xl),
              _sectionTitle(context, 'قيمة الطلبات آخر 7 أيام'),
              AppCard(
                child: SizedBox(
                  height: 220,
                  child: _OrdersChart(orders: orders),
                ),
              ).animate().fadeIn().slideY(begin: 0.06),
              const SizedBox(height: AppSpacing.xl),
              _sectionTitle(context, 'الأكثر طلباً'),
              AppCard(
                child: Column(
                  children: [
                    if (topProducts.isEmpty)
                      const Text('لا توجد بيانات بعد')
                    else
                      ...topProducts.take(5).map((e) {
                        final name = products
                            .where((p) => p.id == e.key)
                            .map((p) => p.name)
                            .firstOrNull;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(name ?? e.key),
                          trailing: Text('${e.value} مرة'),
                        );
                      }),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _sectionTitle(context, 'أفضل الزبائن'),
              AppCard(
                child: Column(
                  children: [
                    if (topCustomers.isEmpty)
                      const Text('لا توجد بيانات بعد')
                    else
                      ...topCustomers.take(5).map((e) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(e.key.name),
                          subtitle: Text('${e.value.orderCount} طلب'),
                          trailing: Text(
                            MoneyFormatter.format(e.value.totalValue),
                          ),
                        );
                      }),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _sectionTitle(context, 'الطلبات الملغاة'),
              AppCard(
                child: Text(
                  cancelled == 0
                      ? 'لا توجد طلبات ملغاة.'
                      : 'عدد الطلبات الملغاة: $cancelled',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'هذه تقارير تشغيلية لقيمة الطلبات وليست أرباحاً محاسبية.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _metric(BuildContext context, String label, String value) {
    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 52) / 2,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _OrdersChart extends StatelessWidget {
  const _OrdersChart({required this.orders});

  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (i) {
      final day = DateTime.now().subtract(Duration(days: 6 - i));
      return DateTime(day.year, day.month, day.day);
    });
    final values = days
        .map((d) => orders
            .where((o) =>
                o.createdAt.year == d.year &&
                o.createdAt.month == d.month &&
                o.createdAt.day == d.day)
            .fold<double>(0, (s, o) => s + o.total))
        .toList();
    final maxY = values.fold<double>(0, (m, v) => v > m ? v : m);
    return BarChart(
      BarChartData(
        maxY: maxY == 0 ? 1 : maxY * 1.2,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= days.length) return const SizedBox.shrink();
                return Text(
                  '${days[i].day}',
                  style: const TextStyle(fontSize: 11),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < values.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i],
                  color: AppColors.primary,
                  width: 14,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
