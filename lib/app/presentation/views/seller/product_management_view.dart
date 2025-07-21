import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/toss_design_system.dart';
import '../../../data/models/product_model.dart';
import '../../controllers/seller/product_management_controller.dart';

class ProductManagementView extends GetView<ProductManagementController> {
  const ProductManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossDesignSystem.background,
      appBar: AppBar(
        title: Text('상품 관리', style: TossDesignSystem.heading4),
        backgroundColor: TossDesignSystem.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          TossWidgets.iconButton(
            icon: Icons.refresh_rounded,
            onPressed: controller.refreshProducts,
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(width: TossDesignSystem.spacing12),
        ],
      ),
      body: Column(
        children: [
          // 상품 추가 버튼
          Padding(
            padding: const EdgeInsets.all(TossDesignSystem.spacing20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showProductDialog(),
                style: TossDesignSystem.primaryButton,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_rounded, size: 20),
                    const SizedBox(width: TossDesignSystem.spacing8),
                    Text(
                      '새 상품 추가',
                      style: TossDesignSystem.button.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 상품 목록
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: TossDesignSystem.primary,
                  ),
                );
              }

              if (controller.products.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: TossDesignSystem.spacing20,
                ),
                itemCount: controller.products.length,
                separatorBuilder:
                    (context, index) =>
                        const SizedBox(height: TossDesignSystem.spacing12),
                itemBuilder: (context, index) {
                  final product = controller.products[index];
                  return _buildProductCard(product);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 빈 상태
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TossDesignSystem.spacing40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: TossDesignSystem.gray100,
                borderRadius: BorderRadius.circular(TossDesignSystem.radius20),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 40,
                color: TossDesignSystem.gray400,
              ),
            ),
            const SizedBox(height: TossDesignSystem.spacing24),
            Text(
              '등록된 상품이 없어요',
              style: TossDesignSystem.heading4.copyWith(
                color: TossDesignSystem.textSecondary,
              ),
            ),
            const SizedBox(height: TossDesignSystem.spacing8),
            Text(
              '첫 번째 상품을 등록해보세요',
              style: TossDesignSystem.body2.copyWith(
                color: TossDesignSystem.textTertiary,
              ),
            ),
            const SizedBox(height: TossDesignSystem.spacing32),
            ElevatedButton(
              onPressed: () => _showProductDialog(),
              style: TossDesignSystem.primaryButton,
              child: Text(
                '상품 등록하기',
                style: TossDesignSystem.button.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 상품 카드
  Widget _buildProductCard(ProductModel product) {
    return TossWidgets.card(
      padding: const EdgeInsets.all(TossDesignSystem.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상품 정보 헤더
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TossDesignSystem.body1.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: TossDesignSystem.spacing4),
                    if (product.unit.isNotEmpty) ...[
                      Text(
                        '단위: ${product.unit}',
                        style: TossDesignSystem.caption.copyWith(
                          color: TossDesignSystem.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TossWidgets.statusBadge(
                    text: product.isActive ? '판매중' : '판매중지',
                    color:
                        product.isActive
                            ? TossDesignSystem.success
                            : TossDesignSystem.gray500,
                  ),
                  const SizedBox(height: TossDesignSystem.spacing4),
                  Text(
                    '${_formatPrice(product.price)}원',
                    style: TossDesignSystem.body1.copyWith(
                      fontWeight: FontWeight.w500,
                      color: TossDesignSystem.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: TossDesignSystem.spacing16),

          // 액션 버튼들
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showProductDialog(product: product),
                  style: TossDesignSystem.outlineButton.copyWith(
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(
                        vertical: TossDesignSystem.spacing12,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: TossDesignSystem.textSecondary,
                      ),
                      const SizedBox(width: TossDesignSystem.spacing4),
                      Text(
                        '수정',
                        style: TossDesignSystem.caption.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: TossDesignSystem.spacing8),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      () => controller.toggleProductStatus(
                        product.id,
                        !product.isActive,
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        product.isActive
                            ? TossDesignSystem.gray100
                            : TossDesignSystem.gray100,
                    foregroundColor:
                        product.isActive
                            ? TossDesignSystem.textPrimary
                            : Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        TossDesignSystem.radius12,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: TossDesignSystem.spacing12,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        product.isActive
                            ? Icons.pause_circle_outline
                            : Icons.play_circle_outline,
                        size: 16,
                        color: TossDesignSystem.textSecondary,
                      ),
                      const SizedBox(width: TossDesignSystem.spacing4),
                      Text(
                        product.isActive ? '중지' : '판매',
                        style: TossDesignSystem.caption.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: TossDesignSystem.spacing8),
              TossWidgets.iconButton(
                icon: Icons.delete_outline_rounded,
                onPressed: () => _showDeleteConfirmDialog(product),
                backgroundColor: TossDesignSystem.error.withOpacity(0.1),
                iconColor: TossDesignSystem.error,
                size: 36,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 상품 추가/수정 다이얼로그
  void _showProductDialog({ProductModel? product}) {
    final isEdit = product != null;
    final nameController = TextEditingController(text: product?.name ?? '');
    final unitController = TextEditingController(text: product?.unit ?? '');
    final priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TossDesignSystem.radius20),
        ),
        backgroundColor: TossDesignSystem.surface,
        child: Padding(
          padding: const EdgeInsets.all(TossDesignSystem.spacing24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 다이얼로그 헤더
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: TossDesignSystem.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          TossDesignSystem.radius8,
                        ),
                      ),
                      child: Icon(
                        isEdit ? Icons.edit_rounded : Icons.add_rounded,
                        color: TossDesignSystem.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: TossDesignSystem.spacing12),
                    Text(
                      isEdit ? '상품 수정' : '상품 추가',
                      style: TossDesignSystem.heading4,
                    ),
                  ],
                ),
                const SizedBox(height: TossDesignSystem.spacing24),

                // 상품명 입력
                TextFormField(
                  controller: nameController,
                  decoration: TossDesignSystem.inputDecoration(
                    labelText: '상품명',
                    hintText: '상품명을 입력하세요',
                  ),
                  style: TossDesignSystem.body1,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '상품명을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: TossDesignSystem.spacing16),

                // 단위 입력 (선택사항)
                TextFormField(
                  controller: unitController,
                  decoration: TossDesignSystem.inputDecoration(
                    labelText: '단위 (선택사항)',
                    hintText: '예: kg, 개, 박스',
                  ),
                  style: TossDesignSystem.body1,
                ),
                const SizedBox(height: TossDesignSystem.spacing16),

                // 가격 입력
                TextFormField(
                  controller: priceController,
                  decoration: TossDesignSystem.inputDecoration(
                    labelText: '가격',
                    hintText: '가격을 입력하세요',
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(
                        right: TossDesignSystem.spacing16,
                      ),
                      child: Center(
                        widthFactor: 0.0,
                        child: Text(
                          '원',
                          style: TossDesignSystem.body2.copyWith(
                            color: TossDesignSystem.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  style: TossDesignSystem.body1,
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
                const SizedBox(height: TossDesignSystem.spacing32),

                // 액션 버튼들
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: TossDesignSystem.outlineButton,
                        child: Text(
                          '취소',
                          style: TossDesignSystem.button.copyWith(
                            color: TossDesignSystem.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: TossDesignSystem.spacing12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final name = nameController.text.trim();
                            final unit = unitController.text.trim();
                            final priceText = priceController.text.trim();
                            final price =
                                priceText.isNotEmpty
                                    ? int.tryParse(priceText) ?? 0
                                    : 0;

                            if (isEdit) {
                              controller.updateProductWithParams(
                                product!.id,
                                name,
                                unit,
                                price,
                              );
                            } else {
                              controller.addProductWithParams(
                                name,
                                unit,
                                price,
                              );
                            }
                            Get.back();
                          }
                        },
                        style: TossDesignSystem.primaryButton,
                        child: Text(
                          isEdit ? '수정' : '추가',
                          style: TossDesignSystem.button.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 삭제 확인 다이얼로그
  void _showDeleteConfirmDialog(ProductModel product) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TossDesignSystem.radius20),
        ),
        backgroundColor: TossDesignSystem.surface,
        child: Padding(
          padding: const EdgeInsets.all(TossDesignSystem.spacing24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: TossDesignSystem.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    TossDesignSystem.radius16,
                  ),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  size: 32,
                  color: TossDesignSystem.error,
                ),
              ),
              const SizedBox(height: TossDesignSystem.spacing20),
              Text(
                '상품을 삭제하시겠어요?',
                style: TossDesignSystem.heading4,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TossDesignSystem.spacing8),
              Text(
                '${product.name}\n삭제된 상품은 복구할 수 없어요',
                style: TossDesignSystem.body2.copyWith(
                  color: TossDesignSystem.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TossDesignSystem.spacing32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: TossDesignSystem.outlineButton,
                      child: Text(
                        '취소',
                        style: TossDesignSystem.button.copyWith(
                          color: TossDesignSystem.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: TossDesignSystem.spacing12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.deleteProduct(product.id);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TossDesignSystem.error,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            TossDesignSystem.radius12,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: TossDesignSystem.spacing20,
                          vertical: TossDesignSystem.spacing16,
                        ),
                      ),
                      child: Text(
                        '삭제',
                        style: TossDesignSystem.button.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
