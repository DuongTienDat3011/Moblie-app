import 'package:flutter_test/flutter_test.dart';
import 'package:nongsanapp2/core/enums/app_enums.dart';
import 'package:nongsanapp2/core/utils/shipping_match_engine.dart';

void main() {
  group('ShippingMatchEngine', () {
    test('ghép đơn theo khu vực, ngày và khung giờ', () {
      final orders = [
        ShippingOrderInput(id: 'o1', sellerId: 'htx-1', routeKey: 'Bình Thuận', deliveryDate: '15/08/2026', deliverySlot: '08:00-11:00', qtyKg: 120, amount: 1500000),
        ShippingOrderInput(id: 'o2', sellerId: 'htx-1', routeKey: 'Bình Thuận', deliveryDate: '15/08/2026', deliverySlot: '08:00-11:00', qtyKg: 180, amount: 2200000),
        ShippingOrderInput(id: 'o3', sellerId: 'htx-1', routeKey: 'Đà Lạt', deliveryDate: '15/08/2026', deliverySlot: '08:00-11:00', qtyKg: 90, amount: 1100000),
      ];

      final matches = ShippingMatchEngine.matchOrders(orders);

      expect(matches.length, 2);
      expect(matches.first.orderIds.length, 2);
      expect(matches.first.routeName, 'Bình Thuận');
      expect(matches.first.totalKg, 300);
    });

    test('tạo trip từ match với mã chuyến và danh sách stops', () {
      final match = ShippingMatchMatch(
        id: 'match-1',
        sellerId: 'htx-1',
        matchKey: 'Bình Thuận|15/08/2026|08:00-11:00',
        routeName: 'Bình Thuận',
        deliveryDate: '15/08/2026',
        deliverySlot: '08:00-11:00',
        orderIds: ['o1', 'o2'],
        totalKg: 300,
        totalGoodsValue: 3700000,
      );

      final trip = ShippingMatchEngine.buildTripFromMatch(match);

      expect(trip.tripCode.isNotEmpty, isTrue);
      expect(trip.orderIds, ['o1', 'o2']);
      expect(trip.stopAddresses.length, 2);
      expect(trip.totalKg, 300);
      expect(trip.status, TripStatus.planned);
    });
  });
}
