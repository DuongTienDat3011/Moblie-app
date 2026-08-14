import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/enums/app_enums.dart';

/// Lô hàng nông sản — collection "lots"
class LotModel {
  final String id;
  final String sellerId;
  final String sellerName;      // HTX / Nhà vườn — denormalize
  final String? sellerAvatar;
  final String name;
  final String? variety;        // Giống / chủng loại
  final String category;        // rau | cu | qua | gao | khac
  final String code;            // LO-RAU-20260801-01
  final List<String> imageUrls;
  final double pricePerKg;
  final double? oldPricePerKg;  // Giá cũ nếu đang giảm
  final double totalKg;
  final double remainKg;
  final double moqKg;           // Đặt tối thiểu
  final String province;
  final String harvestDate;     // "30/07/2026"
  final String readyDate;       // "01/08/2026"
  final int? daysLeft;          // Ngày sử dụng còn lại
  final String packingSpec;     // Quy cách đóng gói
  final String? storageCondition;
  final List<String> certs;     // ["VietGAP", "OCOP 4 sao"]
  final bool allowNegotiate;
  final LotStatus status;
  final InventoryQuality quality;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LotModel({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    this.sellerAvatar,
    required this.name,
    this.variety,
    required this.category,
    required this.code,
    required this.imageUrls,
    required this.pricePerKg,
    this.oldPricePerKg,
    required this.totalKg,
    required this.remainKg,
    required this.moqKg,
    required this.province,
    required this.harvestDate,
    required this.readyDate,
    this.daysLeft,
    this.packingSpec = '',
    this.storageCondition,
    this.certs = const [],
    this.allowNegotiate = false,
    this.status = LotStatus.active,
    this.quality = InventoryQuality.good,
    required this.createdAt,
    required this.updatedAt,
  });

  String? get thumbnailUrl => imageUrls.isNotEmpty ? imageUrls.first : null;
  bool get inStock => status == LotStatus.active && remainKg > 0;
  double get soldKg => totalKg - remainKg;
  double get soldPercent => totalKg > 0 ? (soldKg / totalKg).clamp(0, 1) : 0;

  int? get discountPercent {
    if (oldPricePerKg == null || oldPricePerKg! <= pricePerKg) return null;
    return ((1 - pricePerKg / oldPricePerKg!) * 100).round();
  }

  factory LotModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return LotModel(
      id:              doc.id,
      sellerId:        d['sellerId']        as String? ?? '',
      sellerName:      d['sellerName']      as String? ?? '',
      sellerAvatar:    d['sellerAvatar']    as String?,
      name:            d['name']            as String? ?? '',
      variety:         d['variety']         as String?,
      category:        d['category']        as String? ?? 'khac',
      code:            d['code']            as String? ?? '',
      imageUrls:       List<String>.from(d['imageUrls'] as List? ?? []),
      pricePerKg:      (d['pricePerKg']     as num?)?.toDouble() ?? 0,
      oldPricePerKg:   (d['oldPricePerKg']  as num?)?.toDouble(),
      totalKg:         (d['totalKg']        as num?)?.toDouble() ?? 0,
      remainKg:        (d['remainKg']       as num?)?.toDouble() ?? 0,
      moqKg:           (d['moqKg']          as num?)?.toDouble() ?? 100,
      province:        d['province']        as String? ?? '',
      harvestDate:     d['harvestDate']     as String? ?? '',
      readyDate:       d['readyDate']       as String? ?? '',
      daysLeft:        d['daysLeft']        as int?,
      packingSpec:     d['packingSpec']     as String? ?? '',
      storageCondition:d['storageCondition']as String?,
      certs:           List<String>.from(d['certs'] as List? ?? []),
      allowNegotiate:  d['allowNegotiate']  as bool? ?? false,
      status:          LotStatus.fromString(d['status'] as String? ?? 'active'),
      quality:         InventoryQuality.values.firstWhere(
                         (q) => q.name == (d['quality'] as String? ?? 'good'),
                         orElse: () => InventoryQuality.good),
      createdAt:       (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:       (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'sellerId':        sellerId,
    'sellerName':      sellerName,
    if (sellerAvatar != null) 'sellerAvatar': sellerAvatar,
    'name':            name,
    if (variety != null) 'variety': variety,
    'category':        category,
    'code':            code,
    'imageUrls':       imageUrls,
    'pricePerKg':      pricePerKg,
    if (oldPricePerKg != null) 'oldPricePerKg': oldPricePerKg,
    'totalKg':         totalKg,
    'remainKg':        remainKg,
    'moqKg':           moqKg,
    'province':        province,
    'harvestDate':     harvestDate,
    'readyDate':       readyDate,
    if (daysLeft != null) 'daysLeft': daysLeft,
    'packingSpec':     packingSpec,
    if (storageCondition != null) 'storageCondition': storageCondition,
    'certs':           certs,
    'allowNegotiate':  allowNegotiate,
    'status':          status.name,
    'quality':         quality.name,
    'createdAt':       Timestamp.fromDate(createdAt),
    'updatedAt':       Timestamp.fromDate(updatedAt),
  };

  LotModel copyWith({
    double? pricePerKg, double? remainKg, LotStatus? status,
    InventoryQuality? quality, List<String>? imageUrls,
    bool? allowNegotiate, DateTime? updatedAt,
  }) => LotModel(
    id: id, sellerId: sellerId, sellerName: sellerName,
    sellerAvatar: sellerAvatar, name: name, variety: variety,
    category: category, code: code,
    imageUrls:        imageUrls        ?? this.imageUrls,
    pricePerKg:       pricePerKg       ?? this.pricePerKg,
    oldPricePerKg:    oldPricePerKg,
    totalKg: totalKg,
    remainKg:         remainKg         ?? this.remainKg,
    moqKg: moqKg, province: province,
    harvestDate: harvestDate, readyDate: readyDate,
    daysLeft: daysLeft, packingSpec: packingSpec,
    storageCondition: storageCondition, certs: certs,
    allowNegotiate:   allowNegotiate   ?? this.allowNegotiate,
    status:           status           ?? this.status,
    quality:          quality          ?? this.quality,
    createdAt: createdAt,
    updatedAt:        updatedAt        ?? this.updatedAt,
  );

  @override bool operator ==(Object o) => o is LotModel && id == o.id;
  @override int  get hashCode => id.hashCode;
}
