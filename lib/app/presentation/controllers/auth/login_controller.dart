import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';

class LoginController extends GetxController {
  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Reactive variables
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  
  // 디바운스 타이머
  Timer? _loginDebounce;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    _loginDebounce?.cancel();
    super.onClose();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // Email validation
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요.';
    }
    if (!GetUtils.isEmail(value)) {
      return '올바른 이메일 형식을 입력해주세요.';
    }
    return null;
  }

  // Password validation
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요.';
    }
    return null;
  }

  // Email login with debounce
  void loginWithEmail() {
    // 이미 로딩 중이면 중복 호출 방지
    if (isLoading.value) return;
    
    // 폼 검증
    if (!formKey.currentState!.validate()) return;
    
    // 디바운스 처리
    _loginDebounce?.cancel();
    _loginDebounce = Timer(const Duration(milliseconds: 300), () {
      _performLogin();
    });
  }
  
  // 실제 로그인 수행
  Future<void> _performLogin() async {
    isLoading.value = true;
    print('=== 로그인 시작: ${emailController.text.trim()} ===');

    try {
      if (Get.isRegistered<AuthService>()) {
        final authService = Get.find<AuthService>();
        
        final userCredential = await authService.signInWithEmail(
          emailController.text.trim(),
          passwordController.text,
        );

        if (userCredential != null) {
          print('=== 로그인 성공: ${userCredential.displayName} ===');
          _navigateToHome(userCredential);
        } else {
          print('=== 로그인 실패: 사용자 정보 없음 ===');
        }
      } else {
        print('=== 로그인 실패: AuthService 미등록 ===');
        Get.snackbar(
          '서비스 오류',
          'AuthService가 초기화되지 않았습니다.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('=== 로그인 오류: $e ===');
      Get.log('Email login failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Google login with debounce
  void loginWithGoogle() {
    // 이미 로딩 중이면 중복 호출 방지
    if (isLoading.value) return;
    
    // 디바운스 처리
    _loginDebounce?.cancel();
    _loginDebounce = Timer(const Duration(milliseconds: 300), () {
      _performGoogleLogin();
    });
  }
  
  // 실제 Google 로그인 수행
  Future<void> _performGoogleLogin() async {
    isLoading.value = true;

    try {
      if (Get.isRegistered<AuthService>()) {
        final authService = Get.find<AuthService>();
        
        final userCredential = await authService.signInWithGoogle();

        if (userCredential != null) {
          _navigateToHome(userCredential);
        }
      } else {
        Get.snackbar(
          '서비스 오류',
          'AuthService가 초기화되지 않았습니다.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.log('Google login failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Navigate to appropriate home screen based on user role
  void _navigateToHome(UserModel user) {
    // 모든 사용자를 MainView로 이동 (역할에 관계없이)
    Get.offAllNamed(AppRoutes.main);
  }

  // Navigate to register
  void goToRegister() {
    Get.toNamed(AppRoutes.register);
  }

  // Navigate to forgot password (placeholder)
  void goToForgotPassword() {
    Get.snackbar(
      '기능 준비 중',
      '비밀번호 찾기 기능은 준비 중입니다.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
