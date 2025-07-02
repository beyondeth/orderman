import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_market_app/app/presentation/controllers/main_controller.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/product_service.dart';
import '../../../core/services/order_service.dart';
import '../../../core/services/connection_service.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/connection_model.dart';

class OrderController extends GetxController {
  // Services
  final ProductService _productService = ProductService.instance;
  final OrderService _orderService = OrderService.instance;

  // Reactive variables
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxMap<String, int> selectedItems = <String, int>{}.obs;
  final RxBool isLoading = false.obs;
  final RxBool isCreatingOrder = false.obs;
  final Rx<ConnectionModel?> connection = Rx<ConnectionModel?>(null);
  final RxInt totalAmount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeOrder();
    
    // Also listen to MainController's active connection changes
    _listenToMainControllerConnection();
  }

  void _listenToMainControllerConnection() {
    try {
      final mainController = Get.find<MainController>();
      // Listen to active connection changes
      ever(mainController.activeConnection, (ConnectionModel? newConnection) {
        if (newConnection != null && connection.value?.sellerId != newConnection.sellerId) {
          print('=== 🔄 Active connection changed: ${newConnection.sellerName} ===');
          connection.value = newConnection;
          _loadProducts();
        }
      });
    } catch (e) {
      print('=== ❌ Failed to listen to MainController connection: $e ===');
    }
  }

  void _initializeOrder() {
    print('=== 🔍 OrderController._initializeOrder called ===');

    // First try to get connection from arguments (direct navigation)
    final args = Get.arguments as Map<String, dynamic>?;
    print('=== 📋 Arguments received: $args ===');

    if (args != null && args['connection'] != null) {
      connection.value = args['connection'] as ConnectionModel;
      print(
        '=== 🔗 Connection from arguments: ${connection.value!.sellerName} (${connection.value!.sellerId}) ===',
      );
      _loadProducts();
    } else {
      // Try to get connection from MainController (tab navigation)
      try {
        final mainController = Get.find<MainController>();
        final activeConnection = mainController.currentConnection;
        if (activeConnection != null) {
          connection.value = activeConnection;
          print(
            '=== 🔗 Connection from MainController: ${connection.value!.sellerName} (${connection.value!.sellerId}) ===',
          );
          _loadProducts();
        } else {
          print('=== ⚠️ No active connection in MainController ===');
        }
      } catch (e) {
        print('=== ❌ Failed to get MainController: $e ===');
      }
    }

    // Listen to selected items changes to calculate total
    ever(selectedItems, (_) => _calculateTotal());
  }

  Future<void> _loadProducts() async {
    if (connection.value == null) {
      print('=== ❌ No connection available for loading products ===');
      return;
    }

    print(
      '=== 🔍 Loading products for seller: ${connection.value!.sellerId} ===',
    );
    isLoading.value = true;

    try {
      // Listen to products stream
      _productService
          .getSellerProducts(connection.value!.sellerId)
          .listen(
            (productList) {
              print(
                '=== 📦 Products received in OrderController: ${productList.length} ===',
              );
              products.value = productList;
              isLoading.value = false;

              // Log each product for debugging
              for (final product in productList) {
                print(
                  '=== 📋 Order Product: ${product.name} (${product.id}) - Active: ${product.isActive} ===',
                );
              }

              Get.log('Products loaded: ${productList.length}');
            },
            onError: (error) {
              print(
                '=== ❌ Error loading products in OrderController: $error ===',
              );
              Get.log('Failed to load products: $error');
              Get.snackbar(
                '상품 로딩 실패',
                '상품 목록을 불러오는데 실패했습니다.',
                snackPosition: SnackPosition.BOTTOM,
              );
              isLoading.value = false;
            },
          );
    } catch (e) {
      print('=== ❌ Exception in OrderController._loadProducts: $e ===');
      Get.log('Error loading products: $e');
      isLoading.value = false;
    }
  }

  void selectProduct(String productId, int quantity) {
    if (quantity > 0) {
      selectedItems[productId] = quantity;
      Get.log('Product selected: $productId, quantity: $quantity');
    } else {
      selectedItems.remove(productId);
      Get.log('Product deselected: $productId');
    }
  }

  void removeProduct(String productId) {
    selectedItems.remove(productId);
    Get.log('Product removed: $productId');
  }

  void clearAllSelections() {
    selectedItems.clear();
    Get.log('All selections cleared');
  }

  void _calculateTotal() {
    int total = 0;

    for (final entry in selectedItems.entries) {
      final productId = entry.key;
      final quantity = entry.value;

      final product = products.firstWhereOrNull((p) => p.id == productId);
      if (product != null && product.price != null) {
        total += product.price! * quantity;
      }
    }

    totalAmount.value = total;
    Get.log('Total amount calculated: $total');
  }

  Future<void> createOrder() async {
    print('=== 주문 생성 시작 ===');

    if (selectedItems.isEmpty) {
      print('=== 선택된 상품 없음 ===');
      Get.snackbar(
        '선택된 상품 없음',
        '주문할 상품을 선택해주세요.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (connection.value == null) {
      print('=== 연결 정보 없음 ===');
      Get.snackbar(
        '연결 정보 없음',
        '판매자 연결 정보를 찾을 수 없습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Get current user
    AuthService? authService;
    if (Get.isRegistered<AuthService>()) {
      authService = Get.find<AuthService>();
    }

    if (authService?.userModel == null) {
      print('=== 사용자 정보 없음 ===');
      Get.snackbar(
        '사용자 정보 없음',
        '로그인 정보를 확인해주세요.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isCreatingOrder.value = true;

    try {
      final currentUser = authService!.userModel!;
      print('=== 현재 사용자: ${currentUser.displayName} (${currentUser.uid}) ===');
      print(
        '=== 판매자: ${connection.value!.sellerName} (${connection.value!.sellerId}) ===',
      );
      print('=== 선택된 상품 수: ${selectedItems.length} ===');

      // Create order items
      final orderItems = <OrderItemModel>[];
      final skippedProducts = <String>[];

      for (final entry in selectedItems.entries) {
        final productId = entry.key;
        final quantity = entry.value;

        final product = products.firstWhereOrNull((p) => p.id == productId);
        if (product != null) {
          // 가격이 설정되지 않은 상품도 주문 허용 (가격 0으로 처리)
          final unitPrice = product.price ?? 0;
          final totalPrice = unitPrice * quantity;

          final orderItem = OrderItemModel(
            productId: product.id,
            productName: product.name,
            unit: product.unit,
            quantity: quantity,
            unitPrice: unitPrice,
            totalPrice: totalPrice,
          );
          orderItems.add(orderItem);
          
          if (product.price != null) {
            print(
              '=== 주문 상품 추가: ${product.name} x ${quantity} = ${totalPrice}원 ===',
            );
          } else {
            print(
              '=== 가격 미설정 상품 추가: ${product.name} x ${quantity} (가격: 0원) ===',
            );
            skippedProducts.add(product.name);
          }
        } else {
          print('=== 상품을 찾을 수 없음: $productId ===');
        }
      }

      // Show info if some products have no price
      if (skippedProducts.isNotEmpty) {
        Get.snackbar(
          '가격 미설정 상품 포함',
          '다음 상품들은 가격이 설정되지 않아 0원으로 주문됩니다:\n${skippedProducts.join(', ')}',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
        );
      }

      if (orderItems.isEmpty) {
        print('=== 주문 상품이 없음 ===');
        Get.snackbar(
          '주문 상품 없음',
          '주문할 수 있는 상품이 없습니다.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Create order
      final order = OrderModel(
        id: '', // Will be set by Firestore
        buyerId: currentUser.uid,
        sellerId: connection.value!.sellerId,
        buyerName: currentUser.displayName,
        sellerName: connection.value!.sellerName,
        buyerBusinessName: currentUser.businessName,
        sellerBusinessName: connection.value!.sellerBusinessName,
        items: orderItems,
        orderDate: DateTime.now(),
        totalAmount: totalAmount.value,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
      );

      print('=== 주문 데이터 생성 완료 - 총 금액: ${totalAmount.value}원 ===');
      print('=== Firestore에 저장 시작 ===');

      final success = await _orderService.createOrder(order);

      if (success) {
        print('=== 주문 저장 성공 ===');
        // Clear selections and go back
        clearAllSelections();
        Get.back();

        Get.snackbar(
          '주문 완료',
          '주문이 성공적으로 저장되었습니다.\n총 ${orderItems.length}개 상품, ${totalAmount.value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      } else {
        print('=== 주문 저장 실패 ===');
        Get.snackbar(
          '주문 실패',
          '주문 저장에 실패했습니다. 다시 시도해주세요.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e, stackTrace) {
      print('=== 주문 생성 중 오류 발생: $e ===');
      print('=== Stack trace: $stackTrace ===');
      Get.snackbar(
        '주문 실패',
        '주문을 생성하는데 실패했습니다: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isCreatingOrder.value = false;
      print('=== 주문 생성 프로세스 완료 ===');
    }
  }

  // Refresh products
  Future<void> refreshProducts() async {
    print('=== 🔄 Manual refresh triggered in OrderController ===');
    await _loadProducts();
  }

  // Debug method to check connection and products
  void debugConnectionAndProducts() {
    print('=== 🐛 DEBUG INFO ===');
    print('=== Connection: ${connection.value?.toString()} ===');
    print('=== Products count: ${products.length} ===');
    print('=== Selected items: ${selectedItems.toString()} ===');
    print('=== Is loading: ${isLoading.value} ===');

    if (connection.value != null) {
      print('=== Seller ID: ${connection.value!.sellerId} ===');
      print('=== Seller Name: ${connection.value!.sellerName} ===');
    }
  }
}
