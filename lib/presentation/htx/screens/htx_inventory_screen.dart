import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/lot_provider.dart';
import '../../shared/widgets/app_badge.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/stat_card.dart';

class HtxInventoryScreen extends ConsumerWidget {
  const HtxInventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUserProvider).value?.uid ?? '';
    final lotsAsync = ref.watch(sellerLotsProvider(uid));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Quản lý hàng tồn')),
      body: lotsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (lots) {
          if (lots.isEmpty) return EmptyStateWidget(
            icon: Icons.warehouse_outlined,
            title: 'Chưa có lô hàng nào',
            description: 'Đăng lô nông sản để quản lý tồn kho.');

          final good    = lots.where((l) => l.quality.name == 'good').length;
          final urgent  = lots.where((l) => l.quality.name == 'urgent').length;
          final reject  = lots.where((l) => l.quality.name == 'rejected').length;
          final totalKg = lots.fold<double>(0, (s, l) => s + l.remainKg);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Stats
              GridView.count(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.4,
                children: [
                  StatCard(label: 'Tổng tồn', value: formatQty(totalKg),
                      icon: Icons.warehouse_outlined, tone: 'blue'),
                  StatCard(label: 'Còn tốt', value: '$good',
                      icon: Icons.check_circle_outline, tone: 'green'),
                  StatCard(label: 'Cần bán sớm', value: '$urgent',
                      icon: Icons.access_time_rounded, tone: 'orange'),
                  StatCard(label: 'Không đạt', value: '$reject',
                      icon: Icons.warning_amber_rounded, tone: 'red'),
                ],
              ),
              const SizedBox(height: 20),

              // Lot list
              ...lots.map((lot) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(lot.name,
                          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
                        Text(lot.code,
                          style: const TextStyle(fontFamily: 'monospace',
                              fontSize: 11, color: AppColors.textSecondary)),
                      ])),
                      AppBadge(lot.quality.displayName, tone: lot.quality.tone),
                    ]),
                    const SizedBox(height: 12),

                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: lot.soldPercent,
                        backgroundColor: AppColors.divider,
                        color: AppColors.badgeFg(lot.quality.tone),
                        minHeight: 7,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Thu hoạch', style: TextStyle(fontSize: 11, color: AppColors.textHint)),
                        Text(lot.harvestDate, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      ])),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                        const Text('Còn lại', style: TextStyle(fontSize: 11, color: AppColors.textHint)),
                        Text(formatQty(lot.remainKg),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      ])),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        const Text('Sử dụng', style: TextStyle(fontSize: 11, color: AppColors.textHint)),
                        Text(lot.daysLeft != null ? 'Còn ${lot.daysLeft} ngày' : 'N/A',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                              color: AppColors.badgeFg(lot.quality.tone))),
                      ])),
                    ]),
                    const SizedBox(height: 8),

                    Row(children: [
                      Text(formatPerKg(lot.pricePerKg),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                            color: AppColors.darkGreen)),
                      const Spacer(),
                      if (lot.quality.name == 'urgent') ...[
                        TextButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(
                                'Đang giảm giá lô ${lot.name}...'),
                                duration: const Duration(seconds: 2)));
                          },
                          icon: const Icon(Icons.discount_outlined, size: 16),
                          label: const Text('Giảm giá',
                              style: TextStyle(fontSize: 13)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            foregroundColor: AppColors.orange,
                          ),
                        ),
                      ],
                    ]),
                  ]),
                ),
              )).toList(),
            ],
          );
        },
      ),
    );
  }
}
