import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Badge trạng thái — dùng xuyên suốt app (đơn hàng, lô hàng, xác minh...)
class AppBadge extends StatelessWidget {
  final String label;
  final String tone; // 'green' | 'orange' | 'yellow' | 'red' | 'blue' | 'lilac' | 'gray'
  final String? icon;

  const AppBadge(this.label, {super.key, this.tone = 'gray', this.icon});

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.badgeBg(tone);
    final fg = AppColors.badgeFg(tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon == 'shield' ? Icons.verified_outlined
                : icon == 'check' ? Icons.check_circle_outline
                : Icons.info_outline,
              size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(label, style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: fg,
          )),
        ],
      ),
    );
  }
}
