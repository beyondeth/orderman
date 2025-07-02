import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../data/models/user_model.dart';

class ProfileController extends GetxController {
  // Services
  AuthService get _authService => Get.find<AuthService>();

  // Form controllers
  final displayNameController = TextEditingController();
  final businessNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final addressController = TextEditingController();

  // Reactive variables
  final RxBool isEditing = false.obs;
  final RxBool isLoading = false.obs;

  // Getters
  UserModel? get currentUser => _authService.userModel;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  @override
  void onClose() {
    displayNameController.dispose();
    businessNameController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    super.onClose();
  }

  // 사용자 데이터 로드
  void _loadUserData() {
    final user = currentUser;
    if (user != null) {
      displayNameController.text = user.displayName;
      businessNameController.text = user.businessName ?? '';
      phoneNumberController.text = user.phoneNumber ?? '';
      addressController.text = user.address ?? '';
    }
  }

  // 수정 모드 토글
  void toggleEditMode() {
    if (isEditing.value) {
      // 수정 취소 - 원래 데이터로 복원
      _loadUserData();
    }
    isEditing.value = !isEditing.value;
  }

  // 프로필 저장
  Future<void> saveProfile() async {
    if (!isEditing.value) return;

    // 유효성 검사
    if (displayNameController.text.trim().isEmpty) {
      Get.snackbar('오류', '이름을 입력해주세요.');
      return;
    }

    if (businessNameController.text.trim().isEmpty) {
      Get.snackbar('오류', '사업체명을 입력해주세요.');
      return;
    }

    isLoading.value = true;

    try {
      final success = await _authService.updateUserProfile(
        displayName: displayNameController.text.trim(),
        businessName: businessNameController.text.trim(),
        phoneNumber: phoneNumberController.text.trim(),
        address: addressController.text.trim(),
      );

      if (success) {
        isEditing.value = false;
        Get.snackbar('성공', '프로필이 업데이트되었습니다.');
      } else {
        Get.snackbar('오류', '프로필 업데이트에 실패했습니다.');
      }
    } catch (e) {
      print('=== Profile save error: $e ===');
      Get.snackbar('오류', '프로필 저장 중 오류가 발생했습니다.');
    } finally {
      isLoading.value = false;
    }
  }

  // 프로필 새로고침
  Future<void> refreshProfile() async {
    final user = currentUser;
    if (user != null) {
      await _authService.loadUserData(user.uid);
      _loadUserData();
    }
  }
}
