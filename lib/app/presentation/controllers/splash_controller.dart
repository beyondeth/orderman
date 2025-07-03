import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/user_model.dart';

enum SplashStep { init, dataLoad, authCheck, complete }

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

        // 여전히 null이면 추가 대기 (네트워크 불안정 고려)
        if (userModel == null) {
          print('=== 사용자 데이터 로딩 대기 중... ===');

          // 최대 10초 대기하면서 사용자 데이터 확인 (기존 3초에서 증가)
          for (int i = 0; i < 20; i++) {
            await Future.delayed(const Duration(milliseconds: 500));
            userModel = authService.userModel;
            if (userModel != null) {
              print('=== 대기 중 사용자 데이터 로드 성공 (${(i + 1) * 0.5}초 후) ===');
              break;
            }
          }
        }
      }

      if (userModel != null) {
        print(
          '=== 사용자 데이터 확인됨: ${userModel.displayName} (${userModel.role.name}) ===',
        );

        // 프로필이 완전히 설정되었는지 확인
        if (_isProfileComplete(userModel)) {
          print('=== 프로필 완료 - 홈 화면으로 이동 ===');
          _navigateToHome(userModel.role);
        } else {
          print('=== 프로필 불완전 - 프로필 설정으로 이동 ===');
          _navigateToProfileSetup();
        }
      } else {
        print('=== 사용자 데이터 없음 - Firebase Auth 정보로 임시 처리 ===');
        
        // Firebase Auth에서 기본 정보 확인
        final firebaseUser = authService.firebaseUser!;
        print('Firebase Auth 정보:');
        print('- UID: ${firebaseUser.uid}');
        print('- Email: ${firebaseUser.email}');
        print('- DisplayName: ${firebaseUser.displayName}');
        
        // 이미 로그인된 사용자라면 기본 정보로 임시 UserModel 생성
        if (firebaseUser.email != null && firebaseUser.displayName != null) {
          print('=== Firebase Auth 정보로 임시 사용자 모델 생성 ===');
          
          // 기본값으로 구매자 역할 설정 (나중에 프로필에서 수정 가능)
          final tempUserModel = UserModel(
            uid: firebaseUser.uid,
            email: firebaseUser.email!,
            displayName: firebaseUser.displayName!,
            role: UserRole.seller, // 판매자로 로그인했다고 했으므로
            createdAt: DateTime.now(),
          );
          
          // AuthService에 임시로 설정
          authService.setTempUserModel(tempUserModel);
          
          print('=== 임시 사용자 모델로 홈 화면 이동 ===');
          _navigateToHome(UserRole.seller);
          return;
        }
        
        // 네트워크 문제일 가능성이 높으므로 사용자에게 알림
        Get.snackbar(
          '네트워크 연결 확인',
          '사용자 정보를 불러오는데 시간이 걸리고 있습니다. 네트워크 연결을 확인해주세요.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        
        _navigateToProfileSetup();
      }
    } catch (e) {
      print('=== 인증 확인 실패: $e - 로그인 화면으로 이동 ===');
      _navigateToLogin();
    }
  }

  // 프로필 완성도 확인
  bool _isProfileComplete(UserModel userModel) {
    print('=== 프로필 완성도 확인 시작 ===');
    print('displayName: "${userModel.displayName}"');
    print('email: "${userModel.email}"');
    print('role: ${userModel.role.name}');
    print('businessName: "${userModel.businessName ?? "null"}"');
    print('phoneNumber: "${userModel.phoneNumber ?? "null"}"');

    // 기본 필수 필드들
    bool hasBasicInfo =
        userModel.displayName.isNotEmpty && userModel.email.isNotEmpty;

    print('기본 정보 완성: $hasBasicInfo');

    // 역할별 추가 요구사항 (더 유연하게)
    bool hasRoleSpecificInfo = true;

    // 판매자의 경우 비즈니스 이름이 있으면 좋지만 필수는 아님
    // 구매자의 경우 추가 요구사항 없음

    // 현재는 기본 정보만 확인 (너무 엄격하지 않게)
    bool isComplete = hasBasicInfo;

    print('=== 프로필 완성도 결과: $isComplete ===');

    return isComplete;
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
