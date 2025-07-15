import 'dart:async';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/product_service.dart';
import '../../../data/models/product_model.dart';

class ProductManagementController extends GetxController {
  final ProductService _productService = ProductService.instance;

  // Reactive variables
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isAddingProduct = false.obs;
  final RxBool isUpdatingProduct = false.obs;
  
  // Stream subscription
  StreamSubscription<List<ProductModel>>? _productsSubscription;

  @override
  void onInit() {
    super.onInit();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    print('=== 🔍 _loadProducts called ===');
    
    // Cancel existing subscription
    await _productsSubscription?.cancel();
    
    // Get current user
    AuthService? authService;
    if (Get.isRegistered<AuthService>()) {
      authService = Get.find<AuthService>();
    }

    if (authService?.userModel == null) {
      print('=== ❌ No user model found ===');
      Get.snackbar(
        '사용자 정보 없음',
        '로그인 정보를 확인해주세요.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final currentUser = authService!.userModel!;
    print('=== 👤 Current user: ${currentUser.uid} ===');
    isLoading.value = true;

    try {
      // Listen to products stream
      _productsSubscription = _productService.getAllSellerProducts(currentUser.uid).listen(
        (productList) {
          print('=== 📦 Products received: ${productList.length} ===');
          products.assignAll(productList);
          isLoading.value = false;
          
          // Log each product for debugging
          for (final product in productList) {
            print('=== 📋 Product: ${product.name} (${product.id}) ===');
          }
        },
        onError: (error) {
          print('=== ❌ Stream error: $error ===');
          Get.log('Failed to load products: $error');
          Get.snackbar(
            '상품 로딩 실패',
            '상품 목록을 불러오는데 실패했습니다: $error',
            snackPosition: SnackPosition.BOTTOM,
          );
          isLoading.value = false;
        },
      );
    } catch (e) {
      print('=== ❌ Exception in _loadProducts: $e ===');
      Get.log('Error loading products: $e');
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _productsSubscription?.cancel();
    super.onClose();
  }

  Future<void> addProduct(ProductModel product) async {
    print('=== 🔍 ProductManagementController.addProduct called ===');
    
    // Set loading state
    isAddingProduct.value = true;
    
    try {
      // Get current user
      AuthService? authService;
      if (Get.isRegistered<AuthService>()) {
        authService = Get.find<AuthService>();
      }

      if (authService?.userModel == null) {
        print('=== ❌ No user model found ===');
        Get.snackbar(
          '사용자 정보 없음',
          '로그인 정보를 확인해주세요.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final currentUser = authService!.userModel!;
      print('=== Current user ID: ${currentUser.uid} ===');
      print('=== Current user email: ${currentUser.email} ===');
      
      // Check for duplicate product name
      final isDuplicate = await _productService.isProductNameExists(
        currentUser.uid, 
        product.name.trim()
      );
      
      if (isDuplicate) {
        Get.snackbar(
          '중복된 상품명',
          '이미 등록된 상품명입니다. 다른 이름을 사용해주세요.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      
      final newProduct = product.copyWith(
        sellerId: currentUser.uid,
        orderIndex: products.length,
        createdAt: DateTime.now(),
      );

      print('=== Product to add: ${newProduct.toString()} ===');

      final success = await _productService.addProduct(newProduct);
      
      print('=== Add product result: $success ===');
      
      if (success) {
        Get.snackbar(
          '상품 추가 완료',
          '${newProduct.name} 상품이 추가되었습니다.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        print('=== ❌ Product addition failed ===');
        Get.snackbar(
          '상품 추가 실패',
          '상품 추가 중 오류가 발생했습니다.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('=== ❌ Exception in addProduct: $e ===');
      Get.snackbar(
        '상품 추가 실패',
        '상품 추가 중 오류가 발생했습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      // Reset loading state
      isAddingProduct.value = false;
    }
  }

  // 개별 파라미터를 받는 addProduct 메서드 추가
  Future<void> addProductWithParams(String name, String unit, int price) async {
    final product = ProductModel(
      id: '', // Firestore에서 자동 생성
      sellerId: '', // 메서드 내에서 설정
      name: name,
      unit: unit,
      price: price,
      isActive: true,
      orderIndex: 0, // 메서드 내에서 설정
      createdAt: DateTime.now(),
    );
    
    await addProduct(product);
  }

  Future<void> updateProduct(ProductModel product) async {
    isUpdatingProduct.value = true;
    
    try {
      // Get current user
      AuthService? authService;
      if (Get.isRegistered<AuthService>()) {
        authService = Get.find<AuthService>();
      }

      if (authService?.userModel == null) {
        Get.snackbar(
          '사용자 정보 없음',
          '로그인 정보를 확인해주세요.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final currentUser = authService!.userModel!;
      
      // Check for duplicate product name (excluding current product)
      final isDuplicate = await _productService.isProductNameExists(
        currentUser.uid, 
        product.name.trim(),
        excludeProductId: product.id,
      );
      
      if (isDuplicate) {
        Get.snackbar(
          '중복된 상품명',
          '이미 등록된 상품명입니다. 다른 이름을 사용해주세요.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      
      final success = await _productService.updateProduct(product);
      
      if (success) {
        Get.snackbar(
          '상품 수정 완료',
          '${product.name} 상품이 수정되었습니다.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          '상품 수정 실패',
          '상품 수정 중 오류가 발생했습니다.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        '상품 수정 실패',
        '상품 수정 중 오류가 발생했습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUpdatingProduct.value = false;
    }
  }

  // 개별 파라미터를 받는 updateProduct 메서드 추가
  Future<void> updateProductWithParams(String productId, String name, String unit, int price) async {
    // 기존 상품 찾기
    final existingProduct = products.firstWhereOrNull((p) => p.id == productId);
    if (existingProduct == null) {
      Get.snackbar(
        '상품을 찾을 수 없음',
        '수정할 상품을 찾을 수 없습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    final updatedProduct = existingProduct.copyWith(
      name: name,
      unit: unit,
      price: price,
    );
    
    await updateProduct(updatedProduct);
  }

  Future<void> deleteProduct(String productId) async {
    final success = await _productService.deleteProduct(productId);
    
    if (success) {
      Get.snackbar(
        '상품 삭제 완료',
        '상품이 삭제되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> toggleProductStatus(String productId, bool isActive) async {
    final success = await _productService.toggleProductStatus(productId, isActive);
    
    if (success) {
      final status = isActive ? '활성화' : '비활성화';
      Get.snackbar(
        '상품 상태 변경',
        '상품이 ${status}되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> refreshProducts() async {
    print('=== 🔄 Manual refresh triggered ===');
    await _loadProducts();
  }

  // Create sample products for testing
  Future<void> createSampleProducts() async {
    AuthService? authService;
    if (Get.isRegistered<AuthService>()) {
      authService = Get.find<AuthService>();
    }

    if (authService?.userModel == null) return;

    final currentUser = authService!.userModel!;
    await _productService.createSampleProducts(currentUser.uid);
    
    Get.snackbar(
      '샘플 상품 생성',
      '테스트용 상품들이 생성되었습니다.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
