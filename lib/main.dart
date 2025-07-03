import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/core/theme/app_theme.dart';
import 'app/core/services/firebase_service.dart';
import 'app/core/services/auth_service.dart';
import 'app/core/services/connection_service.dart';
import 'app/core/services/product_service.dart';
import 'app/core/services/order_service.dart';
import 'app/core/services/env_service.dart';
import 'app/core/state/global_state_controller.dart';
import 'app/presentation/controllers/splash_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 환경변수 초기화
    await EnvService.initialize();
    print('=== ✅ 환경변수 초기화 완료 ===');
    
    // 환경 정보 출력 (디버그 모드에서만)
    EnvService.printEnvironmentInfo();
    
    print('=== 🚀 앱 시작 - Firebase 초기화 시작 ===');
    
    // Firebase 초기화
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    print('=== ✅ Firebase 초기화 성공 ===');
    
  } catch (e, stackTrace) {
    print('=== ❌ 초기화 오류: $e ===');
    print('=== Stack trace: $stackTrace ===');
  }
  
  runApp(const OrderMarketApp());
}

class OrderMarketApp extends StatelessWidget {
  const OrderMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Order Market App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      
      // 🔥 bamtol 방식: initialBinding에서 모든 의존성 등록
      initialBinding: BindingsBuilder(() {
        print('=== 의존성 주입 시작 ===');
        
        // 1. Firebase Service 먼저 등록
        Get.put(FirebaseService(), permanent: true);
        print('=== ✅ FirebaseService 등록 완료 ===');
        
        // 2. Auth Service 등록
        Get.put(AuthService(), permanent: true);
        print('=== ✅ AuthService 등록 완료 ===');
        
        // 3. Connection Service 등록
        Get.put(ConnectionService(), permanent: true);
        print('=== ✅ ConnectionService 등록 완료 ===');
        
        // 3. 기타 서비스들 등록
        Get.put(ProductService(), permanent: true);
        Get.put(OrderService(), permanent: true);
        print('=== ✅ 모든 서비스 등록 완료 ===');
        
        // 4. GlobalStateController 등록 (서비스들 이후에)
        Get.put(GlobalStateController(), permanent: true);
        print('=== ✅ GlobalStateController 등록 완료 ===');
        
        // 5. SplashController 등록
        Get.put(SplashController(), permanent: true);
        print('=== ✅ SplashController 등록 완료 ===');
      }),
    );
  }
}
