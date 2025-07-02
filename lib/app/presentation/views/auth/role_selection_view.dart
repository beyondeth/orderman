import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_model.dart';
import '../../controllers/auth/role_selection_controller.dart';

class RoleSelectionView extends GetView<RoleSelectionController> {
  const RoleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppConstants.largePadding),
              
              // 헤더
              _buildHeader(context),
              
              const SizedBox(height: AppConstants.largePadding * 2),
              
              // 역할 선택 카드들
              Expanded(
                child: Column(
                  children: [
                    _buildRoleCard(
                      context,
                      UserRole.buyer,
                      '구매자',
                      controller.getRoleDescription(UserRole.buyer),
                      controller.getRoleIcon(UserRole.buyer),
                    ),
                    
                    const SizedBox(height: AppConstants.defaultPadding),
                    
                    _buildRoleCard(
                      context,
                      UserRole.seller,
                      '판매자',
                      controller.getRoleDescription(UserRole.seller),
                      controller.getRoleIcon(UserRole.seller),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppConstants.largePadding),
              
              // 계속하기 버튼
              _buildContinueButton(),
              
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
          '역할을 선택해주세요',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: AppConstants.smallPadding),
        
        Text(
          '선택한 역할에 따라 맞춤형 기능을 제공합니다',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    UserRole role,
    String title,
    String description,
    String icon,
  ) {
    return Obx(() => GestureDetector(
      onTap: () => controller.selectRole(role),
      child: AnimatedContainer(
        duration: AppConstants.shortAnimation,
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: controller.selectedRole.value == role
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: controller.selectedRole.value == role
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: controller.selectedRole.value == role ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // 아이콘
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: controller.selectedRole.value == role
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // 제목
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: controller.selectedRole.value == role
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
            ),
            
            const SizedBox(height: AppConstants.smallPadding),
            
            // 설명
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            
            // 선택 표시
            if (controller.selectedRole.value == role) ...[
              const SizedBox(height: AppConstants.defaultPadding),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                  vertical: AppConstants.smallPadding,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '선택됨',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ));
  }

  Widget _buildContinueButton() {
    return Obx(() => ElevatedButton(
      onPressed: controller.selectedRole.value != null
          ? controller.continueToProfileSetup
          : null,
      child: const Text('계속하기'),
    ));
  }
}
