import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String sellerId;
  final String name;
  final String unit;
  final int? price;
  final bool isActive;
  final int orderIndex;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ProductModel({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.unit,
    this.price,
    this.isActive = true,
    this.orderIndex = 0,
    required this.createdAt,
    this.updatedAt,
  });

  // Factory constructor for creating ProductModel from Firestore document
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;
      
      return ProductModel(
        id: doc.id,
        sellerId: data['sellerId'] as String,
        name: data['name'] as String,
        unit: data['unit'] as String,
        price: data['price'] as int?,
        isActive: data['isActive'] as bool? ?? true,
        orderIndex: data['orderIndex'] as int? ?? 0,
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        updatedAt: data['updatedAt'] != null 
            ? (data['updatedAt'] as Timestamp).toDate()
            : null,
      );
    } catch (e) {
      print('=== ❌ Error parsing ProductModel from Firestore doc ${doc.id}: $e ===');
      print('=== 📄 Document data: ${doc.data()} ===');
      rethrow;
    }
  }

  // Factory constructor for creating ProductModel from Map
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String,
      sellerId: map['sellerId'] as String,
      name: map['name'] as String,
      unit: map['unit'] as String,
      price: map['price'] as int?,
      isActive: map['isActive'] as bool? ?? true,
      orderIndex: map['orderIndex'] as int? ?? 0,
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is Timestamp 
              ? (map['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(map['updatedAt'] as String))
          : null,
    );
  }

  // Convert ProductModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'name': name,
      'unit': unit,
      'price': price,
      'isActive': isActive,
      'orderIndex': orderIndex,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null 
          ? Timestamp.fromDate(updatedAt!)
          : null,
    };
  }

  // CopyWith method for immutable updates
  ProductModel copyWith({
    String? id,
    String? sellerId,
    String? name,
    String? unit,
    int? price,
    bool? isActive,
    int? orderIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ProductModel &&
        other.id == id &&
        other.sellerId == sellerId &&
        other.name == name &&
        other.unit == unit &&
        other.price == price &&
        other.isActive == isActive &&
        other.orderIndex == orderIndex &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        sellerId.hashCode ^
        name.hashCode ^
        unit.hashCode ^
        price.hashCode ^
        isActive.hashCode ^
        orderIndex.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, sellerId: $sellerId, name: $name, unit: $unit, price: $price, isActive: $isActive, orderIndex: $orderIndex, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
