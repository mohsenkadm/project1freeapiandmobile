import 'package:flutter/material.dart';

import '../../features/transactions/domain/entities/transaction.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../utils/date_formatter.dart';
import '../utils/money_formatter.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  IconData get _icon {
    switch (transaction.type) {
      case TransactionType.sale:
        return Icons.trending_up_rounded;
      case TransactionType.expense:
        return Icons.shopping_bag_outlined;
      case TransactionType.payment:
        return Icons.swap_horiz_rounded;
      case TransactionType.withdrawal:
        return Icons.payments_outlined;
    }
  }

  Color get _color {
    switch (transaction.type) {
      case TransactionType.sale:
        return AppColors.success;
      case TransactionType.expense:
        return AppColors.danger;
      case TransactionType.payment:
        return AppColors.warning;
      case TransactionType.withdrawal:
        return const Color(0xFFFF8A65);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type.isIncome;
    final signed = isIncome ? transaction.amount : -transaction.amount.abs();

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('حذف الحركة؟'),
                content: const Text('راح تنحذف هالحركة وما ترجع.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('إلغاء'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                    child: const Text('حذف'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.danger),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(_icon, color: _color),
        ),
        title: Text(
          transaction.description.isEmpty
              ? transaction.type.arabicLabel
              : transaction.description,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          '${DateFormatter.timeOfDay(transaction.createdAt)} • ${transaction.type.arabicLabel}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Text(
          MoneyFormatter.format(signed, showSign: true),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isIncome ? AppColors.success : AppColors.danger,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}
