import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/shipping_provider.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/section_header.dart';

class HtxShippingScreen extends ConsumerWidget {
  const HtxShippingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUserProvider).value?.uid ?? '';
    final tripsAsync = ref.watch(sellerTripsProvider(uid));
    final matchesAsync = ref.watch(sellerMatchesProvider(uid));
    final ordersAsync = ref.watch(sellerOrdersProvider(uid));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tự động ghép đơn & Chuyến vận chuyển'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Kết quả ghép đơn',
                action: 'Tạo lại',
                onAction: () async {
                  final orders = ordersAsync.value ?? <dynamic>[];
                  if (orders.isEmpty) return;
                  await ref.read(shippingMatchProvider.notifier).runMatchingForSeller(
                    sellerId: uid,
                    orders: orders.cast(),
                  );
                },
              ),
              const SizedBox(height: 12),
              matchesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Không thể tải dữ liệu ghép đơn'),
                data: (matches) {
                  if (matches.isEmpty) {
                    return const AppCard(
                      padding: EdgeInsets.all(20),
                      child: Text('Chưa có match nào được tạo. Hệ thống sẽ tự động ghép khi có đơn xác nhận.'),
                    );
                  }

                  return Column(
                    children: matches.map((match) {
                      return AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    match.routeName,
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.badgeBg(match.status.tone),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    match.status.displayName,
                                    style: TextStyle(
                                      color: AppColors.badgeFg(match.status.tone),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Ngày: ${match.deliveryDate} · ${match.deliverySlot}'),
                            Text('Đơn hàng: ${match.orderIds.length} đơn · ${(match.totalKg).toStringAsFixed(0)} kg'),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final trip = await ref.read(shippingTripProvider.notifier).createTripFromMatch(match);
                                if (trip != null) {
                                  context.push('/htx/trips/${trip.id}');
                                }
                              },
                              icon: const Icon(Icons.local_shipping_outlined),
                              label: const Text('Tạo chuyến'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),
              SectionHeader(title: 'Chuyến vận chuyển'),
              const SizedBox(height: 12),
              tripsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Không thể tải chuyến vận chuyển'),
                data: (trips) {
                  if (trips.isEmpty) {
                    return const AppCard(
                      padding: EdgeInsets.all(20),
                      child: Text('Chưa có chuyến nào được tạo.'),
                    );
                  }

                  return Column(
                    children: trips.map((trip) {
                      return AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    trip.tripCode,
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.badgeBg(trip.status.tone),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    trip.status.displayName,
                                    style: TextStyle(
                                      color: AppColors.badgeFg(trip.status.tone),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Lộ trình: ${trip.routeName}'),
                            Text('Ngày: ${trip.deliveryDate} · ${trip.departureSlot}'),
                            Text('Đơn: ${trip.orderIds.length} · ${trip.totalKg} kg'),
                            if (trip.trackingUrl != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Tracking: ${trip.trackingUrl}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
