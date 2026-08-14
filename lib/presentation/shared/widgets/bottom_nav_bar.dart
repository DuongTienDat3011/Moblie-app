import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final int badge;

  const NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.badge = 0,
  });
}

class AppBottomNavBar extends StatelessWidget {
  final List<NavItem> items;
  final int currentIndex;
  final void Function(int) onTap;

  const AppBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final isActive = i == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 56, height: 30,
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.lightGreen : Colors.transparent,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              isActive ? item.activeIcon : item.icon,
                              size: 22,
                              color: isActive ? AppColors.darkGreen : AppColors.textSecondary,
                            ),
                          ),
                          if (item.badge > 0)
                            Positioned(
                              right: 6, top: -2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('${item.badge}',
                                  style: const TextStyle(
                                    color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                          color: isActive ? AppColors.darkGreen : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
