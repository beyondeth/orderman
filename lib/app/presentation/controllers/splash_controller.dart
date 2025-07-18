import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../firebase_options.dart';
import '../../routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/env_service.dart';
import '../../data/models/user_model.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/connection_service.dart';
import '../../core/services/product_service.dart';
import '../../core/services/order_service.dart';
import '../../core/state/global_state_controller.dart';

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
    print('=== 데이터 로딩 및 서비스 초기화 시작 ===');

    try {
      // 최소 스플래시 시간과 서비스 초기화를 동시에 진행
      final future1 = Future.delayed(const Duration(seconds: 2));
      final future2 = _initializeServices();

      // 두 작업이 모두 끝날 때까지 대기
      await Future.wait([future1, future2]);

      print('=== 데이터 로딩 및 서비스 초기화 완료 ===');
      changeStep(SplashStep.authCheck);
    } catch (e) {
      print('=== 데이터 로딩 또는 서비스 초기화 실패: $e ===');
      // 실패 시에도 다음 단계로 넘어가서 인증 상태에 따라 처리
      changeStep(SplashStep.authCheck);
    }
  }

  // 서비스 초기화 로직을 별도 메서드로 분리
  Future<void> _initializeServices() async {
    try {
      // 환경변수 초기화
      await EnvService.initialize();
      print('=== ✅ 환경변수 초기화 완료 ===');
      
      // 환경 정보 출력 (디버그 모드에서만)
      EnvService.printEnvironmentInfo();
      
      // Firebase 초기화
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('=== ✅ Firebase 초기화 성공 ===');

      // Firebase 초기화 후 서비스 종속성 주입
      print('=== 서비스 종속성 주입 시작 ===');
      Get.put(FirebaseService(), permanent: true);
      Get.put(AuthService(), permanent: true);
      Get.put(ConnectionService(), permanent: true);
      Get.put(ProductService(), permanent: true);
      Get.put(OrderService(), permanent: true);
      Get.put(GlobalStateController(), permanent: true);
      print('=== ✅ 모든 서비스 등록 완료 ===');
    } catch (e, stackTrace) {
      print('=== ❌ 서비스 초기화 오류: $e ===');
      print('=== Stack trace: $stackTrace ===');
      // 오류를 다시 던져서 _loadData에서 잡도록 함
      rethrow;
    }
  }

  void _checkAuthentication() async {
    print('=== 인증 상태 확인 시작 ===');

    if (!Get.isRegistered<AuthService>()) {
      print('=== AuthService가 등록되지 않음 - 로그인 화면으로 이동 ===');
      _navigateToLogin();
      return;
    }

    final authService = Get.find<AuthService>();

    // AuthService의 인증 확인이 완료될 때까지 기다립니다.
    ever(authService.isAuthCheckComplete, (bool isComplete) {
      if (isComplete) {
        print('=== SplashController: AuthService 인증 확인 완료 감지 ===');
        _performNavigationBasedOnAuthState(authService);
        // 화면 전환 후 리스너를 제거하여 중복 호출 방지
        // ever 리스너는 자동으로 제거되지 않으므로 수동으로 관리해야 합니다.
        // 하지만 여기서는 Get.offAllNamed를 사용하므로 컨트롤러가 파괴되어 괜찮을 수 있습니다.
        // 더 안전한 처리를 위해선 Worker를 사용하고 dispose하는 것이 좋습니다.
      }
    });

    // 초기 상태 확인: 만약 이미 인증 확인이 끝난 상태라면 바로 처리
    if (authService.isAuthCheckComplete.value) {
       print('=== SplashController: AuthService 인증이 이미 완료된 상태 ===');
       _performNavigationBasedOnAuthState(authService);
    }
  }

  // 인증 상태에 따라 화면을 전환하는 로직을 별도 메서드로 분리
  void _performNavigationBasedOnAuthState(AuthService authService) {
    final userState = authService.userStateRx.value;
    print('=== 현재 사용자 상태: ${userState.runtimeType} ===');

    if (userState is UserLoaded) {
      if (_isProfileComplete(userState.user)) {
        print('=== 프로필 완료 - 홈 화면으로 이동 ===');
        _navigateToHome(userState.user.role);
      } else {
        print('=== 프로필 불완전 - 프로필 설정으로 이동 ===');
        _navigateToProfileSetup();
      }
    } else if (userState is UserNew) {
      print('=== 새로운 사용자 - 프로필 설정 필요 ===');
      _navigateToProfileSetup();
    } else if (userState is UserError) {
      print('=== 사용자 데이터 로드 오류: ${userState.message} ===');
      Get.snackbar(
        '데이터 로드 오류',
        (userState as UserError).message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
      // 네트워크 오류 시에도 홈으로 보내는 것이 목표
      _navigateToHome(UserRole.buyer); 
    } else { // UserInitial 또는 기타 상태
      print('=== 사용자 로그인되지 않음 - 로그인 화면으로 이동 ===');
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

    // 기본 필수 필드들
    bool hasUid = userModel.uid.isNotEmpty;
    bool hasEmail = userModel.email.isNotEmpty;
    bool hasDisplayName = userModel.displayName.isNotEmpty;
    bool hasValidRole = userModel.role == UserRole.buyer || userModel.role == UserRole.seller;

    print('UID 존재: $hasUid');
    print('이메일 존재: $hasEmail');
    print('표시명 존재: $hasDisplayName');
    print('유효한 역할: $hasValidRole');

    bool isComplete = hasUid && hasEmail && hasDisplayName && hasValidRole;

    // 판매자의 경우 businessName도 필수
    if (userModel.role == UserRole.seller) {
      bool hasBusinessName = userModel.businessName != null && userModel.businessName!.isNotEmpty;
      print('판매자: 사업자명 존재: $hasBusinessName');
      isComplete = isComplete && hasBusinessName;
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