import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../features/transactions/domain/entities/transaction.dart';
import '../di/providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'app_text_field.dart';
import 'primary_button.dart';

Future<void> showTransactionSheet(
  BuildContext context, {
  required TransactionType type,
  Transaction? existing,
  DateTime? initialDate,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => TransactionBottomSheet(
      type: type,
      existing: existing,
      initialDate: initialDate,
    ),
  );
}

class TransactionBottomSheet extends ConsumerStatefulWidget {
  const TransactionBottomSheet({
    super.key,
    required this.type,
    this.existing,
    this.initialDate,
  });

  final TransactionType type;
  final Transaction? existing;
  final DateTime? initialDate;

  @override
  ConsumerState<TransactionBottomSheet> createState() =>
      _TransactionBottomSheetState();
}

class _TransactionBottomSheetState
    extends ConsumerState<TransactionBottomSheet> {
  late final TextEditingController _amount;
  late final TextEditingController _description;
  late TimeOfDay _time;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _amount = TextEditingController(
      text: existing == null
          ? ''
          : existing.amount.round().toString().replaceAllMapped(
                RegExp(r'\B(?=(\d{3})+(?!\d))'),
                (m) => ',',
              ),
    );
    _description = TextEditingController(text: existing?.description ?? '');
    final base = existing?.createdAt ?? widget.initialDate ?? DateTime.now();
    _time = TimeOfDay(hour: base.hour, minute: base.minute);
  }

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = AmountInput.parseAmount(_amount.text);
    if (amount == null || amount <= 0) {
      setState(() => _error = 'يرجى إدخال مبلغ صحيح.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final selectedDate = ref.read(selectedDateProvider);
      final now = DateTime.now();
      final createdAt = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        _time.hour,
        _time.minute,
      );

      final repo = ref.read(transactionRepositoryProvider);
      if (widget.existing == null) {
        await repo.add(
          Transaction(
            id: const Uuid().v4(),
            type: widget.type,
            amount: amount.toDouble(),
            description: _description.text.trim(),
            createdAt: createdAt,
            updatedAt: now,
          ),
        );
      } else {
        await repo.update(
          widget.existing!.copyWith(
            type: widget.type,
            amount: amount.toDouble(),
            description: _description.text.trim(),
            createdAt: createdAt,
            updatedAt: now,
          ),
        );
      }

      if (!mounted) return;
      HapticFeedback.mediumImpact();
      ref.invalidate(historySummariesProvider);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success),
              const SizedBox(width: 10),
              Text(widget.existing == null ? 'تم حفظ الحركة' : 'تم تحديث الحركة'),
            ],
          ),
        ),
      );
    } catch (_) {
      setState(() => _error = 'حدث خطأ، حاول مرة أخرى.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : AppColors.surfaceLight,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              widget.existing == null
                  ? widget.type.addSheetTitle
                  : 'تعديل ${widget.type.arabicLabel}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xl),
            AmountInput(controller: _amount, autofocus: true),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _description,
              label: 'الوصف',
              hint: 'مثال: شراء مواد',
            ),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('الوقت'),
              subtitle: Text(
                '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.access_time_rounded),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _time,
                );
                if (picked != null) setState(() => _time = picked);
              },
            ),
            if (_error != null) ...[
              Text(
                _error!,
                style: const TextStyle(color: AppColors.danger),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            PrimaryButton(
              label: _saving ? 'جارٍ الحفظ...' : 'حفظ',
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
