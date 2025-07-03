import 'package:get/get.dart';
import 'dart:async';

import '../../../core/state/global_state_controller.dart';
import '../../../core/state/app_state.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/connection_model.dart';
import '../../../data/models/order_model.dart';

/// 최적화된 구매자 홈 컨트롤러
/// GlobalStateController를 활용하여 중복 상태 관리 제거
class BuyerHomeControllerOptimized extends GetxController {
  // 글로벌 상태 컨트롤러 참조
  GlobalStateController get _globalState => Get.find<GlobalStateController>();
  
  // 로컬 상태 (뷰 전용)
  final RxString _greetingMessage = ''.obs;
  final RxBool _isRefreshing = false.obs;
  
  // 스트림 구독 (메모리 누수 방지)
  StreamSubscription<AppState>? _stateSubscription;
  
  // Getters - 글로벌 상태에서 가져오기
  UserModel? get currentUser => _globalState.currentUser;
  List<ConnectionModel> get connections => _globalState.connections;
  List<OrderModel> get orders => _globalState.orders;
  List<OrderModel> get recentOrders => _globalState.state.recentOrders;
  LoadingState get loadingState => _globalState.loadingState;
  ErrorState? get errorState => _globalState.errorState;
  
  // 로딩 상태들
  bool get isLoading => loadingState == LoadingState.loading;
  bool get isLoadingOrders => loadingState == LoadingState.loading;
  bool get isLoadingConnections => loadingState == LoadingState.loading;
  bool get isRefreshing => _isRefreshing.value;
  
  // 사용자 정보
  String get userName => currentUser?.displayName ?? '구매자';
  String get businessName => currentUser?.businessName ?? '';
  String get greetingMessage => _greetingMessage.value;

  @override
  void onInit() {
    super.onInit();
    _initializeGreeting();
    _setupStateListener();
  }

  @override
  void onClose() {
    _stateSubscription?.cancel();
    super.onClose();
  }

  /// 인사말 초기화
  void _initializeGreeting() {
    _updateGreeting();
    
    // 1시간마다 인사말 업데이트
    Timer.periodic(const Duration(hours: 1), (_) => _updateGreeting());
  }

  /// 시간대별 인사말 업데이트
  void _updateGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    
    if (hour < 6) {
      greeting = '새벽 시간이네요';
    } else if (hour < 12) {
      greeting = '좋은 아침입니다';
    } else if (hour < 18) {
      greeting = '좋은 오후입니다';
    } else if (hour < 22) {
      greeting = '좋은 저녁입니다';
    } else {
      greeting = '늦은 시간이네요';
    }
    
    _greetingMessage.value = greeting;
  }

  /// 글로벌 상태 변경 리스너 설정
  void _setupStateListener() {
    // 글로벌 상태 변경 감지
    _stateSubscription = _globalState.stateStream.listen((state) {
      // 필요한 경우 로컬 상태 업데이트
      _handleStateChange(state);
    });
  }

  /// 상태 변경 처리
  void _handleStateChange(AppState state) {
    // 에러 상태 처리
    if (state.errorState != null) {
      _handleError(state.errorState!);
    }
    
    // 로딩 상태 변경 시 새로고침 상태 업데이트
    if (state.loadingState != LoadingState.refreshing) {
      _isRefreshing.value = false;
    }
  }

  /// 에러 처리
  void _handleError(ErrorState error) {
    String message;
    
    switch (error) {
      case NetworkError():
        message = '네트워크 연결을 확인해주세요';
        break;
      case AuthError():
        message = '인증에 문제가 발생했습니다';
        break;
      case ValidationError():
        message = '입력 정보를 확인해주세요';
        break;
      case UnknownError():
        message = '알 수 없는 오류가 발생했습니다';
        break;
    }
    
    Get.snackbar(
      '오류',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  // Public API 메서드들

  /// 데이터 새로고침
  Future<void> refreshConnections() async {
    if (_isRefreshing.value) return;
    
    _isRefreshing.value = true;
    
    try {
      await _globalState.refresh();
    } finally {
      _isRefreshing.value = false;
    }
  }

  /// 연결만 새로고침
  Future<void> refreshConnectionsOnly() async {
    await _globalState.reloadConnections();
  }

  /// 주문만 새로고침
  Future<void> refreshOrdersOnly() async {
    await _globalState.reloadOrders();
  }

  /// 에러 클리어
  void clearError() {
    _globalState.clearError();
  }

  /// 특정 연결 정보 가져오기
  ConnectionModel? getConnection(String connectionId) {
    try {
      return connections.firstWhere((c) => c.id == connectionId);
    } catch (e) {
      return null;
    }
  }

  /// 승인된 연결만 가져오기
  List<ConnectionModel> get approvedConnections {
    return connections
        .where((c) => c.status == ConnectionStatus.approved)
        .toList();
  }

  /// 대기 중인 연결만 가져오기
  List<ConnectionModel> get pendingConnections {
    return connections
        .where((c) => c.status == ConnectionStatus.pending)
        .toList();
  }

  /// 특정 판매자의 최근 주문 가져오기
  List<OrderModel> getRecentOrdersFromSeller(String sellerId) {
    return orders
        .where((o) => o.sellerId == sellerId)
        .take(3)
        .toList();
  }

  /// 주문 통계 정보
  OrderStats get orderStats {
    final totalOrders = orders.length;
    final pendingOrders = orders.where((o) => o.status == OrderStatus.pending).length;
    final completedOrders = orders.where((o) => o.status == OrderStatus.completed).length;
    final totalAmount = orders.fold<double>(0.0, (sum, order) => sum + order.totalAmount);
    
    return OrderStats(
      totalOrders: totalOrders,
      pendingOrders: pendingOrders,
      completedOrders: completedOrders,
      totalAmount: totalAmount,
    );
  }

  /// 연결 통계 정보
  ConnectionStats get connectionStats {
    final totalConnections = connections.length;
    final approvedCount = connections.where((c) => c.status == ConnectionStatus.approved).length;
    final pendingCount = connections.where((c) => c.status == ConnectionStatus.pending).length;
    
    return ConnectionStats(
      totalConnections: totalConnections,
      approvedConnections: approvedCount,
      pendingConnections: pendingCount,
    );
  }

  /// 최근 활동 요약
  ActivitySummary get activitySummary {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    
    final todayOrders = orders.where((o) => o.createdAt.isAfter(todayStart)).length;
    final thisWeekStart = todayStart.subtract(Duration(days: today.weekday - 1));
    final thisWeekOrders = orders.where((o) => o.createdAt.isAfter(thisWeekStart)).length;
    
    return ActivitySummary(
      todayOrders: todayOrders,
      thisWeekOrders: thisWeekOrders,
      lastOrderDate: orders.isNotEmpty ? orders.first.createdAt : null,
    );
  }

  /// 추천 액션 가져오기
  List<RecommendedAction> get recommendedActions {
    final actions = <RecommendedAction>[];
    
    // 연결된 판매자가 없는 경우
    if (approvedConnections.isEmpty) {
      actions.add(RecommendedAction(
        title: '판매자와 연결하기',
        description: '신뢰할 수 있는 판매자와 연결하여 주문을 시작하세요',
        icon: 'link',
        action: 'connect_seller',
      ));
    }
    
    // 최근 주문이 없는 경우
    if (recentOrders.isEmpty && approvedConnections.isNotEmpty) {
      actions.add(RecommendedAction(
        title: '첫 주문하기',
        description: '연결된 판매자로부터 상품을 주문해보세요',
        icon: 'shopping_cart',
        action: 'create_order',
      ));
    }
    
    // 대기 중인 연결이 있는 경우
    if (pendingConnections.isNotEmpty) {
      actions.add(RecommendedAction(
        title: '연결 요청 확인',
        description: '${pendingConnections.length}개의 연결 요청이 대기 중입니다',
        icon: 'notifications',
        action: 'check_connections',
      ));
    }
    
    return actions;
  }

  /// 성능 메트릭 (디버그용)
  PerformanceMetrics get performanceMetrics {
    return PerformanceMetrics(
      totalConnections: connections.length,
      totalOrders: orders.length,
      cacheHitRate: 0.0, // 실제 구현 시 캐시 매니저에서 가져오기
      lastRefreshTime: DateTime.now(), // 실제 구현 시 마지막 새로고침 시간
    );
  }
}

/// 주문 통계 클래스
class OrderStats {
  final int totalOrders;
  final int pendingOrders;
  final int completedOrders;
  final double totalAmount;

  const OrderStats({
    required this.totalOrders,
    required this.pendingOrders,
    required this.completedOrders,
    required this.totalAmount,
  });
}

/// 연결 통계 클래스
class ConnectionStats {
  final int totalConnections;
  final int approvedConnections;
  final int pendingConnections;

  const ConnectionStats({
    required this.totalConnections,
    required this.approvedConnections,
    required this.pendingConnections,
  });
}

/// 활동 요약 클래스
class ActivitySummary {
  final int todayOrders;
  final int thisWeekOrders;
  final DateTime? lastOrderDate;

  const ActivitySummary({
    required this.todayOrders,
    required this.thisWeekOrders,
    this.lastOrderDate,
  });
}

/// 추천 액션 클래스
class RecommendedAction {
  final String title;
  final String description;
  final String icon;
  final String action;

  const RecommendedAction({
    required this.title,
    required this.description,
    required this.icon,
    required this.action,
  });
}

/// 성능 메트릭 클래스
class PerformanceMetrics {
  final int totalConnections;
  final int totalOrders;
  final double cacheHitRate;
  final DateTime lastRefreshTime;

  const PerformanceMetrics({
    required this.totalConnections,
    required this.totalOrders,
    required this.cacheHitRate,
    required this.lastRefreshTime,
  });
}
