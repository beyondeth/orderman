import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_market_app/app/presentation/controllers/buyer/seller_connect_controller.dart';

import '../../../core/theme/toss_design_system.dart';
import '../../../data/models/connection_model.dart';
import '../../../data/models/product_model.dart';
import '../../controllers/buyer/buyer_home_controller.dart';
import '../../controllers/main_controller.dart';
import '../common/quantity_input_field.dart';

class OrderTabView extends GetView<BuyerHomeController> {
  const OrderTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshConnections,
      color: TossDesignSystem.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(TossDesignSystem.spacing20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 안내 메시지
                  _buildInfoSection(context),

                  const SizedBox(height: TossDesignSystem.spacing24),

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
      padding: const EdgeInsets.all(TossDesignSystem.spacing20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TossDesignSystem.primary.withOpacity(0.1),
            TossDesignSystem.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(TossDesignSystem.radius16),
        border: Border.all(
          color: TossDesignSystem.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shopping_cart,
                color: TossDesignSystem.primary,
                size: 24,
              ),
              const SizedBox(width: TossDesignSystem.spacing8),
              Text(
                '주문하기',
                style: TossDesignSystem.heading4.copyWith(
                  color: TossDesignSystem.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: TossDesignSystem.spacing8),
          Text(
            '연결된 판매자를 선택하여 주문을 시작하세요.',
            style: TossDesignSystem.body2.copyWith(
              color: TossDesignSystem.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 연결된 판매자 섹션 (홈 화면과 완전히 동일한 UI/UX)
  Widget _buildConnectedSellers(BuildContext context) {
    // SellerConnectController 사용하여 홈 화면과 동일한 로직 적용
    final connectController = Get.find<SellerConnectController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더 (홈 화면과 동일한 스타일)
        Row(
          children: [
            const Icon(Icons.people, color: TossDesignSystem.primary),
            const SizedBox(width: TossDesignSystem.spacing8),
            Text(
              '연결된 판매자',
              style: TossDesignSystem.heading4,
            ),
            const Spacer(),
            // 더보기 버튼 (연결 탭으로 이동)
            TextButton(
              onPressed: () {
                final mainController = Get.find<MainController>();
                mainController.changeTab(3); // 연결 탭으로 이동
              },
              child: Text('더보기', style: TossDesignSystem.body2.copyWith(color: TossDesignSystem.textTertiary)),
            ),
          ],
        ),
        const SizedBox(height: TossDesignSystem.spacing16),

        // 연결된 판매자 목록 (홈 화면과 동일한 로직)
        Obx(() {
          if (connectController.isLoadingConnections.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(TossDesignSystem.spacing24),
                child: CircularProgressIndicator(color: TossDesignSystem.primary),
              ),
            );
          }

          if (connectController.connectedSellers.isEmpty) {
            return _buildEmptyConnectedSellersState(context);
          }

          // 주문 탭에서는 모든 연결된 판매자 표시 (홈과 다른 점)
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: connectController.connectedSellers.length,
            separatorBuilder: (context, index) => const SizedBox(height: TossDesignSystem.spacing12),
            itemBuilder: (context, index) {
              final connection = connectController.connectedSellers[index];
              return _buildSellerCard(context, connection);
            },
          );
        }),
      ],
    );
  }

  /// 빈 연결 상태 (홈 화면과 동일한 스타일)
  Widget _buildEmptyConnectedSellersState(BuildContext context) {
    return TossWidgets.card(
      padding: const EdgeInsets.all(TossDesignSystem.spacing24),
      child: Column(
        children: [
          Icon(Icons.store_outlined, size: 64, color: TossDesignSystem.gray400),
          const SizedBox(height: TossDesignSystem.spacing16),
          Text(
            '연결된 판매자가 없습니다',
            style: TossDesignSystem.heading4.copyWith(color: TossDesignSystem.textSecondary),
          ),
          const SizedBox(height: TossDesignSystem.spacing8),
          Text(
            '연결 탭에서 판매자와 연결해보세요',
            textAlign: TextAlign.center,
            style: TossDesignSystem.body2.copyWith(color: TossDesignSystem.textTertiary),
          ),
          const SizedBox(height: TossDesignSystem.spacing16),
          ElevatedButton(
            onPressed: () {
              final mainController = Get.find<MainController>();
              mainController.changeTab(3); // 연결 탭으로 이동
            },
            style: TossDesignSystem.primaryButton,
            child: const Text('판매자 연결하기'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return TossWidgets.card(
      padding: const EdgeInsets.all(TossDesignSystem.spacing32),
      child: Column(
        children: [
          Icon(
            Icons.store_outlined,
            size: 80,
            color: TossDesignSystem.gray400,
          ),
          const SizedBox(height: TossDesignSystem.spacing20),
          Text(
            '연결된 판매자가 없습니다',
            style: TossDesignSystem.heading3,
          ),
          const SizedBox(height: TossDesignSystem.spacing8),
          Text(
            '주문을 하려면 먼저 판매자와 연결해야 합니다.\n아래 버튼을 눌러 판매자를 찾아보세요.',
            style: TossDesignSystem.body2.copyWith(color: TossDesignSystem.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TossDesignSystem.spacing24),
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
            style: TossDesignSystem.primaryButton,
          ),
        ],
      ),
    );
  }

  Widget _buildSellerCard(BuildContext context, ConnectionModel connection) {
    return TossWidgets.card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // 판매자 정보 헤더
          InkWell(
            onTap: () => _toggleOrderList(connection.id),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(TossDesignSystem.radius16)),
            child: Padding(
              padding: const EdgeInsets.all(TossDesignSystem.spacing16),
              child: Row(
                children: [
                  // 판매자 아바타
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: TossDesignSystem.primary,
                    child: Text(
                      connection.sellerName[0].toUpperCase(),
                      style: TossDesignSystem.heading4.copyWith(color: Colors.white),
                    ),
                  ),

                  const SizedBox(width: TossDesignSystem.spacing16),

                  // 판매자 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          connection.sellerName,
                          style: TossDesignSystem.heading4,
                        ),
                        if (connection.sellerBusinessName != null) ...[
                          const SizedBox(height: TossDesignSystem.spacing4),
                          Text(
                            connection.sellerBusinessName!,
                            style: TossDesignSystem.body2.copyWith(color: TossDesignSystem.textSecondary),
                          ),
                        ],
                        const SizedBox(height: TossDesignSystem.spacing8),
                        TossWidgets.badge(text: '연결됨', backgroundColor: TossDesignSystem.success.withOpacity(0.1), textColor: TossDesignSystem.success),
                      ],
                    ),
                  ),

                  // 주문하기 버튼 (아이콘 + 텍스트)
                  ElevatedButton(
                    onPressed: () => _toggleOrderList(connection.id),
                    style: TossDesignSystem.primaryButton.copyWith(
                      padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: TossDesignSystem.spacing12, vertical: TossDesignSystem.spacing8)),
                    ),
                    child: const Text('주문하기', style: TextStyle(fontSize: 12)),
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
              decoration: const BoxDecoration(
                color: TossDesignSystem.surface,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(TossDesignSystem.radius16),
                ),
                border: Border(top: BorderSide(color: TossDesignSystem.gray200)),
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
          padding: const EdgeInsets.all(TossDesignSystem.spacing20),
          child: Column(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: TossDesignSystem.gray400,
              ),
              const SizedBox(height: TossDesignSystem.spacing8),
              Text(
                '주문 가능한 상품이 없습니다',
                style: TossDesignSystem.body2.copyWith(color: TossDesignSystem.textSecondary),
              ),
              const SizedBox(height: TossDesignSystem.spacing8),
              Text(
                'Seller ID: ${connection.sellerId}',
                style: TossDesignSystem.caption.copyWith(color: TossDesignSystem.textTertiary),
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
            padding: const EdgeInsets.all(TossDesignSystem.spacing16),
            itemCount: products.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: TossDesignSystem.gray200),
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductItem(context, product, connection);
            },
          ),

          // 주문하기 버튼
          if (controller.hasSelectedProducts(connection.sellerId))
            Padding(
              padding: const EdgeInsets.all(TossDesignSystem.spacing16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _createOrder(connection),
                  style: TossDesignSystem.primaryButton,
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
          activeColor: TossDesignSystem.primary,
        ),
        title: Text(
          product.name,
          style: TossDesignSystem.body1.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: TossDesignSystem.spacing4),
            Text(
              product.price != null && product.price! > 0
                  ? '${product.price!.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원'
                  : '가격 미설정',
              style: TossDesignSystem.body1.copyWith(
                color:
                    product.price != null && product.price! > 0
                        ? TossDesignSystem.primary
                        : TossDesignSystem.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing:
            isSelected
                ? QuantityControlButtons(
                  productId: product.id,
                  quantity: quantity,
                  onChanged: (productId, newQuantity) {
                    if (newQuantity > 0) {
                      // 직접 selectProduct 메서드 호출
                      controller.selectProduct(productId, newQuantity);
                    } else {
                      controller.toggleProductSelection(productId);
                    }
                  },
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