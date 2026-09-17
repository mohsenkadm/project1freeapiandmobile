import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../domain/entities/customer.dart';
import '../domain/entities/customer_balance.dart';
import '../domain/entities/timeline_entry.dart';

final customerDetailProvider =
    StreamProvider.autoDispose.family<Customer?, String>((ref, id) {
  return ref.watch(customerRepositoryProvider).watchById(id);
});

final customerBalanceProvider =
    StreamProvider.autoDispose.family<CustomerBalance, String>((ref, id) {
  // Re-read when customers stream updates (debts/payments bump updatedAt)
  return ref.watch(customerRepositoryProvider).watchById(id).asyncMap((_) {
    return ref.read(customerRepositoryProvider).getBalance(id);
  });
});

final customerTimelineProvider =
    StreamProvider.autoDispose.family<List<TimelineEntry>, String>((ref, id) {
  return ref.watch(customerRepositoryProvider).watchTimeline(id);
});

class CustomerDetailScreen extends ConsumerWidget {
  const CustomerDetailScreen({super.key, required this.customerId});

  final String customerId;

  Future<void> _shareStatement(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final statement =
          await ref.read(buildStatementProvider).call(customerId);
      await SharePlus.instance.share(
        ShareParams(text: statement.toShareText()),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorGeneric)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final customerAsync = ref.watch(customerDetailProvider(customerId));
    final balanceAsync = ref.watch(customerBalanceProvider(customerId));
    final timelineAsync = ref.watch(customerTimelineProvider(customerId));

    return Scaffold(
      appBar: AppBar(
        title: customerAsync.maybeWhen(
          data: (c) => Text(c?.name ?? ''),
          orElse: () => Text(l10n.customers),
        ),
      ),
      body: customerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.errorGeneric)),
        data: (customer) {
          if (customer == null) {
            return Center(child: Text(l10n.errorGeneric));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              SoftCard(
                padding: const EdgeInsets.all(20),
                child: balanceAsync.when(
                  loading: () => const SizedBox(
                    height: 80,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => Text(l10n.errorGeneric),
                  data: (balance) => Column(
                    children: [
                      Text(
                        customer.name,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                      ),
                      if (customer.phone != null) ...[
                        const SizedBox(height: 4),
                        Text(customer.phone!),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _BalanceCell(
                              label: l10n.totalDebt,
                              amount: balance.totalDebts,
                              color: AppColors.debt,
                            ),
                          ),
                          Expanded(
                            child: _BalanceCell(
                              label: l10n.paid,
                              amount: balance.totalPayments,
                              color: AppColors.success,
                            ),
                          ),
                          Expanded(
                            child: _BalanceCell(
                              label: l10n.remaining,
                              amount: balance.remaining,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn().slideY(begin: 0.05, end: 0),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () => context.push(
                        '/debts/add?customerId=$customerId',
                      ),
                      child: Text(l10n.addDebt),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () => context.push(
                        '/payments/add?customerId=$customerId',
                      ),
                      child: Text(l10n.recordPayment),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _shareStatement(context, ref),
                icon: const Icon(Icons.ios_share_rounded),
                label: Text(l10n.sendStatement),
              ),
              const SizedBox(height: 24),
              Text(
                'الحركات',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              timelineAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Text(l10n.errorGeneric),
                data: (entries) {
                  if (entries.isEmpty) {
                    return EmptyStateView(
                      title: l10n.emptyDebtsTitle,
                      subtitle: l10n.emptyDebtsSubtitle,
                      icon: Icons.timeline,
                    );
                  }
                  return Column(
                    children: [
                      for (var i = 0; i < entries.length; i++)
                        _TimelineTile(entry: entries[i], l10n: l10n)
                            .animate()
                            .fadeIn(delay: (40 * i).ms),
                      balanceAsync.maybeWhen(
                        data: (b) => Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: SoftCard(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.remaining,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                AnimatedMoneyText(
                                  amount: b.remaining,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BalanceCell extends StatelessWidget {
  const _BalanceCell({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final int amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          MoneyFormatter.format(amount),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: color,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.entry, required this.l10n});

  final TimelineEntry entry;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isDebt = entry.type == TimelineEntryType.debt;
    final color = isDebt ? AppColors.debt : AppColors.success;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SoftCard(
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isDebt ? Icons.add_card_rounded : Icons.payments_rounded,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormatter.shortDate(entry.date),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Text(
                    isDebt ? l10n.newDebt : l10n.payment,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (entry.subtitle != null)
                    Text(
                      entry.subtitle!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if (isDebt && entry.date != entry.date)
                    const SizedBox.shrink(),
                ],
              ),
            ),
            Text(
              MoneyFormatter.format(entry.amount),
              style: TextStyle(fontWeight: FontWeight.w800, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
