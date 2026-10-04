import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/amount_input_formatter.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../debts/presentation/add_debt_screen.dart';
import '../domain/entities/payment.dart';

class AddPaymentScreen extends ConsumerStatefulWidget {
  const AddPaymentScreen({super.key, this.initialCustomerId});

  final String? initialCustomerId;

  @override
  ConsumerState<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends ConsumerState<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String? _customerId;
  PaymentMethod _method = PaymentMethod.cash;
  bool _loading = false;
  bool _success = false;
  int? _remaining;

  @override
  void initState() {
    super.initState();
    _customerId = widget.initialCustomerId;
    if (_customerId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadRemaining());
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadRemaining() async {
    if (_customerId == null) return;
    final balance =
        await ref.read(customerRepositoryProvider).getBalance(_customerId!);
    if (mounted) setState(() => _remaining = balance.remaining);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (_customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorCustomerRequired)),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    final amount = MoneyFormatter.parse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorAmountPositive)),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(recordPaymentProvider).call(
            customerId: _customerId!,
            amount: amount,
            paymentMethod: _method,
            notes: _notesController.text,
          );
      if (!mounted) return;
      setState(() {
        _loading = false;
        _success = true;
      });
      await Future<void>.delayed(const Duration(milliseconds: 1000));
      if (mounted) context.pop();
    } on Failure catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorGeneric)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final customersAsync = ref.watch(customersPickerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recordPayment)),
      body: _success
          ? SuccessOverlay(message: l10n.paymentSavedSuccess)
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  customersAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => Text(l10n.errorGeneric),
                    data: (items) {
                      return DropdownButtonFormField<String>(
                        initialValue: _customerId,
                        decoration: InputDecoration(
                          labelText: l10n.selectCustomer,
                        ),
                        items: items
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.customer.id,
                                child: Text(
                                  '${e.customer.name} (${MoneyFormatter.format(e.balance.remaining)})',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) async {
                          setState(() => _customerId = v);
                          await _loadRemaining();
                        },
                      );
                    },
                  ),
                  if (_remaining != null) ...[
                    const SizedBox(height: 12),
                    SoftCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.remaining),
                          Text(
                            MoneyFormatter.format(_remaining!),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [AmountInputFormatter()],
                    decoration: InputDecoration(
                      labelText: '${l10n.amount} *',
                      suffixText: l10n.iqdSuffix,
                    ),
                    validator: (v) {
                      final amount = MoneyFormatter.parse(v ?? '');
                      if (amount == null) return l10n.errorAmountRequired;
                      if (amount <= 0) return l10n.errorAmountPositive;
                      if (_remaining != null && amount > _remaining!) {
                        return l10n.errorAmountExceedsBalance;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  Text(l10n.paymentMethod),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(l10n.cash),
                        selected: _method == PaymentMethod.cash,
                        onSelected: (_) =>
                            setState(() => _method = PaymentMethod.cash),
                      ),
                      ChoiceChip(
                        label: Text(l10n.transfer),
                        selected: _method == PaymentMethod.transfer,
                        onSelected: (_) =>
                            setState(() => _method = PaymentMethod.transfer),
                      ),
                      ChoiceChip(
                        label: Text(l10n.other),
                        selected: _method == PaymentMethod.other,
                        onSelected: (_) =>
                            setState(() => _method = PaymentMethod.other),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: '${l10n.notes} (${l10n.optional})',
                    ),
                  ),
                  const SizedBox(height: 28),
                  PrimaryActionButton(
                    label: l10n.savePayment,
                    isLoading: _loading,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
    );
  }
}
