import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
              letterSpacing: -0.3))),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
            ),
            child: Text(action!, style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryGreen)),
          ),
      ],
    );
  }
}
