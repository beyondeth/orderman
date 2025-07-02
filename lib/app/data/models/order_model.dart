import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum OrderStatus {
  pending('대기중', Colors.orange, Icons.hourglass_empty),
  confirmed('확인됨', Colors.blue, Icons.check_circle),
  completed('완료', Colors.green, Icons.done_all),
  cancelled('취소됨', Colors.red, Icons.cancel);

  const OrderStatus(this.displayText, this.color, this.icon);

  final String displayText;
  final Color color;
  final IconData icon;

  // 추가 유틸리티 메서드들
  bool get isCompleted => this == OrderStatus.completed;
  bool get isInProgress => this == OrderStatus.pending || this == OrderStatus.confirmed;
  bool get isCancelled => this == OrderStatus.cancelled;
}

class OrderModel {
  final String id;
  final String buyerId;
  final String sellerId;
  final String buyerName;
  final String sellerName;
  final String? buyerBusinessName;
  final String? sellerBusinessName;
  final List<OrderItemModel> items;
  final DateTime orderDate;
  final int totalAmount;
  final OrderStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const OrderModel({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.buyerName,
    required this.sellerName,
    this.buyerBusinessName,
    this.sellerBusinessName,
    required this.items,
    required this.orderDate,
    required this.totalAmount,
    this.status = OrderStatus.pending,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  // Factory constructor for creating OrderModel from Firestore document
  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return OrderModel(
      id: doc.id,
      buyerId: data['buyerId'] as String,
      sellerId: data['sellerId'] as String,
      buyerName: data['buyerName'] as String,
      sellerName: data['sellerName'] as String,
      buyerBusinessName: data['buyerBusinessName'] as String?,
      sellerBusinessName: data['sellerBusinessName'] as String?,
      items:
          (data['items'] as List<dynamic>)
              .map(
                (item) => OrderItemModel.fromMap(item as Map<String, dynamic>),
              )
              .toList(),
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      totalAmount: data['totalAmount'] as int,
      status: OrderStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => OrderStatus.pending,
      ),
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : null,
    );
  }

  // Factory constructor for creating OrderModel from Map
  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] as String,
      buyerId: map['buyerId'] as String,
      sellerId: map['sellerId'] as String,
      buyerName: map['buyerName'] as String,
      sellerName: map['sellerName'] as String,
      buyerBusinessName: map['buyerBusinessName'] as String?,
      sellerBusinessName: map['sellerBusinessName'] as String?,
      items:
          (map['items'] as List<dynamic>)
              .map(
                (item) => OrderItemModel.fromMap(item as Map<String, dynamic>),
              )
              .toList(),
      orderDate:
          map['orderDate'] is Timestamp
              ? (map['orderDate'] as Timestamp).toDate()
              : DateTime.parse(map['orderDate'] as String),
      totalAmount: map['totalAmount'] as int,
      status: OrderStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      notes: map['notes'] as String?,
      createdAt:
          map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.parse(map['createdAt'] as String),
      updatedAt:
          map['updatedAt'] != null
              ? (map['updatedAt'] is Timestamp
                  ? (map['updatedAt'] as Timestamp).toDate()
                  : DateTime.parse(map['updatedAt'] as String))
              : null,
    );
  }

  // Convert OrderModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'buyerId': buyerId,
      'sellerId': sellerId,
      'buyerName': buyerName,
      'sellerName': sellerName,
      'buyerBusinessName': buyerBusinessName,
      'sellerBusinessName': sellerBusinessName,
      'items': items.map((item) => item.toMap()).toList(),
      'orderDate': Timestamp.fromDate(orderDate),
      'totalAmount': totalAmount,
      'status': status.name,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // CopyWith method for immutable updates
  OrderModel copyWith({
    String? id,
    String? buyerId,
    String? sellerId,
    String? buyerName,
    String? sellerName,
    String? buyerBusinessName,
    String? sellerBusinessName,
    List<OrderItemModel>? items,
    DateTime? orderDate,
    int? totalAmount,
    OrderStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      buyerName: buyerName ?? this.buyerName,
      sellerName: sellerName ?? this.sellerName,
      buyerBusinessName: buyerBusinessName ?? this.buyerBusinessName,
      sellerBusinessName: sellerBusinessName ?? this.sellerBusinessName,
      items: items ?? this.items,
      orderDate: orderDate ?? this.orderDate,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, buyerId: $buyerId, sellerId: $sellerId, buyerName: $buyerName, sellerName: $sellerName, items: $items, orderDate: $orderDate, totalAmount: $totalAmount, status: $status)';
  }
}

class OrderItemModel {
  final String productId;
  final String productName;
  final String unit;
  final int quantity;
  final int? unitPrice;
  final int? totalPrice;

  const OrderItemModel({
    required this.productId,
    required this.productName,
    required this.unit,
    required this.quantity,
    this.unitPrice,
    this.totalPrice,
  });

  // Factory constructor for creating OrderItemModel from Map
  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId'] as String,
      productName: map['productName'] as String,
      unit: map['unit'] as String,
      quantity: map['quantity'] as int,
      unitPrice: map['unitPrice'] as int?,
      totalPrice: map['totalPrice'] as int?,
    );
  }

  // Convert OrderItemModel to Map
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'unit': unit,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }

  @override
  String toString() {
    return 'OrderItemModel(productId: $productId, productName: $productName, unit: $unit, quantity: $quantity, unitPrice: $unitPrice, totalPrice: $totalPrice)';
  }
}
