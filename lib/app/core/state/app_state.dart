import '../../data/models/user_model.dart';
import '../../data/models/connection_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';

/// 앱의 전체 상태를 나타내는 불변 클래스
class AppState {
  final UserModel? user;
  final List<ConnectionModel> connections;
  final List<OrderModel> orders;
  final List<ProductModel> products;
  final LoadingState loadingState;
  final ErrorState? errorState;
  final Map<String, dynamic> cache;

  const AppState({
    this.user,
    this.connections = const [],
    this.orders = const [],
    this.products = const [],
    this.loadingState = LoadingState.idle,
    this.errorState,
    this.cache = const {},
  });

  /// 상태 복사 메서드 (불변성 유지)
  AppState copyWith({
    UserModel? user,
    List<ConnectionModel>? connections,
    List<OrderModel>? orders,
    List<ProductModel>? products,
    LoadingState? loadingState,
    ErrorState? errorState,
    Map<String, dynamic>? cache,
  }) {
    return AppState(
      user: user ?? this.user,
      connections: connections ?? this.connections,
      orders: orders ?? this.orders,
      products: products ?? this.products,
      loadingState: loadingState ?? this.loadingState,
      errorState: errorState,
      cache: cache ?? this.cache,
    );
  }

  /// 사용자 관련 편의 메서드
  bool get isAuthenticated => user != null;
  bool get isBuyer => user?.role == UserRole.buyer;
  bool get isSeller => user?.role == UserRole.seller;
  String get userName => user?.displayName ?? '';
  String get businessName => user?.businessName ?? '';

  /// 연결 관련 편의 메서드
  List<ConnectionModel> get approvedConnections => 
      connections.where((c) => c.status == ConnectionStatus.approved).toList();
  
  List<ConnectionModel> get pendingConnections => 
      connections.where((c) => c.status == ConnectionStatus.pending).toList();

  /// 주문 관련 편의 메서드
  List<OrderModel> get recentOrders => 
      orders.take(5).toList();
  
  List<OrderModel> get pendingOrders => 
      orders.where((o) => o.status == OrderStatus.pending).toList();
  
  List<OrderModel> get completedOrders => 
      orders.where((o) => o.status == OrderStatus.completed).toList();

  /// 상품 관련 편의 메서드
  List<ProductModel> get availableProducts => 
      products.where((p) => p.isActive).toList();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppState &&
        other.user == user &&
        _listEquals(other.connections, connections) &&
        _listEquals(other.orders, orders) &&
        _listEquals(other.products, products) &&
        other.loadingState == loadingState &&
        other.errorState == errorState;
  }

  @override
  int get hashCode {
    return Object.hash(
      user,
      connections,
      orders,
      products,
      loadingState,
      errorState,
    );
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// 로딩 상태 열거형
enum LoadingState {
  idle,
  loading,
  refreshing,
  loadingMore,
}

/// 에러 상태 클래스
sealed class ErrorState {
  final String message;
  final DateTime timestamp;
  
  const ErrorState(this.message, this.timestamp);
  
  factory ErrorState.network(String message) = NetworkError;
  factory ErrorState.validation(String message, Map<String, String> errors) = ValidationError;
  factory ErrorState.auth(String message, String code) = AuthError;
  factory ErrorState.unknown(String message) = UnknownError;
}

class NetworkError extends ErrorState {
  NetworkError(String message) : super(message, DateTime.now());
}

class ValidationError extends ErrorState {
  final Map<String, String> errors;
  
  ValidationError(String message, this.errors) : super(message, DateTime.now());
}

class AuthError extends ErrorState {
  final String code;
  
  AuthError(String message, this.code) : super(message, DateTime.now());
}

class UnknownError extends ErrorState {
  UnknownError(String message) : super(message, DateTime.now());
}

/// 상태 변경 액션 인터페이스
abstract class AppAction {
  const AppAction();
}

/// 사용자 관련 액션
class SetUserAction extends AppAction {
  final UserModel? user;
  const SetUserAction(this.user);
}

class ClearUserAction extends AppAction {
  const ClearUserAction();
}

/// 연결 관련 액션
class SetConnectionsAction extends AppAction {
  final List<ConnectionModel> connections;
  const SetConnectionsAction(this.connections);
}

class AddConnectionAction extends AppAction {
  final ConnectionModel connection;
  const AddConnectionAction(this.connection);
}

class UpdateConnectionAction extends AppAction {
  final ConnectionModel connection;
  const UpdateConnectionAction(this.connection);
}

/// 주문 관련 액션
class SetOrdersAction extends AppAction {
  final List<OrderModel> orders;
  const SetOrdersAction(this.orders);
}

class AddOrderAction extends AppAction {
  final OrderModel order;
  const AddOrderAction(this.order);
}

class UpdateOrderAction extends AppAction {
  final OrderModel order;
  const UpdateOrderAction(this.order);
}

/// 상품 관련 액션
class SetProductsAction extends AppAction {
  final List<ProductModel> products;
  const SetProductsAction(this.products);
}

class AddProductAction extends AppAction {
  final ProductModel product;
  const AddProductAction(this.product);
}

class UpdateProductAction extends AppAction {
  final ProductModel product;
  const UpdateProductAction(this.product);
}

/// 로딩 상태 액션
class SetLoadingAction extends AppAction {
  final LoadingState loadingState;
  const SetLoadingAction(this.loadingState);
}

/// 에러 상태 액션
class SetErrorAction extends AppAction {
  final ErrorState? errorState;
  const SetErrorAction(this.errorState);
}

class ClearErrorAction extends AppAction {
  const ClearErrorAction();
}
