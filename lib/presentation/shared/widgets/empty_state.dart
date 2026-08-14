import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'app_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: const BoxDecoration(
                color: AppColors.lightGreen, shape: BoxShape.circle),
              child: Icon(icon, size: 28, color: AppColors.primaryGreen),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(description,
              style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.5),
              textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              AppButton(label: actionLabel!, onPressed: onAction,
                variant: AppButtonVariant.secondary, fullWidth: false, small: true),
            ],
          ],
        ),
      ),
    );
  }
}
