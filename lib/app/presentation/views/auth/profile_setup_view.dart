import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../controllers/auth/profile_setup_controller.dart';

class ProfileSetupView extends GetView<ProfileSetupController> {
  const ProfileSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('프로필 설정'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppConstants.defaultPadding),
              
              // 헤더
              _buildHeader(context),
              
              const SizedBox(height: AppConstants.largePadding),
              
              // 선택된 역할 표시
              _buildRoleDisplay(context),
              
              const SizedBox(height: AppConstants.largePadding),
              
              // 프로필 폼
              _buildProfileForm(context),
              
              const SizedBox(height: AppConstants.largePadding * 2),
              
              // 완료 버튼
              _buildCompleteButton(),
              
              const SizedBox(height: AppConstants.defaultPadding),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          '프로필을 설정해주세요',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: AppConstants.smallPadding),
        
        Text(
          '서비스 이용을 위한 기본 정보를 입력해주세요',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRoleDisplay(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 24,
            ),
          ),
          
          const SizedBox(width: AppConstants.defaultPadding),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.roleDisplayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                
                const SizedBox(height: 2),
                
                Text(
                  controller.roleDescription,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          // 이름 입력 (필수)
          TextFormField(
            controller: controller.displayNameController,
            textInputAction: TextInputAction.next,
            validator: controller.validateDisplayName,
            decoration: const InputDecoration(
              labelText: '이름 *',
              hintText: '실명을 입력해주세요',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          // 전화번호 입력 (선택)
          TextFormField(
            controller: controller.phoneNumberController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            validator: controller.validatePhoneNumber,
            decoration: const InputDecoration(
              labelText: '전화번호',
              hintText: '010-1234-5678',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          // 사업장명 입력 (선택)
          TextFormField(
            controller: controller.businessNameController,
            textInputAction: TextInputAction.done,
            validator: controller.validateBusinessName,
            onFieldSubmitted: (_) => controller.completeSetup(),
            decoration: const InputDecoration(
              labelText: '사업장명',
              hintText: '사업장 이름을 입력해주세요',
              prefixIcon: Icon(Icons.business_outlined),
            ),
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          // 안내 텍스트
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                
                const SizedBox(width: AppConstants.smallPadding),
                
                Expanded(
                  child: Text(
                    '* 표시된 항목은 필수 입력 사항입니다.\n나머지 정보는 나중에 설정에서 변경할 수 있습니다.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteButton() {
    return Obx(() => ElevatedButton(
      onPressed: controller.isLoading.value ? null : controller.completeSetup,
      child: controller.isLoading.value
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text('완료'),
    ));
  }
}
