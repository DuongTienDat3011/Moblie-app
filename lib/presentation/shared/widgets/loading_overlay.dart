import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;

  const LoadingOverlay({super.key, required this.child,
      required this.isLoading, this.message});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      child,
      if (isLoading)
        Container(
          color: Colors.black45,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const CircularProgressIndicator(color: AppColors.primaryGreen),
                if (message != null) ...[
                  const SizedBox(height: 14),
                  Text(message!, style: const TextStyle(fontSize: 14)),
                ],
              ]),
            ),
          ),
        ),
    ]);
  }
}
