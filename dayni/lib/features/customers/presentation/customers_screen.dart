import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../../shared/widgets/debounced_search_bar.dart';
import '../domain/entities/customer_balance.dart';

class CustomersFilterState {
  const CustomersFilterState({
    this.query = '',
    this.filter,
  });

  final String query;
  final CustomerDebtStatus? filter;

  CustomersFilterState copyWith({
    String? query,
    CustomerDebtStatus? filter,
    bool clearFilter = false,
  }) {
    return CustomersFilterState(
      query: query ?? this.query,
      filter: clearFilter ? null : (filter ?? this.filter),
    );
  }
}

class CustomersFilterNotifier extends StateNotifier<CustomersFilterState> {
  CustomersFilterNotifier() : super(const CustomersFilterState());

  void setQuery(String query) => state = state.copyWith(query: query);

  void setFilter(CustomerDebtStatus? filter) {
    if (filter == null) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(filter: filter);
    }
  }
}

final customersFilterProvider =
    StateNotifierProvider<CustomersFilterNotifier, CustomersFilterState>(
  (ref) => CustomersFilterNotifier(),
);

final customersListProvider =
    StreamProvider.autoDispose<List<CustomerListItem>>((ref) {
  final filter = ref.watch(customersFilterProvider);
  return ref.watch(customerRepositoryProvider).watchCustomers(
        query: filter.query,
        filter: filter.filter,
      );
});

class CustomersScreen extends ConsumerWidget {
  const CustomersScreen({super.key});

  Color _statusColor(CustomerDebtStatus status) {
    return switch (status) {
      CustomerDebtStatus.hasDebt => AppColors.debt,
      CustomerDebtStatus.settled => AppColors.success,
      CustomerDebtStatus.overdue => AppColors.danger,
      CustomerDebtStatus.noDebt => AppColors.primary,
    };
  }

  String _statusLabel(AppLocalizations l10n, CustomerDebtStatus status) {
    return switch (status) {
      CustomerDebtStatus.hasDebt => l10n.statusHasDebt,
      CustomerDebtStatus.settled => l10n.statusSettled,
      CustomerDebtStatus.overdue => l10n.statusOverdue,
      CustomerDebtStatus.noDebt => l10n.statusNoDebt,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filterState = ref.watch(customersFilterProvider);
    final async = ref.watch(customersListProvider);

    final filters = <(String, CustomerDebtStatus?)>[
      (l10n.filterAll, null),
      (l10n.filterWithDebt, CustomerDebtStatus.hasDebt),
      (l10n.filterSettled, CustomerDebtStatus.settled),
      (l10n.filterOverdue, CustomerDebtStatus.overdue),
      (l10n.filterNoDebt, CustomerDebtStatus.noDebt),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.customers)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: DebouncedSearchBar(
              hintText: l10n.searchHint,
              onChanged: (q) =>
                  ref.read(customersFilterProvider.notifier).setQuery(q),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = filters[index];
                final selected = filterState.filter == item.$2;
                return FilterChip(
                  selected: selected,
                  label: Text(item.$1),
                  onSelected: (_) => ref
                      .read(customersFilterProvider.notifier)
                      .setFilter(item.$2),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(child: Text(l10n.errorGeneric)),
              data: (items) {
                if (items.isEmpty) {
                  return EmptyStateView(
                    title: filterState.query.isEmpty
                        ? l10n.emptyCustomersTitle
                        : l10n.noResults,
                    subtitle: filterState.query.isEmpty
                        ? l10n.emptyCustomersSubtitle
                        : l10n.noResults,
                    actionLabel: l10n.addCustomer,
                    onAction: () => context.push('/customers/add'),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: items.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Text(
                        '${l10n.customerCount}: ${items.length}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      );
                    }
                    final item = items[index - 1];
                    return SoftCard(
                      onTap: () =>
                          context.push('/customers/${item.customer.id}'),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: _statusColor(item.status)
                                .withValues(alpha: 0.12),
                            child: Text(
                              item.customer.name.characters.first,
                              style: TextStyle(
                                color: _statusColor(item.status),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.customer.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (item.customer.phone != null)
                                  Text(
                                    item.customer.phone!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                if (item.lastActivityAt != null)
                                  Text(
                                    '${l10n.lastActivity}: ${DateFormatter.relativeArabic(item.lastActivityAt!)}',
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                  ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                MoneyFormatter.format(item.balance.remaining),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: item.balance.hasDebt
                                      ? AppColors.debt
                                      : AppColors.success,
                                ),
                              ),
                              const SizedBox(height: 4),
                              StatusChip(
                                label: _statusLabel(l10n, item.status),
                                color: _statusColor(item.status),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: (30 * index).ms);
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
