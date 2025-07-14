# Order Market App - Amazon Q Developer Rules

## 📋 프로젝트 개요

**Order Market App**은 Flutter + Firebase 기반의 B2B 식자재 주문 관리 시스템입니다.
구매자(Buyer)와 판매자(Seller) 간의 주문 프로세스를 디지털화하여 효율적인 거래를 지원합니다.

### 핵심 정보
- **프로젝트명**: order_market_app
- **Firebase 프로젝트**: order-market-app (ID: 486521508162)
- **아키텍처**: Clean Architecture + GetX Pattern
- **상태관리**: GetX (Reactive Programming)
- **백엔드**: Firebase (Auth, Firestore, Storage)

---

## 🏗️ 프로젝트 구조

```
lib/
├── main.dart                           # 앱 진입점, 의존성 주입
├── firebase_options.dart               # Firebase 설정
└── app/
    ├── core/                          # 핵심 기능
    │   ├── config/                    # 설정 파일
    │   ├── constants/                 # 상수 정의
    │   ├── extensions/                # 확장 메서드
    │   ├── services/                  # 비즈니스 로직 서비스
    │   ├── state/                     # 전역 상태 관리
    │   ├── theme/                     # UI 테마
    │   └── utils/                     # 유틸리티 함수
    ├── data/                          # 데이터 계층
    │   ├── models/                    # 데이터 모델
    │   ├── providers/                 # 데이터 제공자
    │   ├── repositories/              # 저장소 패턴
    │   └── services/                  # 데이터 서비스
    ├── modules/                       # 기능별 모듈
    │   ├── auth/                      # 인증 관련
    │   ├── buyer/                     # 구매자 기능
    │   └── seller/                    # 판매자 기능
    ├── presentation/                  # 프레젠테이션 계층
    │   ├── controllers/               # GetX 컨트롤러
    │   └── views/                     # UI 화면
    └── routes/                        # 라우팅 설정
        ├── app_pages.dart             # 페이지 정의
        └── app_routes.dart            # 라우트 상수
```

---

## 🔧 핵심 서비스 구조

### 1. AuthService (인증 서비스)
```dart
// 위치: lib/app/core/services/auth_service.dart
// 역할: Firebase Auth 관리, 사용자 상태 추적
// 주요 기능:
- Firebase Auth 상태 변화 감지
- 사용자 데이터 로드/저장
- 로그인/로그아웃 처리
- 프로필 설정 상태 확인
```

### 2. ProductService (상품 서비스)
```dart
// 위치: lib/app/core/services/product_service.dart
// 역할: 상품 CRUD 관리
// 주요 기능:
- 판매자별 상품 관리
- 상품 목록 조회
- 상품 생성/수정/삭제
- 상품 활성화/비활성화
```

### 3. OrderService (주문 서비스)
```dart
// 위치: lib/app/core/services/order_service.dart
// 역할: 주문 프로세스 관리
// 주요 기능:
- 주문 생성/조회/업데이트
- 주문 상태 관리
- 실시간 주문 알림
- 주문 내역 관리
```

### 4. ConnectionService (연결 서비스)
```dart
// 위치: lib/app/core/services/connection_service.dart
// 역할: 구매자-판매자 연결 관리
// 주요 기능:
- 연결 요청 생성/승인/거절
- 연결된 사용자 목록 관리
- 연결 상태 추적
```

---

## 📊 데이터 모델

### UserModel
```dart
// 위치: lib/app/data/models/user_model.dart
enum UserRole { buyer, seller }

class UserModel {
  final String uid;           // Firebase Auth UID
  final String email;         // 이메일
  final String displayName;   // 표시명
  final UserRole role;        // 사용자 역할
  final String? phoneNumber;  // 전화번호
  final String? businessName; // 사업체명
  final String? address;      // 주소
  final DateTime createdAt;   // 생성일시
}
```

### ProductModel
```dart
// 위치: lib/app/data/models/product_model.dart
class ProductModel {
  final String id;           // 상품 ID
  final String sellerId;     // 판매자 ID
  final String name;         // 상품명
  final String unit;         // 단위
  final int price;           // 가격
  final bool isActive;       // 활성화 상태
  final int orderIndex;      // 정렬 순서
  final DateTime createdAt;  // 생성일시
}
```

### OrderModel
```dart
// 위치: lib/app/data/models/order_model.dart
enum OrderStatus { pending, approved, rejected, completed }

class OrderModel {
  final String id;              // 주문 ID
  final String buyerId;         // 구매자 ID
  final String sellerId;        // 판매자 ID
  final String buyerName;       // 구매자명
  final String sellerName;      // 판매자명
  final OrderStatus status;     // 주문 상태
  final DateTime orderDate;     // 주문일시
  final List<OrderItemModel> items; // 주문 항목
  final int totalAmount;        // 총 금액
  final String? notes;          // 메모
}
```

### ConnectionModel
```dart
// 위치: lib/app/data/models/connection_model.dart
enum ConnectionStatus { pending, approved, rejected }

class ConnectionModel {
  final String id;                    // 연결 ID
  final String buyerId;               // 구매자 ID
  final String sellerId;              // 판매자 ID
  final ConnectionStatus status;      // 연결 상태
  final DateTime createdAt;           // 생성일시
}
```

---

## 🎯 사용자 역할별 기능

### 구매자(Buyer) 기능
1. **홈 화면** (`buyer_home_view.dart`)
   - 연결된 판매자 목록
   - 최근 주문 내역
   - 빠른 주문 기능

2. **주문 탭** (`order_tab_view.dart`)
   - 판매자별 상품 목록
   - 주문 생성
   - 장바구니 기능

3. **내역 탭** (`order_history_view.dart`)
   - 주문 내역 조회
   - 주문 상태 확인
   - 주문 상세 정보

4. **연결 탭** (`seller_connect_view.dart`)
   - 새 판매자 연결 요청
   - 연결된 판매자 관리
   - 연결 상태 확인

### 판매자(Seller) 기능
1. **홈 화면** (`seller_home_view.dart`)
   - 주문 현황 대시보드
   - 최근 주문 알림
   - 빠른 상태 업데이트

2. **상품 탭** (`product_management_view.dart`)
   - 상품 등록/수정/삭제
   - 상품 활성화/비활성화
   - 상품 순서 관리

3. **주문 탭** (`seller_orders_view.dart`)
   - 주문 접수/처리
   - 주문 상태 업데이트
   - 주문 내역 관리

4. **연결 탭** (`connection_requests_view.dart`)
   - 연결 요청 승인/거절
   - 연결된 구매자 관리
   - 연결 현황 확인

---

## 🔄 주요 비즈니스 플로우

### 1. 사용자 인증 플로우
```
앱 시작 → SplashController → AuthService 상태 확인
├─ 미인증: LoginView → RegisterView → RoleSelectionView → ProfileSetupView
└─ 인증됨: 프로필 확인 → MainView (역할별 홈화면)
```

### 2. 주문 생성 플로우
```
구매자: 상품 선택 → 수량 입력 → 주문 생성 → OrderService.createOrder()
판매자: 주문 알림 수신 → 주문 승인/거절 → OrderService.updateOrderStatus()
구매자: 상태 변경 알림 수신 → 주문 완료 처리
```

### 3. 연결 요청 플로우
```
구매자: 판매자 검색 → 연결 요청 → ConnectionService.createConnection()
판매자: 연결 요청 알림 → 승인/거절 → ConnectionService.updateConnectionStatus()
구매자: 연결 완료 알림 → 상품 목록 접근 가능
```

---

## 🎨 UI/UX 가이드라인

### 테마 시스템
```dart
// 위치: lib/app/core/theme/
- app_theme.dart: 전체 테마 설정
- app_colors.dart: 색상 팔레트
```

### 주요 색상
- Primary: 브랜드 메인 컬러
- Secondary: 보조 컬러
- Success: 성공 상태 (주문 완료 등)
- Warning: 경고 상태 (대기 중 등)
- Error: 오류 상태 (주문 실패 등)

### 컴포넌트 재사용
- 공통 위젯은 `presentation/views/common/`에 위치
- 일관된 디자인을 위해 기존 컴포넌트 재사용 권장
- 새로운 컴포넌트 생성 시 재사용 가능하도록 설계

---

## 🔧 개발 규칙 및 컨벤션

### 1. 코딩 컨벤션
```dart
// 클래스명: PascalCase
class UserModel { }

// 변수명, 함수명: camelCase
String userName = '';
void getUserData() { }

// 상수: UPPER_SNAKE_CASE
const String API_BASE_URL = '';

// 파일명: snake_case
user_model.dart
auth_service.dart
```

### 2. GetX 패턴 사용 규칙
```dart
// Controller 생성
class HomeController extends GetxController {
  // Reactive variables
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  
  // Getters
  List<Product> get productList => products;
  bool get loading => isLoading.value;
}

// View에서 사용
class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.loading 
      ? CircularProgressIndicator()
      : ListView.builder(...)
    );
  }
}
```

### 3. 에러 처리 패턴
```dart
try {
  // 비즈니스 로직
  await service.performAction();
} catch (e) {
  print('Error: $e');
  Get.snackbar('오류', '작업을 완료할 수 없습니다.');
} finally {
  isLoading.value = false;
}
```

### 4. Firebase 보안 규칙
```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 사용자는 자신의 문서만 접근 가능
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // 상품은 판매자만 CRUD 가능
    match /products/{productId} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth != null && 
        request.auth.uid == request.resource.data.sellerId;
    }
  }
}
```

---

## 🚨 중요한 개발 이슈 및 해결 방안

### 1. 프로필 설정 중복 표시 문제
**문제**: 이미 프로필을 설정한 사용자에게 계속 프로필 설정 화면이 표시됨
**해결**: `SplashController`에서 사용자 데이터 존재 여부 확인 후 적절한 화면으로 라우팅

```dart
// SplashController에서 구현
if (user != null) {
  final userData = await AuthService.instance.getUserData(user.uid);
  if (userData != null) {
    // 프로필이 이미 설정됨 → 메인 화면으로
    Get.offAllNamed(AppRoutes.main);
  } else {
    // 프로필 미설정 → 프로필 설정 화면으로
    Get.offAllNamed(AppRoutes.profileSetup);
  }
}
```

### 2. 데이터 덮어쓰기 방지
**원칙**: 기존 데이터가 있는 경우 덮어쓰기 허용 (사용자가 수정할 수 있어야 함)
**구현**: 프로필 설정 화면에서 기존 데이터 로드 후 수정 가능하도록 구현

### 3. 네트워크 연결 문제
**해결**: 에뮬레이터에서 Google DNS(8.8.8.8) 사용
```bash
./emulator -avd orderman -dns-server 8.8.8.8,8.8.4.4
```

---

## 🔄 상태 관리 최적화

### GlobalStateController 활용
```dart
// 위치: lib/app/core/state/global_state_controller.dart
// 역할: 앱 전체 상태 관리, 캐싱, 성능 최적화
class GlobalStateController extends GetxController {
  // 전역 상태 변수들
  final RxBool isAppInitialized = false.obs;
  final RxString currentUserRole = ''.obs;
  
  // 캐시 관리
  final CacheManager cacheManager = CacheManager();
}
```

### 성능 최적화 전략
1. **지연 로딩**: 필요한 시점에 데이터 로드
2. **캐싱**: 자주 사용되는 데이터 메모리 캐시
3. **실시간 업데이트**: Firestore 스트림 활용
4. **메모리 관리**: 불필요한 리스너 정리

---

## 🎯 향후 개발 방향

### 1. 홈 화면 개선 (진행 중)
- "연결된 판매자" 컨테이너: 연결 탭의 UI/UX 재사용
- "최근 주문" 컨테이너: 내역 탭의 UI/UX 재사용
- 일관된 디자인 적용

### 2. 추가 기능 계획
- 푸시 알림 시스템
- 결제 시스템 연동
- 채팅 기능
- 분석 대시보드
- 다국어 지원

### 3. 성능 개선
- 이미지 최적화
- 데이터베이스 쿼리 최적화
- 앱 크기 최적화
- 로딩 속도 개선

---

## 🛠️ 개발 환경 설정

### 필수 도구
- Flutter SDK (최신 안정 버전)
- Android Studio / VS Code
- Firebase CLI
- Android Emulator

### 실행 명령어
```bash
# 에뮬레이터 실행
flutter run -d emulator-5556

# 웹 실행
flutter run -d web-server --web-port 8080

# 빌드
flutter build apk --release
flutter build ios --release
```

### 환경 변수 설정
```bash
# .env 파일 생성 필요
cp .env.example .env
# 필요한 환경 변수 설정
```

---

## 📝 코드 작성 시 주의사항

### 1. 기존 코드 재사용 우선
- 새로운 기능 개발 시 기존 컴포넌트/서비스 최대한 활용
- 중복 코드 방지
- 일관된 패턴 유지

### 2. 상세한 주석 작성
```dart
/// 주문을 생성하는 메서드
/// 
/// [buyerId] 구매자 ID
/// [sellerId] 판매자 ID  
/// [items] 주문 항목 리스트
/// 
/// Returns: 생성된 주문의 ID
/// Throws: [FirebaseException] Firestore 오류 시
Future<String> createOrder({
  required String buyerId,
  required String sellerId,
  required List<OrderItemModel> items,
}) async {
  // 구현 내용...
}
```

### 3. 에러 처리 필수
- 모든 비동기 작업에 try-catch 적용
- 사용자 친화적인 에러 메시지 제공
- 로그 출력으로 디버깅 지원

### 4. 테스트 가능한 코드 작성
- 의존성 주입 활용
- 순수 함수 지향
- 모킹 가능한 구조

---

## 🔍 디버깅 및 문제 해결

### 로그 확인
```dart
// 개발 중 로그 출력
print('=== 디버그: $variable ===');

// 조건부 로그 출력
if (kDebugMode) {
  print('Debug info: $data');
}
```

### 일반적인 문제들
1. **Firebase 연결 실패**: DNS 설정 확인
2. **상태 업데이트 안됨**: Obx() 위젯 사용 확인
3. **메모리 누수**: 컨트롤러 dispose 확인
4. **빌드 오류**: 의존성 버전 충돌 확인

---

이 문서는 Order Market App의 현재 코드베이스를 기반으로 작성되었으며, 개발 진행에 따라 지속적으로 업데이트됩니다.
