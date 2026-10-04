import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money_formatter.dart';
import '../domain/entities/order.dart';

abstract final class OrderShareService {
  static String whatsappMessage(Order order) {
    return 'مرحباً ${order.customerName}،\n'
        'طلبك رقم ${order.displayNumber} بقيمة ${MoneyFormatter.format(order.total)} أصبح ${order.status.labelAr}.\n'
        'شكراً لثقتك بنا.';
  }

  static Future<void> shareWhatsApp(Order order) async {
    final text = Uri.encodeComponent(whatsappMessage(order));
    final phone = order.customerPhone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('https://wa.me/$phone?text=$text');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await Share.share(whatsappMessage(order));
    }
  }

  static Future<void> shareText(Order order) async {
    await Share.share(
      '${AppConstants.appName}\n'
      'طلب ${order.displayNumber}\n'
      'الزبون: ${order.customerName}\n'
      'الإجمالي: ${MoneyFormatter.format(order.total)}\n'
      'الحالة: ${order.status.labelAr}',
    );
  }

  static Future<void> shareCardImage(GlobalKey key) async {
    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;
    final bytes = byteData.buffer.asUint8List();
    await Share.shareXFiles(
      [XFile.fromData(bytes, mimeType: 'image/png', name: 'masar_order.png')],
      text: AppConstants.appName,
    );
  }
}

class OrderShareCard extends StatelessWidget {
  const OrderShareCard({super.key, required this.order, required this.repaintKey});

  final Order order;
  final GlobalKey repaintKey;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintKey,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.alt_route_rounded,
                      color: AppColors.background),
                ),
                const SizedBox(width: 12),
                const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'طلب ${order.displayNumber}',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            _line('الزبون', order.customerName),
            _line('الإجمالي', MoneyFormatter.format(order.total)),
            _line('الحالة', order.status.labelAr),
          ],
        ),
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> lightHaptic() => HapticFeedback.lightImpact();
