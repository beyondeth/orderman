import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/order_model.dart';

class OrderUtils {
  /// 금액을 포맷팅합니다 (예: 1000 -> "1,000원")
  static String formatAmount(int amount) {
    return '${amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}원';
  }

  /// 통화 포맷팅 (num 타입 - int와 double 모두 지원)
  static String formatCurrency(num amount) {
    return formatAmount(amount.toInt());
  }

  /// 통화 포맷팅 (int 전용)
  static String formatCurrencyFromInt(int amount) {
    return formatAmount(amount);
  }

  /// 통화 포맷팅 (double 전용)
  static String formatCurrencyFromDouble(double amount) {
    return formatAmount(amount.toInt());
  }

  /// 날짜를 상대적 시간으로 포맷팅합니다 (예: "2일 전", "오늘")
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return '오늘';
    } else if (difference == 1) {
      return '어제';
    } else if (difference < 7) {
      return '$difference일 전';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '${weeks}주 전';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  /// 날짜를 포맷팅합니다 (예: "2024-01-15")
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// 날짜와 시간을 포맷팅합니다 (예: "2024-01-15 14:30")
  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  /// OrderStatus enum을 위한 타입 안전한 메서드들
  
  /// 주문 상태에 따른 텍스트 반환 (OrderStatus enum 지원)
  static String getStatusText(dynamic status) {
    if (status is OrderStatus) {
      return _getStatusTextFromEnum(status);
    } else if (status is String) {
      return _getStatusTextFromString(status);
    } else {
      return '알 수 없음';
    }
  }

  /// OrderStatus enum에서 텍스트 반환
  static String _getStatusTextFromEnum(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return '대기중';
      case OrderStatus.confirmed:
        return '확인됨';
      case OrderStatus.completed:
        return '완료';
      case OrderStatus.cancelled:
        return '취소됨';
    }
  }

  /// String에서 텍스트 반환 (하위 호환성)
  static String _getStatusTextFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return '대기중';
      case 'confirmed':
        return '확인됨';
      case 'preparing':
        return '준비중';
      case 'ready':
        return '준비완료';
      case 'delivered':
        return '배송완료';
      case 'completed':
        return '완료';
      case 'cancelled':
        return '취소됨';
      default:
        return '알 수 없음';
    }
  }

  /// 주문 상태에 따른 색상 반환 (타입 안전)
  static Color getStatusColor(dynamic status) {
    if (status is OrderStatus) {
      return _getStatusColorFromEnum(status);
    } else if (status is String) {
      return _getStatusColorFromString(status);
    } else {
      return Colors.grey;
    }
  }

  /// OrderStatus enum에서 색상 반환
  static Color _getStatusColorFromEnum(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.completed:
        return Colors.green.shade700;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  /// String에서 색상 반환 (하위 호환성)
  static Color _getStatusColorFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.green;
      case 'delivered':
        return Colors.teal;
      case 'completed':
        return Colors.green.shade700;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// 주문 상태에 따른 아이콘 반환 (타입 안전)
  static IconData getStatusIcon(dynamic status) {
    if (status is OrderStatus) {
      return _getStatusIconFromEnum(status);
    } else if (status is String) {
      return _getStatusIconFromString(status);
    } else {
      return Icons.help_outline;
    }
  }

  /// OrderStatus enum에서 아이콘 반환
  static IconData _getStatusIconFromEnum(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.completed:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  /// String에서 아이콘 반환 (하위 호환성)
  static IconData _getStatusIconFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'preparing':
        return Icons.kitchen;
      case 'ready':
        return Icons.done_all;
      case 'delivered':
        return Icons.local_shipping;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  /// 주문 상태 우선순위 반환 (정렬용)
  static int getStatusPriority(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 1;
      case OrderStatus.confirmed:
        return 2;
      case OrderStatus.completed:
        return 3;
      case OrderStatus.cancelled:
        return 4;
    }
  }

  /// 주문 상태가 완료 상태인지 확인
  static bool isCompletedStatus(OrderStatus status) {
    return status == OrderStatus.completed || status == OrderStatus.cancelled;
  }

  /// 주문 상태가 진행 중인지 확인
  static bool isInProgressStatus(OrderStatus status) {
    return status == OrderStatus.confirmed;
  }

  /// 주문 상태가 취소 가능한지 확인
  static bool isCancellableStatus(OrderStatus status) {
    return status == OrderStatus.pending || status == OrderStatus.confirmed;
  }

  /// 주문 총액 계산 (int 반환 - OrderModel과 일관성)
  static int calculateTotalAmount(List<OrderItemModel> items) {
    return items.fold(0, (sum, item) {
      final unitPrice = item.unitPrice ?? 0;
      final quantity = item.quantity;
      return sum + (unitPrice * quantity);
    });
  }

  /// 주문 총액 계산 (double 반환 - 정밀 계산용)
  static double calculateTotalAmountPrecise(List<OrderItemModel> items) {
    return items.fold(0.0, (sum, item) {
      final unitPrice = (item.unitPrice ?? 0).toDouble();
      final quantity = item.quantity.toDouble();
      return sum + (unitPrice * quantity);
    });
  }

  /// 주문 아이템 수 계산
  static int calculateTotalItems(List<OrderItemModel> items) {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  /// 주문 상태 변경 가능 여부 확인
  static bool canChangeStatus(OrderStatus from, OrderStatus to) {
    // 취소된 주문은 상태 변경 불가
    if (from == OrderStatus.cancelled) return false;
    
    // 완료된 주문은 상태 변경 불가
    if (from == OrderStatus.completed) return false;
    
    // 순차적 상태 변경만 허용
    final fromPriority = getStatusPriority(from);
    final toPriority = getStatusPriority(to);
    
    // 취소는 언제든 가능 (완료 제외)
    if (to == OrderStatus.cancelled && from != OrderStatus.completed) {
      return true;
    }
    
    // 순차적 진행만 허용
    return toPriority == fromPriority + 1;
  }

  /// 주문 상태에 따른 다음 가능한 상태들 반환
  static List<OrderStatus> getNextPossibleStatuses(OrderStatus currentStatus) {
    final nextStatuses = <OrderStatus>[];
    
    for (final status in OrderStatus.values) {
      if (canChangeStatus(currentStatus, status)) {
        nextStatuses.add(status);
      }
    }
    
    return nextStatuses;
  }

  /// 주문 생성 시간으로부터 경과 시간 계산
  static Duration getOrderAge(DateTime createdAt) {
    return DateTime.now().difference(createdAt);
  }

  /// 주문이 오래된 주문인지 확인 (7일 기준)
  static bool isOldOrder(DateTime createdAt) {
    return getOrderAge(createdAt).inDays > 7;
  }

  /// 주문 검색 필터링
  static List<OrderModel> filterOrders(
    List<OrderModel> orders, {
    String? searchQuery,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return orders.where((order) {
      // 검색어 필터
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchesId = order.id.toLowerCase().contains(query);
        final matchesSeller = order.sellerName?.toLowerCase().contains(query) ?? false;
        if (!matchesId && !matchesSeller) return false;
      }
      
      // 상태 필터
      if (status != null && order.status != status) return false;
      
      // 날짜 필터
      if (startDate != null && order.createdAt.isBefore(startDate)) return false;
      if (endDate != null && order.createdAt.isAfter(endDate)) return false;
      
      return true;
    }).toList();
  }

  /// 주문 정렬
  static List<OrderModel> sortOrders(
    List<OrderModel> orders, {
    OrderSortBy sortBy = OrderSortBy.dateDesc,
  }) {
    final sortedOrders = List<OrderModel>.from(orders);
    
    switch (sortBy) {
      case OrderSortBy.dateAsc:
        sortedOrders.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case OrderSortBy.dateDesc:
        sortedOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case OrderSortBy.amountAsc:
        sortedOrders.sort((a, b) => a.totalAmount.compareTo(b.totalAmount));
        break;
      case OrderSortBy.amountDesc:
        sortedOrders.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
        break;
      case OrderSortBy.status:
        sortedOrders.sort((a, b) => 
          getStatusPriority(a.status).compareTo(getStatusPriority(b.status)));
        break;
    }
    
    return sortedOrders;
  }
}

/// 주문 정렬 기준
enum OrderSortBy {
  dateAsc,
  dateDesc,
  amountAsc,
  amountDesc,
  status,
}
