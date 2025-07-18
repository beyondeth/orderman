import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            
            // 앱 로고 또는 아이콘
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shopping_cart,
                size: 60,
                color: Color(0xFF2196F3),
              ),
            ),
            
            const SizedBox(height: AppConstants.largePadding),
            
            // 앱 이름
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: AppConstants.smallPadding),
            
            // 앱 설명
            Text(
              '디지털화된 식자재 주문 시스템',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            
            const Spacer(flex: 2),
            
            // bamtol 방식: 단계별 상태 표시
            Column(
              children: [
                Obx(() {
                  return Text(
                    _getStepMessage(controller.currentStep.value),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  );
                }),
                
                const SizedBox(height: 20),
                
                // 로딩 인디케이터
                const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  String _getStepMessage(SplashStep step) {
    switch (step) {
      case SplashStep.init:
        return '초기화 중...';
      case SplashStep.dataLoad:
        return '데이터를 불러오는 중...';
      case SplashStep.authCheck:
        return '인증 상태를 확인하는 중...';
      case SplashStep.complete:
        return '완료되었습니다.';
    }
  }
}