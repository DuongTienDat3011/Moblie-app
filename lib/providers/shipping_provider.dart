import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//import '../core/constants/app_constants.dart';
import '../core/enums/app_enums.dart';
import '../core/utils/shipping_match_engine.dart';
import '../data/datasources/remote/shipping_api_service.dart';
import '../data/models/order_match_model.dart';
import '../data/models/order_model.dart';
import '../data/models/shipping_trip_model.dart';
import 'firebase_providers.dart';

final shippingApiProvider = Provider<ShippingApiService>((ref) => ShippingApiService());

final sellerMatchesProvider = StreamProvider.family<List<OrderMatchModel>, String>((ref, sellerId) {
  if (sellerId.isEmpty) return Stream.value([]);
  return ref.read(firestoreProvider)
      .collection('matches')
      .where('sellerId', isEqualTo: sellerId)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(OrderMatchModel.fromFirestore).toList());
});

final sellerTripsProvider = StreamProvider.family<List<ShippingTripModel>, String>((ref, sellerId) {
  if (sellerId.isEmpty) return Stream.value([]);
  return ref.read(firestoreProvider)
      .collection('shipping_trips')
      .where('sellerId', isEqualTo: sellerId)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(ShippingTripModel.fromFirestore).toList());
});

class ShippingMatchNotifier extends StateNotifier<AsyncValue<List<OrderMatchModel>>> {
  ShippingMatchNotifier(this._db)
      : super(const AsyncValue.data([]));

  final FirebaseFirestore _db;

  Future<List<OrderMatchModel>> runMatchingForSeller({
    required String sellerId,
    required List<OrderModel> orders,
  }) async {
    final candidates = orders
        .where((order) => order.sellerId == sellerId && order.status == OrderStatus.confirmed)
        .map((order) => ShippingOrderInput(
              id: order.id,
              sellerId: order.sellerId,
              routeKey: order.deliveryAddress,
              deliveryDate: order.deliveryDate,
              deliverySlot: order.deliverySlot,
              qtyKg: order.qty,
              amount: order.grandTotal,
            ))
        .toList();

    final matches = ShippingMatchEngine.matchOrders(candidates);
    final result = <OrderMatchModel>[];
    final now = DateTime.now();

    for (final match in matches) {
      final docRef = _db.collection('matches').doc();
      final model = OrderMatchModel(
        id: docRef.id,
        sellerId: sellerId,
        matchKey: match.matchKey,
        routeName: match.routeName,
        deliveryDate: match.deliveryDate,
        deliverySlot: match.deliverySlot,
        orderIds: match.orderIds,
        totalKg: match.totalKg,
        totalGoodsValue: match.totalGoodsValue,
        status: MatchStatus.matched,
        createdAt: now,
        updatedAt: now,
      );
      await docRef.set(model.toFirestore());
      result.add(model);
    }

    state = AsyncValue.data(result);
    return result;
  }
}

final shippingMatchProvider = StateNotifierProvider<ShippingMatchNotifier, AsyncValue<List<OrderMatchModel>>>((ref) {
  return ShippingMatchNotifier(ref.read(firestoreProvider));
});

class ShippingTripNotifier extends StateNotifier<AsyncValue<List<ShippingTripModel>>> {
  ShippingTripNotifier(this._db, this._api)
      : super(const AsyncValue.data([]));

  final FirebaseFirestore _db;
  final ShippingApiService _api;

  Future<ShippingTripModel?> createTripFromMatch(OrderMatchModel match) async {
    final trip = await _api.createTripForMatch(match);
    final docRef = _db.collection('shipping_trips').doc(trip.id);
    await docRef.set(trip.toFirestore());

    final current = state.value ?? <ShippingTripModel>[];
    state = AsyncValue.data([...current, trip]);
    return trip;
  }

  Future<void> updateTripStatus(String tripId, TripStatus status) async {
    final snapshot = await _db.collection('shipping_trips').doc(tripId).get();
    if (!snapshot.exists) return;

    final current = ShippingTripModel.fromFirestore(snapshot);
    final updated = current.copyWith(status: status, updatedAt: DateTime.now());
    await _db.collection('shipping_trips').doc(tripId).update(updated.toFirestore());

    final trips = state.value ?? <ShippingTripModel>[];
    final list = trips.map((e) => e.id == tripId ? updated : e).toList();
    state = AsyncValue.data(list);
  }
}

final shippingTripProvider = StateNotifierProvider<ShippingTripNotifier, AsyncValue<List<ShippingTripModel>>>((ref) {
  return ShippingTripNotifier(ref.read(firestoreProvider), ref.read(shippingApiProvider));
});

final webhookEventsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final api = ref.read(shippingApiProvider);
  return api.webhookStream
      .map((event) => event.toMap())
      .toList()
      .asStream();
});
