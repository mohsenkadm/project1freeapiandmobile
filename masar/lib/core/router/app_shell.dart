import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

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

  void _go(String path) {
    setState(() {
      _fabOpen = false;
      _fabController.reverse();
    });
    context.push(path);
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
                    label: 'طلب جديد',
                    icon: Icons.receipt_long_rounded,
                    color: AppColors.primary,
                    featured: true,
                    onTap: () => _go('/orders/new'),
                  ),
                  _FabAction(
                    label: 'إضافة زبون',
                    icon: Icons.person_add_alt_1_rounded,
                    color: AppColors.info,
                    onTap: () => _go('/customers?add=1'),
                  ),
                  _FabAction(
                    label: 'إضافة منتج',
                    icon: Icons.inventory_2_outlined,
                    color: AppColors.accent,
                    onTap: () => _go('/products?add=1'),
                  ),
                ]
                    .animate(interval: 40.ms)
                    .fadeIn()
                    .scale(begin: const Offset(0.9, 0.9)),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleFab,
        icon: AnimatedBuilder(
          animation: _fabController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _fabController.value * 0.785,
              child: Icon(_fabOpen ? Icons.close : Icons.add),
            );
          },
        ),
        label: const Text('+ طلب جديد'),
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
            label: 'الطلبات',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_shipping_outlined),
            selectedIcon: Icon(Icons.local_shipping_rounded),
            label: 'التوصيل',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'المزيد',
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
    this.featured = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: featured ? AppColors.primary.withValues(alpha: 0.16) : AppColors.card,
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
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight:
                              featured ? FontWeight.w800 : FontWeight.w600,
                        ),
                  ),
                ),
                if (featured)
                  const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
