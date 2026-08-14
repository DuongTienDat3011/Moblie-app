import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../core/enums/app_enums.dart';
import '../data/models/order_model.dart';
import '../data/models/lot_model.dart';
import '../data/models/user_model.dart';
import 'firebase_providers.dart';

// ── Buyer orders (không orderBy → không cần composite index) ──────────────
final buyerOrdersProvider = StreamProvider.family<List<OrderModel>, String>((ref, uid) {
  if (uid.isEmpty) return Stream.value([]);
  return ref.read(firestoreProvider)
      .collection(AppConstants.ordersCol)
      .where('buyerId', isEqualTo: uid)
      .snapshots()
      .map((s) {
        final list = s.docs.map(OrderModel.fromFirestore).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });
});

// ── Seller orders ─────────────────────────────────────────────────────────
final sellerOrdersProvider = StreamProvider.family<List<OrderModel>, String>((ref, uid) {
  if (uid.isEmpty) return Stream.value([]);
  return ref.read(firestoreProvider)
      .collection(AppConstants.ordersCol)
      .where('sellerId', isEqualTo: uid)
      .snapshots()
      .map((s) {
        final list = s.docs.map(OrderModel.fromFirestore).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });
});

// ── Single order realtime ─────────────────────────────────────────────────
final orderDetailProvider = StreamProvider.family<OrderModel?, String>((ref, id) {
  return ref.read(firestoreProvider)
      .collection(AppConstants.ordersCol)
      .doc(id)
      .snapshots()
      .map((s) => s.exists ? OrderModel.fromFirestore(s) : null);
});

// ── Place Order ───────────────────────────────────────────────────────────
class PlaceOrderState {
  final bool isLoading;
  final String? error;
  final String? newOrderId;

  const PlaceOrderState({this.isLoading = false, this.error, this.newOrderId});

  PlaceOrderState copyWith({bool? isLoading, String? error, String? newOrderId}) =>
      PlaceOrderState(
        isLoading:  isLoading  ?? this.isLoading,
        error:      error      ?? this.error,
        newOrderId: newOrderId ?? this.newOrderId,
      );
}

class PlaceOrderNotifier extends StateNotifier<PlaceOrderState> {
  final FirebaseFirestore _db;
  PlaceOrderNotifier(this._db) : super(const PlaceOrderState());

  Future<void> placeOrder({
    required LotModel lot,
    required UserModel buyer,
    required double qty,
    required String address,
    required String deliveryDate,
    required String deliverySlot,
    String? packNote,
    String? qualityNote,
    bool useSystemShip = true,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final shipFee = useSystemShip ? AppConstants.baseShipFee : 0;
      final goods   = lot.pricePerKg * qty;
      final docRef  = _db.collection(AppConstants.ordersCol).doc();
      final now     = DateTime.now();

      final order = OrderModel(
        id:       docRef.id,
        buyerId:  buyer.uid,
        buyerName: buyer.displayName,
        buyerPhone: buyer.phone,
        sellerId:  lot.sellerId,
        sellerName: lot.sellerName,
        lotId:    lot.id,
        lotName:  lot.name,
        lotCode:  lot.code,
        lotImageUrl: lot.thumbnailUrl,
        pricePerKg: lot.pricePerKg,
        qty:        qty,
        goodsTotal: goods,
        shipFee:    shipFee.toDouble(),
        grandTotal: goods + shipFee,
        deliveryAddress: address,
        deliveryDate: deliveryDate,
        deliverySlot: deliverySlot,
        packNote:    packNote,
        qualityNote: qualityNote,
        status: OrderStatus.pendingConfirm,
        timeline: [
          OrderTimeline(title: 'Đơn hàng được tạo', timestamp: now, isDone: true),
        ],
        createdAt: now,
        updatedAt: now,
      );

      await docRef.set(order.toFirestore());
      state = state.copyWith(isLoading: false, newOrderId: docRef.id);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Đặt hàng thất bại: $e',
      );
    }
  }

  Future<void> confirmOrder(String orderId) async {
    await _db.collection(AppConstants.ordersCol).doc(orderId).update({
      'status':    OrderStatus.confirmed.toStorage(),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> cancelOrder(String orderId) async {
    await _db.collection(AppConstants.ordersCol).doc(orderId).update({
      'status':    OrderStatus.cancelled.toStorage(),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  void reset() => state = const PlaceOrderState();
}

final placeOrderProvider = StateNotifierProvider<PlaceOrderNotifier, PlaceOrderState>((ref) {
  return PlaceOrderNotifier(ref.read(firestoreProvider));
});
