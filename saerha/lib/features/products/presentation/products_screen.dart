import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../domain/entities/product.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  String _query = '';

  Future<void> _delete(Product product) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المنتج؟'),
        content: Text('سيتم حذف «${product.name}» نهائياً.'),
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
      await ref.read(productRepositoryProvider).delete(product.id);
    }
  }

  Future<void> _duplicate(Product product) async {
    final now = DateTime.now();
    final copy = product.copyWith(
      id: const Uuid().v4(),
      name: '${product.name} (نسخة)',
      createdAt: now,
      updatedAt: now,
    );
    await ref.read(productRepositoryProvider).save(copy);
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final currency = ref.watch(settingsProvider).asData?.value.currencySuffix ??
        AppConstants.currencySuffix;

    return Scaffold(
      appBar: AppBar(title: const Text('منتجاتي')),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('حدث خطأ: $e')),
        data: (products) {
          final filtered = products
              .where((p) => p.name.toLowerCase().contains(_query.toLowerCase()))
              .toList();

          if (products.isEmpty) {
            return EmptyState(
              title: 'لسه ما سعّرت أي منتج 👋',
              subtitle: 'خلّينا نعرف السعر الصح.',
              actionLabel: 'ابدأ التسعير',
              onAction: () => context.go('/calculator'),
            );
          }

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
                  decoration: const InputDecoration(
                    hintText: 'ابحث عن منتج...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                  onChanged: (v) => setState(() => _query = v.trim()),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('ماكو نتائج مطابقة.'))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          0,
                          AppSpacing.xl,
                          100,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final p = filtered[index];
                          final totalCost = p.purchasePrice +
                              p.additionalCosts
                                  .fold<double>(0, (s, e) => s + e.amount);
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: Dismissible(
                              key: ValueKey(p.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20),
                                decoration: BoxDecoration(
                                  color: AppColors.danger.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(Icons.delete_rounded,
                                    color: AppColors.danger),
                              ),
                              confirmDismiss: (_) async {
                                await _delete(p);
                                return false;
                              },
                              child: AppCard(
                                onTap: () =>
                                    context.go('/calculator?productId=${p.id}'),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            p.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge,
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              context.go(
                                                  '/calculator?productId=${p.id}');
                                            } else if (value == 'duplicate') {
                                              _duplicate(p);
                                            } else if (value == 'delete') {
                                              _delete(p);
                                            }
                                          },
                                          itemBuilder: (_) => const [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Text('تعديل'),
                                            ),
                                            PopupMenuItem(
                                              value: 'duplicate',
                                              child: Text('تكرار'),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Text('حذف'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'تكلفة: ${MoneyFormatter.format(totalCost, currencySuffix: currency)}',
                                      style:
                                          Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    Text(
                                      'بيع: ${MoneyFormatter.format(p.suggestedPrice, currencySuffix: currency)}',
                                      style:
                                          Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'ربح: ${MoneyFormatter.format(p.profit, currencySuffix: currency)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: AppColors.profit,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ],
                                ),
                              )
                                  .animate(delay: (40 * index).ms)
                                  .fadeIn()
                                  .slideX(begin: 0.04),
                            ),
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
