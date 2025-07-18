import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/connection_model.dart';
import '../../controllers/buyer/order_controller.dart';
import '../common/quantity_input_field.dart';

class OrderView extends GetView<OrderController> {
  const OrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          controller.connection.value?.sellerName ?? '주문하기',
        )),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Debug button (temporary)
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              controller.debugConnectionAndProducts();
              controller.refreshProducts();
            },
            tooltip: '디버그 & 새로고침',
          ),
          Obx(() => controller.selectedItems.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_all),
                  onPressed: controller.clearAllSelections,
                  tooltip: '전체 선택 해제',
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Column(
        children: [
          // 주문 정보 헤더
          _buildOrderHeader(),
          
          // 상품 목록
          Expanded(
            child: _buildProductList(),
          ),
          
          // 주문 요약 및 저장 버튼
          _buildOrderSummary(),
        ],
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Get.theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Text(
            controller.connection.value?.sellerBusinessName ?? 
            controller.connection.value?.sellerName ?? 
            '판매자',
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          )),
          const SizedBox(height: AppConstants.smallPadding),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Get.theme.colorScheme.primary,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: Text(
                  '필요한 상품을 선택하고 수량을 입력한 후 저장 버튼을 눌러주세요.',
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],
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

      // Check if there's no connection first
      if (controller.connection.value == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.link_off,
                size: 64,
                color: Get.theme.colorScheme.outline,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Text(
                '판매자 연결이 필요합니다',
                style: Get.textTheme.titleMedium?.copyWith(
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                '홈 화면에서 판매자를 선택해주세요.',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        );
      }

      // Check if products are empty
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
                '${controller.connection.value?.sellerName ?? "판매자"}가 상품을 등록할 때까지 기다려주세요.',
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
    return Obx(() {
      final isSelected = controller.selectedItems.containsKey(product.id);
      final quantity = controller.selectedItems[product.id] ?? 0;

      return Card(
        elevation: isSelected ? 4 : 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(
                    color: Get.theme.colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Row(
              children: [
                // 체크박스
                Checkbox(
                  value: isSelected,
                  onChanged: (bool? value) {
                    if (value == true) {
                      controller.selectProduct(product.id, 1);
                    } else {
                      controller.removeProduct(product.id);
                    }
                  },
                ),
                
                const SizedBox(width: AppConstants.defaultPadding),
                
                // 상품 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Get.theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              product.unit,
                              style: Get.textTheme.bodySmall?.copyWith(
                                color: Get.theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppConstants.smallPadding),
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
                ),
                
                const SizedBox(width: AppConstants.defaultPadding),
                
                // 수량 입력
                SizedBox(
                  width: 80,
                  child: QuantityInputField(
                    productId: product.id,
                    initialValue: quantity,
                    enabled: product.price != null,
                    onChanged: (productId, newQuantity) {
                      if (product.price != null) {
                        if (newQuantity > 0) {
                          controller.selectProduct(productId, newQuantity);
                        } else {
                          controller.removeProduct(productId);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildOrderSummary() {
    return Obx(() {
      final hasSelectedItems = controller.selectedItems.isNotEmpty;
      final totalAmount = controller.totalAmount.value;
      final itemCount = controller.selectedItems.length;

      return Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Get.theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasSelectedItems) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '선택된 상품: ${itemCount}개',
                      style: Get.textTheme.titleMedium,
                    ),
                    Text(
                      '총 ${totalAmount.toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      )}원',
                      style: Get.textTheme.titleLarge?.copyWith(
                        color: Get.theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.defaultPadding),
              ],
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: hasSelectedItems && !controller.isCreatingOrder.value
                      ? controller.createOrder
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.defaultPadding,
                    ),
                  ),
                  child: controller.isCreatingOrder.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          hasSelectedItems 
                              ? '주문 저장하기 (${itemCount}개 상품)'
                              : '상품을 선택해주세요',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
