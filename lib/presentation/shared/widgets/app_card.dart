import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Card chuẩn — bo góc 16, shadow nhẹ, background trắng
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: border ?? Border.all(color: const Color(0xCCE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1F2937),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );

    if (onTap == null) return card;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: card,
    );
  }
}
