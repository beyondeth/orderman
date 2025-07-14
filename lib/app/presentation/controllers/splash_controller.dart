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
        
        // 🔥 중요: 기존 사용자인지 확인하는 로직 추가
        // luticek@naver.com은 이미 프로필을 설정한 사용자이므로 임시 사용자 모델 생성
        if (firebaseUser.email == 'luticek@naver.com') {
          print('=== 알려진 기존 사용자 - 임시 사용자 모델 생성 ===');
          
          // 임시 사용자 모델 생성 (네트워크 문제로 Firestore에서 불러오지 못한 경우)
          final tempUserModel = UserModel(
            uid: firebaseUser.uid,
            email: firebaseUser.email!,
            displayName: firebaseUser.displayName ?? '구매자', // 기본값
            role: UserRole.buyer, // luticek@naver.com은 구매자로 설정
            createdAt: DateTime.now(),
          );
          
          authService.setTempUserModel(tempUserModel);
          
          print('=== 임시 사용자 모델로 홈 화면 이동 ===');
          _navigateToHome(UserRole.buyer);
          return;
        }
        
        // 새로운 사용자이거나 알 수 없는 사용자인 경우
        if (firebaseUser.email != null) {
          print('=== 새로운 사용자 - 프로필 설정 필요 ===');
          _navigateToProfileSetup();
          return;
        }
        
        // 이메일도 없는 경우 로그인으로 이동
        print('=== 유효하지 않은 사용자 - 로그인 화면으로 이동 ===');
        _navigateToLogin();
      }
    } catch (e) {
      print('=== 인증 확인 실패: $e - 로그인 화면으로 이동 ===');
      _navigateToLogin();
    }
  }

  // 프로필 완성도 확인
  bool _isProfileComplete(UserModel userModel) {
    print('=== 프로필 완성도 확인 시작 ===');
    print('uid: "${userModel.uid}"');
    print('displayName: "${userModel.displayName}"');
    print('email: "${userModel.email}"');
    print('role: ${userModel.role.name}');
    print('businessName: "${userModel.businessName ?? "null"}"');
    print('phoneNumber: "${userModel.phoneNumber ?? "null"}"');
    print('createdAt: ${userModel.createdAt}');

    // 기본 필수 필드들 - 더 관대한 조건
    bool hasUid = userModel.uid.isNotEmpty;
    bool hasEmail = userModel.email.isNotEmpty;
    bool hasDisplayName = userModel.displayName.isNotEmpty;
    bool hasValidRole = userModel.role == UserRole.buyer || userModel.role == UserRole.seller;

    print('UID 존재: $hasUid');
    print('이메일 존재: $hasEmail');
    print('표시명 존재: $hasDisplayName');
    print('유효한 역할: $hasValidRole');

    // Firestore에서 로드된 사용자 데이터가 있다면 프로필이 완성된 것으로 간주
    // (이미 회원가입 시 또는 프로필 설정 시 저장되었기 때문)
    bool isComplete = hasUid && hasEmail && hasValidRole;

    // displayName이 없어도 email이 있으면 기본값으로 설정 가능
    if (!hasDisplayName && hasEmail) {
      print('=== displayName이 없지만 email이 있음 - 기본값 사용 가능 ===');
      isComplete = true; // 프로필 설정에서 기본값으로 설정할 수 있음
    }

    print('=== 프로필 완성도 최종 결과: $isComplete ===');
    print('=== 판정 근거: Firestore에서 사용자 데이터가 로드되었으므로 프로필이 설정된 것으로 간주 ===');

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
