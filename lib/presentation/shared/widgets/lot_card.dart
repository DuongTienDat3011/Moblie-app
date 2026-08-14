import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/lot_model.dart';
import 'app_badge.dart';

/// Card lô hàng — dùng ở Home (ngang scroll) và Search (grid 2 cột)
class LotCard extends StatelessWidget {
  final LotModel lot;
  final VoidCallback onTap;
  /// wide = true → chiều ngang full (dùng trong grid)
  /// wide = false → width cố định 196px (dùng trong horizontal scroll)
  final bool wide;

  const LotCard({
    super.key,
    required this.lot,
    required this.onTap,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: wide ? null : 196,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xCCE5E7EB)),
            boxShadow: const [
              BoxShadow(color: Color(0x0A1F2937), blurRadius: 4,
                  offset: Offset(0, 1))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Ảnh ────────────────────────────────────────────────────
              Stack(children: [
                AspectRatio(
                  aspectRatio: wide ? 16 / 9 : 1,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16)),
                    child: lot.thumbnailUrl != null
                        ? CachedNetworkImage(
                            imageUrl: lot.thumbnailUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _placeholder(),
                            errorWidget: (_, __, ___) => _placeholder())
                        : _placeholder(),
                  ),
                ),
                if (lot.discountPercent != null)
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        borderRadius: BorderRadius.circular(6)),
                      child: Text('−${lot.discountPercent}%',
                        style: const TextStyle(
                          color: Colors.white, fontSize: 10,
                          fontWeight: FontWeight.bold)),
                    )),
                // Nút yêu thích
                Positioned(
                  top: 6, right: 6,
                  child: Container(
                    width: 28, height: 28,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                        color: Color(0x1A000000), blurRadius: 4)],
                    ),
                    child: const Icon(Icons.favorite_border_rounded,
                        size: 15, color: AppColors.red),
                  )),
              ]),

              // ── Info ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tên sản phẩm
                    Text(lot.name,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),

                    // Seller + icon xác minh
                    Row(children: [
                      Expanded(child: Text(lot.sellerName,
                        style: const TextStyle(
                            fontSize: 11.5, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)),
                      const Icon(Icons.verified_outlined, size: 12,
                          color: AppColors.primaryGreen),
                    ]),
                    const SizedBox(height: 6),

                    // Giá — dùng Flexible để tránh overflow
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(child: Text(
                          formatPerKg(lot.pricePerKg),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700,
                              color: AppColors.darkGreen),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1)),
                        if (lot.oldPricePerKg != null) ...[
                          const SizedBox(width: 5),
                          Flexible(child: Text(
                            '${lot.oldPricePerKg!.toStringAsFixed(0)} ₫',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textHint,
                                decoration: TextDecoration.lineThrough),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),

                    // Số lượng — maxLines + ellipsis
                    Text(
                      'Còn ${formatQty(lot.remainKg)} · tối thiểu ${formatQty(lot.moqKg)}',
                      style: const TextStyle(
                          fontSize: 11.5, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),

                    // Ngày sẵn hàng
                    Text('Sẵn sàng ${lot.readyDate}',
                      style: const TextStyle(
                          fontSize: 11.5, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),

                    // Badges — giới hạn 2 cert để tránh card cao quá
                    Wrap(
                      spacing: 4, runSpacing: 4,
                      children: [
                        AppBadge(lot.province, tone: 'gray'),
                        ...lot.certs.take(2)
                            .map((c) => AppBadge(c, tone: 'green')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: AppColors.lightGreen,
    child: const Center(
      child: Icon(Icons.eco_rounded, size: 40,
          color: AppColors.primaryGreen)));
}
