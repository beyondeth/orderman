import 'package:get/get.dart';
import 'dart:async';

import '../../core/services/auth_service.dart';
import '../../core/services/connection_service.dart';
import '../../core/services/order_service.dart';
import '../../core/services/product_service.dart';
import '../../data/models/user_model.dart';
import '../../data/models/connection_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';
import 'app_state.dart';
import 'cache_manager.dart';

/// 앱 전체의 상태를 중앙집중식으로 관리하는 컨트롤러
class GlobalStateController extends GetxController {
  // 현재 상태
  final Rx<AppState> _state = const AppState().obs;
  
  // 서비스들
  AuthService get _authService => Get.find<AuthService>();
  ConnectionService get _connectionService => Get.find<ConnectionService>();
  OrderService get _orderService => OrderService.instance;
  ProductService get _productService => ProductService.instance;
  
  // 캐시 매니저
  final CacheManager _cacheManager = CacheManager();
  
  // 스트림 구독들 (메모리 누수 방지)
  final List<StreamSubscription> _subscriptions = [];
  
  // 현재 상태 getter
  AppState get state => _state.value;
  
  // 상태 스트림 (외부 접근용)
  Stream<AppState> get stateStream => _state.stream;
  
  // AuthService 접근 (외부 접근용)
  AuthService get authService => _authService;
  
  // 편의 getters
  UserModel? get currentUser => state.user;
  bool get isAuthenticated => state.isAuthenticated;
  bool get isBuyer => state.isBuyer;
  bool get isSeller => state.isSeller;
  List<ConnectionModel> get connections => state.connections;
  List<OrderModel> get orders => state.orders;
  List<ProductModel> get products => state.products;
  LoadingState get loadingState => state.loadingState;
  ErrorState? get errorState => state.errorState;

  @override
  void onInit() {
    super.onInit();
    _initializeState();
    _setupAuthListener();
  }

  @override
  void onClose() {
    // 모든 구독 해제 (메모리 누수 방지)
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    super.onClose();
  }

  /// 초기 상태 설정
  void _initializeState() {
    final currentUser = _authService.userModel;
    if (currentUser != null) {
      _updateState(SetUserAction(currentUser));
      _loadInitialData();
    }
  }

  /// 인증 상태 리스너 설정
  void _setupAuthListener() {
    // AuthService의 사용자 상태 변경 감지
    // 실제 구현에서는 AuthService에 userStream이 있다고 가정
    // 현재는 주기적으로 체크하는 방식으로 대체
    Timer.periodic(const Duration(seconds: 5), (timer) {
      final currentUser = _authService.userModel;
      if (currentUser != _state.value.user) {
        _updateState(SetUserAction(currentUser));
        if (currentUser != null) {
          _loadInitialData();
        } else {
          _clearUserData();
          timer.cancel(); // 로그아웃 시 타이머 중지
        }
      }
    });
  }

  /// 초기 데이터 로드
  Future<void> _loadInitialData() async {
    if (!isAuthenticated) return;

    _updateState(const SetLoadingAction(LoadingState.loading));
    
    try {
      // 병렬로 데이터 로드
      await Future.wait([
        _loadConnections(),
        _loadOrders(),
        if (isSeller) _loadProducts(),
      ]);
      
      _updateState(const SetLoadingAction(LoadingState.idle));
      _updateState(const SetErrorAction(null));
    } catch (error) {
      _updateState(SetErrorAction(ErrorState.network(
        'Failed to load initial data: $error',
      )));
      _updateState(const SetLoadingAction(LoadingState.idle));
    }
  }

  /// 연결 데이터 로드
  Future<void> _loadConnections() async {
    if (!isAuthenticated) return;

    final cacheKey = 'connections_${currentUser!.uid}';
    
    // 캐시에서 먼저 확인
    final cachedConnections = _cacheManager.get<List<ConnectionModel>>(cacheKey);
    if (cachedConnections != null) {
      _updateState(SetConnectionsAction(cachedConnections));
      return;
    }

    try {
      // TODO: ConnectionService에 getUserConnections 메서드 구현 필요
      // 임시로 빈 리스트 반환
      final connections = <ConnectionModel>[];
      _updateState(SetConnectionsAction(connections));
      
      // 캐시에 저장 (5분 TTL)
      _cacheManager.set(cacheKey, connections, ttl: const Duration(minutes: 5));
    } catch (error) {
      throw Exception('Failed to load connections: $error');
    }
  }

  /// 주문 데이터 로드
  Future<void> _loadOrders() async {
    if (!isAuthenticated) return;

    final cacheKey = 'orders_${currentUser!.uid}';
    
    // 캐시에서 먼저 확인
    final cachedOrders = _cacheManager.get<List<OrderModel>>(cacheKey);
    if (cachedOrders != null) {
      _updateState(SetOrdersAction(cachedOrders));
      return;
    }

    try {
      final ordersStream = isBuyer 
          ? _orderService.getBuyerOrders(currentUser!.uid)
          : _orderService.getSellerOrders(currentUser!.uid);
      
      // Stream에서 첫 번째 값 가져오기
      final orders = await ordersStream.first;
      
      // 날짜순 정렬 (최신순)
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      _updateState(SetOrdersAction(orders));
      
      // 캐시에 저장 (3분 TTL)
      _cacheManager.set(cacheKey, orders, ttl: const Duration(minutes: 3));
    } catch (error) {
      throw Exception('Failed to load orders: $error');
    }
  }

  /// 상품 데이터 로드 (판매자만)
  Future<void> _loadProducts() async {
    if (!isAuthenticated || !isSeller) return;

    final cacheKey = 'products_${currentUser!.uid}';
    
    // 캐시에서 먼저 확인
    final cachedProducts = _cacheManager.get<List<ProductModel>>(cacheKey);
    if (cachedProducts != null) {
      _updateState(SetProductsAction(cachedProducts));
      return;
    }

    try {
      final productsStream = _productService.getSellerProducts(currentUser!.uid);
      
      // Stream에서 첫 번째 값 가져오기
      final products = await productsStream.first;
      
      _updateState(SetProductsAction(products));
      
      // 캐시에 저장 (10분 TTL)
      _cacheManager.set(cacheKey, products, ttl: const Duration(minutes: 10));
    } catch (error) {
      throw Exception('Failed to load products: $error');
    }
  }

  /// 사용자 데이터 클리어
  void _clearUserData() {
    _updateState(const SetUserAction(null));
    _updateState(const SetConnectionsAction([]));
    _updateState(const SetOrdersAction([]));
    _updateState(const SetProductsAction([]));
    _updateState(const SetLoadingAction(LoadingState.idle));
    _updateState(const SetErrorAction(null));
    _cacheManager.clearAll();
  }

  /// 상태 업데이트 (액션 기반)
  void _updateState(AppAction action) {
    final currentState = _state.value;
    
    switch (action) {
      case SetUserAction():
        _state.value = currentState.copyWith(user: action.user);
        break;
      case ClearUserAction():
        _state.value = currentState.copyWith(user: null);
        break;
      case SetConnectionsAction():
        _state.value = currentState.copyWith(connections: action.connections);
        break;
      case AddConnectionAction():
        final updatedConnections = [...currentState.connections, action.connection];
        _state.value = currentState.copyWith(connections: updatedConnections);
        break;
      case UpdateConnectionAction():
        final updatedConnections = currentState.connections.map((c) {
          return c.id == action.connection.id ? action.connection : c;
        }).toList();
        _state.value = currentState.copyWith(connections: updatedConnections);
        break;
      case SetOrdersAction():
        _state.value = currentState.copyWith(orders: action.orders);
        break;
      case AddOrderAction():
        final updatedOrders = [action.order, ...currentState.orders];
        _state.value = currentState.copyWith(orders: updatedOrders);
        break;
      case UpdateOrderAction():
        final updatedOrders = currentState.orders.map((o) {
          return o.id == action.order.id ? action.order : o;
        }).toList();
        _state.value = currentState.copyWith(orders: updatedOrders);
        break;
      case SetProductsAction():
        _state.value = currentState.copyWith(products: action.products);
        break;
      case AddProductAction():
        final updatedProducts = [...currentState.products, action.product];
        _state.value = currentState.copyWith(products: updatedProducts);
        break;
      case UpdateProductAction():
        final updatedProducts = currentState.products.map((p) {
          return p.id == action.product.id ? action.product : p;
        }).toList();
        _state.value = currentState.copyWith(products: updatedProducts);
        break;
      case SetLoadingAction():
        _state.value = currentState.copyWith(loadingState: action.loadingState);
        break;
      case SetErrorAction():
        _state.value = currentState.copyWith(errorState: action.errorState);
        break;
      case ClearErrorAction():
        _state.value = currentState.copyWith(errorState: null);
        break;
    }
  }

  // Public API 메서드들

  /// 데이터 새로고침
  Future<void> refresh() async {
    _cacheManager.clearAll();
    await _loadInitialData();
  }

  /// 연결 추가
  Future<void> addConnection(ConnectionModel connection) async {
    _updateState(AddConnectionAction(connection));
    
    // 캐시 무효화
    final cacheKey = 'connections_${currentUser!.uid}';
    _cacheManager.remove(cacheKey);
  }

  /// 연결 업데이트
  Future<void> updateConnection(ConnectionModel connection) async {
    _updateState(UpdateConnectionAction(connection));
    
    // 캐시 무효화
    final cacheKey = 'connections_${currentUser!.uid}';
    _cacheManager.remove(cacheKey);
  }

  /// 주문 추가
  Future<void> addOrder(OrderModel order) async {
    _updateState(AddOrderAction(order));
    
    // 캐시 무효화
    final cacheKey = 'orders_${currentUser!.uid}';
    _cacheManager.remove(cacheKey);
  }

  /// 주문 업데이트
  Future<void> updateOrder(OrderModel order) async {
    _updateState(UpdateOrderAction(order));
    
    // 캐시 무효화
    final cacheKey = 'orders_${currentUser!.uid}';
    _cacheManager.remove(cacheKey);
  }

  /// 상품 추가 (판매자만)
  Future<void> addProduct(ProductModel product) async {
    if (!isSeller) return;
    
    _updateState(AddProductAction(product));
    
    // 캐시 무효화
    final cacheKey = 'products_${currentUser!.uid}';
    _cacheManager.remove(cacheKey);
  }

  /// 상품 업데이트 (판매자만)
  Future<void> updateProduct(ProductModel product) async {
    if (!isSeller) return;
    
    _updateState(UpdateProductAction(product));
    
    // 캐시 무효화
    final cacheKey = 'products_${currentUser!.uid}';
    _cacheManager.remove(cacheKey);
  }

  /// 에러 클리어
  void clearError() {
    _updateState(const ClearErrorAction());
  }

  /// 특정 타입의 데이터만 다시 로드
  Future<void> reloadConnections() async {
    final cacheKey = 'connections_${currentUser!.uid}';
    _cacheManager.remove(cacheKey);
    await _loadConnections();
  }

  Future<void> reloadOrders() async {
    final cacheKey = 'orders_${currentUser!.uid}';
    _cacheManager.remove(cacheKey);
    await _loadOrders();
  }

  Future<void> reloadProducts() async {
    if (!isSeller) return;
    final cacheKey = 'products_${currentUser!.uid}';
    _cacheManager.remove(cacheKey);
    await _loadProducts();
  }
}
