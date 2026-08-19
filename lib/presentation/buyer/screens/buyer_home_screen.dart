import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/lot_provider.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/lot_card.dart';
import '../../shared/widgets/section_header.dart';

class BuyerHomeScreen extends ConsumerWidget {
  const BuyerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user        = ref.watch(currentUserProvider).value;
    final lotsAsync   = ref.watch(featuredLotsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header xanh lá (đúng Figma BUYER_01) ─────────────────────
          SliverAppBar(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            floating: true, snap: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Column(children: [
                    Row(children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(38),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Center(
                          child: Text(
                            (user?.displayName ?? 'A').substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white, fontSize: 15,
                              fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Xin chào,',
                            style: TextStyle(fontSize: 12, color: Colors.white70)),
                          Text(
                            user?.orgName ?? user?.displayName ?? 'Đơn vị thu mua',
                            style: const TextStyle(fontSize: 16,
                                fontWeight: FontWeight.w600, color: Colors.white),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      )),
                      IconButton(
                        icon: const Icon(Icons.notifications_none_rounded,
                            color: Colors.white),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Chưa có thông báo mới'),
                              duration: Duration(seconds: 1)));
                        },
                      ),
                    ]),
                    const SizedBox(height: 10),
                    // Search bar — Expanded để tránh overflow
                    GestureDetector(
                      onTap: () => context.push('/buyer/search'),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: const Row(children: [
                          Icon(Icons.search_rounded, size: 19,
                              color: Color(0xFF6B7280)),
                          SizedBox(width: 8),
                          Expanded(child: Text(
                            'Tìm nông sản, hợp tác xã, mã lô…',
                            style: TextStyle(fontSize: 14,
                                color: Color(0xFF9CA3AF)),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1)),
                        ]),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(delegate: SliverChildListDelegate([

              // ── Banner mùa vụ ─────────────────────────────────────────
              GestureDetector(
                onTap: () => context.push('/buyer/search'),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 130, width: double.infinity,
                    child: Stack(children: [
                      lotsAsync.when(
                        loading: () => Container(color: AppColors.lightGreen),
                        error: (_, __) => Container(color: AppColors.lightGreen),
                        data: (lots) => lots.isNotEmpty && lots.first.thumbnailUrl != null
                            ? CachedNetworkImage(
                                imageUrl: lots.first.thumbnailUrl!,
                                fit: BoxFit.cover, width: double.infinity, height: 130)
                            : Container(color: AppColors.lightGreen,
                                child: const Icon(Icons.eco, size: 56,
                                    color: AppColors.primaryGreen)),
                      ),
                      // Gradient overlay
                      Container(decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft, end: Alignment.centerRight,
                          colors: [Color(0xD91B5E20), Color(0x331B5E20)],
                        ),
                      )),
                      const Positioned(left: 16, right: 80, top: 0, bottom: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('THÁNG 8 · 2026',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                                  letterSpacing: 1.4, color: Colors.white70)),
                            SizedBox(height: 4),
                            Text('Nông sản theo mùa',
                              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                            SizedBox(height: 3),
                            Text('Vải thiều, thanh long, xoài chính vụ',
                              style: TextStyle(fontSize: 12.5,
                                  color: Color(0xD9FFFFFF))),
                          ],
                        )),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Categories (5 ô) ──────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ('Rau', Icons.grass_rounded),
                  ('Củ', Icons.radio_button_unchecked_rounded),
                  ('Quả', Icons.circle_outlined),
                  ('Gạo', Icons.grain_rounded),
                  ('Khác', Icons.more_horiz_rounded),
                ].map((c) => GestureDetector(
                  onTap: () => context.push('/buyer/search'),
                  child: Column(children: [
                    Container(
                      width: 58, height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Icon(c.$2, size: 22, color: AppColors.darkGreen),
                    ),
                    const SizedBox(height: 5),
                    Text(c.$1,
                      style: const TextStyle(fontSize: 11.5,
                          fontWeight: FontWeight.w500)),
                  ]),
                )).toList(),
              ),
              const SizedBox(height: 24),

              // ── Lô hàng mới ───────────────────────────────────────────
              SectionHeader(title: 'Lô hàng mới',
                action: 'Xem tất cả',
                onAction: () => context.push('/buyer/search')),
              const SizedBox(height: 12),
              lotsAsync.when(
                loading: () => const SizedBox(height: 220,
                    child: Center(child: CircularProgressIndicator(
                        color: AppColors.primaryGreen))),
                error: (_, __) => const SizedBox.shrink(),
                data: (lots) => SizedBox(
                  height: 258,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: lots.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => LotCard(
                      lot: lots[i],
                      onTap: () => context.push('/buyer/lot/${lots[i].id}'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── HTX uy tín ────────────────────────────────────────────
              const SectionHeader(title: 'Hợp tác xã uy tín'),
              const SizedBox(height: 12),
              ...[
                ('HTX Rau sạch Đà Lạt', 'Lâm Đồng', 4.9, 128),
                ('HTX Thanh long Bình Thuận', 'Bình Thuận', 4.8, 96),
              ].map((h) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  onTap: () => context.push('/buyer/search'),
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 24, backgroundColor: AppColors.lightGreen,
                      child: const Icon(Icons.eco, color: AppColors.primaryGreen)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(h.$1,
                          style: const TextStyle(fontSize: 14.5,
                              fontWeight: FontWeight.w600),
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_outlined, size: 14,
                            color: AppColors.primaryGreen),
                      ]),
                      Text('${h.$2} · ${h.$4} đơn đã giao',
                        style: const TextStyle(fontSize: 12,
                            color: AppColors.textSecondary)),
                    ])),
                    const SizedBox(width: 8),
                    Row(children: [
                      const Icon(Icons.star_rounded, size: 14,
                          color: Color(0xFFF9A825)),
                      const SizedBox(width: 3),
                      Text('${h.$3}',
                        style: const TextStyle(fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    ]),
                  ]),
                ),
              )),
              const SizedBox(height: 24),
            ])),
          ),
        ],
      ),
    );
  }
}
