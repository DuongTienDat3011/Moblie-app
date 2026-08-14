import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/lot_provider.dart';
import '../../../providers/order_provider.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/loading_overlay.dart';

class BuyerPlaceOrderScreen extends ConsumerStatefulWidget {
  final String lotId;
  const BuyerPlaceOrderScreen({super.key, required this.lotId});
  @override ConsumerState<BuyerPlaceOrderScreen> createState() => _State();
}

class _State extends ConsumerState<BuyerPlaceOrderScreen> {
  final _addressCtrl = TextEditingController(
      text: '128 Trần Hưng Đạo, Quận 1, TP.HCM');
  final _receiverCtrl = TextEditingController(text: 'Lê Minh Tuấn');
  final _phoneCtrl    = TextEditingController(text: '0908 776 554');
  final _dateCtrl     = TextEditingController(text: '02/08/2026');
  final _packCtrl     = TextEditingController(text: 'Thùng nhựa 20 kg, có nhãn mã lô');
  final _noteCtrl     = TextEditingController();

  double _qty  = 500;
  bool _useShip = true;
  String _slot = '06:00 – 09:00';
  static const _slots = [
    '06:00 – 09:00', '09:00 – 12:00', '13:00 – 16:00'
  ];

  @override
  void dispose() {
    for (final c in [_addressCtrl, _receiverCtrl, _phoneCtrl,
        _dateCtrl, _packCtrl, _noteCtrl]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lotAsync   = ref.watch(lotDetailProvider(widget.lotId));
    final orderState = ref.watch(placeOrderProvider);

    ref.listen(placeOrderProvider, (_, next) {
      if (next.newOrderId != null) {
        showDialog(context: context, barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 64, height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.lightGreen, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, size: 34,
                    color: AppColors.primaryGreen)),
              const SizedBox(height: 16),
              const Text('Đã gửi đơn hàng!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text(
                'Đơn đã gửi tới HTX. Bạn sẽ nhận thông báo khi xác nhận.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5,
                    color: AppColors.textSecondary)),
            ]),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(placeOrderProvider.notifier).reset();
                  context.go('/buyer');
                },
                child: const Text('Theo dõi đơn hàng')),
            ],
          ));
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error!), backgroundColor: AppColors.red));
      }
    });

    return LoadingOverlay(
      isLoading: orderState.isLoading,
      message: 'Đang đặt hàng…',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Đặt hàng'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop()),
        ),
        body: lotAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(
              color: AppColors.primaryGreen)),
          error: (e, _) => Center(child: Text('Lỗi: $e')),
          data: (lot) {
            if (lot == null) return const Center(
                child: Text('Không tìm thấy lô hàng'));

            final goods  = lot.pricePerKg * _qty;
            final fee    = _useShip ? AppConstants.baseShipFee.toDouble() : 0.0;
            final total  = goods + fee;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Lot summary
                AppCard(padding: const EdgeInsets.all(14),
                  child: Column(children: [
                  Row(children: [
                    ClipRRect(borderRadius: BorderRadius.circular(10),
                      child: lot.thumbnailUrl != null
                          ? Image.network(lot.thumbnailUrl!,
                              width: 64, height: 64, fit: BoxFit.cover)
                          : Container(width: 64, height: 64,
                              color: AppColors.lightGreen,
                              child: const Icon(Icons.eco,
                                  color: AppColors.primaryGreen))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(lot.name, style: const TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w600)),
                      Text('${lot.sellerName} · ${formatPerKg(lot.pricePerKg)}',
                        style: const TextStyle(fontSize: 12,
                            color: AppColors.textSecondary)),
                    ])),
                  ]),
                  const SizedBox(height: 12),
                  // Số lượng
                  Row(children: [
                    const Expanded(child: Text('Số lượng đặt (kg)',
                      style: TextStyle(fontSize: 13.5,
                          color: AppColors.textSecondary))),
                    Row(children: [
                      _QtyBtn(
                        icon: Icons.remove_rounded,
                        onTap: _qty > lot.moqKg
                            ? () => setState(() => _qty = (_qty - 100)
                                .clamp(lot.moqKg, lot.remainKg))
                            : null),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text('${_qty.toInt()}',
                          style: const TextStyle(fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      ),
                      _QtyBtn(
                        icon: Icons.add_rounded,
                        onTap: _qty < lot.remainKg
                            ? () => setState(() => _qty = (_qty + 100)
                                .clamp(lot.moqKg, lot.remainKg))
                            : null),
                    ]),
                  ]),
                  const SizedBox(height: 6),
                  Text('Đặt tối thiểu ${formatQty(lot.moqKg)} · '
                      'còn ${formatQty(lot.remainKg)}',
                    style: const TextStyle(fontSize: 11.5,
                        color: AppColors.textSecondary)),
                ])),
                const SizedBox(height: 16),

                // Thông tin nhận hàng
                const Text('Thông tin nhận hàng',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                AppCard(padding: const EdgeInsets.all(14),
                  child: Column(children: [
                  _field('Địa chỉ giao', _addressCtrl,
                      icon: Icons.location_on_outlined, required: true),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _field('Người nhận', _receiverCtrl, required: true)),
                    const SizedBox(width: 10),
                    Expanded(child: _field('Số điện thoại', _phoneCtrl,
                        icon: Icons.phone_outlined, required: true)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _field('Ngày mong muốn', _dateCtrl,
                        icon: Icons.calendar_today_outlined)),
                    const SizedBox(width: 10),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Khung giờ', style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _slot,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AppColors.divider)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AppColors.divider)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        items: _slots.map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s, style: const TextStyle(fontSize: 13))
                        )).toList(),
                        onChanged: (v) => setState(() => _slot = v!),
                      ),
                    ])),
                  ]),
                  const SizedBox(height: 12),
                  _field('Yêu cầu đóng gói', _packCtrl),
                  const SizedBox(height: 12),
                  _field('Ghi chú chất lượng', _noteCtrl,
                      hint: 'VD: chọn quả chín đều, không dập',
                      maxLines: 3),
                ])),
                const SizedBox(height: 16),

                // Phương thức giao
                const Text('Phương thức giao',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _ShipOption(
                    label: 'Đối tác hệ thống',
                    sub: formatMoney(AppConstants.baseShipFee),
                    selected: _useShip,
                    onTap: () => setState(() => _useShip = true),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _ShipOption(
                    label: 'Tự nhận tại vườn',
                    sub: 'Miễn phí',
                    selected: !_useShip,
                    onTap: () => setState(() => _useShip = false),
                  )),
                ]),
                const SizedBox(height: 16),

                // Tổng cộng
                AppCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  child: Column(children: [
                    _sumRow('Tạm tính tiền hàng', formatMoney(goods)),
                    const Divider(height: 1, color: Color(0xFFF0F2F0)),
                    _sumRow('Phí vận chuyển dự kiến',
                        fee > 0 ? formatMoney(fee) : 'Miễn phí (tự nhận)'),
                    const Divider(height: 1, color: Color(0xFFF0F2F0)),
                    _sumRow('Tổng cộng', formatMoney(total),
                        bold: true, color: AppColors.darkGreen),
                  ]),
                ),
                const SizedBox(height: 24),
              ]),
            );
          },
        ),
        bottomNavigationBar: lotAsync.value == null ? null : Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          decoration: const BoxDecoration(color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.divider))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Tổng cộng',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              Text(formatMoney(lotAsync.value!.pricePerKg * _qty +
                  (_useShip ? AppConstants.baseShipFee : 0)),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen)),
            ]),
            const SizedBox(height: 10),
            AppButton(
              label: 'Xác nhận đặt hàng',
              isLoading: orderState.isLoading,
              onPressed: () async {
                final user = ref.read(currentUserProvider).value;
                final lot  = lotAsync.value;
                if (user == null || lot == null) return;
                await ref.read(placeOrderProvider.notifier).placeOrder(
                  lot: lot, buyer: user, qty: _qty,
                  address: _addressCtrl.text.trim(),
                  deliveryDate: _dateCtrl.text.trim(),
                  deliverySlot: _slot,
                  useSystemShip: _useShip,
                  packNote: _packCtrl.text.trim().isEmpty
                      ? null : _packCtrl.text.trim(),
                  qualityNote: _noteCtrl.text.trim().isEmpty
                      ? null : _noteCtrl.text.trim(),
                );
              },
            ),
          ]),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {
    IconData? icon, bool required = false,
    String? hint, int maxLines = 1,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label, style: const TextStyle(
            fontSize: 13, color: AppColors.textSecondary)),
        if (required) const Text(' *',
            style: TextStyle(color: AppColors.red)),
      ]),
      const SizedBox(height: 5),
      TextFormField(
        controller: ctrl, maxLines: maxLines,
        style: const TextStyle(fontSize: 14.5),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, size: 18,
              color: AppColors.textSecondary) : null,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: AppColors.primaryGreen, width: 2)),
        ),
      ),
    ]);
  }

  Widget _sumRow(String label, String value,
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
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QtyBtn({required this.icon, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: onTap != null ? AppColors.lightGreen : AppColors.divider,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18,
          color: onTap != null ? AppColors.darkGreen : AppColors.textHint),
    ),
  );
}

class _ShipOption extends StatelessWidget {
  final String label, sub;
  final bool selected;
  final VoidCallback onTap;
  const _ShipOption({
    required this.label, required this.sub,
    required this.selected, required this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selected ? AppColors.lightGreen : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: selected ? AppColors.primaryGreen : AppColors.divider,
            width: selected ? 2 : 1)),
      child: Column(children: [
        Text(label, style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600,
          color: selected ? AppColors.darkGreen : AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(sub, style: TextStyle(
          fontSize: 12,
          color: selected ? AppColors.primaryGreen : AppColors.textHint)),
      ]),
    ),
  );
}
