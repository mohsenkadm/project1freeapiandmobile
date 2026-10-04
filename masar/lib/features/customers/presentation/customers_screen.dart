import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/providers.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/utils/phone_validator.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../domain/entities/customer.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key, this.openAdd = false});

  final bool openAdd;

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final _search = TextEditingController();
  bool _opened = false;

  @override
  void initState() {
    super.initState();
    if (widget.openAdd) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_opened && mounted) {
          _opened = true;
          _showEditor();
        }
      });
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _showEditor({Customer? customer}) async {
    final nameCtrl = TextEditingController(text: customer?.name ?? '');
    final phoneCtrl = TextEditingController(text: customer?.phone ?? '');
    final addressCtrl = TextEditingController(text: customer?.address ?? '');
    final notesCtrl = TextEditingController(text: customer?.notes ?? '');

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            top: AppSpacing.xl,
            bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                customer == null ? 'زبون جديد' : 'تعديل الزبون',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'الاسم'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(labelText: 'العنوان'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(labelText: 'ملاحظات'),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: 'حفظ',
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  final phone = phoneCtrl.text.trim();
                  if (name.isEmpty) {
                    context.showMessage('اسم الزبون مطلوب', isError: true);
                    return;
                  }
                  if (!PhoneValidator.isValid(phone)) {
                    context.showMessage('رقم الهاتف غير صالح', isError: true);
                    return;
                  }
                  final entity = Customer(
                    id: customer?.id ?? const Uuid().v4(),
                    name: name,
                    phone: PhoneValidator.normalize(phone),
                    address: addressCtrl.text.trim(),
                    notes: notesCtrl.text.trim(),
                    createdAt: customer?.createdAt ?? DateTime.now(),
                  );
                  await ref.read(customerRepositoryProvider).save(entity);
                  if (context.mounted) {
                    Navigator.pop(context);
                    context.showMessage('تم حفظ الزبون');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider);
    final ordersAsync = ref.watch(ordersProvider);
    final compute = ref.watch(computeCustomerTotalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الزبائن'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            onPressed: () => _showEditor(),
            icon: const Icon(Icons.person_add_alt_1_rounded),
          ),
        ],
      ),
      body: customersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (customers) {
          final q = _search.text.trim().toLowerCase();
          final filtered = customers.where((c) {
            if (q.isEmpty) return true;
            return c.name.toLowerCase().contains(q) || c.phone.contains(q);
          }).toList();

          if (customers.isEmpty) {
            return EmptyState(
              title: 'أضف أول زبون حتى تبدأ.',
              subtitle: 'كل طلب يحتاج زبوناً واضحاً.',
              icon: Icons.people_outline_rounded,
              actionLabel: 'إضافة زبون',
              onAction: () => _showEditor(),
            );
          }

          final orders = ordersAsync.asData?.value ?? [];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.sm,
                  AppSpacing.xl,
                  AppSpacing.md,
                ),
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'بحث بالاسم أو الهاتف',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.xxxl,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final customer = filtered[index];
                    final totals = compute(orders, customer.id);
                    return AppCard(
                      onTap: () => context.push('/customers/${customer.id}'),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.15),
                              child: Text(
                              customer.name.isEmpty
                                  ? '?'
                                  : customer.name.substring(0, 1),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(customer.name,
                                    style:
                                        Theme.of(context).textTheme.titleMedium),
                                Text(customer.phone,
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                                Text(
                                  '${totals.orderCount} طلب · ${MoneyFormatter.format(totals.totalValue)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _showEditor(customer: customer),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                        ],
                      ),
                    )
                        .animate(delay: (40 * index).ms)
                        .fadeIn()
                        .slideY(begin: 0.08);
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
