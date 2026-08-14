import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'app_card.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? delta;
  final IconData icon;
  final String tone;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.delta,
    this.tone = 'green',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.badgeBg(tone);
    final fg = AppColors.badgeFg(tone);
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: fg),
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700, height: 1,
            letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(
            fontSize: 12, color: AppColors.textSecondary, height: 1.3)),
          if (delta != null) ...[
            const SizedBox(height: 4),
            Text(delta!, style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen)),
          ],
        ],
      ),
    );
  }
}
