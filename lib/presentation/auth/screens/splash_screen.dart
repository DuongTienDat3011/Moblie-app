import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreen,
      body: Stack(
        children: [
          // radial gradient background
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.6, -0.7),
                  radius: 1.2,
                  colors: [
                    const Color(0xFFC8E6C9),
                    AppColors.lightGreen.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Container(
                  width: 84, height: 84,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.18),
                        blurRadius: 30, offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(Icons.eco_rounded, size: 48, color: AppColors.primaryGreen),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Nông sản Việt',
                  style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    letterSpacing: 2.5, color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(AppConstants.appSubtitle,
                  style: TextStyle(
                    fontSize: 14.5, fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen, height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text('Kết nối Hợp tác xã, Nhà vườn\nvà đơn vị thu mua trên cả nước',
                  style: TextStyle(fontSize: 13.5, color: Color(0xFF4B5563), height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 120,
                  child: LinearProgressIndicator(
                    backgroundColor: AppColors.primaryGreen.withOpacity(0.15),
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: 28, left: 0, right: 0,
            child: Text('Phiên bản ${AppConstants.appVersion}',
              style: TextStyle(fontSize: 12, color: AppColors.textHint),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
