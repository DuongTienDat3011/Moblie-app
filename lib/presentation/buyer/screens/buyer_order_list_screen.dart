import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/order_provider.dart';
import '../../shared/widgets/app_badge.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/empty_state.dart';

class BuyerOrderListScreen extends ConsumerStatefulWidget {
  const BuyerOrderListScreen({super.key});
  @override ConsumerState<BuyerOrderListScreen> createState() => _State();
}

class _State extends ConsumerState<BuyerOrderListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  static const _tabs = [
    'Chờ xác nhận', 'Đã xác nhận', 'Đang giao', 'Hoàn thành', 'Đã hủy'
  ];
  static const _statusMap = {
    0: 'pendingConfirm', 1: 'confirmed', 2: 'inTransit',
    3: 'completed', 4: 'cancelled',
  };

  @override void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this);
  }
  @override void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUserProvider).value?.uid ?? '';
    final ordersAsync = ref.watch(buyerOrdersProvider(uid));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Đơn hàng của tôi'),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryGreen,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 13.5),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(
            color: AppColors.primaryGreen)),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (orders) => TabBarView(
          controller: _tab,
          children: List.generate(5, (i) {
            final list = orders.where((o) =>
                o.status.name == _statusMap[i]).toList();
            if (list.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.receipt_long_outlined,
                title: 'Không có đơn "${_tabs[i]}"',
                description: 'Đơn hàng ở trạng thái này sẽ hiển thị tại đây.',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, j) => _OrderCard(order: list[j]),
            );
          }),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push('/buyer/order/${order.id}'),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(
            'DH-${order.id.substring(0, 8).toUpperCase()}',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12,
                fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
          const Spacer(),
          AppBadge(order.status.displayName, tone: order.status.tone),
        ]),
        const SizedBox(height: 8),
        Text(order.lotName,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 3),
        Text('${order.sellerName} · ${formatQty(order.qty)} · ${order.deliveryDate}',
          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Row(children: [
          Text(formatMoney(order.grandTotal),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                color: AppColors.darkGreen)),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
        ]),
      ]),
    );
  }
}
