import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/order_utils.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/connection_model.dart';
import '../../controllers/buyer/buyer_home_controller.dart';
import '../../controllers/main_controller.dart';

class BuyerHomeViewImproved extends GetView<BuyerHomeController> {
  const BuyerHomeViewImproved({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshConnections,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 인사말 및 사용자 정보
            _buildWelcomeSection(context),

            const SizedBox(height: 24.0),

            // 빠른 액션 버튼들
            _buildQuickActions(context),

            const SizedBox(height: 24.0),

            // 연결된 판매자 목록
            _buildConnectedSellers(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.greetingMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            '${controller.userName}님',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (controller.businessName.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              controller.businessName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],

          const SizedBox(height: 16.0),

          Row(
            children: [
              const Icon(Icons.shopping_cart, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                '오늘도 효율적인 주문 관리를 시작해보세요',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '최근 주문 내역',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16.0),

        _buildRecentOrdersContainer(context),
      ],
    );
  }

  Widget _buildRecentOrdersContainer(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.receipt_long,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    '최근 주문',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  try {
                    final mainController = Get.find<MainController>();
                    mainController.changeTabIndex(2);
                  } catch (e) {
                    print('MainController not found: $e');
                  }
                },
                child: const Text('전체보기'),
              ),
            ],
          ),
          
          const SizedBox(height: 16.0),
          
          // 최근 주문 목록
          Obx(() {
            if (controller.isLoadingOrders.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (controller.recentOrders.isEmpty) {
              return _buildEmptyOrdersState(context);
            }

            return Column(
              children: [
                ...controller.recentOrders.asMap().entries.map((entry) {
                  final index = entry.key;
                  final order = entry.value;
                  return Column(
                    children: [
                      _buildRecentOrderItem(context, order),
                      if (index < controller.recentOrders.length - 1)
                        const Divider(height: 16.0),
                    ],
                  );
                }).toList(),
                
                const SizedBox(height: 8.0),
                
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      try {
                        final mainController = Get.find<MainController>();
                        mainController.changeTabIndex(2);
                      } catch (e) {
                        print('MainController not found: $e');
                      }
                    },
                    icon: const Icon(Icons.history, size: 18),
                    label: const Text('전체보기'),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyOrdersState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 8.0),
          Text(
            '아직 주문 내역이 없습니다',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8.0),
          TextButton(
            onPressed: () {
              try {
                final mainController = Get.find<MainController>();
                mainController.changeTabIndex(1);
              } catch (e) {
                print('MainController not found: $e');
              }
            },
            child: const Text('첫 주문하러 가기'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrderItem(BuildContext context, order) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.sellerName ?? '판매자',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${OrderUtils.formatRelativeDate(order.orderDate)} • ${order.items.length}개 상품',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                OrderUtils.formatAmount(order.totalAmount),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: order.status.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.status.displayText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: order.status.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedSellers(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '연결된 판매자',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                try {
                  final mainController = Get.find<MainController>();
                  mainController.changeTabIndex(3);
                } catch (e) {
                  print('MainController not found: $e');
                }
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('연결 추가'),
            ),
          ],
        ),

        const SizedBox(height: 16.0),

        Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.connections.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.connections.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8.0),
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
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.store_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),

          const SizedBox(height: 16.0),

          Text(
            '연결된 판매자가 없습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8.0),

          Text(
            '판매자와 연결하여 주문을 시작해보세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16.0),

          ElevatedButton.icon(
            onPressed: () {
              try {
                final mainController = Get.find<MainController>();
                mainController.changeTabIndex(3);
              } catch (e) {
                print('MainController not found: $e');
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('판매자 연결하기'),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerCard(BuildContext context, connection) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            connection.sellerName[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          connection.sellerName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: connection.sellerBusinessName != null
            ? Text(connection.sellerBusinessName!)
            : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Get.snackbar('준비중', '주문 생성 기능은 준비 중입니다.');
        },
      ),
    );
  }
}
