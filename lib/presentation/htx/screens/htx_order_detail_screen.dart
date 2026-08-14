import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/order_provider.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';

class HtxOrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const HtxOrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Chi tiết đơn hàng')),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (order) {
          if (order == null) return const Center(child: Text('Không tìm thấy đơn hàng'));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Buyer info
              AppCard(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  CircleAvatar(backgroundColor: AppColors.blueSurface,
                    child: const Icon(Icons.shopping_bag_outlined, color: AppColors.blue)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(order.buyerName,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    Text(order.buyerPhone,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ])),
                  IconButton(
                    icon: const Icon(Icons.phone_outlined,
                        color: AppColors.primaryGreen),
                    onPressed: () async {
                      final uri = Uri.parse('tel:${order.buyerPhone}');
                      try {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(
                                'Gọi: ${order.buyerPhone}')));
                        }
                      }
                    }),
                ]),
              ),
              const SizedBox(height: 12),

              // Lot info
              AppCard(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  if (order.lotImageUrl != null)
                    ClipRRect(borderRadius: BorderRadius.circular(10),
                      child: Image.network(order.lotImageUrl!, width: 68, height: 68, fit: BoxFit.cover))
                  else
                    Container(width: 68, height: 68,
                      decoration: BoxDecoration(color: AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.eco, color: AppColors.primaryGreen)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(order.lotName,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
                    Text(order.lotCode,
                      style: const TextStyle(fontFamily: 'monospace',
                          fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text('${formatQty(order.qty)} × ${formatPerKg(order.pricePerKg)}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ])),
                ]),
              ),
              const SizedBox(height: 12),

              // Details
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(children: [
                  _row('Tiền hàng', formatMoney(order.goodsTotal)),
                  _divider(),
                  _row('Phí vận chuyển', formatMoney(order.shipFee)),
                  _divider(),
                  _row('Tổng thanh toán', formatMoney(order.grandTotal),
                      bold: true, color: AppColors.darkGreen),
                  _divider(),
                  _row('Địa chỉ giao', order.deliveryAddress),
                  _divider(),
                  _row('Ngày giao', order.deliveryDate),
                  _divider(),
                  _row('Khung giờ', order.deliverySlot),
                  if (order.packNote != null) ...[_divider(), _row('Yêu cầu đóng gói', order.packNote!)],
                  if (order.qualityNote != null) ...[_divider(), _row('Ghi chú chất lượng', order.qualityNote!)],
                ]),
              ),
              const SizedBox(height: 20),

              if (order.status.name == 'pendingConfirm') ...[
                AppButton(label: 'Xác nhận đơn', onPressed: () async {
                  await ref.read(placeOrderProvider.notifier).confirmOrder(orderId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã xác nhận đơn hàng'),
                          backgroundColor: AppColors.primaryGreen));
                    context.pop();
                  }
                }),
                const SizedBox(height: 10),
                AppButton(label: 'Từ chối', variant: AppButtonVariant.destructive,
                  onPressed: () async {
                    await ref.read(placeOrderProvider.notifier).cancelOrder(orderId);
                    if (context.mounted) context.pop();
                  }),
              ] else ...[
                AppButton(
                  label: 'Xem trạng thái vận chuyển',
                  variant: AppButtonVariant.secondary,
                  icon: Icons.local_shipping_outlined,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Trạng thái vận chuyển'),
                        content: Column(mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Text('Đơn hàng: ${orderId.substring(0, 8).toUpperCase()}'),
                          const SizedBox(height: 8),
                          Text('Trạng thái: ${order.status.displayName}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text(
                            'Vui lòng liên hệ đơn vị vận chuyển để biết '
                            'thêm chi tiết.',
                            style: TextStyle(color: AppColors.textSecondary)),
                        ]),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Đóng')),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ]),
          );
        },
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false, Color? color}) =>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Text(label, style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
        const SizedBox(width: 16),
        Expanded(child: Text(value, textAlign: TextAlign.right,
          style: TextStyle(fontSize: 14,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: color ?? AppColors.textPrimary))),
      ]),
    );

  Widget _divider() => const Divider(height: 1, thickness: 1, color: Color(0xFFF0F2F0));
}
