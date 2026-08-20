import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { voter, candidate, admin, auditor }

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? nationalId;
  final bool isVerified;
  final bool biometricEnabled;
  final UserRole role;
  final String? solanaWalletAddress;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.nationalId,
    this.isVerified = false,
    this.biometricEnabled = false,
    this.role = UserRole.voter,
    this.solanaWalletAddress,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, {String? uid}) {
    return UserModel(
      uid: uid ?? map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      displayName:
          map['displayName'] as String? ?? map['display_name'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? map['photo_url'] as String?,
      nationalId: map['nationalId'] as String? ?? map['national_id'] as String?,
      isVerified:
          map['isVerified'] as bool? ?? map['is_verified'] as bool? ?? false,
      biometricEnabled:
          map['biometricEnabled'] as bool? ??
          map['biometric_enabled'] as bool? ??
          false,
      role: _parseRole(map['role'] as String?),
      solanaWalletAddress:
          map['solanaWalletAddress'] as String? ??
          map['solana_wallet_address'] as String?,
      createdAt:
          _parseDateTime(map['createdAt'] ?? map['created_at']) ??
          DateTime.now(),
      lastLoginAt: _parseDateTime(map['lastLoginAt'] ?? map['last_login_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'nationalId': nationalId,
      'isVerified': isVerified,
      'biometricEnabled': biometricEnabled,
      'role': role.name,
      'solanaWalletAddress': solanaWalletAddress,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserModel.fromMap(data, uid: doc.id);
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? nationalId,
    bool? isVerified,
    bool? biometricEnabled,
    UserRole? role,
    String? solanaWalletAddress,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      nationalId: nationalId ?? this.nationalId,
      isVerified: isVerified ?? this.isVerified,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      role: role ?? this.role,
      solanaWalletAddress: solanaWalletAddress ?? this.solanaWalletAddress,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  static UserRole _parseRole(String? roleStr) {
    if (roleStr == null) return UserRole.voter;
    switch (roleStr.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'candidate':
        return UserRole.candidate;
      case 'auditor':
        return UserRole.auditor;
      case 'voter':
      default:
        return UserRole.voter;
    }
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMicrosecondsSinceEpoch(value);
    return null;
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, $displayName, role: ${role.name}, verified: $isVerified)';
  }
}
