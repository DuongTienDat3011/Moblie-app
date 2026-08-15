import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/enums/app_enums.dart';

class OrderMatchModel {
  final String id;
  final String sellerId;
  final String matchKey;
  final String routeName;
  final String deliveryDate;
  final String deliverySlot;
  final List<String> orderIds;
  final double totalKg;
  final double totalGoodsValue;
  final MatchStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderMatchModel({
    required this.id,
    required this.sellerId,
    required this.matchKey,
    required this.routeName,
    required this.deliveryDate,
    required this.deliverySlot,
    required this.orderIds,
    required this.totalKg,
    required this.totalGoodsValue,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderMatchModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return OrderMatchModel(
      id: doc.id,
      sellerId: d['sellerId'] as String? ?? '',
      matchKey: d['matchKey'] as String? ?? '',
      routeName: d['routeName'] as String? ?? '',
      deliveryDate: d['deliveryDate'] as String? ?? '',
      deliverySlot: d['deliverySlot'] as String? ?? '',
      orderIds: List<String>.from(d['orderIds'] as List? ?? const []),
      totalKg: (d['totalKg'] as num?)?.toDouble() ?? 0,
      totalGoodsValue: (d['totalGoodsValue'] as num?)?.toDouble() ?? 0,
      status: MatchStatus.fromString(d['status'] as String? ?? 'matched'),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'sellerId': sellerId,
    'matchKey': matchKey,
    'routeName': routeName,
    'deliveryDate': deliveryDate,
    'deliverySlot': deliverySlot,
    'orderIds': orderIds,
    'totalKg': totalKg,
    'totalGoodsValue': totalGoodsValue,
    'status': status.toStorage(),
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  OrderMatchModel copyWith({
    String? id,
    String? sellerId,
    String? matchKey,
    String? routeName,
    String? deliveryDate,
    String? deliverySlot,
    List<String>? orderIds,
    double? totalKg,
    double? totalGoodsValue,
    MatchStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => OrderMatchModel(
    id: id ?? this.id,
    sellerId: sellerId ?? this.sellerId,
    matchKey: matchKey ?? this.matchKey,
    routeName: routeName ?? this.routeName,
    deliveryDate: deliveryDate ?? this.deliveryDate,
    deliverySlot: deliverySlot ?? this.deliverySlot,
    orderIds: orderIds ?? this.orderIds,
    totalKg: totalKg ?? this.totalKg,
    totalGoodsValue: totalGoodsValue ?? this.totalGoodsValue,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
