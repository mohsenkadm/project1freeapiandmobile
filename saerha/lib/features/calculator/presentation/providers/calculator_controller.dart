import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../products/domain/entities/product.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../domain/entities/cost_item.dart';
import '../../domain/entities/pricing_calculation.dart';
import '../../domain/entities/pricing_result.dart';

class CalculatorState {
  const CalculatorState({
    this.productId,
    this.productName = '',
    this.purchasePrice = 0,
    this.costItems = const [],
    this.targetPercent = 20,
    this.marginMode = MarginMode.sellingMargin,
    this.result,
    this.errorMessage,
    this.insight,
  });

  final String? productId;
  final String productName;
  final double purchasePrice;
  final List<CostItem> costItems;
  final double targetPercent;
  final MarginMode marginMode;
  final PricingResult? result;
  final String? errorMessage;
  final String? insight;

  CalculatorState copyWith({
    String? productId,
    String? productName,
    double? purchasePrice,
    List<CostItem>? costItems,
    double? targetPercent,
    MarginMode? marginMode,
    PricingResult? result,
    String? errorMessage,
    String? insight,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return CalculatorState(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      costItems: costItems ?? this.costItems,
      targetPercent: targetPercent ?? this.targetPercent,
      marginMode: marginMode ?? this.marginMode,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      insight: insight ?? this.insight,
    );
  }
}

class CalculatorController extends StateNotifier<CalculatorState> {
  CalculatorController(this._ref, {String? productId})
      : super(const CalculatorState()) {
    final settings = _ref.read(settingsProvider).asData?.value;
    if (settings != null) {
      state = state.copyWith(marginMode: settings.marginMode);
    }
    if (productId != null) {
      _loadProduct(productId);
    } else {
      _recalculate();
    }
  }

  final Ref _ref;
  final _uuid = const Uuid();

  Future<void> _loadProduct(String id) async {
    final product = await _ref.read(productRepositoryProvider).getById(id);
    if (product == null) return;
    state = state.copyWith(
      productId: product.id,
      productName: product.name,
      purchasePrice: product.purchasePrice,
      costItems: product.additionalCosts,
      targetPercent: product.targetMargin,
      marginMode: product.marginMode,
    );
    _recalculate();
  }

  void setPurchasePrice(double value) {
    state = state.copyWith(purchasePrice: value, clearError: true);
    _recalculate();
  }

  void setTargetPercent(double value) {
    state = state.copyWith(targetPercent: value, clearError: true);
    _recalculate();
  }

  void setMarginMode(MarginMode mode) {
    state = state.copyWith(marginMode: mode, clearError: true);
    _recalculate();
  }

  void setProductName(String name) {
    state = state.copyWith(productName: name);
  }

  void upsertCostItem(CostItem item) {
    final list = [...state.costItems];
    final index = list.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      list[index] = item;
    } else {
      list.add(item);
    }
    state = state.copyWith(costItems: list, clearError: true);
    _recalculate();
  }

  void removeCostItem(String id) {
    state = state.copyWith(
      costItems: state.costItems.where((e) => e.id != id).toList(),
      clearError: true,
    );
    _recalculate();
  }

  void addPresetCost(String name, double amount) {
    upsertCostItem(CostItem(id: _uuid.v4(), name: name, amount: amount));
  }

  void _recalculate() {
    if (state.purchasePrice <= 0) {
      state = state.copyWith(clearResult: true, clearError: true, insight: '');
      return;
    }
    try {
      final result = _ref.read(calculatePricingProvider)(
        purchasePrice: state.purchasePrice,
        costItems: state.costItems,
        targetPercent: state.targetPercent,
        marginMode: state.marginMode,
      );
      final insight = _ref.read(buildSmartInsightProvider)(result);
      state = state.copyWith(
        result: result,
        insight: insight,
        clearError: true,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        errorMessage: e.message,
        clearResult: true,
        insight: '',
      );
    }
  }

  Future<Product> saveProduct() async {
    final result = state.result;
    if (result == null) {
      throw const ValidationException('احسب السعر أولاً قبل الحفظ.');
    }
    final name = state.productName.trim().isEmpty
        ? 'منتج ${DateTime.now().day}/${DateTime.now().month}'
        : state.productName.trim();
    final now = DateTime.now();
    DateTime createdAt = now;
    if (state.productId != null) {
      final existing =
          await _ref.read(productRepositoryProvider).getById(state.productId!);
      createdAt = existing?.createdAt ?? now;
    }
    final product = Product(
      id: state.productId ?? _uuid.v4(),
      name: name,
      purchasePrice: result.purchasePrice,
      additionalCosts: result.costItems,
      targetMargin: result.targetPercent,
      marginMode: result.marginMode,
      suggestedPrice: result.suggestedPrice,
      profit: result.profit,
      createdAt: createdAt,
      updatedAt: now,
    );
    await _ref.read(productRepositoryProvider).save(product);

    await _ref.read(historyRepositoryProvider).add(
          PricingCalculation(
            id: _uuid.v4(),
            productName: product.name,
            purchasePrice: result.purchasePrice,
            costItems: result.costItems,
            totalCost: result.totalCost,
            targetPercent: result.targetPercent,
            marginMode: result.marginMode,
            suggestedPrice: result.suggestedPrice,
            profit: result.profit,
            createdAt: now,
          ),
        );

    state = state.copyWith(productId: product.id, productName: product.name);
    return product;
  }

  Future<void> recordHistoryIfNeeded() async {
    final result = state.result;
    if (result == null) return;
    await _ref.read(historyRepositoryProvider).add(
          PricingCalculation(
            id: _uuid.v4(),
            productName: state.productName.trim().isEmpty
                ? null
                : state.productName.trim(),
            purchasePrice: result.purchasePrice,
            costItems: result.costItems,
            totalCost: result.totalCost,
            targetPercent: result.targetPercent,
            marginMode: result.marginMode,
            suggestedPrice: result.suggestedPrice,
            profit: result.profit,
            createdAt: DateTime.now(),
          ),
        );
  }
}

final calculatorControllerProvider = StateNotifierProvider.autoDispose
    .family<CalculatorController, CalculatorState, String?>((ref, productId) {
  return CalculatorController(ref, productId: productId);
});
