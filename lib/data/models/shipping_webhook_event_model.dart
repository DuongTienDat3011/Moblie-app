import 'package:cloud_firestore/cloud_firestore.dart';

class ShippingWebhookEventModel {
  final String id;
  final String tripId;
  final String eventType;
  final String status;
  final String message;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  const ShippingWebhookEventModel({
    required this.id,
    required this.tripId,
    required this.eventType,
    required this.status,
    required this.message,
    required this.payload,
    required this.createdAt,
  });

  factory ShippingWebhookEventModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ShippingWebhookEventModel(
      id: id ?? map['id'] as String? ?? '',
      tripId: map['tripId'] as String? ?? '',
      eventType: map['eventType'] as String? ?? 'trip.status_changed',
      status: map['status'] as String? ?? 'planned',
      message: map['message'] as String? ?? '',
      payload: Map<String, dynamic>.from(map['payload'] as Map? ?? const {}),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'tripId': tripId,
    'eventType': eventType,
    'status': status,
    'message': message,
    'payload': payload,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
