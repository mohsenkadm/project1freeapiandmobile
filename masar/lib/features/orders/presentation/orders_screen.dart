import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state.dart';
import '../domain/entities/order_status.dart';
import '../domain/usecases/filter_orders.dart';
import 'widgets/order_card.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _search = TextEditingController();
  OrderSort _sort = OrderSort.newest;

  static const _tabStatuses = <OrderStatus?>[
    null,
    OrderStatus.neu,
    OrderStatus.processing,
    OrderStatus.outForDelivery,
    OrderStatus.delivered,
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _tabStatuses.length, vsync: this);
    _tabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);
    final filter = ref.watch(filterOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات'),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'جديد'),
            Tab(text: 'تجهيز'),
            Tab(text: 'توصيل'),
            Tab(text: 'تم التسليم'),
          ],
        ),
        actions: [
          PopupMenuButton<OrderSort>(
            initialValue: _sort,
            onSelected: (v) => setState(() => _sort = v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: OrderSort.newest, child: Text('الأحدث')),
              PopupMenuItem(value: OrderSort.oldest, child: Text('الأقدم')),
              PopupMenuItem(
                  value: OrderSort.highestValue, child: Text('الأعلى قيمة')),
              PopupMenuItem(
                  value: OrderSort.lowestValue, child: Text('الأقل قيمة')),
            ],
            icon: const Icon(Icons.sort_rounded),
          ),
        ],
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (orders) {
          final filtered = filter(
            orders: orders,
            query: _search.text,
            status: _tabStatuses[_tabs.index],
            sort: _sort,
          );

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.md,
                  AppSpacing.xl,
                  AppSpacing.sm,
                ),
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'بحث برقم الطلب أو الزبون أو الهاتف أو المنتج',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? EmptyState(
                        title: 'ما عندك طلبات بهذه الفلترة 👋',
                        subtitle: 'جرّب تغيير البحث أو أضف طلباً جديداً.',
                        actionLabel: 'إضافة طلب',
                        onAction: () => context.push('/orders/new'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          AppSpacing.sm,
                          AppSpacing.xl,
                          120,
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          return OrderCard(
                            order: filtered[index],
                            index: index,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
