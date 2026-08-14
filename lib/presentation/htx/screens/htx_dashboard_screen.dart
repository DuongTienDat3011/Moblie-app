import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/lot_provider.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/app_badge.dart';
import '../../shared/widgets/app_card.dart';

class HtxDashboardScreen extends ConsumerWidget {
  const HtxDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (user) => _Body(sellerId: user?.uid ?? ''),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  final String sellerId;
  const _Body({required this.sellerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync   = ref.watch(currentUserProvider);
    final lotsAsync   = ref.watch(sellerLotsProvider(sellerId));
    final ordersAsync = ref.watch(sellerOrdersProvider(sellerId));

    return CustomScrollView(
      slivers: [
        // ── Green App Bar ─────────────────────────────────────────────────
        SliverAppBar(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          floating: true,
          snap: true,
          expandedHeight: 100,
          flexibleSpace: FlexibleSpaceBar(
            background: Padding(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white24,
                    backgroundImage: userAsync.value?.avatarUrl != null
                        ? NetworkImage(userAsync.value!.avatarUrl!) : null,
                    child: userAsync.value?.avatarUrl == null
                        ? Text(
                            (userAsync.value?.displayName ?? 'H').substring(0, 1),
                            style: const TextStyle(color: Colors.white,
                                fontSize: 16, fontWeight: FontWeight.bold))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Xin chào,',
                        style: TextStyle(fontSize: 12, color: Colors.white70)),
                      Text(
                        userAsync.value?.orgName ?? userAsync.value?.displayName ?? 'HTX',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                            color: Colors.white),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )),
                  // Không hiển thị badge xác minh nữa — tài khoản đã kích hoạt ngay
                ],
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(delegate: SliverChildListDelegate([
            // ── Stats ──────────────────────────────────────────────────
            lotsAsync.when(
              loading: () => const SizedBox(height: 120,
                  child: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))),
              error: (_, __) => const SizedBox.shrink(),
              data: (lots) {
                final activeLots = lots.where((l) => l.status.name == 'active').length;
                return Column(children: [
                  Row(children: [
                    Expanded(child: StatCard(
                      label: 'Lô đang bán', value: '$activeLots',
                      icon: Icons.inventory_2_outlined, tone: 'green',
                      delta: '${lots.length} lô tổng cộng',
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: ordersAsync.when(
                      loading: () => const StatCard(label: 'Đơn cần xử lý',
                          value: '...', icon: Icons.receipt_long_outlined, tone: 'yellow'),
                      error: (_, __) => const StatCard(label: 'Đơn cần xử lý',
                          value: '-', icon: Icons.receipt_long_outlined, tone: 'yellow'),
                      data: (orders) {
                        final pending = orders.where((o) =>
                            o.status.name == 'pendingConfirm').length;
                        return StatCard(
                          label: 'Đơn cần xử lý', value: '$pending',
                          icon: Icons.receipt_long_outlined, tone: 'yellow',
                          delta: 'Đơn mới cần phản hồi',
                        );
                      },
                    )),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: ordersAsync.when(
                      loading: () => const StatCard(label: 'Đang giao',
                          value: '...', icon: Icons.local_shipping_outlined, tone: 'blue'),
                      error: (_, __) => const StatCard(label: 'Đang giao',
                          value: '-', icon: Icons.local_shipping_outlined, tone: 'blue'),
                      data: (orders) {
                        final transit = orders.where((o) =>
                            o.status.name == 'inTransit').length;
                        return StatCard(label: 'Đang giao', value: '$transit',
                            icon: Icons.local_shipping_outlined, tone: 'blue');
                      },
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: ordersAsync.when(
                      loading: () => const StatCard(label: 'Doanh thu tháng',
                          value: '...', icon: Icons.bar_chart_rounded, tone: 'green'),
                      error: (_, __) => const StatCard(label: 'Doanh thu tháng',
                          value: '-', icon: Icons.bar_chart_rounded, tone: 'green'),
                      data: (orders) {
                        final total = orders
                          .where((o) => o.status.name == 'completed')
                          .fold<double>(0, (s, o) => s + o.grandTotal);
                        final m = total >= 1e6 ? '${(total/1e6).toStringAsFixed(0)} tr' : formatMoney(total);
                        return StatCard(label: 'Doanh thu tháng', value: m,
                            icon: Icons.bar_chart_rounded, tone: 'green',
                            delta: '+18% so với tháng trước');
                      },
                    )),
                  ]),
                ]);
              },
            ),
            const SizedBox(height: 24),

            // ── Pending orders ──────────────────────────────────────────
            SectionHeader(
              title: 'Đơn hàng cần xử lý',
              action: 'Xem tất cả',
              onAction: () => context.push('/htx/orders'),
            ),
            const SizedBox(height: 12),
            ordersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
              error: (_, __) => const SizedBox.shrink(),
              data: (orders) {
                final pending = orders.where((o) => o.status.name == 'pendingConfirm').take(3).toList();
                if (pending.isEmpty) {
                  return AppCard(
                    padding: const EdgeInsets.all(16),
                    child: const Center(
                      child: Text('Không có đơn nào cần xử lý',
                        style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  );
                }
                return Column(
                  children: pending.map((o) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      onTap: () => context.push('/htx/order/${o.id}'),
                      padding: const EdgeInsets.all(14),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Text(o.id.length > 8 ? o.id.substring(0, 8).toUpperCase() : o.id,
                            style: const TextStyle(fontFamily: 'monospace',
                                fontSize: 12, fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary)),
                          const Spacer(),
                          AppBadge(o.status.displayName, tone: o.status.tone),
                        ]),
                        const SizedBox(height: 8),
                        Text(o.buyerName,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('${o.lotName} · ${formatQty(o.qty)} · ${o.deliveryDate}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Text(formatMoney(o.grandTotal),
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                              color: AppColors.darkGreen)),
                      ]),
                    ),
                  )).toList(),
                );
              },
            ),
            const SizedBox(height: 24),

            // ── FAB hint ───────────────────────────────────────────────
            Material(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => context.push('/htx/create-lot'),
                borderRadius: BorderRadius.circular(14),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.add_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 8),
                    Text('Đăng lô hàng mới', style: TextStyle(
                        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ])),
        ),
      ],
    );
  }
}
