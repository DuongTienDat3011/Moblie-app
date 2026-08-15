import '../enums/app_enums.dart';

class ShippingOrderInput {
  final String id;
  final String sellerId;
  final String routeKey;
  final String deliveryDate;
  final String deliverySlot;
  final double qtyKg;
  final double amount;

  const ShippingOrderInput({
    required this.id,
    required this.sellerId,
    required this.routeKey,
    required this.deliveryDate,
    required this.deliverySlot,
    required this.qtyKg,
    required this.amount,
  });
}

class ShippingMatchMatch {
  final String id;
  final String sellerId;
  final String matchKey;
  final String routeName;
  final String deliveryDate;
  final String deliverySlot;
  final List<String> orderIds;
  final double totalKg;
  final double totalGoodsValue;

  const ShippingMatchMatch({
    required this.id,
    required this.sellerId,
    required this.matchKey,
    required this.routeName,
    required this.deliveryDate,
    required this.deliverySlot,
    required this.orderIds,
    required this.totalKg,
    required this.totalGoodsValue,
  });
}

class ShippingTrip {
  final String id;
  final String tripCode;
  final String routeName;
  final String deliveryDate;
  final String departureSlot;
  final List<String> orderIds;
  final List<String> stopAddresses;
  final double totalKg;
  final double totalValue;
  final TripStatus status;
  final String trackingUrl;

  const ShippingTrip({
    required this.id,
    required this.tripCode,
    required this.routeName,
    required this.deliveryDate,
    required this.departureSlot,
    required this.orderIds,
    required this.stopAddresses,
    required this.totalKg,
    required this.totalValue,
    required this.status,
    required this.trackingUrl,
  });
}

class ShippingMatchEngine {
  static String normalizeRouteKey(String routeKey) {
    final sanitized = routeKey.trim();
    if (sanitized.isEmpty) return 'Chưa xác định';
    final cleaned = sanitized.replaceAll(RegExp(r'\s+'), ' ');
    return cleaned;
  }

  static List<ShippingMatchMatch> matchOrders(List<ShippingOrderInput> orders) {
    final grouped = <String, List<ShippingOrderInput>>{};

    for (final order in orders) {
      final key = '${order.sellerId}|${normalizeRouteKey(order.routeKey)}|${order.deliveryDate}|${order.deliverySlot}';
      grouped.putIfAbsent(key, () => <ShippingOrderInput>[]).add(order);
    }

    final matches = grouped.entries.map((entry) {
      final items = entry.value;
      final first = items.first;
      final ids = items.map((e) => e.id).toList()..sort();
      final totalKg = items.fold<double>(0, (sum, e) => sum + e.qtyKg);
      final totalValue = items.fold<double>(0, (sum, e) => sum + e.amount);

      return ShippingMatchMatch(
        id: 'MATCH-${DateTime.now().millisecondsSinceEpoch}-${first.sellerId.substring(0, 4)}',
        sellerId: first.sellerId,
        matchKey: entry.key,
        routeName: normalizeRouteKey(first.routeKey),
        deliveryDate: first.deliveryDate,
        deliverySlot: first.deliverySlot,
        orderIds: ids,
        totalKg: totalKg,
        totalGoodsValue: totalValue,
      );
    }).toList();

    matches.sort((a, b) {
      final dateCompare = a.deliveryDate.compareTo(b.deliveryDate);
      if (dateCompare != 0) return dateCompare;
      return a.routeName.compareTo(b.routeName);
    });

    return matches;
  }

  static ShippingTrip buildTripFromMatch(ShippingMatchMatch match) {
    final tripId = 'T-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final orderIds = match.orderIds.toList()..sort();

    return ShippingTrip(
      id: tripId,
      tripCode: 'VT-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}-${tripId.substring(1, 6)}',
      routeName: match.routeName,
      deliveryDate: match.deliveryDate,
      departureSlot: match.deliverySlot,
      orderIds: orderIds,
      stopAddresses: orderIds.map((id) => '${match.routeName} - $id').toList(),
      totalKg: match.totalKg,
      totalValue: match.totalGoodsValue,
      status: TripStatus.planned,
      trackingUrl: 'https://mock-shipping.example/trip/$tripId',
    );
  }
}
