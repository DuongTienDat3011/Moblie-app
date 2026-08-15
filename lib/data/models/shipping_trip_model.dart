import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/enums/app_enums.dart';

class ShippingTripModel {
  final String id;
  final String sellerId;
  final String tripCode;
  final String routeName;
  final String origin;
  final String destination;
  final String deliveryDate;
  final String departureSlot;
  final List<String> orderIds;
  final List<String> stopAddresses;
  final double totalKg;
  final double totalValue;
  final TripStatus status;
  final String driverName;
  final String vehiclePlate;
  final String? trackingUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ShippingTripModel({
    required this.id,
    required this.sellerId,
    required this.tripCode,
    required this.routeName,
    required this.origin,
    required this.destination,
    required this.deliveryDate,
    required this.departureSlot,
    required this.orderIds,
    required this.stopAddresses,
    required this.totalKg,
    required this.totalValue,
    required this.status,
    required this.driverName,
    required this.vehiclePlate,
    this.trackingUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShippingTripModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ShippingTripModel(
      id: doc.id,
      sellerId: d['sellerId'] as String? ?? '',
      tripCode: d['tripCode'] as String? ?? '',
      routeName: d['routeName'] as String? ?? '',
      origin: d['origin'] as String? ?? '',
      destination: d['destination'] as String? ?? '',
      deliveryDate: d['deliveryDate'] as String? ?? '',
      departureSlot: d['departureSlot'] as String? ?? '',
      orderIds: List<String>.from(d['orderIds'] as List? ?? const []),
      stopAddresses: List<String>.from(d['stopAddresses'] as List? ?? const []),
      totalKg: (d['totalKg'] as num?)?.toDouble() ?? 0,
      totalValue: (d['totalValue'] as num?)?.toDouble() ?? 0,
      status: TripStatus.fromString(d['status'] as String? ?? 'planned'),
      driverName: d['driverName'] as String? ?? 'Tài xế nội bộ',
      vehiclePlate: d['vehiclePlate'] as String? ?? 'PT-9999',
      trackingUrl: d['trackingUrl'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'sellerId': sellerId,
    'tripCode': tripCode,
    'routeName': routeName,
    'origin': origin,
    'destination': destination,
    'deliveryDate': deliveryDate,
    'departureSlot': departureSlot,
    'orderIds': orderIds,
    'stopAddresses': stopAddresses,
    'totalKg': totalKg,
    'totalValue': totalValue,
    'status': status.toStorage(),
    'driverName': driverName,
    'vehiclePlate': vehiclePlate,
    if (trackingUrl != null) 'trackingUrl': trackingUrl,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  ShippingTripModel copyWith({
    String? id,
    String? sellerId,
    String? tripCode,
    String? routeName,
    String? origin,
    String? destination,
    String? deliveryDate,
    String? departureSlot,
    List<String>? orderIds,
    List<String>? stopAddresses,
    double? totalKg,
    double? totalValue,
    TripStatus? status,
    String? driverName,
    String? vehiclePlate,
    String? trackingUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ShippingTripModel(
    id: id ?? this.id,
    sellerId: sellerId ?? this.sellerId,
    tripCode: tripCode ?? this.tripCode,
    routeName: routeName ?? this.routeName,
    origin: origin ?? this.origin,
    destination: destination ?? this.destination,
    deliveryDate: deliveryDate ?? this.deliveryDate,
    departureSlot: departureSlot ?? this.departureSlot,
    orderIds: orderIds ?? this.orderIds,
    stopAddresses: stopAddresses ?? this.stopAddresses,
    totalKg: totalKg ?? this.totalKg,
    totalValue: totalValue ?? this.totalValue,
    status: status ?? this.status,
    driverName: driverName ?? this.driverName,
    vehiclePlate: vehiclePlate ?? this.vehiclePlate,
    trackingUrl: trackingUrl ?? this.trackingUrl,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
