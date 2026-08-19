import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/lot_model.dart';

/// Card lô hàng
/// wide = true  → dùng trong grid 2 cột (search)
/// wide = false → dùng trong horizontal scroll (home)
class LotCard extends StatelessWidget {
  final LotModel lot;
  final VoidCallback onTap;
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
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: wide ? null : 175,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: const [
              BoxShadow(color: Color(0x0A000000), blurRadius: 4,
                  offset: Offset(0, 1))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Ảnh ─────────────────────────────────────────────────
              Stack(children: [
                SizedBox(
                  height: 130,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14)),
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
                        style: const TextStyle(color: Colors.white,
                            fontSize: 10, fontWeight: FontWeight.bold)),
                    )),
                Positioned(
                  top: 6, right: 6,
                  child: Container(
                    width: 28, height: 28,
                    decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                          color: Color(0x15000000), blurRadius: 4)],
                    ),
                    child: const Icon(Icons.favorite_border_rounded,
                        size: 15, color: AppColors.red),
                  )),
              ]),

              // ── Info ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tên
                    Text(lot.name,
                      style: const TextStyle(fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    // Seller
                    Row(children: [
                      Expanded(child: Text(lot.sellerName,
                        style: const TextStyle(fontSize: 11.5,
                            color: AppColors.textSecondary),
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                      const Icon(Icons.verified_outlined, size: 12,
                          color: AppColors.primaryGreen),
                    ]),
                    const SizedBox(height: 5),
                    // Giá
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(child: Text(formatPerKg(lot.pricePerKg),
                          style: const TextStyle(fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkGreen),
                          overflow: TextOverflow.ellipsis, maxLines: 1)),
                        if (lot.oldPricePerKg != null) ...[
                          const SizedBox(width: 4),
                          Flexible(child: Text(
                            '${lot.oldPricePerKg!.toStringAsFixed(0)}₫',
                            style: const TextStyle(fontSize: 10.5,
                                color: AppColors.textHint,
                                decoration: TextDecoration.lineThrough),
                            overflow: TextOverflow.ellipsis, maxLines: 1)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    // Còn lại
                    Text('Còn ${formatQty(lot.remainKg)}',
                      style: const TextStyle(fontSize: 11.5,
                          color: AppColors.textSecondary),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
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
    child: const Center(child: Icon(Icons.eco_rounded,
        size: 40, color: AppColors.primaryGreen)));
}
