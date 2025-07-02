import 'package:cloud_firestore/cloud_firestore.dart';

enum ConnectionStatus { pending, approved, rejected }

class ConnectionModel {
  final String id;
  final String buyerId;
  final String sellerId;
  final String buyerName;
  final String sellerName;
  final String? buyerEmail;
  final String? sellerEmail;
  final String? buyerBusinessName;
  final String? sellerBusinessName;
  final ConnectionStatus status;
  final DateTime requestedAt;
  final DateTime? connectedAt;

  const ConnectionModel({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.buyerName,
    required this.sellerName,
    this.buyerEmail,
    this.sellerEmail,
    this.buyerBusinessName,
    this.sellerBusinessName,
    required this.status,
    required this.requestedAt,
    this.connectedAt,
  });

  // Factory constructor for creating ConnectionModel from Firestore document
  factory ConnectionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ConnectionModel(
      id: doc.id,
      buyerId: data['buyerId'] as String,
      sellerId: data['sellerId'] as String,
      buyerName: data['buyerName'] as String,
      sellerName: data['sellerName'] as String,
      buyerEmail: data['buyerEmail'] as String?,
      sellerEmail: data['sellerEmail'] as String?,
      buyerBusinessName: data['buyerBusinessName'] as String?,
      sellerBusinessName: data['sellerBusinessName'] as String?,
      status: ConnectionStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => ConnectionStatus.pending,
      ),
      requestedAt: (data['requestedAt'] as Timestamp).toDate(),
      connectedAt: data['connectedAt'] != null 
          ? (data['connectedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Factory constructor for creating ConnectionModel from Map
  factory ConnectionModel.fromMap(Map<String, dynamic> map) {
    return ConnectionModel(
      id: map['id'] as String,
      buyerId: map['buyerId'] as String,
      sellerId: map['sellerId'] as String,
      buyerName: map['buyerName'] as String,
      sellerName: map['sellerName'] as String,
      buyerEmail: map['buyerEmail'] as String?,
      sellerEmail: map['sellerEmail'] as String?,
      buyerBusinessName: map['buyerBusinessName'] as String?,
      sellerBusinessName: map['sellerBusinessName'] as String?,
      status: ConnectionStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => ConnectionStatus.pending,
      ),
      requestedAt: map['requestedAt'] is Timestamp 
          ? (map['requestedAt'] as Timestamp).toDate()
          : DateTime.parse(map['requestedAt'] as String),
      connectedAt: map['connectedAt'] != null
          ? (map['connectedAt'] is Timestamp 
              ? (map['connectedAt'] as Timestamp).toDate()
              : DateTime.parse(map['connectedAt'] as String))
          : null,
    );
  }

  // Convert ConnectionModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'buyerId': buyerId,
      'sellerId': sellerId,
      'buyerName': buyerName,
      'sellerName': sellerName,
      'buyerEmail': buyerEmail,
      'sellerEmail': sellerEmail,
      'buyerBusinessName': buyerBusinessName,
      'sellerBusinessName': sellerBusinessName,
      'status': status.name,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'connectedAt': connectedAt != null 
          ? Timestamp.fromDate(connectedAt!)
          : null,
    };
  }

  // CopyWith method for immutable updates
  ConnectionModel copyWith({
    String? id,
    String? buyerId,
    String? sellerId,
    String? buyerName,
    String? sellerName,
    String? buyerEmail,
    String? sellerEmail,
    String? buyerBusinessName,
    String? sellerBusinessName,
    ConnectionStatus? status,
    DateTime? requestedAt,
    DateTime? connectedAt,
  }) {
    return ConnectionModel(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      buyerName: buyerName ?? this.buyerName,
      sellerName: sellerName ?? this.sellerName,
      buyerEmail: buyerEmail ?? this.buyerEmail,
      sellerEmail: sellerEmail ?? this.sellerEmail,
      buyerBusinessName: buyerBusinessName ?? this.buyerBusinessName,
      sellerBusinessName: sellerBusinessName ?? this.sellerBusinessName,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      connectedAt: connectedAt ?? this.connectedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ConnectionModel &&
        other.id == id &&
        other.buyerId == buyerId &&
        other.sellerId == sellerId &&
        other.buyerName == buyerName &&
        other.sellerName == sellerName &&
        other.buyerEmail == buyerEmail &&
        other.sellerEmail == sellerEmail &&
        other.buyerBusinessName == buyerBusinessName &&
        other.sellerBusinessName == sellerBusinessName &&
        other.status == status &&
        other.requestedAt == requestedAt &&
        other.connectedAt == connectedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        buyerId.hashCode ^
        sellerId.hashCode ^
        buyerName.hashCode ^
        sellerName.hashCode ^
        buyerEmail.hashCode ^
        sellerEmail.hashCode ^
        buyerBusinessName.hashCode ^
        sellerBusinessName.hashCode ^
        status.hashCode ^
        requestedAt.hashCode ^
        connectedAt.hashCode;
  }

  @override
  String toString() {
    return 'ConnectionModel(id: $id, buyerId: $buyerId, sellerId: $sellerId, buyerName: $buyerName, sellerName: $sellerName, buyerEmail: $buyerEmail, sellerEmail: $sellerEmail, status: $status, requestedAt: $requestedAt, connectedAt: $connectedAt)';
  }
}
