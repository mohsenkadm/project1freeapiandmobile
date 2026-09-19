import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/bottom_action_sheet.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/transaction_tile.dart';
import '../domain/entities/transaction.dart';

final _txQueryProvider = StateProvider<String>((ref) => '');
final _txFilterProvider = StateProvider<TransactionType?>((ref) => null);

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(selectedDateProvider);
    final query = ref.watch(_txQueryProvider);
    final filter = ref.watch(_txFilterProvider);
    final txsAsync = ref.watch(transactionsForSelectedDateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('حركات اليوم'),
        actions: [
          IconButton(
            tooltip: 'إضافة',
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (ctx) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final type in TransactionType.values)
                      ListTile(
                        title: Text(type.addSheetTitle),
                        onTap: () {
                          Navigator.pop(ctx);
                          showTransactionSheet(context, type: type);
                        },
                      ),
                  ],
                ),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.sm,
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'ابحث بالوصف أو النوع...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (v) =>
                  ref.read(_txQueryProvider.notifier).state = v,
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              children: [
                _FilterChip(
                  label: 'الكل',
                  selected: filter == null,
                  onTap: () =>
                      ref.read(_txFilterProvider.notifier).state = null,
                ),
                for (final type in TransactionType.values)
                  _FilterChip(
                    label: type.arabicLabel,
                    selected: filter == type,
                    onTap: () =>
                        ref.read(_txFilterProvider.notifier).state = type,
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: txsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const EmptyState(
                title: 'حدث خطأ، حاول مرة أخرى.',
                subtitle: 'ما كدرنا نحمّل الحركات.',
              ),
              data: (txs) {
                final needle = query.trim().toLowerCase();
                final filtered = txs.where((tx) {
                  if (filter != null && tx.type != filter) return false;
                  if (needle.isEmpty) return true;
                  return tx.description.toLowerCase().contains(needle) ||
                      tx.type.arabicLabel.contains(needle);
                }).toList();

                if (filtered.isEmpty) {
                  return EmptyState(
                    title: 'لسه ما سجلت أي حركة اليوم 👋',
                    subtitle: 'ابدأ بأول حركة حتى نعرف وين تروح فلوسك.',
                    actionLabel: 'إضافة حركة',
                    onAction: () => showTransactionSheet(
                      context,
                      type: TransactionType.sale,
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    120,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final tx = filtered[index];
                    return TransactionTile(
                      transaction: tx,
                      onTap: () => showTransactionSheet(
                        context,
                        type: tx.type,
                        existing: tx,
                        initialDate: date,
                      ),
                      onDelete: () async {
                        await ref
                            .read(transactionRepositoryProvider)
                            .delete(tx.id);
                        ref.invalidate(historySummariesProvider);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary.withValues(alpha: 0.25),
        labelStyle: TextStyle(
          color: selected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
