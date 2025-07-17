import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/toss_design_system.dart';
import '../../../data/models/order_model.dart';
import '../../controllers/seller/seller_orders_controller.dart';

class OrderDetailView extends StatelessWidget {
  const OrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get order from arguments
    final arguments = Get.arguments as Map<String, dynamic>?;
    final OrderModel? order = arguments?['order'] as OrderModel?;

    if (order == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('주문 상세'),
          backgroundColor: TossDesignSystem.background,
        ),
        body: const Center(
          child: Text('주문 정보를 찾을 수 없습니다.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: TossDesignSystem.background,
      appBar: AppBar(
        title: const Text('주문 상세'),
        backgroundColor: TossDesignSystem.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TossDesignSystem.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 주문 기본 정보
            _buildOrderHeader(order),
            
            const SizedBox(height: TossDesignSystem.spacing20),
            
            // 구매자 정보
            _buildBuyerInfo(order),
            
            const SizedBox(height: TossDesignSystem.spacing20),
            
            // 주문 상품 목록
            _buildOrderItems(order),
            
            const SizedBox(height: TossDesignSystem.spacing20),
            
            // 주문 총액
            _buildOrderTotal(order),
            
            if (order.notes != null && order.notes!.isNotEmpty) ...[
              const SizedBox(height: TossDesignSystem.spacing20),
              _buildOrderNotes(order),
            ],
            
            const SizedBox(height: TossDesignSystem.spacing32),
            
            // 액션 버튼들
            _buildActionButtons(order),
          ],
        ),
      ),
    );
  }

  /// 주문 헤더 (상태, 주문일시)
  Widget _buildOrderHeader(OrderModel order) {
    return TossWidgets.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '주문 #${order.id.substring(0, 8)}',
                      style: TossDesignSystem.heading4,
                    ),
                    const SizedBox(height: TossDesignSystem.spacing4),
                    Text(
                      DateFormat('yyyy년 MM월 dd일 HH:mm').format(order.orderDate),
                      style: TossDesignSystem.body2.copyWith(
                        color: TossDesignSystem.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TossWidgets.statusBadge(
                text: _getStatusText(order.status),
                color: _getStatusColor(order.status),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 구매자 정보
  Widget _buildBuyerInfo(OrderModel order) {
    return TossWidgets.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: TossDesignSystem.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(TossDesignSystem.radius8),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: TossDesignSystem.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: TossDesignSystem.spacing12),
              Text(
                '구매자 정보',
                style: TossDesignSystem.heading4,
              ),
            ],
          ),
          const SizedBox(height: TossDesignSystem.spacing16),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '이름',
                      style: TossDesignSystem.caption.copyWith(
                        color: TossDesignSystem.textSecondary,
                      ),
                    ),
                    const SizedBox(height: TossDesignSystem.spacing4),
                    Text(
                      order.buyerName,
                      style: TossDesignSystem.body1.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (order.buyerBusinessName != null && order.buyerBusinessName!.isNotEmpty)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '상호명',
                        style: TossDesignSystem.caption.copyWith(
                          color: TossDesignSystem.textSecondary,
                        ),
                      ),
                      const SizedBox(height: TossDesignSystem.spacing4),
                      Text(
                        order.buyerBusinessName!,
                        style: TossDesignSystem.body1.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// 주문 상품 목록
  Widget _buildOrderItems(OrderModel order) {
    return TossWidgets.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: TossDesignSystem.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(TossDesignSystem.radius8),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: TossDesignSystem.secondary,
                  size: 18,
                ),
              ),
              const SizedBox(width: TossDesignSystem.spacing12),
              Text(
                '주문 상품',
                style: TossDesignSystem.heading4,
              ),
            ],
          ),
          const SizedBox(height: TossDesignSystem.spacing16),
          
          ...order.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            
            return Column(
              children: [
                if (index > 0) 
                  const Divider(color: TossDesignSystem.gray200),
                if (index > 0) 
                  const SizedBox(height: TossDesignSystem.spacing12),
                
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: TossDesignSystem.body1.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (item.unit.isNotEmpty) ...[
                            const SizedBox(height: TossDesignSystem.spacing4),
                            Text(
                              '단위: ${item.unit}',
                              style: TossDesignSystem.caption.copyWith(
                                color: TossDesignSystem.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${item.quantity}개',
                        style: TossDesignSystem.body1.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${_formatAmount(item.totalPrice ?? 0)}원',
                        style: TossDesignSystem.body1.copyWith(
                          color: TossDesignSystem.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                
                if (index < order.items.length - 1)
                  const SizedBox(height: TossDesignSystem.spacing12),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// 주문 총액
  Widget _buildOrderTotal(OrderModel order) {
    return TossWidgets.card(
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: TossDesignSystem.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(TossDesignSystem.radius8),
            ),
            child: const Icon(
              Icons.receipt_outlined,
              color: TossDesignSystem.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: TossDesignSystem.spacing12),
          Expanded(
            child: Text(
              '총 주문 금액',
              style: TossDesignSystem.heading4,
            ),
          ),
          Text(
            '${_formatAmount(order.totalAmount)}원',
            style: TossDesignSystem.heading3.copyWith(
              color: TossDesignSystem.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// 주문 메모
  Widget _buildOrderNotes(OrderModel order) {
    return TossWidgets.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: TossDesignSystem.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(TossDesignSystem.radius8),
                ),
                child: const Icon(
                  Icons.note_outlined,
                  color: TossDesignSystem.info,
                  size: 18,
                ),
              ),
              const SizedBox(width: TossDesignSystem.spacing12),
              Text(
                '주문 메모',
                style: TossDesignSystem.heading4,
              ),
            ],
          ),
          const SizedBox(height: TossDesignSystem.spacing12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(TossDesignSystem.spacing16),
            decoration: BoxDecoration(
              color: TossDesignSystem.gray50,
              borderRadius: BorderRadius.circular(TossDesignSystem.radius12),
            ),
            child: Text(
              order.notes!,
              style: TossDesignSystem.body1,
            ),
          ),
        ],
      ),
    );
  }

  /// 액션 버튼들
  Widget _buildActionButtons(OrderModel order) {
    // SellerOrdersController가 등록되어 있는지 확인
    if (!Get.isRegistered<SellerOrdersController>()) {
      Get.put(SellerOrdersController());
    }
    
    final controller = Get.find<SellerOrdersController>();
    
    switch (order.status) {
      case OrderStatus.pending:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showRejectDialog(order, controller),
                style: TossDesignSystem.outlineButton.copyWith(
                  foregroundColor: MaterialStateProperty.all(TossDesignSystem.error),
                  side: MaterialStateProperty.all(
                    const BorderSide(color: TossDesignSystem.error, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.close_rounded, size: 16),
                    const SizedBox(width: TossDesignSystem.spacing8),
                    Text(
                      '거절',
                      style: TossDesignSystem.button.copyWith(
                        color: TossDesignSystem.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: TossDesignSystem.spacing16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _approveOrder(order, controller),
                style: TossDesignSystem.primaryButton,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_rounded, size: 16),
                    const SizedBox(width: TossDesignSystem.spacing8),
                    Text(
                      '승인',
                      style: TossDesignSystem.button.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
        
      case OrderStatus.confirmed:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _completeOrder(order, controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: TossDesignSystem.success,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(TossDesignSystem.radius12),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: TossDesignSystem.spacing16,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_shipping_rounded, size: 16),
                const SizedBox(width: TossDesignSystem.spacing8),
                Text(
                  '배송완료',
                  style: TossDesignSystem.button.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
        
      case OrderStatus.completed:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: TossDesignSystem.spacing16,
          ),
          decoration: BoxDecoration(
            color: TossDesignSystem.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(TossDesignSystem.radius12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_shipping_rounded,
                color: TossDesignSystem.success,
                size: 20,
              ),
              const SizedBox(width: TossDesignSystem.spacing8),
              Text(
                '배송완료된 주문입니다',
                style: TossDesignSystem.body1.copyWith(
                  color: TossDesignSystem.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
        
      case OrderStatus.cancelled:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: TossDesignSystem.spacing16,
          ),
          decoration: BoxDecoration(
            color: TossDesignSystem.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(TossDesignSystem.radius12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cancel_rounded,
                color: TossDesignSystem.error,
                size: 20,
              ),
              const SizedBox(width: TossDesignSystem.spacing8),
              Text(
                '거절된 주문입니다',
                style: TossDesignSystem.body1.copyWith(
                  color: TossDesignSystem.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
    }
  }

  /// 주문 승인
  void _approveOrder(OrderModel order, SellerOrdersController controller) {
    controller.updateOrderStatus(order.id, OrderStatus.confirmed);
    Get.back(); // 상세 화면 닫기
  }

  /// 주문 완료
  void _completeOrder(OrderModel order, SellerOrdersController controller) {
    controller.updateOrderStatus(order.id, OrderStatus.completed);
    Get.back(); // 상세 화면 닫기
  }

  /// 거절 확인 다이얼로그
  void _showRejectDialog(OrderModel order, SellerOrdersController controller) {
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
                  borderRadius: BorderRadius.circular(TossDesignSystem.radius16),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 32,
                  color: TossDesignSystem.error,
                ),
              ),
              const SizedBox(height: TossDesignSystem.spacing20),
              Text(
                '주문을 거절하시겠어요?',
                style: TossDesignSystem.heading4,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TossDesignSystem.spacing8),
              Text(
                '${order.buyerBusinessName ?? order.buyerName}의 주문\n거절된 주문은 되돌릴 수 없어요',
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
                        controller.updateOrderStatus(order.id, OrderStatus.cancelled);
                        Get.back(); // 다이얼로그 닫기
                        Get.back(); // 상세 화면 닫기
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TossDesignSystem.error,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(TossDesignSystem.radius12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: TossDesignSystem.spacing20,
                          vertical: TossDesignSystem.spacing16,
                        ),
                      ),
                      child: Text(
                        '거절',
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

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return '신규';
      case OrderStatus.confirmed:
        return '주문확인';
      case OrderStatus.completed:
        return '배송완료';
      case OrderStatus.cancelled:
        return '거절';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return TossDesignSystem.warning;
      case OrderStatus.confirmed:
        return TossDesignSystem.info;
      case OrderStatus.completed:
        return TossDesignSystem.success;
      case OrderStatus.cancelled:
        return TossDesignSystem.error;
    }
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
