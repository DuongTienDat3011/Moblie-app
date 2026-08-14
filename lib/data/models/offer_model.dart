import 'package:cloud_firestore/cloud_firestore.dart';

enum OfferStatus { waiting, accepted, rejected, expired;
  String get displayName {
    const m = {
      OfferStatus.waiting:  'Chờ phản hồi',
      OfferStatus.accepted: 'Đã chấp nhận',
      OfferStatus.rejected: 'Bị từ chối',
      OfferStatus.expired:  'Hết hạn',
    };
    return m[this]!;
  }
  String get tone {
    const m = {
      OfferStatus.waiting:  'yellow',
      OfferStatus.accepted: 'green',
      OfferStatus.rejected: 'red',
      OfferStatus.expired:  'gray',
    };
    return m[this]!;
  }
  static OfferStatus fromString(String v) =>
      OfferStatus.values.firstWhere((e) => e.name == v, orElse: () => OfferStatus.waiting);
}

class OfferModel {
  final String id;
  final String lotId;
  final String lotName;
  final String? lotImageUrl;
  final String buyerId;
  final String buyerName;
  final String sellerId;
  final String sellerName;
  final double listedPrice;
  final double offeredPrice;
  final double? counterPrice;   // Giá phản hồi từ seller
  final double qty;
  final String message;
  final String expiry;          // "12 giờ"
  final OfferStatus status;
  final DateTime createdAt;

  const OfferModel({
    required this.id,
    required this.lotId,
    required this.lotName,
    this.lotImageUrl,
    required this.buyerId,
    required this.buyerName,
    required this.sellerId,
    required this.sellerName,
    required this.listedPrice,
    required this.offeredPrice,
    this.counterPrice,
    required this.qty,
    required this.message,
    required this.expiry,
    required this.status,
    required this.createdAt,
  });

  double get discount => listedPrice > 0
      ? ((1 - offeredPrice / listedPrice) * 100)
      : 0;

  factory OfferModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return OfferModel(
      id:           doc.id,
      lotId:        d['lotId']        as String? ?? '',
      lotName:      d['lotName']      as String? ?? '',
      lotImageUrl:  d['lotImageUrl']  as String?,
      buyerId:      d['buyerId']      as String? ?? '',
      buyerName:    d['buyerName']    as String? ?? '',
      sellerId:     d['sellerId']     as String? ?? '',
      sellerName:   d['sellerName']   as String? ?? '',
      listedPrice:  (d['listedPrice']  as num?)?.toDouble() ?? 0,
      offeredPrice: (d['offeredPrice'] as num?)?.toDouble() ?? 0,
      counterPrice: (d['counterPrice'] as num?)?.toDouble(),
      qty:          (d['qty']          as num?)?.toDouble() ?? 0,
      message:      d['message']      as String? ?? '',
      expiry:       d['expiry']       as String? ?? '12 giờ',
      status:       OfferStatus.fromString(d['status'] as String? ?? 'waiting'),
      createdAt:    (d['createdAt']   as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'lotId': lotId, 'lotName': lotName,
    if (lotImageUrl != null) 'lotImageUrl': lotImageUrl,
    'buyerId': buyerId, 'buyerName': buyerName,
    'sellerId': sellerId, 'sellerName': sellerName,
    'listedPrice': listedPrice, 'offeredPrice': offeredPrice,
    if (counterPrice != null) 'counterPrice': counterPrice,
    'qty': qty, 'message': message, 'expiry': expiry,
    'status': status.name,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  @override bool operator ==(Object o) => o is OfferModel && id == o.id;
  @override int  get hashCode => id.hashCode;
}
