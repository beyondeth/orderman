import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/user_model.dart';

enum SplashStep {
  init,
  dataLoad,
  authCheck,
  complete
}

class SplashController extends GetxController {
  final Rx<SplashStep> currentStep = SplashStep.init.obs;
  
  @override
  void onInit() {
    super.onInit();
    print('=== SplashController onInit 시작 ===');
    
    // bamtol 방식: 단계별 진행
    _startSplashFlow();
  }

  void _startSplashFlow() {
    print('=== 스플래시 플로우 시작 ===');
    
    // 1단계: 데이터 로드
    changeStep(SplashStep.dataLoad);
  }

  void changeStep(SplashStep step) {
    print('=== 단계 변경: ${currentStep.value.name} → ${step.name} ===');
    currentStep.value = step;
    
    switch (step) {
      case SplashStep.init:
        break;
        
      case SplashStep.dataLoad:
        _loadData();
        break;
        
      case SplashStep.authCheck:
        _checkAuthentication();
        break;
        
      case SplashStep.complete:
        _navigateToNextScreen();
        break;
    }
  }

  void _loadData() async {
    print('=== 데이터 로딩 시작 ===');
    
    try {
      // 최소 스플래시 시간 보장 (2초)
      await Future.delayed(const Duration(seconds: 2));
      
      print('=== 데이터 로딩 완료 ===');
      changeStep(SplashStep.authCheck);
      
    } catch (e) {
      print('=== 데이터 로딩 실패: $e ===');
      changeStep(SplashStep.authCheck); // 실패해도 다음 단계로
    }
  }

  void _checkAuthentication() async {
    print('=== 인증 상태 확인 시작 ===');
    
    try {
      if (!Get.isRegistered<AuthService>()) {
        print('=== AuthService가 등록되지 않음 - 로그인 화면으로 이동 ===');
        _navigateToLogin();
        return;
      }

      final authService = Get.find<AuthService>();
      
      // bamtol 방식: Firebase Auth 상태 직접 확인
      final firebaseUser = authService.firebaseUser;
      
      if (firebaseUser == null) {
        print('=== Firebase 사용자 없음 - 로그인 화면으로 이동 ===');
        _navigateToLogin();
        return;
      }

      print('=== Firebase 사용자 확인됨: ${firebaseUser.uid} ===');
      
      // 사용자 데이터 로딩 대기 (최대 5초)
      UserModel? userModel = authService.userModel;
      
      if (userModel == null) {
        print('=== 사용자 데이터 로딩 중... ===');
        
        // 사용자 데이터 직접 로드 시도
        await authService.loadUserData(firebaseUser.uid);
        userModel = authService.userModel;
        
        // 여전히 null이면 추가 대기
        if (userModel == null) {
          print('=== 사용자 데이터 로딩 대기 중... ===');
          
          // 최대 3초 대기하면서 사용자 데이터 확인
          for (int i = 0; i < 6; i++) {
            await Future.delayed(const Duration(milliseconds: 500));
            userModel = authService.userModel;
            if (userModel != null) break;
          }
        }
      }
      
      if (userModel != null) {
        print('=== 사용자 데이터 확인됨: ${userModel.displayName} (${userModel.role.name}) ===');
        
        // 프로필이 완전히 설정되었는지 확인
        if (_isProfileComplete(userModel)) {
          print('=== 프로필 완료 - 홈 화면으로 이동 ===');
          _navigateToHome(userModel.role);
        } else {
          print('=== 프로필 불완전 - 프로필 설정으로 이동 ===');
          _navigateToProfileSetup();
        }
      } else {
        print('=== 사용자 데이터 없음 - 프로필 설정으로 이동 ===');
        _navigateToProfileSetup();
      }
      
    } catch (e) {
      print('=== 인증 확인 실패: $e - 로그인 화면으로 이동 ===');
      _navigateToLogin();
    }
  }

  // 프로필 완성도 확인
  bool _isProfileComplete(UserModel userModel) {
    // 필수 필드들이 모두 설정되어 있는지 확인
    return userModel.displayName.isNotEmpty &&
           userModel.email.isNotEmpty &&
           (userModel.businessName?.isNotEmpty ?? false) &&
           (userModel.phoneNumber?.isNotEmpty ?? false);
  }

  void _navigateToNextScreen() {
    // 이 메서드는 현재 사용하지 않음 (직접 네비게이션)
  }

  void _navigateToLogin() {
    print('=== 로그인 화면으로 이동 ===');
    Get.offAllNamed(AppRoutes.login);
  }

  void _navigateToProfileSetup() {
    print('=== 프로필 설정 화면으로 이동 ===');
    Get.offAllNamed(AppRoutes.profileSetup);
  }

  void _navigateToHome(UserRole role) {
    print('=== 메인 화면으로 이동 - 역할: $role ===');
    Get.offAllNamed(AppRoutes.main);
  }
}
