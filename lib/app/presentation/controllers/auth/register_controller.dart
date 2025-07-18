import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../routes/app_routes.dart';
import '../../../data/models/user_model.dart'; // UserRole을 위한 import 추가

class RegisterController extends GetxController {
  // GetX 의존성 주입 사용
  AuthService get _authService => Get.find<AuthService>();

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Reactive variables
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final Rx<UserRole> selectedRole = UserRole.buyer.obs; // 역할 선택 추가

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // 역할 선택
  void selectRole(UserRole role) {
    selectedRole.value = role;
    print('=== RegisterController: Selected role: ${role.name} ===');
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
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
    if (value.length < 6) {
      return '비밀번호는 6자 이상이어야 합니다.';
    }
    return null;
  }

  // Confirm password validation
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호 확인을 입력해주세요.';
    }
    if (value != passwordController.text) {
      return '비밀번호가 일치하지 않습니다.';
    }
    return null;
  }

  // Email register
  Future<void> registerWithEmail() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final userModel = await _authService.signUpWithEmail(
        emailController.text.trim(),
        passwordController.text,
        role: selectedRole.value,
      );

      if (userModel != null) {
        print('=== Registration successful ===');

        // 회원가입 성공 후 프로필 완성도를 확인하여 프로필 설정 화면으로 이동
        // AuthService의 _isProfileComplete 로직을 재사용하거나 유사한 로직을 여기에 구현
        // 현재는 SplashController의 로직을 따르기 위해 ProfileSetup으로 이동
        Get.offAllNamed(AppRoutes.profileSetup, arguments: {'role': userModel.role});

        Get.snackbar(
          '회원가입 성공',
          '환영합니다! ${userModel.displayName}님',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('=== Email register failed: $e ===');
      Get.snackbar(
        '회원가입 실패',
        '회원가입 중 오류가 발생했습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Google register
  Future<void> registerWithGoogle() async {
    isLoading.value = true;

    try {
      final userModel = await _authService.signInWithGoogle();

      if (userModel != null) {
        // Google 로그인 성공 후 프로필이 완성되어 있으면 홈으로, 아니면 역할 선택으로
        if (userModel.displayName.isNotEmpty) {
          if (userModel.role == UserRole.buyer) {
            Get.offAllNamed(AppRoutes.buyerHome);
          } else {
            Get.offAllNamed(AppRoutes.sellerHome);
          }
        } else {
          Get.offAllNamed(AppRoutes.roleSelection);
        }
      }
    } catch (e) {
      print('=== Google register failed: $e ===');
    } finally {
      isLoading.value = false;
    }
  }

  // Navigate back to login
  void goToLogin() {
    Get.back();
  }
}
