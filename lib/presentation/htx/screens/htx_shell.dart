import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/enums/app_enums.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/order_provider.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import 'htx_dashboard_screen.dart';
import 'htx_lot_list_screen.dart';
import 'htx_order_list_screen.dart';
import 'htx_inventory_screen.dart';
import 'htx_profile_screen.dart';

class HtxShell extends ConsumerStatefulWidget {
  const HtxShell({super.key});
  @override
  ConsumerState<HtxShell> createState() => _HtxShellState();
}

class _HtxShellState extends ConsumerState<HtxShell> {
  int _index = 0;

  final _screens = const [
    HtxDashboardScreen(),
    HtxLotListScreen(),
    HtxOrderListScreen(),
    HtxInventoryScreen(),
    HtxProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Badge đơn hàng mới — realtime từ Firestore
    final uid = ref.watch(currentUserProvider).value?.uid ?? '';
    final ordersAsync = ref.watch(sellerOrdersProvider(uid));
    final pendingCount = ordersAsync.when(
      data: (orders) => orders
          .where((o) => o.status.name == OrderStatus.pendingConfirm.name)
          .length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    final items = [
      const NavItem(label: 'Tổng quan',
          icon: Icons.home_outlined, activeIcon: Icons.home_rounded),
      const NavItem(label: 'Lô hàng',
          icon: Icons.inventory_2_outlined,
          activeIcon: Icons.inventory_2_rounded),
      NavItem(label: 'Đơn hàng',
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long_rounded,
          badge: pendingCount), // ← realtime badge
      const NavItem(label: 'Hàng tồn',
          icon: Icons.warehouse_outlined,
          activeIcon: Icons.warehouse_rounded),
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
