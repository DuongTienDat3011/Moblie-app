import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/lot_provider.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/lot_card.dart';

class BuyerSearchScreen extends ConsumerStatefulWidget {
  const BuyerSearchScreen({super.key});
  @override ConsumerState<BuyerSearchScreen> createState() => _State();
}

class _State extends ConsumerState<BuyerSearchScreen> {
  final _ctrl   = TextEditingController();
  String _query = '';
  String _chip  = 'Tất cả';

  static const _chips = [
    'Tất cả', 'Lâm Đồng', 'Bình Thuận', 'Đồng Tháp', 'Bắc Giang', 'Sóc Trăng'
  ];

  static const _history = [
    'Cà chua Lâm Đồng', 'Gạo ST25', 'Thanh long ruột đỏ', 'Rau cải VietGAP'
  ];

  static const _categories = [
    'Rau ăn lá', 'Trái cây chính vụ', 'Gạo đặc sản', 'Củ quả bảo quản lạnh'
  ];

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final lotsAsync = ref.watch(featuredLotsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Row(children: [
          Expanded(
            child: Container(
              height: 46, margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F2),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(children: [
                const Icon(Icons.search_rounded, size: 19,
                    color: Color(0xFF6B7280)),
                const SizedBox(width: 8),
                Expanded(child: TextField(
                  controller: _ctrl,
                  autofocus: true,
                  onChanged: (v) => setState(() => _query = v.toLowerCase()),
                  style: const TextStyle(fontSize: 14,
                      color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Tìm nông sản, hợp tác xã, mã lô…',
                    hintStyle: TextStyle(fontSize: 14,
                        color: Color(0xFF9CA3AF)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                )),
                if (_query.isNotEmpty)
                  GestureDetector(
                    onTap: () { _ctrl.clear(); setState(() => _query = ''); },
                    child: const Icon(Icons.close_rounded, size: 18,
                        color: AppColors.textHint),
                  ),
              ]),
            ),
          ),
          Container(
            width: 46, height: 46,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune_rounded, size: 20,
                color: AppColors.darkGreen),
          ),
        ]),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: _chips.map((c) {
                final on = c == _chip;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _chip = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: on ? AppColors.primaryGreen : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: on ? AppColors.primaryGreen : AppColors.divider),
                      ),
                      child: Text(c, style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500,
                        color: on ? Colors.white : AppColors.textSecondary,
                      )),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: lotsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(
            color: AppColors.primaryGreen)),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (lots) {
          var filtered = lots;
          if (_chip != 'Tất cả') {
            filtered = filtered.where((l) => l.province == _chip).toList();
          }
          if (_query.isNotEmpty) {
            filtered = filtered.where((l) =>
              l.name.toLowerCase().contains(_query) ||
              l.sellerName.toLowerCase().contains(_query) ||
              l.code.toLowerCase().contains(_query)).toList();
          }

          return CustomScrollView(
            slivers: [
              // Lịch sử + danh mục khi chưa tìm
              if (_query.isEmpty) ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        const Expanded(child: Text('Lịch sử tìm kiếm',
                          style: TextStyle(fontSize: 15,
                              fontWeight: FontWeight.w600))),
                        TextButton(
                          onPressed: () => setState(() {
                            _ctrl.clear();
                            _query = '';
                          }),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero, minimumSize: Size.zero),
                          child: const Text('Xóa',
                            style: TextStyle(fontSize: 13,
                                color: AppColors.primaryGreen))),
                      ]),
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, runSpacing: 8,
                        children: _history.map((s) => GestureDetector(
                          onTap: () {
                            _ctrl.text = s.split(' ')[0];
                            setState(() => _query = s.split(' ')[0].toLowerCase());
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.history_rounded, size: 13,
                                  color: AppColors.textHint),
                              const SizedBox(width: 5),
                              Text(s, style: const TextStyle(fontSize: 12.5,
                                  color: Color(0xFF4B5563))),
                            ]),
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: 20),
                      const Text('Danh mục phổ biến',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 2, shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10, mainAxisSpacing: 10,
                        childAspectRatio: 2.5,
                        children: _categories.map((c) => AppCard(
                          onTap: () {
                            // Search theo danh mục
                            setState(() {
                              _query = c.split(' ').first.toLowerCase();
                              _ctrl.text = c.split(' ').first;
                            });
                          },
                          padding: const EdgeInsets.all(12),
                          child: Row(children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.lightGreen,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.eco_rounded, size: 18,
                                  color: AppColors.primaryGreen),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(c, style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                              maxLines: 2, overflow: TextOverflow.ellipsis)),
                          ]),
                        )).toList(),
                      ),
                      const SizedBox(height: 20),
                    ]),
                  ),
                ),
              ],

              // Kết quả
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Row(children: [
                    Expanded(child: Text('Kết quả (${filtered.length})',
                      style: const TextStyle(fontSize: 15,
                          fontWeight: FontWeight.w600))),
                    TextButton(
                      onPressed: () {
                        // Sắp xếp theo giá tăng dần
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã sắp xếp theo giá tăng dần'),
                            duration: Duration(seconds: 1)));
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero, minimumSize: Size.zero),
                      child: const Text('Sắp xếp',
                        style: TextStyle(fontSize: 13,
                            color: AppColors.primaryGreen))),
                  ]),
                ),
              ),

              if (filtered.isEmpty)
                SliverFillRemaining(child: EmptyStateWidget(
                  icon: Icons.search_off_rounded,
                  title: 'Không tìm thấy nông sản phù hợp',
                  description: 'Thử từ khóa khác hoặc mở rộng bộ lọc.',
                  actionLabel: 'Đặt lại',
                  onAction: () {
                    _ctrl.clear();
                    setState(() { _query = ''; _chip = 'Tất cả'; });
                  },
                ))
              else
                SliverPadding(
                  padding: const EdgeInsets.all(12),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => LotCard(
                        lot: filtered[i], wide: true,
                        onTap: () =>
                            context.push('/buyer/lot/${filtered[i].id}'),
                      ),
                      childCount: filtered.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 10,
                      mainAxisSpacing: 10, childAspectRatio: 0.78,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
