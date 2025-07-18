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

  // .env 파일 로드
  await EnvService.initialize();

  // Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 앱 실행
  runApp(const OrderMarketApp());
}

class OrderMarketApp extends StatelessWidget {
  const OrderMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Order Market App',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,

      // 🔥 bamtol 방식: initialBinding에서 모든 의존성 등록
      initialBinding: BindingsBuilder(() {
        // SplashController가 다른 모든 서비스의 초기화 및 등록을 담당합니다.
        Get.put(SplashController(), permanent: true);
        print('=== ✅ SplashController 등록 완료 ===');
      }),
    );
  }
}