# order_market_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


The method 'signInWithGoogle' isn't defined for the type 'AuthService'.
Try correcting the name to the name of an existing method, or defining a method named 'signInWithGoogle'.dartundefined_method


The method 'createUserProfile' isn't defined for the type 'AuthService'.
Try correcting the name to the name of an existing method, or defining a method named 'createUserProfile'.dartundefined_method

The method 'signInWithGoogle' isn't defined for the type 'AuthService'.
Try correcting the name to the name of an existing method, or defining a method named 'signInWithGoogle'.dartundefined_method

    6:     // 사용자 문서 규칙
+      7:     match /users/{userId} {
+      8:       // 사용자는 자신의 문서만 읽기/쓰기 가능
+      9:       allow read, write: if request.auth != null && request.auth.uid == userId;
+     10:       
+     11:       // 다른 사용자는 기본 정보만 읽기 가능 (연결 시 필요)
+     12:       allow read: if request.auth != null && 
+     13:                      resource.data.keys().hasAny(['displayName', 'email', 'role']);
+     14:     }
+     15:     
+     16:     // 연결 문서 규칙 (구매자-판매자 연결)
+     17:     match /connections/{connectionId} {
+     18:       // 연결 당사자만 읽기 가능
+     19:       allow read: if request.auth != null && 
+     20:                      (request.auth.uid == resource.data.buyerId || 
+     21:                       request.auth.uid == resource.data.sellerId);
+     22:       
+     23:       // 구매자만 연결 요청 생성 가능
+     24:       allow create: if request.auth != null && 
+     25:                        request.auth.uid == request.resource.data.buyerId &&
+     26:                        request.resource.data.status == 'pending';
+     27:       
+     28:       // 판매자만 연결 승인/거절 가능
+     29:       allow update: if request.auth != null && 
+     30:                        request.auth.uid == resource.data.sellerId &&
+     31:                        request.resource.data.status in ['approved', 'rejected'];
+     32:     }
+     33:     
+     34:     // 상품 문서 규칙
+     35:     match /products/{productId} {
+     36:       // 모든 인증된 사용자가 상품 읽기 가능
+     37:       allow read: if request.auth != null;
+     38:       
+     39:       // 판매자만 자신의 상품 생성/수정/삭제 가능
+     40:       allow create, update, delete: if request.auth != null && 
+     41:                                        request.auth.uid == request.resource.data.sellerId;
+     42:     }
+     43:     
+     44:     // 주문 문서 규칙
+     45:     match /orders/{orderId} {
+     46:       // 주문 당사자만 읽기 가능
+     47:       allow read: if request.auth != null && 
+     48:                      (request.auth.uid == resource.data.buyerId || 
+     49:                       request.auth.uid == resource.data.sellerId);
+     50:       
+     51:       // 구매자만 주문 생성 가능
+     52:       allow create: if request.auth != null && 
+     53:                        request.auth.uid == request.resource.data.buyerId;
+     54:       
+     55:       // 판매자만 주문 상태 업데이트 가능 (승인/거절/완료)
+     56:       allow update: if request.auth != null && 
+     57:                        request.auth.uid == resource.data.sellerId &&
+     58:                        request.resource.data.diff(resource.data).affectedKeys()
+     59:                          .hasOnly(['status', 'updatedAt']);
  17, 60:     }
+     61:     
+     62:     // 개발/테스트용 임시 규칙 (필요시 주석 해제)
+     63:     // match /{document=**} {
+     64:     //   allow read, write: if request.time < timestamp.date(2025, 1, 31);
+     65:     // }
  18, 66:   }
  19, 67: }

Replacing: firestore.rules


register_controller -> The named parameter 'role' isn't defined.
Try correcting the name to an existing named parameter's name, or defining a named parameter with the name 'role'.dartundefined_named_parameter

buyer_home_view -> The method 'goToProfile' isn't defined for the type 'BuyerHomeController'.
Try correcting the name to the name of an existing method, or defining a method named 'goToProfile'.dartundefined_method
The getter 'currentTabIndex' isn't defined for the type 'BuyerHomeController'.
Try importing the library that defines 'currentTabIndex', correcting the name to the name of an existing getter, or defining a getter or field named 'currentTabIndex'.dartundefined_getter
The getter 'onTabChanged' isn't defined for the type 'BuyerHomeController'.
Try importing the library that defines 'onTabChanged', correcting the name to the name of an existing getter, or defining a getter or field named 'onTabChanged'.dartundefined_getter
