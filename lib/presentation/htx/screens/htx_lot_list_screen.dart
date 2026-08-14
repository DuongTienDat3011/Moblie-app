import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/lot_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/lot_provider.dart';
import '../../shared/widgets/app_badge.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/empty_state.dart';

class HtxLotListScreen extends ConsumerStatefulWidget {
  const HtxLotListScreen({super.key});
  @override ConsumerState<HtxLotListScreen> createState() => _State();
}

class _State extends ConsumerState<HtxLotListScreen> {
  String _filter = 'Tất cả';
  final _filters = ['Tất cả', 'Đang bán', 'Bản nháp', 'Đã bán', 'Hết hạn'];

  @override
  Widget build(BuildContext context) {
    final userAsync  = ref.watch(currentUserProvider);
    final sellerId   = userAsync.value?.uid ?? '';
    final lotsAsync  = ref.watch(sellerLotsProvider(sellerId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lô hàng của tôi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => context.push('/htx/create-lot'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: _filters.map((f) {
                final on = f == _filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f),
                    selected: on,
                    onSelected: (_) => setState(() => _filter = f),
                    selectedColor: AppColors.primaryGreen,
                    labelStyle: TextStyle(
                      color: on ? Colors.white : AppColors.textSecondary,
                      fontWeight: on ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 13,
                    ),
                    backgroundColor: AppColors.surface,
                    showCheckmark: false,
                    side: BorderSide(color: on ? AppColors.primaryGreen : AppColors.divider),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: lotsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (lots) {
          final filtered = _filter == 'Tất cả'
              ? lots
              : lots.where((l) => l.status.displayName == _filter).toList();

          if (filtered.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.inventory_2_outlined,
              title: 'Chưa có lô hàng',
              description: 'Đăng lô nông sản đầu tiên để đơn vị thu mua tìm thấy bạn.',
              actionLabel: 'Đăng lô hàng',
              onAction: () => context.push('/htx/create-lot'),
            );
          }

          return RefreshIndicator(
            color: AppColors.primaryGreen,
            onRefresh: () => ref.refresh(sellerLotsProvider(sellerId).future),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _LotTile(lot: filtered[i]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/htx/create-lot'),
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Thêm lô', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _LotTile extends StatelessWidget {
  final LotModel lot;
  const _LotTile({required this.lot});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push('/htx/lot/${lot.id}'),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
            child: lot.thumbnailUrl != null
                ? Image.network(lot.thumbnailUrl!, width: 92, height: 92, fit: BoxFit.cover)
                : Container(width: 92, height: 92, color: AppColors.lightGreen,
                    child: const Icon(Icons.eco, size: 36, color: AppColors.primaryGreen)),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(lot.name,
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 6),
                  AppBadge(lot.status.displayName, tone: lot.status.tone),
                ]),
                const SizedBox(height: 2),
                Text(lot.code,
                  style: const TextStyle(fontFamily: 'monospace',
                      fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Text(formatPerKg(lot.pricePerKg),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen)),
                const SizedBox(height: 4),
                // Dùng Wrap thay Row để tránh overflow khi text dài
                Wrap(
                  spacing: 4, runSpacing: 2,
                  children: [
                    Text('Còn ${formatQty(lot.remainKg)}',
                      style: const TextStyle(fontSize: 11.5,
                          color: AppColors.textSecondary)),
                    const Text('·',
                        style: TextStyle(color: AppColors.textHint)),
                    Text('Tối thiểu ${formatQty(lot.moqKg)}',
                      style: const TextStyle(fontSize: 11.5,
                          color: AppColors.textSecondary)),
                    const Text('·',
                        style: TextStyle(color: AppColors.textHint)),
                    Text('Thu hoạch ${lot.harvestDate}',
                      style: const TextStyle(fontSize: 11.5,
                          color: AppColors.textSecondary)),
                  ],
                ),
              ]),
            ),
          ),

          // Arrow
          const Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 20),
          ),
        ],
      ),
    );
  }
}
