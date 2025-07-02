import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { buyer, seller }

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final String? phoneNumber;
  final String? businessName;
  final String? address;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.phoneNumber,
    this.businessName,
    this.address,
    required this.createdAt,
  });

  // Factory constructor for creating UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data();
      
      // 데이터가 null이거나 Map이 아닌 경우 처리
      if (data == null) {
        throw Exception('Document data is null');
      }
      
      if (data is! Map<String, dynamic>) {
        print('=== Unexpected data type: ${data.runtimeType} ===');
        print('=== Data content: $data ===');
        throw Exception('Document data is not a Map<String, dynamic>');
      }
      
      return UserModel(
        uid: doc.id,
        email: data['email'] as String? ?? '',
        displayName: data['displayName'] as String? ?? '',
        role: UserRole.values.firstWhere(
          (role) => role.name == data['role'],
          orElse: () => UserRole.buyer,
        ),
        phoneNumber: data['phoneNumber'] as String?,
        businessName: data['businessName'] as String?,
        address: data['address'] as String?,
        createdAt: data['createdAt'] is Timestamp 
            ? (data['createdAt'] as Timestamp).toDate()
            : (data['createdAt'] != null 
                ? DateTime.parse(data['createdAt'] as String)
                : DateTime.now()),
      );
    } catch (e) {
      print('=== Error parsing user document: $e ===');
      print('=== Document ID: ${doc.id} ===');
      print('=== Document data: ${doc.data()} ===');
      rethrow;
    }
  }

  // Factory constructor for creating UserModel from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String,
      role: UserRole.values.firstWhere(
        (role) => role.name == map['role'],
        orElse: () => UserRole.buyer,
      ),
      phoneNumber: map['phoneNumber'] as String?,
      businessName: map['businessName'] as String?,
      address: map['address'] as String?,
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] as String),
    );
  }

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role.name,
      'phoneNumber': phoneNumber,
      'businessName': businessName,
      'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // CopyWith method for immutable updates
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    UserRole? role,
    String? phoneNumber,
    String? businessName,
    String? address,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      businessName: businessName ?? this.businessName,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is UserModel &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName &&
        other.role == role &&
        other.phoneNumber == phoneNumber &&
        other.businessName == businessName &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        role.hashCode ^
        phoneNumber.hashCode ^
        businessName.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, role: $role, phoneNumber: $phoneNumber, businessName: $businessName, createdAt: $createdAt)';
  }
}
