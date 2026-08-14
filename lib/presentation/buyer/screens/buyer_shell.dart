import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/order_provider.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import 'buyer_home_screen.dart';
import 'buyer_search_screen.dart';
import 'buyer_order_list_screen.dart';
import 'buyer_profile_screen.dart';

class BuyerShell extends ConsumerStatefulWidget {
  const BuyerShell({super.key});
  @override ConsumerState<BuyerShell> createState() => _BuyerShellState();
}

class _BuyerShellState extends ConsumerState<BuyerShell> {
  int _index = 0;

  final _screens = const [
    BuyerHomeScreen(),
    BuyerSearchScreen(),
    BuyerOrderListScreen(),
    BuyerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUserProvider).value?.uid ?? '';
    final ordersAsync = ref.watch(buyerOrdersProvider(uid));

    final pendingCount = ordersAsync.when(
      data: (orders) => orders
          .where((o) => o.status.name == 'pendingConfirm')
          .length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    final items = [
      const NavItem(label: 'Trang chủ',
          icon: Icons.home_outlined, activeIcon: Icons.home_rounded),
      const NavItem(label: 'Tìm kiếm',
          icon: Icons.search_outlined, activeIcon: Icons.search_rounded),
      NavItem(label: 'Đơn hàng',
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long_rounded,
          badge: pendingCount),
      const NavItem(label: 'Tài khoản',
          icon: Icons.person_outline, activeIcon: Icons.person_rounded),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: AppBottomNavBar(
        items: items,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
