import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/lot_provider.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_button.dart';

class BuyerLotDetailScreen extends ConsumerStatefulWidget {
  final String lotId;
  const BuyerLotDetailScreen({super.key, required this.lotId});

  @override
  ConsumerState<BuyerLotDetailScreen> createState() => _State();
}

class _State extends ConsumerState<BuyerLotDetailScreen> {
  bool _isFav = false;

  @override
  Widget build(BuildContext context) {
    final lotAsync = ref.watch(lotDetailProvider(widget.lotId));

    return lotAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(
            color: AppColors.primaryGreen))),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Lỗi: $e'))),
      data: (lot) {
        if (lot == null) return Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text('Không tìm thấy lô hàng')));

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(slivers: [
            // ── Ảnh header ──────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 230,
              pinned: true,
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => context.pop()),
              actions: [
                // Nút yêu thích — toggle state
                IconButton(
                  icon: Icon(
                    _isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: _isFav ? Colors.red[300] : Colors.white),
                  onPressed: () {
                    setState(() => _isFav = !_isFav);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(_isFav
                          ? 'Đã thêm "${lot.name}" vào yêu thích'
                          : 'Đã xóa khỏi yêu thích'),
                      duration: const Duration(seconds: 1)));
                  }),
                // Nút chia sẻ
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.white),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(
                        text: 'Lô hàng: ${lot.name}\n'
                            'Giá: ${formatPerKg(lot.pricePerKg)}\n'
                            'Mã lô: ${lot.code}'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã sao chép thông tin lô hàng'),
                        duration: Duration(seconds: 1)));
                  }),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(children: [
                  lot.thumbnailUrl != null
                      ? CachedNetworkImage(
                          imageUrl: lot.thumbnailUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity, height: 230)
                      : Container(color: AppColors.lightGreen,
                          child: const Icon(Icons.eco, size: 72,
                              color: AppColors.primaryGreen)),
                  // Dots
                  Positioned(bottom: 12, left: 0, right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        lot.imageUrls.length.clamp(1, 4),
                        (i) => Container(
                          width: i == 0 ? 20 : 8, height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: i == 0 ? Colors.white : Colors.white60,
                            borderRadius: BorderRadius.circular(4)))))),
                ]),
              ),
            ),

            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // ── Tên + mã lô ────────────────────────────────────────
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(lot.name, style: const TextStyle(
                      fontSize: 21, fontWeight: FontWeight.bold,
                      height: 1.2, letterSpacing: -0.3)),
                    const SizedBox(height: 4),
                    Text(lot.code, style: const TextStyle(
                      fontFamily: 'monospace', fontSize: 12,
                      color: AppColors.textSecondary)),
                  ])),
                  const SizedBox(width: 12),
                  // QR — tap để sao chép mã lô
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: lot.code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã sao chép mã lô'),
                          duration: Duration(seconds: 1)));
                    },
                    child: Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider)),
                      child: const Icon(Icons.qr_code_2_rounded, size: 36)),
                  ),
                ]),
                const SizedBox(height: 14),

                // ── Giá ───────────────────────────────────────────────
                AppCard(
                  color: AppColors.lightGreen,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    const Text('Giá hiện tại', style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                    Text(formatPerKg(lot.pricePerKg), style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w800,
                      color: AppColors.darkGreen, height: 1.2)),
                    if (lot.discountPercent != null)
                      Text(
                        'Giảm ${lot.discountPercent}% so với giá cũ '
                        '(${formatPerKg(lot.oldPricePerKg!)})',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.red)),
                  ]),
                ),
                const SizedBox(height: 12),

                // ── Thông tin seller ───────────────────────────────────
                AppCard(
                  onTap: () {
                    // Mở sheet thông tin HTX
                    _showSellerSheet(context, lot.sellerName, lot.province);
                  },
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.lightGreen,
                      backgroundImage: lot.sellerAvatar != null
                          ? NetworkImage(lot.sellerAvatar!) : null,
                      child: lot.sellerAvatar == null
                          ? const Icon(Icons.store_outlined,
                              color: AppColors.primaryGreen) : null),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Row(children: [
                        Expanded(child: Text(lot.sellerName,
                          style: const TextStyle(
                              fontSize: 14.5, fontWeight: FontWeight.w600))),
                        const Icon(Icons.verified_outlined, size: 14,
                            color: AppColors.primaryGreen),
                      ]),
                      Row(children: [
                        const Icon(Icons.star_rounded, size: 12,
                            color: Color(0xFFF9A825)),
                        const SizedBox(width: 3),
                        const Text('4.9 · 128 đơn đã giao',
                          style: TextStyle(fontSize: 12.5,
                              color: AppColors.textSecondary)),
                      ]),
                    ])),
                    // Nút gọi điện
                    IconButton(
                      icon: const Icon(Icons.phone_outlined, size: 20,
                          color: AppColors.primaryGreen),
                      onPressed: () => _callSeller(context)),
                  ]),
                ),
                const SizedBox(height: 12),

                // ── Chi tiết lô ────────────────────────────────────────
                AppCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  child: Column(children: [
                    _row('Số lượng còn lại',
                        formatQty(lot.remainKg), bold: true),
                    _div(), _row('Đặt tối thiểu', formatQty(lot.moqKg)),
                    _div(), _row('Ngày thu hoạch', lot.harvestDate),
                    _div(), _row('Ngày có thể giao', lot.readyDate),
                    _div(), _row('Nguồn gốc', lot.province),
                    if (lot.packingSpec.isNotEmpty) ...[
                      _div(), _row('Quy cách đóng gói', lot.packingSpec),
                    ],
                    if (lot.storageCondition != null) ...[
                      _div(), _row('Bảo quản', lot.storageCondition!),
                    ],
                    if (lot.certs.isNotEmpty) ...[
                      _div(), _row('Chứng nhận', lot.certs.join(', '),
                          bold: true, color: AppColors.darkGreen),
                    ],
                  ]),
                ),
                const SizedBox(height: 12),

                // ── Đánh giá ──────────────────────────────────────────
                Row(children: [
                  const Expanded(child: Text('Đánh giá hợp tác xã',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600))),
                  TextButton(
                    onPressed: () {
                      // Hiện tất cả đánh giá
                      _showAllReviews(context, lot.sellerName);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero, minimumSize: Size.zero),
                    child: const Text('Tất cả (42)',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.primaryGreen))),
                ]),
                const SizedBox(height: 8),
                AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(children: [
                    ...[
                      ('Nhà hàng Hương Quê', 5.0,
                          'Rau tươi, đóng gói kỹ, giao đúng khung giờ.'),
                      ('Bếp ăn Minh Phát', 4.0,
                          'Chất lượng ổn định, hỗ trợ xuất hóa đơn nhanh.'),
                    ].map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Row(children: [
                          Expanded(child: Text(r.$1,
                            style: const TextStyle(
                                fontSize: 13.5, fontWeight: FontWeight.w600))),
                          RatingBarIndicator(
                            rating: r.$2, itemSize: 13,
                            itemBuilder: (_, __) => const Icon(
                              Icons.star_rounded, color: Color(0xFFF9A825)),
                            itemCount: 5),
                        ]),
                        const SizedBox(height: 4),
                        Text(r.$3, style: const TextStyle(
                            fontSize: 12.5, color: AppColors.textSecondary,
                            height: 1.4)),
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: Color(0xFFF0F2F0)),
                      ]),
                    )),
                  ]),
                ),
                const SizedBox(height: 80),
              ]),
            )),
          ]),

          // ── Bottom action bar ────────────────────────────────────────
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.divider))),
            child: Row(children: [
              // Gửi đề nghị giá — mở bottom sheet
              Expanded(child: AppButton(
                label: 'Đề nghị giá',
                variant: AppButtonVariant.outline,
                fullWidth: true,
                icon: Icons.handshake_outlined,
                onPressed: () => _showOfferSheet(context, lot.name,
                    lot.pricePerKg),
              )),
              const SizedBox(width: 12),
              // Đặt hàng
              Expanded(child: AppButton(
                label: 'Đặt hàng',
                fullWidth: true,
                icon: Icons.shopping_cart_outlined,
                onPressed: () =>
                    context.push('/buyer/place-order/${widget.lotId}'),
              )),
            ]),
          ),
        );
      },
    );
  }

  // ── Gọi điện cho seller ─────────────────────────────────────────────────
  void _callSeller(BuildContext context) async {
    final uri = Uri.parse('tel:0912345678');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể thực hiện cuộc gọi')));
      }
    }
  }

  // ── Sheet thông tin seller ──────────────────────────────────────────────
  void _showSellerSheet(BuildContext context, String name, String province) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          CircleAvatar(radius: 30, backgroundColor: AppColors.lightGreen,
              child: const Icon(Icons.store, size: 30,
                  color: AppColors.primaryGreen)),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold)),
          Text(province, style: const TextStyle(
              color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          const Divider(),
          _sheetRow(Icons.star_rounded, 'Đánh giá', '4.9 / 5.0 ★'),
          _sheetRow(Icons.receipt_long_outlined, 'Tổng đơn hàng', '128 đơn'),
          _sheetRow(Icons.verified_outlined, 'Chứng nhận', 'VietGAP'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _callSeller(context);
            },
            icon: const Icon(Icons.phone_outlined),
            label: const Text('Gọi điện cho HTX'),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48)),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Widget _sheetRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      Icon(icon, size: 18, color: AppColors.primaryGreen),
      const SizedBox(width: 10),
      Text(label, style: const TextStyle(color: AppColors.textSecondary)),
      const Spacer(),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    ]),
  );

  // ── Sheet tất cả đánh giá ──────────────────────────────────────────────
  void _showAllReviews(BuildContext context, String sellerName) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6, maxChildSize: 0.9, minChildSize: 0.4,
        expand: false,
        builder: (_, ctrl) => Column(children: [
          Padding(padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(child: Text('Đánh giá · $sellerName',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold))),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context)),
            ])),
          const Divider(height: 1),
          Expanded(child: ListView.separated(
            controller: ctrl,
            padding: const EdgeInsets.all(16),
            itemCount: 5,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, i) {
              final names = ['Nhà hàng Hương Quê', 'Bếp ăn Minh Phát',
                'Siêu thị An Việt', 'Cơm văn phòng Thắng Lợi',
                'Canteen Công ty ABC'];
              final comments = [
                'Rau tươi, giao đúng giờ.',
                'Chất lượng ổn định.',
                'Đóng gói sạch sẽ.',
                'Giá tốt, HTX nhiệt tình.',
                'Sẽ tiếp tục đặt hàng.',
              ];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.lightGreen,
                  child: Text(names[i][0],
                    style: const TextStyle(color: AppColors.darkGreen))),
                title: Text(names[i],
                  style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(comments[i]),
                trailing: RatingBarIndicator(
                  rating: 4.5 - i * 0.1, itemSize: 14,
                  itemBuilder: (_, __) =>
                    const Icon(Icons.star_rounded, color: Color(0xFFF9A825)),
                  itemCount: 5),
              );
            },
          )),
        ]),
      ),
    );
  }

  // ── Sheet đề nghị giá ─────────────────────────────────────────────────
  void _showOfferSheet(BuildContext context, String lotName, double price) {
    double offerPrice = price * 0.9;
    final ctrl = TextEditingController(
        text: offerPrice.toInt().toString());
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20, right: 20, top: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.divider,
                borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text('Gửi đề nghị giá cho "$lotName"',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text('Giá niêm yết: ${formatPerKg(price)}',
            style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          TextFormField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Giá đề nghị của bạn (₫/kg)',
              suffixText: '₫/kg',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: AppColors.primaryGreen, width: 2)),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            maxLines: 3, maxLength: 200,
            decoration: InputDecoration(
              labelText: 'Lời nhắn cho HTX (tùy chọn)',
              hintText: 'VD: Chúng tôi cần 500kg/tuần, có thể ký hợp đồng dài hạn',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: AppColors.primaryGreen, width: 2)),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    'Đã gửi đề nghị ${ctrl.text} ₫/kg tới HTX. '
                    'Chờ phản hồi trong 24 giờ.'),
                backgroundColor: AppColors.primaryGreen));
            },
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50)),
            child: const Text('Gửi đề nghị giá'),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _row(String label, String value,
      {bool bold = false, Color? color}) =>
    Padding(padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Text(label, style: const TextStyle(
            fontSize: 13.5, color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: TextStyle(
          fontSize: 14,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          color: color ?? AppColors.textPrimary)),
      ]));

  Widget _div() => const Divider(height: 1, color: Color(0xFFF0F2F0));
}
