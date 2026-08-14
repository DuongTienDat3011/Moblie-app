import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/enums/app_enums.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String phone;
  final String? avatarUrl;
  final UserRole role;
  final String? orgName;       // Tên HTX hoặc tên doanh nghiệp
  final String? province;
  final bool isVerified;       // Tài khoản đã kích hoạt
  final bool isActive;
  final String? fcmToken;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.phone,
    this.avatarUrl,
    required this.role,
    this.orgName,
    this.province,
    this.isVerified = false,
    this.isActive = true,
    this.fcmToken,
    required this.createdAt,
  });

  bool get isHtx   => role == UserRole.htx;
  bool get isBuyer => role == UserRole.buyer;

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid:         doc.id,
      email:       d['email']       as String? ?? '',
      displayName: d['displayName'] as String? ?? '',
      phone:       d['phone']       as String? ?? '',
      avatarUrl:   d['avatarUrl']   as String?,
      role:        UserRole.fromString(d['role'] as String? ?? 'buyer'),
      orgName:     d['orgName']     as String?,
      province:    d['province']    as String?,
      isVerified:  d['isVerified']  as bool?   ?? false,
      isActive:    d['isActive']    as bool?   ?? true,
      fcmToken:    d['fcmToken']    as String?,
      createdAt:   (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'email':       email,
    'displayName': displayName,
    'phone':       phone,
    if (avatarUrl != null) 'avatarUrl': avatarUrl,
    'role':        role.name,
    if (orgName  != null) 'orgName':  orgName,
    if (province != null) 'province': province,
    'isVerified':  isVerified,
    'isActive':    isActive,
    if (fcmToken != null) 'fcmToken': fcmToken,
    'createdAt':   Timestamp.fromDate(createdAt),
  };

  UserModel copyWith({
    String? displayName, String? phone, String? avatarUrl,
    bool? isVerified, bool? isActive, String? fcmToken,
    String? orgName, String? province,
  }) => UserModel(
    uid: uid, email: email, role: role,
    createdAt: createdAt,
    displayName: displayName ?? this.displayName,
    phone:       phone       ?? this.phone,
    avatarUrl:   avatarUrl   ?? this.avatarUrl,
    orgName:     orgName     ?? this.orgName,
    province:    province    ?? this.province,
    isVerified:  isVerified  ?? this.isVerified,
    isActive:    isActive    ?? this.isActive,
    fcmToken:    fcmToken    ?? this.fcmToken,
  );

  @override bool operator ==(Object o) => o is UserModel && uid == o.uid;
  @override int  get hashCode => uid.hashCode;
}
