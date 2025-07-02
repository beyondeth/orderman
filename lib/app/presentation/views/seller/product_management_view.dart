import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/product_model.dart';
import '../../controllers/seller/product_management_controller.dart';

class ProductManagementView extends GetView<ProductManagementController> {
  const ProductManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 제목과 새로고침 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '상품 관리',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showProductDialog(),
                icon: const Icon(Icons.add),
                label: const Text('상품 추가'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 상품 통계
          _buildProductStats(),
          
          // 상품 목록
          Expanded(
            child: _buildProductList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductStats() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Get.theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              '전체 상품',
              controller.products.length.toString(),
              Icons.inventory_2,
              Get.theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: _buildStatCard(
              '활성 상품',
              controller.products.where((p) => p.isActive).length.toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: _buildStatCard(
              '비활성 상품',
              controller.products.where((p) => !p.isActive).length.toString(),
              Icons.pause_circle,
              Colors.orange,
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            value,
            style: Get.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Get.textTheme.bodySmall?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (controller.products.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Get.theme.colorScheme.outline,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Text(
                '등록된 상품이 없습니다',
                style: Get.textTheme.titleMedium?.copyWith(
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                '+ 버튼을 눌러 첫 상품을 등록해보세요.',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: controller.products.length,
        separatorBuilder: (context, index) => const SizedBox(
          height: AppConstants.smallPadding,
        ),
        itemBuilder: (context, index) {
          final product = controller.products[index];
          return _buildProductItem(product);
        },
      );
    });
  }

  Widget _buildProductItem(ProductModel product) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: product.isActive 
              ? Get.theme.colorScheme.primary
              : Get.theme.colorScheme.outline,
          child: Icon(
            product.isActive ? Icons.check : Icons.pause,
            color: Colors.white,
          ),
        ),
        title: Text(
          product.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: product.isActive 
                ? null 
                : Get.theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    product.unit,
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: Get.theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  product.price != null 
                      ? '${product.price.toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                        )}원'
                      : '가격 미정',
                  style: Get.textTheme.titleSmall?.copyWith(
                    color: product.price != null 
                        ? Get.theme.colorScheme.primary
                        : Get.theme.colorScheme.outline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleProductAction(value, product),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('수정'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: ListTile(
                leading: Icon(
                  product.isActive ? Icons.pause : Icons.play_arrow,
                ),
                title: Text(product.isActive ? '비활성화' : '활성화'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('삭제', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleProductAction(String action, ProductModel product) {
    switch (action) {
      case 'edit':
        _showProductDialog(product: product);
        break;
      case 'toggle':
        controller.toggleProductStatus(product.id, !product.isActive);
        break;
      case 'delete':
        _showDeleteConfirmDialog(product);
        break;
    }
  }

  void _showProductDialog({ProductModel? product}) {
    final isEdit = product != null;
    final nameController = TextEditingController(text: product?.name ?? '');
    final unitController = TextEditingController(text: product?.unit ?? '');
    final priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: Text(isEdit ? '상품 수정' : '상품 추가'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '상품명',
                  hintText: '예: 양파',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '상품명을 입력해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              TextFormField(
                controller: unitController,
                decoration: const InputDecoration(
                  labelText: '단위',
                  hintText: '예: kg, 개, 박스',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '단위를 입력해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '가격 (원) - 선택사항',
                  hintText: '예: 2000',
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final price = int.tryParse(value);
                    if (price == null || price <= 0) {
                      return '올바른 가격을 입력해주세요.';
                    }
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('취소'),
          ),
          Obx(() => ElevatedButton(
            onPressed: (controller.isAddingProduct.value || controller.isUpdatingProduct.value)
                ? null 
                : () async {
                    if (formKey.currentState!.validate()) {
                      final priceText = priceController.text.trim();
                      final price = priceText.isNotEmpty ? int.tryParse(priceText) : null;
                      
                      final newProduct = ProductModel(
                        id: product?.id ?? '',
                        sellerId: product?.sellerId ?? '',
                        name: nameController.text.trim(),
                        unit: unitController.text.trim(),
                        price: price,
                        isActive: product?.isActive ?? true,
                        orderIndex: product?.orderIndex ?? 0,
                        createdAt: product?.createdAt ?? DateTime.now(),
                        updatedAt: isEdit ? DateTime.now() : null,
                      );

                      if (isEdit) {
                        await controller.updateProduct(newProduct);
                        // Close dialog after update
                        Get.back();
                      } else {
                        await controller.addProduct(newProduct);
                        // Close dialog after successful addition
                        Get.back();
                      }
                    }
                  },
            child: (controller.isAddingProduct.value && !isEdit) || (controller.isUpdatingProduct.value && isEdit)
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(isEdit ? '수정중...' : '저장중...'),
                    ],
                  )
                : Text(isEdit ? '수정' : '추가'),
          )),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(ProductModel product) {
    Get.dialog(
      AlertDialog(
        title: const Text('상품 삭제'),
        content: Text('${product.name} 상품을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteProduct(product.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
