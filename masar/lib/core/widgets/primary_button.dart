import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expanded = true,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expanded;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final child = AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 100),
      child: FilledButton(
        onPressed: widget.onPressed == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                widget.onPressed!();
              },
        style: FilledButton.styleFrom(
          backgroundColor: widget.backgroundColor ?? AppColors.primary,
          foregroundColor: widget.foregroundColor ?? AppColors.background,
          minimumSize: Size(widget.expanded ? double.infinity : 0, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        child: Row(
          mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: 20),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(widget.label),
          ],
        ),
      ),
    );

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: child,
    );
  }
}
