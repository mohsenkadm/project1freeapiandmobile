import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../features/transactions/domain/entities/transaction.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/bottom_action_sheet.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with SingleTickerProviderStateMixin {
  bool _fabOpen = false;
  late final AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    HapticFeedback.selectionClick();
    setState(() {
      _fabOpen = !_fabOpen;
      if (_fabOpen) {
        _fabController.forward();
      } else {
        _fabController.reverse();
      }
    });
  }

  Future<void> _openType(TransactionType type) async {
    setState(() {
      _fabOpen = false;
      _fabController.reverse();
    });
    await showTransactionSheet(context, type: type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.navigationShell,
          if (_fabOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleFab,
                child: AnimatedOpacity(
                  opacity: _fabOpen ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(color: Colors.black54),
                ),
              ),
            ),
          if (_fabOpen)
            Positioned(
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              bottom: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FabAction(
                    label: 'مبيعات',
                    icon: Icons.add_rounded,
                    color: AppColors.success,
                    onTap: () => _openType(TransactionType.sale),
                  ),
                  _FabAction(
                    label: 'مصروف',
                    icon: Icons.remove_rounded,
                    color: AppColors.danger,
                    onTap: () => _openType(TransactionType.expense),
                  ),
                  _FabAction(
                    label: 'دفعة',
                    icon: Icons.swap_horiz_rounded,
                    color: AppColors.warning,
                    onTap: () => _openType(TransactionType.payment),
                  ),
                  _FabAction(
                    label: 'سحب',
                    icon: Icons.payments_outlined,
                    color: const Color(0xFFFF8A65),
                    onTap: () => _openType(TransactionType.withdrawal),
                  ),
                ]
                    .animate(interval: 40.ms)
                    .fadeIn()
                    .scale(begin: const Offset(0.9, 0.9)),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleFab,
        child: AnimatedBuilder(
          animation: _fabController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _fabController.value * 0.785,
              child: Icon(_fabOpen ? Icons.close : Icons.add),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) {
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'الحركات',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'التقارير',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}

class _FabAction extends StatelessWidget {
  const _FabAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.18),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(label, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
