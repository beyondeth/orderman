# Order Market App - 프로젝트 구조 및 기능 흐름 분석

## 📋 프로젝트 개요
Flutter + Firebase 기반의 B2B 주문 관리 앱으로, 구매자(Buyer)와 판매자(Seller) 간의 주문 프로세스를 관리합니다.

## 🏗️ 전체 아키텍처

```mermaid
graph TB
    subgraph "Frontend - Flutter App"
        A[main.dart] --> B[GetX App]
        B --> C[Routes & Pages]
        C --> D[Views]
        D --> E[Controllers]
        E --> F[Services]
        F --> G[Models]
    end
    
    subgraph "Backend - Firebase"
        H[Firebase Auth]
        I[Cloud Firestore]
        J[Firebase Storage]
    end
    
    F --> H
    F --> I
    F --> J
    
    subgraph "State Management"
        K[GetX Controllers]
        L[Global State]
        M[Cache Manager]
    end
    
    E --> K
    K --> L
    L --> M
```

## 🔄 사용자 인증 흐름

```mermaid
sequenceDiagram
    participant U as User
    participant S as SplashController
    participant A as AuthService
    participant F as Firebase Auth
    participant D as Firestore
    
    U->>S: 앱 시작
    S->>A: 인증 상태 확인
    A->>F: authStateChanges()
    
    alt 로그인된 사용자
        F->>A: User 객체 반환
        A->>D: 사용자 데이터 조회
        D->>A: UserModel 반환
        A->>S: 인증 완료
        S->>U: 메인 화면으로 이동
    else 미로그인 사용자
        F->>A: null 반환
        A->>S: 미인증 상태
        S->>U: 로그인 화면으로 이동
    end
```

## 👥 사용자 역할별 기능 구조

```mermaid
graph LR
    subgraph "공통 기능"
        A1[회원가입/로그인]
        A2[프로필 관리]
        A3[설정]
    end
    
    subgraph "구매자(Buyer) 기능"
        B1[판매자 연결 요청]
        B2[상품 목록 조회]
        B3[주문 생성]
        B4[주문 내역 조회]
        B5[주문 상태 확인]
    end
    
    subgraph "판매자(Seller) 기능"
        C1[연결 요청 관리]
        C2[상품 관리]
        C3[주문 접수/처리]
        C4[주문 상태 업데이트]
        C5[구매자 관리]
    end
    
    A1 --> B1
    A1 --> C1
    B1 --> B2
    B2 --> B3
    C1 --> C2
    C2 --> C3
```

## 📱 화면 네비게이션 구조

```mermaid
graph TD
    A[Splash Screen] --> B{인증 상태}
    B -->|미인증| C[Login Screen]
    B -->|인증됨| D[Main Screen]
    
    C --> E[Register Screen]
    E --> F[Role Selection]
    F --> G[Profile Setup]
    G --> D
    
    D --> H{사용자 역할}
    H -->|Buyer| I[Buyer Home]
    H -->|Seller| J[Seller Home]
    
    I --> K[Order Tab]
    I --> L[History Tab]
    I --> M[Profile Tab]
    
    J --> N[Products Tab]
    J --> O[Orders Tab]
    J --> P[Connections Tab]
    
    K --> Q[Order Creation]
    N --> R[Product Management]
    O --> S[Order Processing]
```

## 🔧 서비스 계층 구조

```mermaid
graph TB
    subgraph "Core Services"
        A[AuthService]
        B[FirebaseService]
        C[ProductService]
        D[OrderService]
        E[ConnectionService]
        F[EnvService]
    end
    
    subgraph "State Management"
        G[GlobalStateController]
        H[CacheManager]
        I[AppState]
    end
    
    subgraph "Controllers"
        J[AuthControllers]
        K[BuyerControllers]
        L[SellerControllers]
        M[CommonControllers]
    end
    
    A --> G
    B --> A
    C --> B
    D --> B
    E --> B
    F --> B
    
    G --> H
    G --> I
    
    J --> A
    K --> C
    K --> D
    K --> E
    L --> C
    L --> D
    L --> E
    M --> A
```

## 📊 데이터 모델 관계

```mermaid
erDiagram
    UserModel {
        string uid PK
        string email
        string displayName
        UserRole role
        string phoneNumber
        string businessName
        string address
        DateTime createdAt
    }
    
    ProductModel {
        string id PK
        string sellerId FK
        string name
        string unit
        int price
        bool isActive
        int orderIndex
        DateTime createdAt
    }
    
    OrderModel {
        string id PK
        string buyerId FK
        string sellerId FK
        string buyerName
        string sellerName
        OrderStatus status
        DateTime orderDate
        int totalAmount
        string notes
    }
    
    OrderItemModel {
        string productId FK
        string productName
        string unit
        int quantity
        int unitPrice
        int totalPrice
    }
    
    ConnectionModel {
        string id PK
        string buyerId FK
        string sellerId FK
        ConnectionStatus status
        DateTime createdAt
    }
    
    UserModel ||--o{ ProductModel : "판매자가 상품 소유"
    UserModel ||--o{ OrderModel : "구매자가 주문 생성"
    UserModel ||--o{ OrderModel : "판매자가 주문 처리"
    OrderModel ||--o{ OrderItemModel : "주문이 주문항목 포함"
    ProductModel ||--o{ OrderItemModel : "상품이 주문항목에 포함"
    UserModel ||--o{ ConnectionModel : "구매자-판매자 연결"
```

## 🔄 주문 프로세스 흐름

```mermaid
sequenceDiagram
    participant B as Buyer
    participant BC as BuyerController
    participant OS as OrderService
    participant FS as Firestore
    participant SC as SellerController
    participant S as Seller
    
    B->>BC: 주문 생성 요청
    BC->>OS: createOrder()
    OS->>FS: 주문 데이터 저장
    FS-->>OS: 저장 완료
    OS-->>BC: 주문 생성 완료
    BC-->>B: 주문 완료 알림
    
    Note over FS: 실시간 리스너 활성화
    
    FS->>SC: 새 주문 알림
    SC->>S: 주문 접수 알림
    S->>SC: 주문 상태 변경
    SC->>OS: updateOrderStatus()
    OS->>FS: 상태 업데이트
    FS->>BC: 상태 변경 알림
    BC->>B: 주문 상태 업데이트
```

## 🎯 핵심 기능별 컴포넌트

### 1. 인증 시스템
```mermaid
graph LR
    A[AuthService] --> B[Firebase Auth]
    A --> C[Firestore Users]
    D[LoginController] --> A
    E[RegisterController] --> A
    F[ProfileSetupController] --> A
```

### 2. 상품 관리 시스템
```mermaid
graph LR
    A[ProductService] --> B[Firestore Products]
    C[ProductManagementController] --> A
    D[ProductManagementView] --> C
    E[BuyerHomeController] --> A
```

### 3. 주문 관리 시스템
```mermaid
graph LR
    A[OrderService] --> B[Firestore Orders]
    C[OrderController] --> A
    D[SellerOrdersController] --> A
    E[OrderHistoryController] --> A
```

### 4. 연결 관리 시스템
```mermaid
graph LR
    A[ConnectionService] --> B[Firestore Connections]
    C[SellerConnectController] --> A
    D[ConnectionRequestsController] --> A
```

## 🔧 상태 관리 패턴

```mermaid
graph TB
    subgraph "GetX State Management"
        A[Controllers] --> B[Reactive Variables]
        B --> C[UI Updates]
        A --> D[Business Logic]
        D --> E[Service Calls]
        E --> F[Firebase Operations]
    end
    
    subgraph "Global State"
        G[GlobalStateController] --> H[App-wide State]
        H --> I[Cache Management]
        I --> J[Performance Optimization]
    end
    
    A --> G
```

## 📱 UI 컴포넌트 구조

```mermaid
graph TB
    subgraph "Theme System"
        A[AppTheme] --> B[AppColors]
        A --> C[AppTypography]
        A --> D[AppSpacing]
    end
    
    subgraph "Common Widgets"
        E[AppComponents] --> F[Custom Buttons]
        E --> G[Form Fields]
        E --> H[Cards & Lists]
    end
    
    subgraph "Navigation"
        I[AppNavigation] --> J[Bottom Navigation]
        I --> K[Tab Navigation]
        I --> L[Drawer Navigation]
    end
    
    A --> E
    E --> I
```

## 🚀 앱 시작 프로세스

```mermaid
flowchart TD
    A[main.dart] --> B[환경변수 초기화]
    B --> C[Firebase 초기화]
    C --> D[의존성 주입]
    D --> E[서비스 등록]
    E --> F[컨트롤러 등록]
    F --> G[앱 시작]
    G --> H[Splash Screen]
    H --> I{인증 상태 확인}
    I -->|인증됨| J[Main Screen]
    I -->|미인증| K[Login Screen]
```

## 📊 성능 최적화 전략

```mermaid
graph LR
    subgraph "캐싱 전략"
        A[CacheManager] --> B[메모리 캐시]
        A --> C[디스크 캐시]
        A --> D[네트워크 캐시]
    end
    
    subgraph "상태 최적화"
        E[GlobalState] --> F[상태 분리]
        E --> G[지연 로딩]
        E --> H[메모리 관리]
    end
    
    subgraph "UI 최적화"
        I[Widget 최적화] --> J[const 생성자]
        I --> K[Builder 패턴]
        I --> L[리스트 가상화]
    end
```

## 🔐 보안 및 권한 관리

```mermaid
graph TB
    subgraph "Firebase Security Rules"
        A[Users Collection] --> B[자신의 데이터만 접근]
        C[Products Collection] --> D[판매자만 CRUD]
        E[Orders Collection] --> F[관련 당사자만 접근]
        G[Connections Collection] --> H[연결 당사자만 접근]
    end
    
    subgraph "앱 레벨 보안"
        I[AuthService] --> J[토큰 관리]
        I --> K[세션 관리]
        I --> L[권한 검증]
    end
```

## 📈 확장 가능성

```mermaid
graph LR
    subgraph "현재 구조"
        A[Core Services]
        B[Controllers]
        C[Views]
        D[Models]
    end
    
    subgraph "확장 가능 영역"
        E[알림 시스템]
        F[결제 시스템]
        G[채팅 시스템]
        H[분석 시스템]
        I[다국어 지원]
    end
    
    A --> E
    A --> F
    A --> G
    A --> H
    A --> I
```

## 🎯 주요 특징

1. **Clean Architecture**: 계층별 분리된 구조
2. **GetX Pattern**: 반응형 상태 관리
3. **Firebase Integration**: 실시간 데이터 동기화
4. **Role-based Access**: 사용자 역할별 기능 분리
5. **Responsive Design**: 다양한 화면 크기 지원
6. **Error Handling**: 포괄적인 오류 처리
7. **Performance Optimization**: 캐싱 및 최적화 전략
8. **Security**: Firebase Security Rules 적용

## 🔧 개발 환경 설정

- **Flutter SDK**: 최신 안정 버전
- **Firebase Project**: 인증, Firestore, Storage 활성화
- **GetX**: 상태 관리 및 라우팅
- **Environment Variables**: .env 파일을 통한 설정 관리

이 구조는 확장 가능하고 유지보수가 용이한 B2B 주문 관리 시스템을 제공합니다.
