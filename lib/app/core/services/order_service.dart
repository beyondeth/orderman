import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/order_model.dart';
import 'firebase_service.dart';

class OrderService extends GetxService {
  static OrderService get instance => Get.find<OrderService>();

  final FirebaseService _firebaseService = FirebaseService.instance;

  // Create new order
  Future<bool> createOrder(OrderModel order) async {
    try {
      print('=== OrderService: 주문 생성 시작 ===');
      print('=== 구매자: ${order.buyerName} (${order.buyerId}) ===');
      print('=== 판매자: ${order.sellerName} (${order.sellerId}) ===');
      print('=== 상품 수: ${order.items.length} ===');
      print('=== 총 금액: ${order.totalAmount}원 ===');

      final docRef = _firebaseService.ordersCollection.doc();
      final newOrder = order.copyWith(id: docRef.id, createdAt: DateTime.now());

      print('=== 생성된 주문 ID: ${docRef.id} ===');
      print('=== Firestore에 저장 중... ===');

      // 주문 데이터를 Map으로 변환하여 로그 출력
      final orderMap = newOrder.toMap();
      print('=== 저장할 주문 데이터: $orderMap ===');

      await docRef.set(orderMap);

      print('=== Firestore 저장 완료 ===');
      Get.log('Order created successfully: ${newOrder.id}');

      // 성공 메시지는 컨트롤러에서 처리하므로 여기서는 제거
      return true;
    } catch (e, stackTrace) {
      print('=== OrderService: 주문 생성 실패 ===');
      print('=== 오류: $e ===');
      print('=== Stack trace: $stackTrace ===');
      Get.log('Failed to create order: $e');

      // 에러 메시지는 컨트롤러에서 처리하므로 여기서는 제거
      return false;
    }
  }

  // Get buyer orders stream
  Stream<List<OrderModel>> getBuyerOrders(String buyerId) {
    return _firebaseService.ordersCollection
        .where('buyerId', isEqualTo: buyerId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => OrderModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // Get seller orders stream
  Stream<List<OrderModel>> getSellerOrders(String sellerId) {
    return _firebaseService.ordersCollection
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => OrderModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // Get today's orders for seller
  Stream<List<OrderModel>> getTodaySellerOrders(String sellerId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return _firebaseService.ordersCollection
        .where('sellerId', isEqualTo: sellerId)
        .where(
          'orderDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('orderDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => OrderModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // Get orders by date range
  Stream<List<OrderModel>> getOrdersByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate, {
    bool isSeller = false,
  }) {
    final field = isSeller ? 'sellerId' : 'buyerId';

    return _firebaseService.ordersCollection
        .where(field, isEqualTo: userId)
        .where(
          'orderDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        )
        .where('orderDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => OrderModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _firebaseService.ordersCollection.doc(orderId).update({
        'status': status.name,
        'updatedAt': Timestamp.now(),
      });

      Get.log('Order status updated: $orderId -> ${status.name}');
      return true;
    } catch (e) {
      Get.log('Failed to update order status: $e');
      Get.snackbar(
        '주문 상태 변경 실패',
        '주문 상태를 변경하는데 실패했습니다: ${_firebaseService.getFirebaseErrorMessage(e)}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firebaseService.ordersCollection.doc(orderId).get();
      if (doc.exists) {
        return OrderModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      Get.log('Failed to get order: $e');
      return null;
    }
  }

  // Delete order
  Future<bool> deleteOrder(String orderId) async {
    try {
      await _firebaseService.ordersCollection.doc(orderId).delete();

      Get.log('Order deleted successfully: $orderId');
      return true;
    } catch (e) {
      Get.log('Failed to delete order: $e');
      Get.snackbar(
        '주문 삭제 실패',
        '주문을 삭제하는데 실패했습니다: ${_firebaseService.getFirebaseErrorMessage(e)}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Get monthly summary
  Future<Map<String, dynamic>> getMonthlySummary(
    String userId,
    int year,
    int month, {
    bool isSeller = false,
  }) async {
    try {
      print('=== 📊 getMonthlySummary called ===');
      print('=== 👤 User ID: $userId ===');
      print('=== 📅 Year: $year, Month: $month ===');
      print('=== 🏪 Is Seller: $isSeller ===');
      
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
      final field = isSeller ? 'sellerId' : 'buyerId';

      print('=== 📅 Date range: $startDate to $endDate ===');
      print('=== 🔍 Querying field: $field ===');

      final snapshot = await _firebaseService.ordersCollection
          .where(field, isEqualTo: userId)
          .where(
            'orderDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where(
            'orderDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate),
          )
          .get();

      print('=== 📋 Found ${snapshot.docs.length} documents ===');

      final orders = snapshot.docs.map((doc) {
        print('=== 📄 Processing document: ${doc.id} ===');
        final data = doc.data() as Map<String, dynamic>;
        print('=== 📄 Document data: $data ===');
        return OrderModel.fromFirestore(doc);
      }).toList();

      final totalAmount = orders.fold<int>(
        0,
        (sum, order) {
          print('=== 💰 Adding order amount: ${order.totalAmount} (running total: ${sum + order.totalAmount}) ===');
          return sum + order.totalAmount;
        },
      );
      final totalOrders = orders.length;

      print('=== ✅ Final summary: $totalOrders orders, $totalAmount total amount ===');

      return {
        'totalAmount': totalAmount,
        'totalOrders': totalOrders,
        'orders': orders,
      };
    } catch (e, stackTrace) {
      print('=== ❌ Failed to get monthly summary: $e ===');
      print('=== ❌ Stack trace: $stackTrace ===');
      return {'totalAmount': 0, 'totalOrders': 0, 'orders': <OrderModel>[]};
    }
  }
}
