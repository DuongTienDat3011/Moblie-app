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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Theo dõi vận chuyển',
            style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
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

class _TrackingBody extends StatelessWidget {
  final OrderModel order;
  const _TrackingBody({required this.order});

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps(order);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Trạng thái chính ─────────────────────────────────────────
          _StatusBanner(order: order),
          const SizedBox(height: 16),

          // ── Mã vận đơn ───────────────────────────────────────────────
          if (order.trackingCode != null) ...[
            _TrackingCodeCard(code: order.trackingCode!),
            const SizedBox(height: 16),
          ],

          // ── Timeline vận chuyển ───────────────────────────────────────
          _SectionTitle(title: 'Lịch trình đơn hàng'),
          const SizedBox(height: 12),
          _TimelineWidget(steps: steps),
          const SizedBox(height: 16),

          // ── Thông tin giao hàng ───────────────────────────────────────
          _SectionTitle(title: 'Thông tin giao hàng'),
          const SizedBox(height: 12),
          _InfoCard(children: [
            _InfoRow(
              icon: Icons.location_on_rounded,
              label: 'Địa chỉ nhận',
              value: order.deliveryAddress),
            _InfoRow(
              icon: Icons.calendar_today_rounded,
              label: 'Ngày giao',
              value: order.deliveryDate),
            _InfoRow(
              icon: Icons.access_time_rounded,
              label: 'Khung giờ',
              value: order.deliverySlot),
          ]),
          const SizedBox(height: 16),

          // ── Thông tin lô hàng ─────────────────────────────────────────
          _SectionTitle(title: 'Thông tin lô hàng'),
          const SizedBox(height: 12),
          _InfoCard(children: [
            _InfoRow(
              icon: Icons.eco_rounded,
              label: 'Sản phẩm',
              value: order.lotName),
            _InfoRow(
              icon: Icons.qr_code_rounded,
              label: 'Mã lô',
              value: order.lotCode),
            _InfoRow(
              icon: Icons.scale_rounded,
              label: 'Khối lượng',
              value: formatQty(order.qty)),
            _InfoRow(
              icon: Icons.store_rounded,
              label: 'HTX',
              value: order.sellerName),
            _InfoRow(
              icon: Icons.payments_rounded,
              label: 'Tổng tiền',
              value: formatCurrency(order.grandTotal)),
          ]),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<_TimelineStep> _buildSteps(OrderModel order) {
    // Nếu có timeline từ Firestore → dùng
    if (order.timeline.isNotEmpty) {
      return order.timeline.map((t) => _TimelineStep(
        title: t.title,
        time: DateFormat('dd/MM HH:mm').format(t.timestamp),
        isDone: t.isDone,
      )).toList();
    }

    // Fallback: generate từ status
    final steps = [
      _TimelineStep(
        title: 'Đơn hàng được tạo',
        time: DateFormat('dd/MM HH:mm').format(order.createdAt),
        isDone: true,
      ),
      _TimelineStep(
        title: 'HTX xác nhận đơn',
        time: order.status.index >= OrderStatus.confirmed.index
            ? DateFormat('dd/MM').format(order.updatedAt) : '',
        isDone: order.status.index >= OrderStatus.confirmed.index,
      ),
      _TimelineStep(
        title: 'Chờ bàn giao vận chuyển',
        time: order.status.index >= OrderStatus.waitingShip.index
            ? DateFormat('dd/MM').format(order.updatedAt) : '',
        isDone: order.status.index >= OrderStatus.waitingShip.index,
      ),
      _TimelineStep(
        title: 'Đang vận chuyển',
        time: order.status.index >= OrderStatus.inTransit.index
            ? order.deliveryDate : '',
        isDone: order.status.index >= OrderStatus.inTransit.index,
      ),
      _TimelineStep(
        title: 'Giao hàng thành công',
        time: order.status == OrderStatus.completed
            ? DateFormat('dd/MM').format(order.updatedAt) : order.deliveryDate,
        isDone: order.status == OrderStatus.completed,
      ),
    ];

    if (order.status == OrderStatus.cancelled) {
      return [
        steps.first,
        _TimelineStep(
          title: 'Đơn hàng đã bị huỷ',
          time: DateFormat('dd/MM HH:mm').format(order.updatedAt),
          isDone: true,
          isError: true,
        ),
      ];
    }
    return steps;
  }
}

// ── Widgets ──────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final OrderModel order;
  const _StatusBanner({required this.order});

  @override
  Widget build(BuildContext context) {
    final (color, bg, icon, label) = _statusInfo(order.status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                  color: color)),
            const SizedBox(height: 3),
            Text('Mã đơn: #${order.id.substring(0, 8).toUpperCase()}',
              style: const TextStyle(fontSize: 12,
                  color: AppColors.textSecondary)),
          ],
        )),
      ]),
    );
  }

  (Color, Color, IconData, String) _statusInfo(OrderStatus s) {
    switch (s) {
      case OrderStatus.pendingConfirm:
        return (const Color(0xFFF59E0B), const Color(0xFFFFFBEB),
            Icons.hourglass_empty_rounded, 'Chờ HTX xác nhận');
      case OrderStatus.confirmed:
        return (const Color(0xFF3B82F6), const Color(0xFFEFF6FF),
            Icons.check_circle_outline_rounded, 'Đã xác nhận');
      case OrderStatus.waitingShip:
        return (const Color(0xFF8B5CF6), const Color(0xFFF5F3FF),
            Icons.inventory_2_rounded, 'Chờ bàn giao vận chuyển');
      case OrderStatus.inTransit:
        return (AppColors.primaryGreen, const Color(0xFFECFDF5),
            Icons.local_shipping_rounded, 'Đang vận chuyển');
      case OrderStatus.completed:
        return (AppColors.darkGreen, const Color(0xFFECFDF5),
            Icons.check_circle_rounded, 'Giao hàng thành công');
      case OrderStatus.cancelled:
        return (AppColors.red, const Color(0xFFFEF2F2),
            Icons.cancel_rounded, 'Đơn hàng đã huỷ');
      default:
        return (AppColors.textSecondary, AppColors.background,
            Icons.info_outline_rounded, s.label);
    }
  }
}

class _TrackingCodeCard extends StatelessWidget {
  final String code;
  const _TrackingCodeCard({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(children: [
        const Icon(Icons.qr_code_scanner_rounded,
            color: AppColors.primaryGreen, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mã vận đơn',
              style: TextStyle(fontSize: 11,
                  color: AppColors.textSecondary)),
            Text(code,
              style: const TextStyle(fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.2)),
          ],
        )),
        IconButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: code));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã sao chép mã vận đơn'),
                duration: Duration(seconds: 1),
                backgroundColor: AppColors.primaryGreen));
          },
          icon: const Icon(Icons.copy_rounded, size: 18,
              color: AppColors.primaryGreen),
        ),
      ]),
    );
  }
}

class _TimelineStep {
  final String title;
  final String time;
  final bool isDone;
  final bool isError;

  const _TimelineStep({
    required this.title,
    required this.time,
    required this.isDone,
    this.isError = false,
  });
}

class _TimelineWidget extends StatelessWidget {
  final List<_TimelineStep> steps;
  const _TimelineWidget({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: List.generate(steps.length, (i) {
          final step = steps[i];
          final isLast = i == steps.length - 1;

          // Tìm step hiện tại (done cuối cùng)
          final currentIdx = steps.lastIndexWhere((s) => s.isDone);
          final isCurrent = i == currentIdx && !step.isError;

          final dotColor = step.isError
              ? AppColors.red
              : step.isDone
                  ? AppColors.primaryGreen
                  : AppColors.divider;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dot + line
              SizedBox(width: 24, child: Column(
                children: [
                  Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      color: step.isDone ? dotColor : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: dotColor, width: 2),
                    ),
                    child: step.isDone
                        ? Icon(
                            step.isError ? Icons.close : Icons.check,
                            size: 12, color: Colors.white)
                        : null,
                  ),
                  if (!isLast) Container(
                    width: 2, height: 36,
                    color: step.isDone
                        ? AppColors.primaryGreen.withAlpha(60)
                        : AppColors.divider),
                ],
              )),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step.title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: isCurrent
                              ? FontWeight.w700 : FontWeight.w500,
                          color: step.isError
                              ? AppColors.red
                              : step.isDone
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                        )),
                      if (step.time.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(step.time,
                          style: const TextStyle(fontSize: 11.5,
                              color: AppColors.textSecondary)),
                      ],
                      const SizedBox(height: 4),
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

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Text(title,
    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary));
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, size: 17, color: AppColors.primaryGreen),
        const SizedBox(width: 10),
        SizedBox(width: 100, child: Text(label,
          style: const TextStyle(fontSize: 13,
              color: AppColors.textSecondary))),
        Expanded(child: Text(value,
          style: const TextStyle(fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary),
          textAlign: TextAlign.end,
          maxLines: 2,
          overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}
