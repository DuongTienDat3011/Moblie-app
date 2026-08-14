import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, outline, text, destructive }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;
  final bool small;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = true,
    this.small = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final height = small ? 38.0 : 50.0;
    final fontSize = small ? 13.0 : 15.0;

    Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18, height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == AppButtonVariant.primary ? Colors.white : AppColors.primaryGreen,
            ),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, size: small ? 16 : 20),
          const SizedBox(width: 6),
        ],
        Text(label, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600)),
      ],
    );

    final minSize = Size(fullWidth ? double.infinity : 80, height);
    final radius = BorderRadius.circular(14);

    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: minSize, shape: RoundedRectangleBorder(borderRadius: radius),
            backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white,
            elevation: 0,
          ),
          child: child,
        );
      case AppButtonVariant.secondary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: minSize, shape: RoundedRectangleBorder(borderRadius: radius),
            backgroundColor: AppColors.lightGreen, foregroundColor: AppColors.darkGreen,
            elevation: 0,
          ),
          child: child,
        );
      case AppButtonVariant.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: minSize, shape: RoundedRectangleBorder(borderRadius: radius),
            foregroundColor: AppColors.primaryGreen,
            side: const BorderSide(color: Color(0x662E7D32)),
          ),
          child: child,
        );
      case AppButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            minimumSize: minSize, shape: RoundedRectangleBorder(borderRadius: radius),
            foregroundColor: AppColors.primaryGreen,
          ),
          child: child,
        );
      case AppButtonVariant.destructive:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: minSize, shape: RoundedRectangleBorder(borderRadius: radius),
            foregroundColor: AppColors.red,
            side: const BorderSide(color: Color(0x59C62828)),
            backgroundColor: Colors.white,
          ),
          child: child,
        );
    }
  }
}
