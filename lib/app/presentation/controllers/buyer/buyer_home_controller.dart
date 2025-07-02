import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/connection_service.dart';
import '../../../core/services/order_service.dart';
import '../../../core/services/product_service.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/connection_model.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/product_model.dart';
import '../../../routes/app_routes.dart';
import '../main_controller.dart';

class BuyerHomeController extends GetxController {
  // Reactive variables
  final RxList<ConnectionModel> connections = <ConnectionModel>[].obs;
  final RxList<OrderModel> recentOrders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingOrders = false.obs;

  // Services
  AuthService get _authService => Get.find<AuthService>();
  ConnectionService get _connectionService => Get.find<ConnectionService>();
  OrderService get _orderService => OrderService.instance;
  ProductService get _productService => ProductService.instance;

  // Getters
  UserModel? get currentUser {
    if (Get.isRegistered<AuthService>()) {
      final user = Get.find<AuthService>().userModel;
      print('=== BuyerHomeController - Current User: ${user?.displayName} ===');
      print('=== BuyerHomeController - User Role: ${user?.role} ===');
      return user;
    }
    print('=== BuyerHomeController - AuthService not registered ===');
    return null;
  }

  String get userName {
    final name = currentUser?.displayName ?? '구매자';
    print('=== BuyerHomeController - User Name: $name ===');
    return name;
  }

  String get businessName {
    final business = currentUser?.businessName ?? '';
    print('=== BuyerHomeController - Business Name: $business ===');
    return business;
  }

  // 인사말 메시지
  String get greetingMessage {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '좋은 아침입니다!';
    } else if (hour < 18) {
      return '좋은 오후입니다!';
    } else {
      return '좋은 저녁입니다!';
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadConnections();
    _loadRecentOrders();
  }

  // 프로필 화면으로 이동
  void goToProfile() {
    Get.toNamed(AppRoutes.profile);
  }

  // Load connected sellers
  Future<void> _loadConnections() async {
    final currentUser = this.currentUser;
    if (currentUser == null) {
      print('=== ❌ Current user is null ===');
      return;
    }

    print('=== 🔍 Loading connections for user: ${currentUser.uid} ===');
    print('=== 🔍 User email: ${currentUser.email} ===');
    print('=== 🔍 User role: ${currentUser.role} ===');

    isLoading.value = true;

    try {
      // 모든 연결 상태 확인 (디버깅용)
      await _debugAllConnections(currentUser.uid);

      _connectionService
          .getApprovedConnections(currentUser.uid)
          .listen(
            (connectionList) {
              connections.value = connectionList;
              print(
                '=== ✅ Loaded ${connectionList.length} approved connections ===',
              );

              // 각 연결 정보 출력 및 상품 미리 로드
              for (int i = 0; i < connectionList.length; i++) {
                final conn = connectionList[i];
                print('=== Connection $i: ===');
                print('  - ID: ${conn.id}');
                print('  - Buyer ID: ${conn.buyerId}');
                print('  - Seller ID: ${conn.sellerId}');
                print('  - Buyer Name: ${conn.buyerName}');
                print('  - Seller Name: ${conn.sellerName}');
                print('  - Status: ${conn.status}');
                print('  - Requested At: ${conn.requestedAt}');
                
                // 판매자 상품 미리 로드
                print('=== 🔗 Preloading products for seller: ${conn.sellerName} (${conn.sellerId}) ===');
                _loadSellerProducts(conn.sellerId);
              }
            },
            onError: (error) {
              print('=== ❌ Error loading connections: $error ===');
            },
          );
    } catch (e) {
      print('=== ❌ Failed to load connections: $e ===');
    } finally {
      isLoading.value = false;
    }
  }

  // 디버깅용: 모든 연결 상태 확인
  Future<void> _debugAllConnections(String buyerId) async {
    try {
      final allConnections =
          await FirebaseFirestore.instance
              .collection('connections')
              .where('buyerId', isEqualTo: buyerId)
              .get();

      print(
        '=== 🔍 All connections for buyer $buyerId: ${allConnections.docs.length} ===',
      );

      for (var doc in allConnections.docs) {
        final data = doc.data();
        print('=== Connection ${doc.id}: ===');
        print('  - Buyer ID: ${data['buyerId']}');
        print('  - Seller ID: ${data['sellerId']}');
        print('  - Buyer Email: ${data['buyerEmail']}');
        print('  - Seller Email: ${data['sellerEmail']}');
        print('  - Status: ${data['status']}');
        print('  - Requested At: ${data['requestedAt']}');
      }
    } catch (e) {
      print('=== ❌ Debug connections error: $e ===');
    }
  }

  // Load recent orders (최근 5개)
  Future<void> _loadRecentOrders() async {
    final currentUser = this.currentUser;
    if (currentUser == null) {
      print('=== ❌ Current user is null for recent orders ===');
      return;
    }

    print('=== 🔍 Loading recent orders for user: ${currentUser.uid} ===');
    isLoadingOrders.value = true;

    try {
      _orderService
          .getBuyerOrders(currentUser.uid)
          .listen(
            (orderList) {
              // 최근 5개 주문만 가져오기
              final sortedOrders =
                  orderList..sort((a, b) => b.orderDate.compareTo(a.orderDate));
              recentOrders.value = sortedOrders.take(5).toList();

              print('=== ✅ Loaded ${recentOrders.length} recent orders ===');
              isLoadingOrders.value = false;
            },
            onError: (error) {
              print('=== ❌ Error loading recent orders: $error ===');
              isLoadingOrders.value = false;
            },
          );
    } catch (e) {
      print('=== ❌ Failed to load recent orders: $e ===');
      isLoadingOrders.value = false;
    }
  }

  // Refresh connections
  Future<void> refreshConnections() async {
    await _loadConnections();
    await _loadRecentOrders();
  }

  // 데이터 새로고침
  Future<void> refreshData() async {
    await _loadConnections();
  }

  // Navigate to seller connection
  void goToSellerConnect() {
    Get.toNamed(AppRoutes.sellerConnect);
  }

  // Navigate to order history
  void goToOrderHistory() {
    Get.toNamed(AppRoutes.orderHistory);
  }

  // 새로운 주문 관련 기능들
  final RxSet<String> expandedSellers = <String>{}.obs;
  final RxMap<String, bool> selectedProducts = <String, bool>{}.obs;
  final RxMap<String, int> productQuantities = <String, int>{}.obs;
  final RxMap<String, List<ProductModel>> sellerProductsMap = <String, List<ProductModel>>{}.obs;

  // 판매자 확장/축소 토글
  void toggleSellerExpansion(String sellerId) {
    if (expandedSellers.contains(sellerId)) {
      expandedSellers.remove(sellerId);
    } else {
      expandedSellers.add(sellerId);
      // 판매자 상품 로드 (기존 ProductService 사용)
      _loadSellerProducts(sellerId);
    }
  }

  // 판매자 상품 로드 (기존 ProductService 활용)
  void _loadSellerProducts(String sellerId) {
    try {
      print('=== 🔍 Loading products for seller: $sellerId ===');
      
      // 기존 ProductService의 getSellerProducts 사용
      _productService.getSellerProducts(sellerId).listen(
        (products) {
          print('=== 📦 Loaded ${products.length} products for seller: $sellerId ===');
          for (var product in products) {
            print('=== Product: ${product.name} - ${product.price}원 (Active: ${product.isActive}) ===');
          }
          sellerProductsMap[sellerId] = products;
          
          // UI 업데이트를 위해 강제로 갱신
          sellerProductsMap.refresh();
        },
        onError: (error) {
          print('=== ❌ Failed to load seller products: $error ===');
          sellerProductsMap[sellerId] = [];
        },
      );
    } catch (e) {
      print('=== ❌ Exception in _loadSellerProducts: $e ===');
      sellerProductsMap[sellerId] = [];
    }
  }

  // 판매자 상품 가져오기
  List<ProductModel> getSellerProducts(String sellerId) {
    final products = sellerProductsMap[sellerId] ?? [];
    print('=== 🔍 getSellerProducts called for seller: $sellerId, found ${products.length} products ===');
    return products;
  }

  // 상품 선택/해제
  void toggleProductSelection(String productId) {
    final isSelected = selectedProducts[productId] ?? false;
    selectedProducts[productId] = !isSelected;

    if (!isSelected) {
      // 선택 시 기본 수량 1로 설정
      productQuantities[productId] = 1;
    } else {
      // 선택 해제 시 수량 제거
      productQuantities.remove(productId);
    }
  }

  // 상품 선택 여부 확인
  bool isProductSelected(String productId) {
    return selectedProducts[productId] ?? false;
  }

  // 상품 수량 가져오기
  int getProductQuantity(String productId) {
    return productQuantities[productId] ?? 0;
  }

  // 수량 증가
  void increaseQuantity(String productId) {
    final currentQuantity = productQuantities[productId] ?? 0;
    productQuantities[productId] = currentQuantity + 1;
  }

  // 수량 감소
  void decreaseQuantity(String productId) {
    final currentQuantity = productQuantities[productId] ?? 0;
    if (currentQuantity > 1) {
      productQuantities[productId] = currentQuantity - 1;
    } else {
      // 수량이 1 이하가 되면 선택 해제
      selectedProducts[productId] = false;
      productQuantities.remove(productId);
    }
  }

  // 선택된 상품이 있는지 확인
  bool hasSelectedProducts(String sellerId) {
    return selectedProducts.values.any((selected) => selected);
  }

  // 선택된 상품으로 주문 생성
  Future<void> createOrderFromSelection(ConnectionModel connection) async {
    try {
      print('=== 🛒 Starting order creation for seller: ${connection.sellerName} ===');
      
      final selectedProductIds = selectedProducts.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      print('=== 📋 Selected product IDs: $selectedProductIds ===');

      if (selectedProductIds.isEmpty) {
        print('=== ❌ No products selected ===');
        Get.snackbar('알림', '주문할 상품을 선택해주세요.');
        return;
      }

      final sellerProducts = getSellerProducts(connection.sellerId);
      print('=== 📦 Available seller products: ${sellerProducts.length} ===');
      
      if (sellerProducts.isEmpty) {
        print('=== ❌ No seller products found ===');
        Get.snackbar('오류', '판매자의 상품을 찾을 수 없습니다.');
        return;
      }
      
      // 주문 생성 로직 - 실제 상품 정보 사용
      final orderItems = <Map<String, dynamic>>[];
      
      for (var productId in selectedProductIds) {
        try {
          final quantity = productQuantities[productId] ?? 1;
          final product = sellerProducts.firstWhere(
            (p) => p.id == productId,
            orElse: () => throw Exception('Product not found: $productId'),
          );
          
          print('=== 📝 Processing product: ${product.name}, quantity: $quantity, price: ${product.price} ===');
          
          final orderItem = {
            'productId': productId,
            'productName': product.name,
            'unit': product.unit,
            'quantity': quantity,
            'unitPrice': product.price ?? 0, // 가격 미설정도 허용
            'totalPrice': (product.price ?? 0) * quantity,
          };
          
          orderItems.add(orderItem);
          print('=== ✅ Added order item: ${orderItem} ===');
          
        } catch (e) {
          print('=== ❌ Error processing product $productId: $e ===');
          Get.snackbar('오류', '상품 처리 중 오류가 발생했습니다: $productId');
          return;
        }
      }

      print('=== 📋 Final order items: ${orderItems.length} ===');

      // 주문 생성 (가격 미설정 상품도 포함)
      await _createOrderWithItems(connection, orderItems);
      
      // 선택 상태 초기화
      selectedProducts.clear();
      productQuantities.clear();
      
      Get.snackbar('성공', '주문이 생성되었습니다.');
      
    } catch (e, stackTrace) {
      print('=== ❌ Failed to create order: $e ===');
      print('=== ❌ Stack trace: $stackTrace ===');
      Get.snackbar('오류', '주문 생성 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  // 주문 생성 (가격 미설정 상품 포함)
  Future<void> _createOrderWithItems(
    ConnectionModel connection,
    List<Map<String, dynamic>> orderItems,
  ) async {
    try {
      print('=== 🔧 Creating order with items: ${orderItems.length} ===');
      
      final user = currentUser;
      if (user == null) {
        throw Exception('Current user is null');
      }

      print('=== 👤 User: ${user.displayName} (${user.uid}) ===');

      // OrderItemModel 리스트 생성
      final orderItemModels = orderItems.map((item) {
        final unitPrice = item['unitPrice'] as int? ?? 0;
        final totalPrice = item['totalPrice'] as int? ?? 0;
        
        print('=== 📝 Creating OrderItem: ${item['productName']}, qty: ${item['quantity']}, unit: $unitPrice, total: $totalPrice ===');
        
        return OrderItemModel(
          productId: item['productId'] as String,
          productName: item['productName'] as String,
          unit: item['unit'] as String? ?? '',
          quantity: item['quantity'] as int,
          unitPrice: unitPrice,
          totalPrice: totalPrice,
        );
      }).toList();

      // 총 금액 계산
      final totalAmount = orderItemModels.fold<int>(0, (sum, item) {
        return sum + (item.totalPrice ?? 0);
      });

      print('=== 💰 Total amount: $totalAmount ===');

      // OrderModel 객체 생성
      final order = OrderModel(
        id: '', // Firestore에서 자동 생성
        buyerId: user.uid,
        sellerId: connection.sellerId,
        buyerName: user.displayName ?? '',
        sellerName: connection.sellerName,
        buyerBusinessName: user.businessName,
        sellerBusinessName: connection.sellerBusinessName,
        items: orderItemModels,
        orderDate: DateTime.now(),
        totalAmount: totalAmount,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
      );

      print('=== 📤 Sending order to service ===');

      // OrderService를 통해 주문 생성
      final success = await _orderService.createOrder(order);
      
      if (success) {
        print('=== ✅ Order created successfully ===');
        // 주문 목록 새로고침
        await _loadRecentOrders();
      } else {
        throw Exception('OrderService returned false');
      }
      
    } catch (e, stackTrace) {
      print('=== ❌ Failed to create order with items: $e ===');
      print('=== ❌ Stack trace: $stackTrace ===');
      rethrow;
    }
  }

  // Navigate to settings
  void goToSettings() {
    Get.toNamed(AppRoutes.settings);
  }

  // Navigate to order create for specific seller
  void goToOrderCreate(ConnectionModel connection) {
    print('=== 🔍 Setting active connection: ${connection.sellerName} ===');

    // Set active connection in MainController for tab navigation
    try {
      final mainController = Get.find<MainController>();
      mainController.setActiveConnection(connection);
      print('=== ✅ Active connection set in MainController ===');

      // Switch to order tab instead of navigating to new page
      mainController.changeTab(1);
      print('=== ✅ Switched to order tab ===');
    } catch (e) {
      print('=== ❌ Failed to set active connection: $e ===');

      // Fallback: navigate to order page with arguments
      Get.toNamed(
        AppRoutes.orderCreate,
        arguments: {'connection': connection, 'sellerId': connection.sellerId},
      );
    }
  }

  // Navigate to order detail
  void goToOrderDetail(dynamic order) {
    Get.toNamed(AppRoutes.orderDetail, arguments: {'order': order});
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      print('=== Sign out error: $e ===');
      Get.snackbar('오류', '로그아웃 중 오류가 발생했습니다.');
    }
  }
}
