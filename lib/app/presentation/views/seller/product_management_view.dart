import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_model.dart';
import '../../controllers/seller/product_management_controller.dart';

class ProductManagementView extends GetView<ProductManagementController> {
  const ProductManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 헤더 섹션
          _buildHeader(context),
          const SizedBox(height: AppTheme.large),
          
          // 상품 통계
          _buildProductStats(),
          const SizedBox(height: AppTheme.large),
          
          // 상품 목록
          Expanded(
            child: _buildProductList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '상품 관리',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '판매할 상품을 관리하세요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () => _showProductDialog(),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('상품 추가'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductStats() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              '전체 상품',
              controller.products.length.toString(),
              Icons.inventory_2_rounded,
              AppColors.primary,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.textHint.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              '활성 상품',
              controller.products.where((p) => p.isActive).length.toString(),
              Icons.check_circle_rounded,
              Colors.green,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.textHint.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              '비활성 상품',
              controller.products.where((p) => !p.isActive).length.toString(),
              Icons.pause_circle_rounded,
              Colors.orange,
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: AppTheme.small),
        Text(
          value,
          style: Get.textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: Get.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProductList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingState();
      }

      if (controller.products.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.separated(
        padding: const EdgeInsets.only(top: 8),
        itemCount: controller.products.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final product = controller.products[index];
          return _buildProductItem(product);
        },
      );
    });
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.large),
          Text(
            '등록된 상품이 없습니다',
            style: Get.textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.small),
          Text(
            '+ 버튼을 눌러 첫 상품을 등록해보세요',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // 상태 아이콘
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: product.isActive 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              product.isActive ? Icons.check_circle_rounded : Icons.pause_circle_rounded,
              color: product.isActive ? Colors.green : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.medium),
          
          // 상품 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: product.isActive 
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.small),
                Row(
                  children: [
                    // 단위 태그
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.unit,
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // 가격
                    Text(
                      product.price != null 
                          ? '${product.price.toString().replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]},',
                            )}원'
                          : '가격 미정',
                      style: Get.textTheme.titleSmall?.copyWith(
                        color: product.price != null 
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 액션 버튼
          PopupMenuButton<String>(
            onSelected: (value) => _handleProductAction(value, product),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.more_vert_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, size: 20, color: AppColors.textSecondary),
                    const SizedBox(width: 12),
                    const Text('수정'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'toggle',
                child: Row(
                  children: [
                    Icon(
                      product.isActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Text(product.isActive ? '비활성화' : '활성화'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_rounded, size: 20, color: Colors.red),
                    const SizedBox(width: 12),
                    const Text('삭제', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.surface,
        title: Text(
          isEdit ? '상품 수정' : '상품 추가',
          style: Get.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '상품명',
                  hintText: '상품명을 입력하세요',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '상품명을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.medium),
              TextFormField(
                controller: unitController,
                decoration: const InputDecoration(
                  labelText: '단위',
                  hintText: '예: kg, 개, 박스',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '단위를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.medium),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: '가격',
                  hintText: '가격을 입력하세요',
                  suffixText: '원',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (int.tryParse(value) == null) {
                      return '올바른 숫자를 입력해주세요';
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
            child: Text(
              '취소',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                if (isEdit) {
                  // 기존 상품 수정
                  final updatedProduct = product!.copyWith(
                    name: nameController.text.trim(),
                    unit: unitController.text.trim(),
                    price: priceController.text.isNotEmpty 
                        ? int.parse(priceController.text) 
                        : null,
                    updatedAt: DateTime.now(),
                  );
                  controller.updateProduct(updatedProduct);
                } else {
                  // 새 상품 추가
                  final newProduct = ProductModel(
                    id: '', // Firestore에서 자동 생성
                    name: nameController.text.trim(),
                    unit: unitController.text.trim(),
                    price: priceController.text.isNotEmpty 
                        ? int.parse(priceController.text) 
                        : null,
                    sellerId: '', // Controller에서 설정
                    isActive: true,
                    orderIndex: 0, // Controller에서 설정
                    createdAt: DateTime.now(),
                  );
                  controller.addProduct(newProduct);
                }
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(isEdit ? '수정' : '추가'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(ProductModel product) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.surface,
        title: Text(
          '상품 삭제',
          style: Get.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          '${product.name}을(를) 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
          style: Get.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              '취소',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteProduct(product.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
