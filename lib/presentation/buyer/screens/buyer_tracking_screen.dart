import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order_model.dart';
import '../../../providers/order_provider.dart';

class BuyerTrackingScreen extends ConsumerWidget {
  final String orderId;
  const BuyerTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: orderAsync.when(
          loading: () => const Text('Theo dõi vận chuyển'),
          error: (_, __) => const Text('Theo dõi vận chuyển'),
          data: (order) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Theo dõi vận chuyển',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              if (order != null)
                Text('DH-${order.id.substring(0, 16).toUpperCase()}',
                  style: const TextStyle(fontSize: 11.5,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400)),
            ],
          ),
        ),
      ),
      body: orderAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen)),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (order) {
          if (order == null) {
            return const Center(child: Text('Không tìm thấy đơn hàng'));
          }
          return _TrackingBody(order: order);
        },
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────

class _TrackingBody extends StatelessWidget {
  final OrderModel order;
  const _TrackingBody({required this.order});

  @override
  Widget build(BuildContext context) {
    final timeline = _buildTimeline(order);
    final updatedStr = DateFormat('HH:mm · dd/MM/yyyy').format(order.updatedAt);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Trạng thái chính ─────────────────────────────────────────
          _StatusCard(order: order, updatedStr: updatedStr),
          const SizedBox(height: 16),

          // ── Thông tin vận chuyển ──────────────────────────────────────
          _ShippingInfoCard(order: order),
          const SizedBox(height: 20),

          // ── Tiến trình điều phối ──────────────────────────────────────
          const Text('Tiến trình điều phối',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          _TimelineCard(steps: timeline),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<_Step> _buildTimeline(OrderModel order) {
    // Nếu Firestore có timeline đầy đủ
    if (order.timeline.isNotEmpty) {
      return order.timeline.map((t) => _Step(
        title: t.title,
        time: DateFormat('dd/MM/yyyy · HH:mm').format(t.timestamp),
        isDone: t.isDone,
      )).toList();
    }

    // Fallback từ status
    final now   = DateTime.now();
    final fmt   = DateFormat('dd/MM/yyyy · HH:mm');
    final base  = order.createdAt;

    final allSteps = [
      _Step(title: 'Đơn đã xác nhận',
          time: fmt.format(base),
          isDone: true),
      _Step(title: 'Đang gom đơn',
          time: fmt.format(base.add(const Duration(minutes: 6))),
          isDone: order.status.index >= OrderStatus.confirmed.index),
      _Step(title: 'Đã tạo yêu cầu vận chuyển',
          time: fmt.format(base.add(const Duration(minutes: 9))),
          isDone: order.status.index >= OrderStatus.waitingShip.index),
      _Step(title: 'Đã gửi đối tác',
          time: fmt.format(base.add(const Duration(minutes: 10))),
          isDone: order.status.index >= OrderStatus.waitingShip.index),
      _Step(title: 'Đối tác tiếp nhận',
          time: fmt.format(base.add(const Duration(minutes: 12))),
          isDone: order.status.index >= OrderStatus.inTransit.index),
      _Step(title: 'Đã bố trí tài xế',
          time: fmt.format(base.add(const Duration(minutes: 18))),
          isDone: order.status.index >= OrderStatus.inTransit.index),
      _Step(title: 'Đang đến lấy hàng',
          time: fmt.format(now),
          isDone: order.status == OrderStatus.inTransit),
      _Step(title: 'Giao hàng thành công',
          time: order.status == OrderStatus.completed
              ? fmt.format(order.updatedAt) : '',
          isDone: order.status == OrderStatus.completed),
    ];

    if (order.status == OrderStatus.cancelled) {
      return [
        allSteps.first,
        _Step(title: 'Đơn hàng đã bị huỷ',
            time: fmt.format(order.updatedAt),
            isDone: true, isError: true),
      ];
    }
    return allSteps;
  }
}

// ── Status Card ───────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final OrderModel order;
  final String updatedStr;
  const _StatusCard({required this.order, required this.updatedStr});

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = _info(order.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: const [BoxShadow(
            color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 15,
                    fontWeight: FontWeight.w700, color: color)),
                const SizedBox(height: 2),
                Text('Cập nhật lúc $updatedStr',
                  style: const TextStyle(fontSize: 12,
                      color: AppColors.textSecondary)),
              ],
            )),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Trạng thái được đồng bộ từ hệ thống của đối tác vận chuyển '
              'qua webhook. Hợp tác xã không thao tác trực tiếp với tài xế '
              'trong ứng dụng.',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary,
                  height: 1.5)),
          ),
        ],
      ),
    );
  }

  (IconData, String, Color) _info(OrderStatus s) {
    switch (s) {
      case OrderStatus.pendingConfirm:
        return (Icons.hourglass_empty_rounded,
            'Chờ HTX xác nhận', const Color(0xFFF59E0B));
      case OrderStatus.confirmed:
        return (Icons.check_circle_outline_rounded,
            'Đã xác nhận', const Color(0xFF3B82F6));
      case OrderStatus.waitingShip:
        return (Icons.inventory_2_rounded,
            'Chờ bàn giao vận chuyển', const Color(0xFF8B5CF6));
      case OrderStatus.inTransit:
        return (Icons.local_shipping_rounded,
            'Đang đến lấy hàng', AppColors.primaryGreen);
      case OrderStatus.completed:
        return (Icons.check_circle_rounded,
            'Giao hàng thành công', AppColors.darkGreen);
      case OrderStatus.cancelled:
        return (Icons.cancel_rounded,
            'Đơn hàng đã huỷ', AppColors.red);
    }
  }
}

// ── Shipping Info Card ────────────────────────────────────────────────────

class _ShippingInfoCard extends StatelessWidget {
  final OrderModel order;
  const _ShippingInfoCard({required this.order});

  @override
  Widget build(BuildContext context) {
    // ETA: parse deliveryDate an toàn
    String eta = '${order.deliverySlot} · ${order.deliveryDate}';
    try {
      final parts = order.deliveryDate.split('/');
      if (parts.length == 3) {
        final dt = DateTime(int.parse(parts[2]), int.parse(parts[1]),
            int.parse(parts[0]), 10, 40);
        eta = '${DateFormat('HH:mm').format(dt)} · ${order.deliveryDate}';
      }
    } catch (_) {}

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(
            color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(children: [
        _InfoRow('Đối tác vận chuyển', 'Logistics Xanh',
            valueStyle: const TextStyle(fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        _divider(),
        _InfoRow('Mã vận đơn',
            order.trackingCode ?? 'VC-${order.id.substring(0, 14).toUpperCase()}',
            trailing: IconButton(
              onPressed: () {
                final code = order.trackingCode ??
                    'VC-${order.id.substring(0, 14).toUpperCase()}';
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Đã sao chép mã vận đơn'),
                  duration: Duration(seconds: 1),
                  backgroundColor: AppColors.primaryGreen));
              },
              icon: const Icon(Icons.copy_outlined, size: 16,
                  color: AppColors.primaryGreen),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )),
        _divider(),
        _InfoRow('Phí vận chuyển', formatMoney(order.shipFee)),
        _divider(),
        _InfoRow('ETA đến điểm lấy hàng', eta,
            valueStyle: const TextStyle(fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2563EB))),
        _divider(),
        _InfoRow('Tài xế (API trả về)',
            'Trần Văn Hùng · 51C-478.90'),
      ]),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 16, endIndent: 16,
      color: Color(0xFFF0F0F0));
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  final Widget? trailing;

  const _InfoRow(this.label, this.value,
      {this.valueStyle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(children: [
        Expanded(flex: 4, child: Text(label,
          style: const TextStyle(fontSize: 13.5,
              color: AppColors.textSecondary))),
        const SizedBox(width: 8),
        Expanded(flex: 5, child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(child: Text(value,
              style: valueStyle ?? const TextStyle(fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis)),
            if (trailing != null) ...[
              const SizedBox(width: 6),
              trailing!,
            ],
          ],
        )),
      ]),
    );
  }
}

// ── Timeline ──────────────────────────────────────────────────────────────

class _Step {
  final String title;
  final String time;
  final bool isDone;
  final bool isError;
  const _Step({
    required this.title,
    required this.time,
    required this.isDone,
    this.isError = false,
  });
}

class _TimelineCard extends StatelessWidget {
  final List<_Step> steps;
  const _TimelineCard({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(
            color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        children: List.generate(steps.length, (i) {
          final step   = steps[i];
          final isLast = i == steps.length - 1;

          final dotColor = step.isError
              ? AppColors.red
              : step.isDone
                  ? AppColors.primaryGreen
                  : const Color(0xFFD1D5DB);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dot + connector
              SizedBox(width: 28, child: Column(
                children: [
                  Container(
                    width: 26, height: 26,
                    decoration: BoxDecoration(
                      color: step.isDone ? dotColor : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: dotColor, width: 2.5),
                    ),
                    child: step.isDone
                        ? Icon(
                            step.isError ? Icons.close_rounded
                                         : Icons.check_rounded,
                            size: 13, color: Colors.white)
                        : null,
                  ),
                  if (!isLast)
                    Container(
                      width: 2.5, height: 36,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: step.isDone
                            ? AppColors.primaryGreen.withAlpha(80)
                            : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2),
                      )),
                ],
              )),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 8 : 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 3),
                      Text(step.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: step.isError
                              ? AppColors.red
                              : step.isDone
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                        )),
                      if (step.time.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(step.time,
                          style: const TextStyle(fontSize: 12,
                              color: AppColors.textSecondary)),
                      ],
                      SizedBox(height: isLast ? 0 : 10),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
