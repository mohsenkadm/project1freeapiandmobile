import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/amount_input_formatter.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../customers/domain/entities/customer_balance.dart';

final customersPickerProvider = StreamProvider<List<CustomerListItem>>((ref) {
  return ref.watch(customerRepositoryProvider).watchCustomers();
});

class AddDebtScreen extends ConsumerStatefulWidget {
  const AddDebtScreen({super.key, this.initialCustomerId});

  final String? initialCustomerId;

  @override
  ConsumerState<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends ConsumerState<AddDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  String? _customerId;
  DateTime _debtDate = DateTime.now();
  DateTime? _dueDate;
  bool _loading = false;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _customerId = widget.initialCustomerId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (_customerId == null || _customerId!.isEmpty) {
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
      await ref.read(addDebtProvider).call(
            customerId: _customerId!,
            amount: amount,
            description: _descriptionController.text,
            dueDate: _dueDate,
            notes: _notesController.text,
            createdAt: _debtDate,
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
      appBar: AppBar(title: Text(l10n.addDebt)),
      body: _success
          ? SuccessOverlay(message: l10n.debtSavedSuccess)
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  customersAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => Text(l10n.errorGeneric),
                    data: (items) {
                      final customers =
                          items.map((e) => e.customer).toList();
                      return DropdownButtonFormField<String>(
                        initialValue: _customerId,
                        decoration: InputDecoration(
                          labelText: l10n.selectCustomer,
                        ),
                        items: customers
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _customerId = v),
                      );
                    },
                  ),
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
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: l10n.debtDescription,
                      hintText: l10n.descriptionHint,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.debtDate),
                    subtitle: Text(
                      '${_debtDate.day}/${_debtDate.month}/${_debtDate.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today_rounded),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _debtDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _debtDate = picked);
                      }
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${l10n.dueDate} (${l10n.optional})'),
                    subtitle: Text(
                      _dueDate == null
                          ? l10n.none
                          : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        _dueDate == null
                            ? Icons.event_available_rounded
                            : Icons.clear_rounded,
                      ),
                      onPressed: _dueDate == null
                          ? _pickDueDate
                          : () => setState(() => _dueDate = null),
                    ),
                    onTap: _pickDueDate,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: '${l10n.notes} (${l10n.optional})',
                    ),
                  ),
                  const SizedBox(height: 28),
                  PrimaryActionButton(
                    label: l10n.saveDebt,
                    isLoading: _loading,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
    );
  }
}
