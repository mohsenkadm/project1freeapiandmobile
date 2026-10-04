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
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../domain/entities/product.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key, this.openAdd = false});

  final bool openAdd;

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
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

  Future<void> _showEditor({Product? product}) async {
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final priceCtrl = TextEditingController(
      text: product == null ? '' : product.sellingPrice.round().toString(),
    );
    final costCtrl = TextEditingController(
      text: product?.costPrice == null
          ? ''
          : product!.costPrice!.round().toString(),
    );

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
                product == null ? 'منتج جديد' : 'تعديل المنتج',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'اسم المنتج'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'سعر البيع'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: costCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'تكلفة المنتج (اختياري)',
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: 'حفظ',
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  final price = MoneyFormatter.parse(priceCtrl.text) ?? -1;
                  final cost = MoneyFormatter.parse(costCtrl.text);
                  if (name.isEmpty) {
                    context.showMessage('اسم المنتج مطلوب', isError: true);
                    return;
                  }
                  if (price < 0) {
                    context.showMessage('السعر غير صالح', isError: true);
                    return;
                  }
                  final now = DateTime.now();
                  final entity = Product(
                    id: product?.id ?? const Uuid().v4(),
                    name: name,
                    sellingPrice: price,
                    costPrice: cost,
                    createdAt: product?.createdAt ?? now,
                    updatedAt: now,
                  );
                  await ref.read(productRepositoryProvider).save(entity);
                  if (context.mounted) {
                    Navigator.pop(context);
                    context.showMessage('تم حفظ المنتج');
                  }
                },
              ),
              if (product != null) ...[
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('حذف المنتج؟'),
                        content: const Text('لن يتم حذف الطلبات السابقة.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('إلغاء'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('حذف'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) {
                      await ref
                          .read(productRepositoryProvider)
                          .delete(product.id);
                      if (context.mounted) {
                        Navigator.pop(context);
                        context.showMessage('تم حذف المنتج');
                      }
                    }
                  },
                  style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                  child: const Text('حذف المنتج'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final ordersAsync = ref.watch(ordersProvider);
    final countsUseCase = ref.watch(computeProductOrderCountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المنتجات'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            onPressed: () => _showEditor(),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (products) {
          if (products.isEmpty) {
            return EmptyState(
              title: 'أضف المنتجات التي تبيعها.',
              subtitle: 'قائمة بسيطة بدون إدارة مخزون معقدة.',
              icon: Icons.inventory_2_outlined,
              actionLabel: 'إضافة منتج',
              onAction: () => _showEditor(),
            );
          }

          final q = _search.text.trim().toLowerCase();
          final filtered = products
              .where((p) => q.isEmpty || p.name.toLowerCase().contains(q))
              .toList();
          final counts = countsUseCase(ordersAsync.asData?.value ?? []);

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
                    hintText: 'بحث عن منتج',
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
                    final product = filtered[index];
                    final ordered = counts[product.id] ?? 0;
                    return AppCard(
                      onTap: () => _showEditor(product: product),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                AppColors.accent.withValues(alpha: 0.15),
                            child: const Icon(Icons.inventory_2_outlined,
                                color: AppColors.accent),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.name,
                                    style:
                                        Theme.of(context).textTheme.titleMedium),
                                Text(
                                  MoneyFormatter.format(product.sellingPrice),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(color: AppColors.primary),
                                ),
                                Text(
                                  'تم طلبه $ordered مرة',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_left_rounded),
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
