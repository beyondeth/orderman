import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/connection_model.dart';
import '../../../data/models/product_model.dart';
import '../../controllers/buyer/buyer_home_controller.dart';
import '../../controllers/main_controller.dart';

class OrderTabView extends GetView<BuyerHomeController> {
  const OrderTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshConnections,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 안내 메시지
                  _buildInfoSection(context),

                  const SizedBox(height: AppConstants.largePadding),

                  // 연결된 판매자 목록
                  _buildConnectedSellers(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shopping_cart,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Text(
                '주문하기',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            '연결된 판매자를 선택하여 주문을 시작하세요.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedSellers(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '연결된 판매자',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppConstants.largePadding),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.connections.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.connections.length,
            separatorBuilder:
                (context, index) =>
                    const SizedBox(height: AppConstants.smallPadding),
            itemBuilder: (context, index) {
              final connection = controller.connections[index];
              return _buildSellerCard(context, connection);
            },
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.largePadding * 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.store_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            '연결된 판매자가 없습니다',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            '주문을 하려면 먼저 판매자와 연결해야 합니다.\n아래 버튼을 눌러 판매자를 찾아보세요.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.largePadding),
          ElevatedButton.icon(
            onPressed: () {
              // MainController를 통해 연결 탭으로 이동
              try {
                final mainController = Get.find<MainController>();
                mainController.changeTab(3); // 연결 탭으로 이동
              } catch (e) {
                // Fallback: 직접 연결 화면으로 이동
                controller.goToSellerConnect();
              }
            },
            icon: const Icon(Icons.add_business),
            label: const Text('판매자 연결하기'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.largePadding,
                vertical: AppConstants.defaultPadding,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerCard(BuildContext context, ConnectionModel connection) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          // 판매자 정보 헤더
          InkWell(
            onTap: () => _toggleOrderList(connection.id),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                children: [
                  // 판매자 아바타
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      connection.sellerName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),

                  const SizedBox(width: AppConstants.defaultPadding),

                  // 판매자 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          connection.sellerName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (connection.sellerBusinessName != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            connection.sellerBusinessName!,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '연결됨',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 주문하기 버튼 (아이콘 + 텍스트)
                  ElevatedButton.icon(
                    onPressed: () => _toggleOrderList(connection.id),
                    icon: const Icon(Icons.shopping_cart, size: 20),
                    label: const Text('주문하기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 주문 가능한 상품 목록 (확장 가능)
          Obx(() {
            final isExpanded = controller.expandedSellers.contains(
              connection.id,
            );
            if (!isExpanded) return const SizedBox.shrink();

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
                border: Border(
                  top: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: _buildOrderableProductsList(context, connection),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOrderableProductsList(
    BuildContext context,
    ConnectionModel connection,
  ) {
    return Obx(() {
      final products = controller.getSellerProducts(connection.sellerId);

      print(
        '=== 🔍 _buildOrderableProductsList: sellerId=${connection.sellerId}, products=${products.length} ===',
      );

      if (products.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(height: 8),
              Text(
                '주문 가능한 상품이 없습니다',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Seller ID: ${connection.sellerId}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          // 상품 목록
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            itemCount: products.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductItem(context, product, connection);
            },
          ),

          // 주문하기 버튼
          if (controller.hasSelectedProducts(connection.sellerId))
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _createOrder(connection),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('선택한 상품 주문하기'),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildProductItem(
    BuildContext context,
    ProductModel product,
    ConnectionModel connection,
  ) {
    return Obx(() {
      final isSelected = controller.isProductSelected(product.id);
      final quantity = controller.getProductQuantity(product.id);

      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Checkbox(
          value: isSelected,
          onChanged: (value) => controller.toggleProductSelection(product.id),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              product.price != null && product.price! > 0
                  ? '${product.price!.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원'
                  : '가격 미설정',
              style: TextStyle(
                color:
                    product.price != null && product.price! > 0
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing:
            isSelected
                ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => controller.decreaseQuantity(product.id),
                      icon: const Icon(Icons.remove_circle_outline),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                    Text(
                      quantity.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      onPressed: () => controller.increaseQuantity(product.id),
                      icon: const Icon(Icons.add_circle_outline),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                )
                : null,
      );
    });
  }

  void _toggleOrderList(String sellerId) {
    controller.toggleSellerExpansion(sellerId);
  }

  void _createOrder(ConnectionModel connection) {
    controller.createOrderFromSelection(connection);
  }
}
