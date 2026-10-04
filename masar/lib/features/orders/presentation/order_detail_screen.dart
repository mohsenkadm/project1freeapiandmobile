import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/status_chip.dart';
import '../domain/entities/order_status.dart';
import 'order_status_ui.dart';
import 'order_share_service.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  final _shareKey = GlobalKey();
  bool _showSuccess = false;

  Future<void> _changeStatus(OrderStatus status) async {
    try {
      await ref.read(changeOrderStatusProvider)(
        orderId: widget.orderId,
        status: status,
      );
      HapticFeedback.selectionClick();
      if (status == OrderStatus.delivered) {
        setState(() => _showSuccess = true);
        await Future<void>.delayed(const Duration(milliseconds: 1200));
        if (mounted) setState(() => _showSuccess = false);
      }
      await refreshNotifications(ref);
      if (mounted) context.showMessage('تم تحديث حالة الطلب');
    } on AppException catch (e) {
      if (mounted) context.showMessage(e.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderByIdProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الطلب'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'مشاركة',
            onPressed: () async {
              final order = orderAsync.asData?.value;
              if (order == null) return;
              await showModalBottomSheet<void>(
                context: context,
                backgroundColor: AppColors.surface,
                builder: (context) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.image_outlined),
                          title: const Text('مشاركة بطاقة'),
                          onTap: () async {
                            Navigator.pop(context);
                            await OrderShareService.shareCardImage(_shareKey);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.chat_rounded),
                          title: const Text('إرسال للزبون'),
                          onTap: () async {
                            Navigator.pop(context);
                            await OrderShareService.shareWhatsApp(order);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.share_rounded),
                          title: const Text('مشاركة نص'),
                          onTap: () async {
                            Navigator.pop(context);
                            await OrderShareService.shareText(order);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            icon: const Icon(Icons.ios_share_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          orderAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (order) {
              if (order == null) {
                return const EmptyState(
                  title: 'الطلب غير موجود',
                  subtitle: 'ربما تم حذفه.',
                );
              }

              final next = order.status.nextActive;

              return ListView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [
                  Offstage(
                    offstage: true,
                    child: OrderShareCard(order: order, repaintKey: _shareKey),
                  ),
                  AppCard(
                    glow: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              order.displayNumber,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(color: AppColors.primary),
                            ),
                            const Spacer(),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 280),
                              child: StatusChip(
                                key: ValueKey(order.status),
                                status: order.status,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(order.customerName,
                            style: Theme.of(context).textTheme.titleLarge),
                        Text(order.customerPhone),
                        if (order.address.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(order.address,
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          MoneyFormatter.format(order.total),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: AppColors.accent),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('المنتجات',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.md),
                        ...order.items.map(
                          (item) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.productName} × ${item.quantity}',
                                  ),
                                ),
                                Text(MoneyFormatter.format(item.lineTotal)),
                              ],
                            ),
                          ),
                        ),
                        const Divider(),
                        _moneyRow(context, 'قيمة المنتجات', order.subtotal),
                        _moneyRow(context, 'الخصم', order.discount),
                        _moneyRow(context, 'التوصيل', order.deliveryFee),
                        _moneyRow(context, 'الإجمالي', order.total, bold: true),
                        _moneyRow(context, 'المدفوع', order.paidAmount),
                        _moneyRow(context, 'المتبقي', order.remainingAmount),
                        if (order.hasEstimatedProfit) ...[
                          const Divider(),
                          _moneyRow(
                            context,
                            'الربح التقديري',
                            order.estimatedProfit!,
                          ),
                          Text(
                            'للحساب المحاسبي الكامل استخدم قيد.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ] else ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'أدخل تكلفة المنتج لمعرفة الربح التقديري.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (order.notes.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ملاحظات',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: AppSpacing.sm),
                          Text(order.notes),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('مسار الطلب',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.lg),
                        ...OrderStatus.activeFlow.map((status) {
                          final historyEntry = order.history
                              .where((h) => h.status == status)
                              .toList();
                          final done = historyEntry.isNotEmpty ||
                              order.status == OrderStatus.delivered &&
                                  status == OrderStatus.delivered;
                          final current = order.status == status;
                          final time = historyEntry.isEmpty
                              ? null
                              : historyEntry.last.createdAt;
                          return _TimelineTile(
                            label: status.timelineLabel,
                            done: done && !current,
                            current: current,
                            time: time,
                          );
                        }),
                        if (order.status == OrderStatus.cancelled)
                          _TimelineTile(
                            label: OrderStatus.cancelled.timelineLabel,
                            done: true,
                            current: true,
                            time: () {
                              final cancelled = order.history
                                  .where((h) =>
                                      h.status == OrderStatus.cancelled)
                                  .toList();
                              return cancelled.isEmpty
                                  ? null
                                  : cancelled.last.createdAt;
                            }(),
                            danger: true,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (next != null)
                    PrimaryButton(
                      label: 'تحويل إلى ${next.labelAr}',
                      icon: next.icon,
                      onPressed: () => _changeStatus(next),
                    ),
                  if (order.status != OrderStatus.cancelled &&
                      order.status != OrderStatus.delivered) ...[
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton(
                      onPressed: () => _changeStatus(OrderStatus.cancelled),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('إلغاء الطلب'),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final uri =
                                Uri(scheme: 'tel', path: order.customerPhone);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          },
                          icon: const Icon(Icons.call_rounded),
                          label: const Text('اتصال'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              OrderShareService.shareWhatsApp(order),
                          icon: const Icon(Icons.chat_rounded),
                          label: const Text('واتساب'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              );
            },
          ),
          if (_showSuccess)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black54,
                child: Center(
                  child: const Icon(
                    Icons.verified_rounded,
                    size: 120,
                    color: AppColors.success,
                  )
                      .animate()
                      .scale(begin: const Offset(0.5, 0.5))
                      .fadeIn(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _moneyRow(
    BuildContext context,
    String label,
    double value, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
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

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.label,
    required this.done,
    required this.current,
    this.time,
    this.danger = false,
  });

  final String label;
  final bool done;
  final bool current;
  final DateTime? time;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger
        ? AppColors.danger
        : current
            ? AppColors.primary
            : done
                ? AppColors.success
                : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: done || current ? color : Colors.transparent,
                  border: Border.all(color: color, width: 2),
                  shape: BoxShape.circle,
                ),
                child: done
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : current
                        ? const Icon(Icons.arrow_forward,
                            size: 12, color: Colors.white)
                        : null,
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: color,
                        fontWeight:
                            current ? FontWeight.w800 : FontWeight.w600,
                      ),
                ),
                if (time != null)
                  Text(
                    DateFormatter.timeOnly(time!),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.05);
  }
}

