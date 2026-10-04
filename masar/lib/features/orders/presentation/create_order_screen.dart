import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/utils/phone_validator.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../customers/domain/entities/customer.dart';
import '../domain/entities/order_item.dart';
import '../domain/usecases/calculate_order_totals.dart';
import '../domain/usecases/create_order.dart';

class CreateOrderScreen extends ConsumerStatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  int _step = 0;
  Customer? _customer;
  final _items = <OrderItem>[];
  final _discountCtrl = TextEditingController(text: '0');
  final _deliveryCtrl = TextEditingController(text: '0');
  final _paidCtrl = TextEditingController(text: '0');
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _saving = false;
  bool _success = false;
  String? _createdId;

  @override
  void dispose() {
    _discountCtrl.dispose();
    _deliveryCtrl.dispose();
    _paidCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickOrCreateCustomer() async {
    final customers = await ref.read(customerRepositoryProvider).getAll();
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final search = TextEditingController();
        return StatefulBuilder(
          builder: (context, setModal) {
            final q = search.text.trim().toLowerCase();
            final filtered = customers
                .where((c) =>
                    q.isEmpty ||
                    c.name.toLowerCase().contains(q) ||
                    c.phone.contains(q))
                .toList();
            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                top: AppSpacing.xl,
                bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
              ),
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.7,
                child: Column(
                  children: [
                    Text('اختيار الزبون',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: search,
                      onChanged: (_) => setModal(() {}),
                      decoration: const InputDecoration(
                        hintText: 'بحث',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PrimaryButton(
                      label: '+ زبون جديد',
                      onPressed: () async {
                        Navigator.pop(context);
                        await _createCustomer();
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final c = filtered[index];
                          return ListTile(
                            title: Text(c.name),
                            subtitle: Text(c.phone),
                            onTap: () {
                              setState(() {
                                _customer = c;
                                if (_addressCtrl.text.isEmpty) {
                                  _addressCtrl.text = c.address;
                                }
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _createCustomer() async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
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
              Text('زبون جديد', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'الاسم')),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'الهاتف'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(labelText: 'العنوان'),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'حفظ واختيار',
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  final phone = phoneCtrl.text.trim();
                  if (name.isEmpty || !PhoneValidator.isValid(phone)) {
                    context.showMessage('تحقق من الاسم والهاتف', isError: true);
                    return;
                  }
                  final customer = Customer(
                    id: const Uuid().v4(),
                    name: name,
                    phone: PhoneValidator.normalize(phone),
                    address: addressCtrl.text.trim(),
                    createdAt: DateTime.now(),
                  );
                  await ref.read(customerRepositoryProvider).save(customer);
                  setState(() {
                    _customer = customer;
                    _addressCtrl.text = customer.address;
                  });
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addProduct() async {
    final products = await ref.read(productRepositoryProvider).getAll();
    if (!mounted) return;
    if (products.isEmpty) {
      context.showMessage('أضف منتجاً أولاً من شاشة المنتجات', isError: true);
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (context) {
        final search = TextEditingController();
        return StatefulBuilder(
          builder: (context, setModal) {
            final q = search.text.trim().toLowerCase();
            final filtered = products
                .where((p) => q.isEmpty || p.name.toLowerCase().contains(q))
                .toList();
            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                top: AppSpacing.xl,
                bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
              ),
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.7,
                child: Column(
                  children: [
                    Text('إضافة منتج',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: search,
                      onChanged: (_) => setModal(() {}),
                      decoration: const InputDecoration(
                        hintText: 'بحث',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final p = filtered[index];
                          return ListTile(
                            title: Text(p.name),
                            subtitle:
                                Text(MoneyFormatter.format(p.sellingPrice)),
                            onTap: () {
                              setState(() {
                                final existingIndex = _items.indexWhere(
                                  (e) => e.productId == p.id,
                                );
                                if (existingIndex >= 0) {
                                  final current = _items[existingIndex];
                                  _items[existingIndex] = current.copyWith(
                                    quantity: current.quantity + 1,
                                  );
                                } else {
                                  _items.add(
                                    OrderItem(
                                      productId: p.id,
                                      productName: p.name,
                                      quantity: 1,
                                      unitPrice: p.sellingPrice,
                                      costPrice: p.costPrice,
                                    ),
                                  );
                                }
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool _validateStep() {
    if (_step == 0 && _customer == null) {
      context.showMessage('اختيار الزبون مطلوب', isError: true);
      return false;
    }
    if (_step == 1 && _items.isEmpty) {
      context.showMessage('تأكد من إضافة منتج واحد على الأقل.', isError: true);
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    if (_customer == null || _items.isEmpty) return;
    setState(() => _saving = true);
    try {
      final orderNumber =
          await ref.read(settingsRepositoryProvider).takeNextOrderNumber();
      final order = await ref.read(createOrderProvider)(
        CreateOrderInput(
          orderNumber: orderNumber,
          customerId: _customer!.id,
          customerName: _customer!.name,
          customerPhone: _customer!.phone,
          items: List.of(_items),
          discount: MoneyFormatter.parse(_discountCtrl.text) ?? 0,
          deliveryFee: MoneyFormatter.parse(_deliveryCtrl.text) ?? 0,
          paidAmount: MoneyFormatter.parse(_paidCtrl.text) ?? 0,
          address: _addressCtrl.text,
          notes: _notesCtrl.text,
        ),
      );
      HapticFeedback.mediumImpact();
      setState(() {
        _success = true;
        _createdId = order.id;
      });
      await refreshNotifications(ref);
    } on AppException catch (e) {
      if (mounted) context.showMessage(e.message, isError: true);
    } catch (_) {
      if (mounted) {
        context.showMessage('تعذر إنشاء الطلب. حاول مرة أخرى.', isError: true);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_rounded,
                      size: 96, color: AppColors.success)
                  .animate()
                  .scale(begin: const Offset(0.6, 0.6))
                  .fadeIn(),
              const SizedBox(height: AppSpacing.xl),
              Text('تم إنشاء الطلب',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(
                label: 'عرض الطلب',
                expanded: false,
                onPressed: () {
                  if (_createdId != null) {
                    context.go('/orders/$_createdId');
                  } else {
                    context.go('/orders');
                  }
                },
              ),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('العودة للرئيسية'),
              ),
            ],
          ),
        ),
      );
    }

    final calculator = ref.watch(calculateOrderTotalsProvider);
    OrderTotals? preview;
    try {
      if (_items.isNotEmpty) {
        preview = calculator(
          items: _items,
          discount: MoneyFormatter.parse(_discountCtrl.text) ?? 0,
          deliveryFee: MoneyFormatter.parse(_deliveryCtrl.text) ?? 0,
          paidAmount: MoneyFormatter.parse(_paidCtrl.text) ?? 0,
        );
      }
    } catch (_) {
      preview = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلب جديد'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              children: List.generate(4, (i) {
                final active = i <= _step;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 4,
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.primary
                          : AppColors.textSecondary.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: KeyedSubtree(
                key: ValueKey(_step),
                child: _buildStep(preview),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _step--),
                        child: const Text('رجوع'),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      label: _step == 3
                          ? (_saving ? 'جاري الإنشاء...' : 'إنشاء الطلب')
                          : 'التالي',
                      onPressed: _saving
                          ? null
                          : () {
                              if (!_validateStep()) return;
                              if (_step < 3) {
                                setState(() => _step++);
                              } else {
                                _submit();
                              }
                            },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(OrderTotals? preview) {
    switch (_step) {
      case 0:
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Text('الزبون', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              onTap: _pickOrCreateCustomer,
              child: _customer == null
                  ? const Row(
                      children: [
                        Icon(Icons.person_add_alt_1_rounded,
                            color: AppColors.primary),
                        SizedBox(width: AppSpacing.md),
                        Text('اختيار زبون أو إضافة جديد'),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_customer!.name,
                            style: Theme.of(context).textTheme.titleLarge),
                        Text(_customer!.phone),
                        if (_customer!.address.isNotEmpty)
                          Text(_customer!.address,
                              style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _addressCtrl,
              decoration: const InputDecoration(
                labelText: 'عنوان التوصيل',
              ),
            ),
          ],
        );
      case 1:
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Row(
              children: [
                Text('المنتجات',
                    style: Theme.of(context).textTheme.headlineSmall),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addProduct,
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (_items.isEmpty)
              const Text('لم تُضف منتجات بعد.')
            else
              ..._items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.productName,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  if (item.quantity <= 1) {
                                    _items.removeAt(index);
                                  } else {
                                    _items[index] = item.copyWith(
                                      quantity: item.quantity - 1,
                                    );
                                  }
                                });
                              },
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text('${item.quantity}',
                                style: Theme.of(context).textTheme.titleLarge),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _items[index] = item.copyWith(
                                    quantity: item.quantity + 1,
                                  );
                                });
                              },
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                            const Spacer(),
                            Text(MoneyFormatter.format(item.lineTotal)),
                            IconButton(
                              onPressed: () =>
                                  setState(() => _items.removeAt(index)),
                              icon: const Icon(Icons.delete_outline,
                                  color: AppColors.danger),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        );
      case 2:
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Text('الدفع والتوصيل',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _discountCtrl,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'الخصم'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _deliveryCtrl,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'أجرة التوصيل'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _paidCtrl,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'المبلغ المدفوع'),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (preview != null)
              AppCard(
                child: Column(
                  children: [
                    _kv('قيمة المنتجات', preview.subtotal),
                    _kv('الخصم', preview.discount),
                    _kv('التوصيل', preview.deliveryFee),
                    const Divider(),
                    _kv('الإجمالي', preview.total, bold: true),
                    _kv('المدفوع', preview.paidAmount),
                    _kv('المتبقي', preview.remainingAmount),
                    if (preview.estimatedProfit != null) ...[
                      const Divider(),
                      _kv('الربح التقديري', preview.estimatedProfit!),
                    ] else
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: Text(
                          'أدخل تكلفة المنتج لمعرفة الربح التقديري.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );
      default:
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Text('ملاحظات', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _notesCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'ملاحظات للطلب (اختياري)',
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_customer != null)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ملخص سريع',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(_customer!.name),
                    Text('${_items.length} منتج'),
                    if (preview != null)
                      Text(MoneyFormatter.format(preview.total),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: AppColors.primary)),
                  ],
                ),
              ),
          ],
        );
    }
  }

  Widget _kv(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Text(
            MoneyFormatter.format(value),
            style: bold
                ? Theme.of(context).textTheme.titleMedium
                : Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
