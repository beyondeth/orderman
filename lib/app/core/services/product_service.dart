import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/product_model.dart';
import 'firebase_service.dart';

class ProductService extends GetxService {
  static ProductService get instance => Get.find<ProductService>();

  final FirebaseService _firebaseService = FirebaseService.instance;

  // Get products stream for a seller
  Stream<List<ProductModel>> getSellerProducts(String sellerId) {
    print('=== 🔍 Getting ACTIVE products for seller: $sellerId ===');
    return _firebaseService.productsCollection
        .where('sellerId', isEqualTo: sellerId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          print('=== 📦 Active products snapshot received: ${snapshot.docs.length} docs ===');
          final products = snapshot.docs
              .map((doc) {
                try {
                  final product = ProductModel.fromFirestore(doc);
                  print('=== ✅ Active product parsed: ${product.name} (isActive: ${product.isActive}) ===');
                  return product;
                } catch (e) {
                  print('=== ❌ Error parsing active product ${doc.id}: $e ===');
                  return null;
                }
              })
              .where((product) => product != null)
              .cast<ProductModel>()
              .toList();
          
          // Sort in memory instead of using Firestore orderBy
          products.sort((a, b) {
            final orderComparison = a.orderIndex.compareTo(b.orderIndex);
            if (orderComparison != 0) return orderComparison;
            return a.name.compareTo(b.name);
          });
          
          print('=== 📋 Final active products list: ${products.length} items ===');
          return products;
        });
  }

  // Get all products for a seller (including inactive)
  Stream<List<ProductModel>> getAllSellerProducts(String sellerId) {
    print('=== 🔍 Getting products for seller: $sellerId ===');
    return _firebaseService.productsCollection
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) {
          print(
            '=== 📦 Firestore snapshot received: ${snapshot.docs.length} docs ===',
          );
          final products =
              snapshot.docs
                  .map((doc) {
                    try {
                      final product = ProductModel.fromFirestore(doc);
                      print('=== ✅ Product parsed: ${product.name} ===');
                      return product;
                    } catch (e) {
                      print('=== ❌ Error parsing product ${doc.id}: $e ===');
                      return null;
                    }
                  })
                  .where((product) => product != null)
                  .cast<ProductModel>()
                  .toList();

          // Sort in memory instead of using Firestore orderBy
          products.sort((a, b) {
            final orderComparison = a.orderIndex.compareTo(b.orderIndex);
            if (orderComparison != 0) return orderComparison;
            return a.name.compareTo(b.name);
          });

          print('=== 📋 Final products list: ${products.length} items ===');
          return products;
        });
  }

  // Check if product name already exists for a seller
  Future<bool> isProductNameExists(
    String sellerId,
    String productName, {
    String? excludeProductId,
  }) async {
    try {
      Query query = _firebaseService.productsCollection
          .where('sellerId', isEqualTo: sellerId)
          .where('name', isEqualTo: productName);

      final snapshot = await query.get();

      if (excludeProductId != null) {
        // For updates, exclude the current product being updated
        return snapshot.docs.any((doc) => doc.id != excludeProductId);
      }

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      Get.log('Failed to check product name: $e');
      return false;
    }
  }

  // Add new product
  Future<bool> addProduct(ProductModel product) async {
    try {
      print('=== 🔍 Adding product: ${product.name} ===');
      print('=== Seller ID: ${product.sellerId} ===');
      print('=== Product data: ${product.toMap()} ===');

      final docRef = _firebaseService.productsCollection.doc();
      print('=== Generated doc ID: ${docRef.id} ===');

      final newProduct = product.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
      );

      print('=== Final product data: ${newProduct.toMap()} ===');

      await docRef.set(newProduct.toMap());

      print('=== ✅ Product added successfully: ${newProduct.name} ===');
      Get.log('Product added successfully: ${newProduct.name}');
      return true;
    } catch (e) {
      print('=== ❌ Failed to add product: $e ===');
      print('=== Error type: ${e.runtimeType} ===');
      Get.log('Failed to add product: $e');
      Get.snackbar(
        '상품 추가 실패',
        '상품을 추가하는데 실패했습니다: ${_firebaseService.getFirebaseErrorMessage(e)}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Update product
  Future<bool> updateProduct(ProductModel product) async {
    try {
      final updatedProduct = product.copyWith(updatedAt: DateTime.now());

      await _firebaseService.productsCollection
          .doc(product.id)
          .update(updatedProduct.toMap());

      Get.log('Product updated successfully: ${product.name}');
      return true;
    } catch (e) {
      Get.log('Failed to update product: $e');
      Get.snackbar(
        '상품 수정 실패',
        '상품을 수정하는데 실패했습니다: ${_firebaseService.getFirebaseErrorMessage(e)}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Delete product
  Future<bool> deleteProduct(String productId) async {
    try {
      await _firebaseService.productsCollection.doc(productId).delete();

      Get.log('Product deleted successfully: $productId');
      return true;
    } catch (e) {
      Get.log('Failed to delete product: $e');
      Get.snackbar(
        '상품 삭제 실패',
        '상품을 삭제하는데 실패했습니다: ${_firebaseService.getFirebaseErrorMessage(e)}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Toggle product active status
  Future<bool> toggleProductStatus(String productId, bool isActive) async {
    try {
      await _firebaseService.productsCollection.doc(productId).update({
        'isActive': isActive,
        'updatedAt': Timestamp.now(),
      });

      Get.log('Product status updated: $productId -> $isActive');
      return true;
    } catch (e) {
      Get.log('Failed to update product status: $e');
      Get.snackbar(
        '상품 상태 변경 실패',
        '상품 상태를 변경하는데 실패했습니다: ${_firebaseService.getFirebaseErrorMessage(e)}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Update product order
  Future<bool> updateProductOrder(String productId, int orderIndex) async {
    try {
      await _firebaseService.productsCollection.doc(productId).update({
        'orderIndex': orderIndex,
        'updatedAt': Timestamp.now(),
      });

      Get.log('Product order updated: $productId -> $orderIndex');
      return true;
    } catch (e) {
      Get.log('Failed to update product order: $e');
      return false;
    }
  }

  // Get product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc =
          await _firebaseService.productsCollection.doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      Get.log('Failed to get product: $e');
      return null;
    }
  }

  // Create sample products for testing
  Future<void> createSampleProducts(String sellerId) async {
    final sampleProducts = [
      ProductModel(
        id: '',
        sellerId: sellerId,
        name: '양파',
        unit: 'kg',
        price: 2000,
        orderIndex: 1,
        createdAt: DateTime.now(),
      ),
      ProductModel(
        id: '',
        sellerId: sellerId,
        name: '당근',
        unit: 'kg',
        price: 3000,
        orderIndex: 2,
        createdAt: DateTime.now(),
      ),
      ProductModel(
        id: '',
        sellerId: sellerId,
        name: '감자',
        unit: 'kg',
        price: 2500,
        orderIndex: 3,
        createdAt: DateTime.now(),
      ),
      ProductModel(
        id: '',
        sellerId: sellerId,
        name: '배추',
        unit: '포기',
        price: 4000,
        orderIndex: 4,
        createdAt: DateTime.now(),
      ),
      ProductModel(
        id: '',
        sellerId: sellerId,
        name: '무',
        unit: '개',
        price: 3500,
        orderIndex: 5,
        createdAt: DateTime.now(),
      ),
    ];

    for (final product in sampleProducts) {
      await addProduct(product);
    }
  }
}
