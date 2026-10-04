import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/animated_money.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../domain/entities/cost_item.dart';
import '../providers/calculator_controller.dart';
import '../widgets/cost_breakdown.dart';
import '../widgets/profit_result_card.dart';
import '../widgets/scenario_cards.dart';
import '../widgets/share_result_card.dart';

class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key, this.productId});

  final String? productId;

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  late final TextEditingController _priceController;
  late final TextEditingController _nameController;
  final _shareKey = GlobalKey();
  bool _hapticFired = false;

  static const _presets = [
    ('نقل', 300.0),
    ('تغليف', 100.0),
    ('عمولة', 100.0),
    ('توصيل', 250.0),
  ];

  static const _marginStops = [5, 10, 15, 20, 25, 30, 40, 50];

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      final product = await ref
          .read(calculatorControllerProvider(widget.productId).notifier)
          .saveProduct();
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.profit),
              const SizedBox(width: 8),
              Expanded(child: Text('تم حفظ المنتج: ${product.name}')),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Future<void> _share() async {
    final state = ref.read(calculatorControllerProvider(widget.productId));
    if (state.result == null) return;
    await ref.read(shareResultServiceProvider).shareBoundary(
          _shareKey,
          text: AppConstants.tagline,
        );
  }

  void _applyPrice(String raw) {
    final normalized = raw
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .replaceAll('٬', '')
        .replaceAllMapped(RegExp(r'[٠-٩]'), (m) {
      const eastern = '٠١٢٣٤٥٦٧٨٩';
      return '${eastern.indexOf(m[0]!)}';
    });
    final value = double.tryParse(normalized) ?? 0;
    ref
        .read(calculatorControllerProvider(widget.productId).notifier)
        .setPurchasePrice(value);
  }

  void _togglePresetCost(String name, double amount) {
    final notifier =
        ref.read(calculatorControllerProvider(widget.productId).notifier);
    final existing = ref
        .read(calculatorControllerProvider(widget.productId))
        .costItems
        .where((e) => e.name == name)
        .toList();
    if (existing.isNotEmpty) {
      for (final item in existing) {
        notifier.removeCostItem(item.id);
      }
    } else {
      notifier.addPresetCost(name, amount);
    }
  }

  Future<void> _addCustomCost() async {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مصروف إضافي'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'الاسم (مثل: نقل)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'المبلغ'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final amount = double.tryParse(amountController.text.replaceAll(',', ''));
    if (amount == null || amount < 0 || nameController.text.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تأكد من اسم المصروف والمبلغ.')),
      );
      return;
    }
    ref
        .read(calculatorControllerProvider(widget.productId).notifier)
        .upsertCostItem(
          CostItem(
            id: const Uuid().v4(),
            name: nameController.text.trim(),
            amount: amount,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calculatorControllerProvider(widget.productId));
    final settings = ref.watch(settingsProvider).asData?.value;
    final currency = settings?.currencySuffix ?? AppConstants.currencySuffix;

    ref.listen(calculatorControllerProvider(widget.productId), (prev, next) {
      if (next.result != null &&
          prev?.result?.suggestedPrice != next.result?.suggestedPrice) {
        if (!_hapticFired) {
          HapticFeedback.selectionClick();
          _hapticFired = true;
          Future<void>.delayed(const Duration(milliseconds: 800), () {
            _hapticFired = false;
          });
        }
      }
      if (_nameController.text != next.productName &&
          next.productName.isNotEmpty &&
          !_nameController.selection.isValid) {
        // keep user typing intact
      }
      if (next.purchasePrice > 0 && _priceController.text.isEmpty) {
        _priceController.text =
            MoneyFormatter.format(next.purchasePrice, withCurrency: false);
      }
      if (next.productName.isNotEmpty && _nameController.text.isEmpty) {
        _nameController.text = next.productName;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('سعّر منتجك'),
        actions: [
          if (state.result != null)
            IconButton(
              tooltip: 'مشاركة النتيجة',
              onPressed: _share,
              icon: const Icon(Icons.ios_share_rounded),
            ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              120,
            ),
            children: [
              Hero(
                tag: 'pricing-hero',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    'كم كلفك المنتج؟',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: TextField(
                  controller: _priceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '10,000',
                    suffixText: currency,
                    suffixStyle: Theme.of(context).textTheme.titleLarge,
                  ),
                  onChanged: _applyPrice,
                  onEditingComplete: () => _applyPrice(_priceController.text),
                  onSubmitted: _applyPrice,
                ),
              ).animate().fadeIn().slideY(begin: 0.04),
              if (state.result != null) ...[
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  glow: true,
                  gradient: AppColors.profitGradient,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'سعر البيع المقترح',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            AnimatedMoney(
                              value: state.result!.suggestedPrice,
                              currencySuffix: currency,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'الربح',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          AnimatedMoney(
                            value: state.result!.profit,
                            currencySuffix: currency,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: AppColors.profit,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              Text(
                'مصاريف إضافية',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final preset in _presets)
                    FilterChip(
                      label: Text(preset.$1),
                      selected: state.costItems.any((e) => e.name == preset.$1),
                      onSelected: (_) =>
                          _togglePresetCost(preset.$1, preset.$2),
                    ),
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 18),
                    label: const Text('أخرى'),
                    onPressed: _addCustomCost,
                  ),
                ],
              ),
              if (state.costItems.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                ...state.costItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Text(
                            MoneyFormatter.format(
                              item.amount,
                              currencySuffix: currency,
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          IconButton(
                            onPressed: () => ref
                                .read(calculatorControllerProvider(
                                        widget.productId)
                                    .notifier)
                                .removeCostItem(item.id),
                            icon: const Icon(Icons.close_rounded, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Text(
                  'المجموع: ${MoneyFormatter.format(state.result?.totalAdditionalCosts ?? state.costItems.fold<double>(0, (s, e) => s + e.amount), currencySuffix: currency)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
              Text(
                state.marginMode == MarginMode.sellingMargin
                    ? 'هامش الربح من سعر البيع'
                    : 'نسبة زيادة على التكلفة',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<MarginMode>(
                segments: const [
                  ButtonSegment(
                    value: MarginMode.sellingMargin,
                    label: Text('هامش من البيع'),
                  ),
                  ButtonSegment(
                    value: MarginMode.costMarkup,
                    label: Text('زيادة على التكلفة'),
                  ),
                ],
                selected: {state.marginMode},
                onSelectionChanged: (value) {
                  ref
                      .read(calculatorControllerProvider(widget.productId)
                          .notifier)
                      .setMarginMode(value.first);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Column(
                  children: [
                    Text(
                      MoneyFormatter.percent(state.targetPercent),
                      style:
                          Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900,
                              ),
                    ),
                    Slider(
                      value: state.targetPercent.clamp(0, 90),
                      min: 0,
                      max: 90,
                      divisions: 90,
                      label: MoneyFormatter.percent(state.targetPercent),
                      onChanged: (v) => ref
                          .read(calculatorControllerProvider(widget.productId)
                              .notifier)
                          .setTargetPercent(v.roundToDouble()),
                    ),
                    Wrap(
                      spacing: 6,
                      children: _marginStops
                          .map(
                            (p) => ChoiceChip(
                              label: Text('$p%'),
                              selected: state.targetPercent.round() == p,
                              onSelected: (_) => ref
                                  .read(calculatorControllerProvider(
                                          widget.productId)
                                      .notifier)
                                  .setTargetPercent(p.toDouble()),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  state.errorMessage!,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.danger),
                ),
              ],
              if (state.result != null) ...[
                const SizedBox(height: AppSpacing.xxl),
                ProfitResultCard(
                  result: state.result!,
                  currencySuffix: currency,
                ),
                if (state.insight != null && state.insight!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    color: AppColors.surface,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_rounded,
                            color: AppColors.warning),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            state.insight!,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),
                ],
                const SizedBox(height: AppSpacing.xxl),
                ScenarioCards(
                  result: state.result!,
                  currencySuffix: currency,
                ),
                const SizedBox(height: AppSpacing.xxl),
                CostBreakdown(
                  result: state.result!,
                  currencySuffix: currency,
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'اسم المنتج (اختياري)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'مثال: عطر X'),
                  onChanged: (v) => ref
                      .read(calculatorControllerProvider(widget.productId)
                          .notifier)
                      .setProductName(v),
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: 'حفظ المنتج',
                  icon: Icons.bookmark_added_rounded,
                  onPressed: _save,
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: _share,
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('مشاركة النتيجة'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ],
            ],
          ),
          // Offstage shareable card for capture
          if (state.result != null)
            Positioned(
              left: -10000,
              child: RepaintBoundary(
                key: _shareKey,
                child: ShareResultCard(
                  result: state.result!,
                  currencySuffix: currency,
                  productName: state.productName,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
