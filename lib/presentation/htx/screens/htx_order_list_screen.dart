import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/order_provider.dart';
import '../../shared/widgets/app_badge.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/empty_state.dart';

class HtxOrderListScreen extends ConsumerStatefulWidget {
  const HtxOrderListScreen({super.key});
  @override ConsumerState<HtxOrderListScreen> createState() => _State();
}

class _State extends ConsumerState<HtxOrderListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  final _tabs = ['Đơn mới', 'Đã xác nhận', 'Đang giao', 'Hoàn thành', 'Đã hủy'];

  @override void initState() { super.initState(); _tab = TabController(length: 5, vsync: this); }
  @override void dispose()   { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUserProvider).value?.uid ?? '';
    final ordersAsync = ref.watch(sellerOrdersProvider(uid));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Đơn hàng'),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryGreen,
          labelStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (orders) {
          final mapFilter = {
            0: 'pendingConfirm', 1: 'confirmed', 2: 'inTransit',
            3: 'completed', 4: 'cancelled',
          };
          return TabBarView(
            controller: _tab,
            children: List.generate(5, (i) {
              final filtered = orders.where((o) => o.status.name == mapFilter[i]).toList();
              if (filtered.isEmpty) return EmptyStateWidget(
                icon: Icons.receipt_long_outlined,
                title: 'Không có đơn ${_tabs[i].toLowerCase()}',
                description: 'Đơn hàng ở trạng thái này sẽ hiển thị tại đây.');

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, j) => AppCard(
                  onTap: () => context.push('/htx/order/${filtered[j].id}'),
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text('DH-${filtered[j].id.substring(0, 8).toUpperCase()}',
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12,
                            fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const Spacer(),
                      AppBadge(filtered[j].status.displayName, tone: filtered[j].status.tone),
                    ]),
                    const SizedBox(height: 8),
                    Text(filtered[j].buyerName,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('${filtered[j].lotName} · ${formatQty(filtered[j].qty)}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text('Giao ${filtered[j].deliveryDate} · ${filtered[j].deliverySlot}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Text(formatMoney(filtered[j].grandTotal),
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                            color: AppColors.darkGreen)),
                      const Spacer(),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 20),
                    ]),
                  ]),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
