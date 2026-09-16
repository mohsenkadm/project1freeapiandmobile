import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/common_widgets.dart';

class QaidPromoScreen extends StatelessWidget {
  const QaidPromoScreen({super.key});

  Future<void> _openQaid() async {
    final uri = Uri.parse(AppConstants.qaidUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final features = [
      (Icons.point_of_sale_rounded, l10n.qaidFeatureSales),
      (Icons.shopping_bag_outlined, l10n.qaidFeaturePurchases),
      (Icons.inventory_2_outlined, l10n.qaidFeatureInventory),
      (Icons.account_balance_wallet_outlined, l10n.qaidFeatureDebts),
      (Icons.calendar_month_outlined, l10n.qaidFeatureInstallments),
      (Icons.analytics_outlined, l10n.qaidFeatureReports),
      (Icons.qr_code_2_rounded, l10n.qaidFeatureBarcode),
      (Icons.phone_iphone_rounded, l10n.qaidFeatureMobile),
      (Icons.store_mall_directory_outlined, l10n.qaidFeatureBranches),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.qaidPageTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          SoftCard(
            padding: const EdgeInsets.all(24),
            color: AppColors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.qaidPageTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.qaidBannerBody,
                  style: const TextStyle(color: Colors.white70, height: 1.5),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.06, end: 0),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < features.length; i++)
                SizedBox(
                  width: (MediaQuery.sizeOf(context).width - 50) / 2,
                  child: SoftCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Icon(features[i].$1, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            features[i].$2,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: (40 * i).ms),
                ),
            ],
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _openQaid,
            child: Text(l10n.tryQaidFree),
          ),
        ],
      ),
    );
  }
}
