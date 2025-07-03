import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';

class ProfileSetupController extends GetxController {
  final AuthService _authService = AuthService.instance;

  // Form controllers
  final displayNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final businessNameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Reactive variables
  final RxBool isLoading = false.obs;
  late final UserRole selectedRole;

  @override
  void onInit() {
    super.onInit();

    // Get role from arguments
    final arguments = Get.arguments as Map<String, dynamic>?;
    selectedRole = arguments?['role'] ?? UserRole.buyer;

    // Pre-fill existing data if available
    _prefillExistingData();
  }

  void _prefillExistingData() {
    // Firebase Auth에서 displayName 가져오기
    if (_authService.firebaseUser?.displayName != null) {
      displayNameController.text = _authService.firebaseUser!.displayName!;
    }

    // 기존 UserModel에서 데이터 가져오기
    final userModel = _authService.userModel;
    if (userModel != null) {
      print('=== 기존 프로필 데이터로 미리 채우기 ===');
      
      if (userModel.displayName.isNotEmpty) {
        displayNameController.text = userModel.displayName;
      }
      
      if (userModel.phoneNumber?.isNotEmpty == true) {
        phoneNumberController.text = userModel.phoneNumber!;
      }
      
      if (userModel.businessName?.isNotEmpty == true) {
        businessNameController.text = userModel.businessName!;
      }
      
      print('displayName: ${displayNameController.text}');
      print('phoneNumber: ${phoneNumberController.text}');
      print('businessName: ${businessNameController.text}');
    }
  }

  @override
  void onClose() {
    displayNameController.dispose();
    phoneNumberController.dispose();
    businessNameController.dispose();
    super.onClose();
  }

  // Display name validation
  String? validateDisplayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '이름을 입력해주세요.';
    }
    if (value.trim().length < 2) {
      return '이름은 2자 이상이어야 합니다.';
    }
    return null;
  }

  // Phone number validation
  String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length < 10 || digitsOnly.length > 11) {
      return '올바른 전화번호를 입력해주세요.';
    }
    return null;
  }

  // Business name validation
  String? validateBusinessName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    if (value.trim().length < 2) {
      return '사업장명은 2자 이상이어야 합니다.';
    }
    return null;
  }

  // Complete profile setup
  Future<void> completeSetup() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final success = await _authService.createUserProfile(
        displayName: displayNameController.text.trim(),
        role: selectedRole,
        phoneNumber:
            phoneNumberController.text.trim().isEmpty
                ? null
                : phoneNumberController.text.trim(),
        businessName:
            businessNameController.text.trim().isEmpty
                ? null
                : businessNameController.text.trim(),
      );

      if (success != null) {
        // 프로필 생성 성공 후 역할에 따라 홈으로 이동
        _navigateToHome();
      }
    } catch (e) {
      Get.log('Profile setup failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Navigate to home based on role
  void _navigateToHome() {
    switch (selectedRole) {
      case UserRole.buyer:
        Get.offAllNamed(AppRoutes.buyerHome);
        break;
      case UserRole.seller:
        Get.offAllNamed(AppRoutes.sellerHome);
        break;
    }
  }

  // Get role display name
  String get roleDisplayName {
    switch (selectedRole) {
      case UserRole.buyer:
        return '구매자';
      case UserRole.seller:
        return '판매자';
    }
  }

  // Get role description
  String get roleDescription {
    switch (selectedRole) {
      case UserRole.buyer:
        return '식자재를 주문하는 사업자';
      case UserRole.seller:
        return '식자재를 판매하는 사업자';
    }
  }
}
