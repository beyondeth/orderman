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

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
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

  // Email login
  Future<void> loginWithEmail() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      if (Get.isRegistered<AuthService>()) {
        final authService = Get.find<AuthService>();
        
        final userCredential = await authService.signInWithEmail(
          emailController.text.trim(),
          passwordController.text,
        );

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
      Get.log('Email login failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Google login
  Future<void> loginWithGoogle() async {
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
