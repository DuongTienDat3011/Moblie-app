import 'package:flutter/material.dart';

/// Bảng màu lấy trực tiếp từ Figma design system của nhóm
class AppColors {
  AppColors._();

  // Primary
  static const Color primaryGreen   = Color(0xFF2E7D32);
  static const Color darkGreen      = Color(0xFF1B5E20);
  static const Color lightGreen     = Color(0xFFE8F5E9);
  static const Color midGreen       = Color(0xFF256628);

  // Secondary / Status
  static const Color orange         = Color(0xFFF57C00);
  static const Color orangeSurface  = Color(0xFFFFF1E0);
  static const Color yellow         = Color(0xFFF9A825);
  static const Color yellowSurface  = Color(0xFFFDF6DC);
  static const Color red            = Color(0xFFC62828);
  static const Color redSurface     = Color(0xFFFDEAEA);
  static const Color blue           = Color(0xFF1976D2);
  static const Color blueSurface    = Color(0xFFE5F0FB);
  static const Color lilac          = Color(0xFF5B3EA8);
  static const Color lilacSurface   = Color(0xFFEFE9FA);

  // Neutrals
  static const Color background     = Color(0xFFF6F8F6);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color divider        = Color(0xFFE5E7EB);
  static const Color dividerLight   = Color(0xFFF0F2F0);
  static const Color inputBg        = Color(0xFFF2F4F2);

  // Text
  static const Color textPrimary    = Color(0xFF1F2937);
  static const Color textSecondary  = Color(0xFF6B7280);
  static const Color textHint       = Color(0xFF9CA3AF);
  static const Color textDisabled   = Color(0xFFD1D5DB);

  // Badge tone helpers
  static Color badgeBg(String tone) {
    switch (tone) {
      case 'green':  return lightGreen;
      case 'orange': return orangeSurface;
      case 'yellow': return yellowSurface;
      case 'red':    return redSurface;
      case 'blue':   return blueSurface;
      case 'lilac':  return lilacSurface;
      default:       return const Color(0xFFF0F2F0);
    }
  }

  static Color badgeFg(String tone) {
    switch (tone) {
      case 'green':  return darkGreen;
      case 'orange': return const Color(0xFFB35C00);
      case 'yellow': return const Color(0xFF8A6D00);
      case 'red':    return red;
      case 'blue':   return const Color(0xFF155FA8);
      case 'lilac':  return lilac;
      default:       return textSecondary;
    }
  }
}
