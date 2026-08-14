import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/enums/app_enums.dart';

class OrderTimeline {
  final String title;
  final DateTime timestamp;
  final bool isDone;

  const OrderTimeline({
    required this.title,
    required this.timestamp,
    required this.isDone,
  });

  factory OrderTimeline.fromMap(Map<String, dynamic> m) => OrderTimeline(
    title:     m['title']     as String? ?? '',
    timestamp: (m['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    isDone:    m['isDone']    as bool?   ?? true,
  );

  Map<String, dynamic> toMap() => {
    'title':     title,
    'timestamp': Timestamp.fromDate(timestamp),
    'isDone':    isDone,
  };
}

class OrderModel {
  final String id;
  final String buyerId;
  final String buyerName;
  final String buyerPhone;
  final String sellerId;
  final String sellerName;
  final String lotId;
  final String lotName;
  final String lotCode;
  final String? lotImageUrl;
  final double pricePerKg;
  final double qty;          // kg
  final double goodsTotal;   // pricePerKg * qty
  final double shipFee;
  final double grandTotal;
  final String deliveryAddress;
  final String deliveryDate;
  final String deliverySlot;
  final String? packNote;
  final String? qualityNote;
  final OrderStatus status;
  final List<OrderTimeline> timeline;
  final String? trackingCode;  // mã vận đơn
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderModel({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    required this.buyerPhone,
    required this.sellerId,
    required this.sellerName,
    required this.lotId,
    required this.lotName,
    required this.lotCode,
    this.lotImageUrl,
    required this.pricePerKg,
    required this.qty,
    required this.goodsTotal,
    required this.shipFee,
    required this.grandTotal,
    required this.deliveryAddress,
    required this.deliveryDate,
    required this.deliverySlot,
    this.packNote,
    this.qualityNote,
    required this.status,
    this.timeline = const [],
    this.trackingCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id:              doc.id,
      buyerId:         d['buyerId']         as String? ?? '',
      buyerName:       d['buyerName']       as String? ?? '',
      buyerPhone:      d['buyerPhone']      as String? ?? '',
      sellerId:        d['sellerId']        as String? ?? '',
      sellerName:      d['sellerName']      as String? ?? '',
      lotId:           d['lotId']           as String? ?? '',
      lotName:         d['lotName']         as String? ?? '',
      lotCode:         d['lotCode']         as String? ?? '',
      lotImageUrl:     d['lotImageUrl']     as String?,
      pricePerKg:      (d['pricePerKg']     as num?)?.toDouble() ?? 0,
      qty:             (d['qty']            as num?)?.toDouble() ?? 0,
      goodsTotal:      (d['goodsTotal']     as num?)?.toDouble() ?? 0,
      shipFee:         (d['shipFee']        as num?)?.toDouble() ?? 0,
      grandTotal:      (d['grandTotal']     as num?)?.toDouble() ?? 0,
      deliveryAddress: d['deliveryAddress'] as String? ?? '',
      deliveryDate:    d['deliveryDate']    as String? ?? '',
      deliverySlot:    d['deliverySlot']    as String? ?? '',
      packNote:        d['packNote']        as String?,
      qualityNote:     d['qualityNote']     as String?,
      status:          OrderStatus.fromString(d['status'] as String? ?? ''),
      timeline:        (d['timeline'] as List? ?? [])
                         .map((e) => OrderTimeline.fromMap(e as Map<String, dynamic>))
                         .toList(),
      trackingCode:    d['trackingCode']    as String?,
      createdAt:       (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:       (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'buyerId':         buyerId,
    'buyerName':       buyerName,
    'buyerPhone':      buyerPhone,
    'sellerId':        sellerId,
    'sellerName':      sellerName,
    'lotId':           lotId,
    'lotName':         lotName,
    'lotCode':         lotCode,
    if (lotImageUrl != null) 'lotImageUrl': lotImageUrl,
    'pricePerKg':      pricePerKg,
    'qty':             qty,
    'goodsTotal':      goodsTotal,
    'shipFee':         shipFee,
    'grandTotal':      grandTotal,
    'deliveryAddress': deliveryAddress,
    'deliveryDate':    deliveryDate,
    'deliverySlot':    deliverySlot,
    if (packNote    != null) 'packNote':    packNote,
    if (qualityNote != null) 'qualityNote': qualityNote,
    'status':          status.toStorage(),
    'timeline':        timeline.map((t) => t.toMap()).toList(),
    if (trackingCode != null) 'trackingCode': trackingCode,
    'createdAt':       Timestamp.fromDate(createdAt),
    'updatedAt':       Timestamp.fromDate(updatedAt),
  };

  OrderModel copyWith({OrderStatus? status, List<OrderTimeline>? timeline,
      String? trackingCode, DateTime? updatedAt}) =>
    OrderModel(
      id: id, buyerId: buyerId, buyerName: buyerName, buyerPhone: buyerPhone,
      sellerId: sellerId, sellerName: sellerName, lotId: lotId, lotName: lotName,
      lotCode: lotCode, lotImageUrl: lotImageUrl, pricePerKg: pricePerKg,
      qty: qty, goodsTotal: goodsTotal, shipFee: shipFee, grandTotal: grandTotal,
      deliveryAddress: deliveryAddress, deliveryDate: deliveryDate,
      deliverySlot: deliverySlot, packNote: packNote, qualityNote: qualityNote,
      status:       status       ?? this.status,
      timeline:     timeline     ?? this.timeline,
      trackingCode: trackingCode ?? this.trackingCode,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );

  @override bool operator ==(Object o) => o is OrderModel && id == o.id;
  @override int  get hashCode => id.hashCode;
}
