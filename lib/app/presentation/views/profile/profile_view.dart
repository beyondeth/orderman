import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../controllers/profile/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('프로필'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: controller.toggleEditMode,
            child: Obx(() => Text(
              controller.isEditing.value ? '취소' : '수정',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 헤더
            _buildProfileHeader(context),
            
            const SizedBox(height: AppConstants.largePadding),
            
            // 프로필 정보 폼
            _buildProfileForm(context),
            
            const SizedBox(height: AppConstants.largePadding),
            
            // 저장 버튼 (수정 모드일 때만)
            Obx(() {
              if (controller.isEditing.value) {
                return _buildSaveButton(context);
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text(
                    controller.currentUser?.displayName ?? '사용자',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                  const SizedBox(height: 4),
                  Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      controller.currentUser?.role.name == 'buyer' ? '구매자' : '판매자',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                    controller.currentUser?.email ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileForm(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '기본 정보',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // 이름
            _buildFormField(
              context,
              '이름',
              controller.displayNameController,
              Icons.person,
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // 사업체명
            _buildFormField(
              context,
              '사업체명',
              controller.businessNameController,
              Icons.business,
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // 전화번호
            _buildFormField(
              context,
              '전화번호',
              controller.phoneNumberController,
              Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // 주소
            _buildFormField(
              context,
              '주소',
              controller.addressController,
              Icons.location_on,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(
    BuildContext context,
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => TextField(
          controller: controller,
          enabled: this.controller.isEditing.value,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: this.controller.isEditing.value 
                ? Colors.white 
                : Colors.grey[100],
          ),
        )),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => ElevatedButton.icon(
        onPressed: controller.isLoading.value 
            ? null 
            : controller.saveProfile,
        icon: controller.isLoading.value
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save),
        label: Text(
          controller.isLoading.value ? '저장 중...' : '저장',
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      )),
    );
  }
}
