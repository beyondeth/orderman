import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_model.dart';
import '../../controllers/auth/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('회원가입'),
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
              
              const SizedBox(height: AppConstants.largePadding * 2),
              
              // 역할 선택 섹션 추가
              _buildRoleSelection(context),
              
              const SizedBox(height: AppConstants.largePadding),
              
              // 회원가입 폼
              _buildRegisterForm(context),
              
              const SizedBox(height: AppConstants.largePadding),
              
              // 회원가입 버튼
              _buildRegisterButton(),
              
              const SizedBox(height: AppConstants.defaultPadding),
              
              // 구분선
              _buildDivider(),
              
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Google 회원가입 버튼
              _buildGoogleRegisterButton(),
              
              const SizedBox(height: AppConstants.largePadding),
              
              // 로그인 링크
              _buildLoginLink(),
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
          '새 계정 만들기',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: AppConstants.smallPadding),
        
        Text(
          '식자재 주문을 더 쉽고 빠르게',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegisterForm(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          // 이메일 입력
          TextFormField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: controller.validateEmail,
            decoration: const InputDecoration(
              labelText: '이메일',
              hintText: 'example@email.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          // 비밀번호 입력
          Obx(() => TextFormField(
            controller: controller.passwordController,
            obscureText: controller.obscurePassword.value,
            textInputAction: TextInputAction.next,
            validator: controller.validatePassword,
            decoration: InputDecoration(
              labelText: '비밀번호',
              hintText: '6자 이상 입력하세요',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscurePassword.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
            ),
          )),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          // 비밀번호 확인 입력
          Obx(() => TextFormField(
            controller: controller.confirmPasswordController,
            obscureText: controller.obscureConfirmPassword.value,
            textInputAction: TextInputAction.done,
            validator: controller.validateConfirmPassword,
            onFieldSubmitted: (_) => controller.registerWithEmail(),
            decoration: InputDecoration(
              labelText: '비밀번호 확인',
              hintText: '비밀번호를 다시 입력하세요',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscureConfirmPassword.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: controller.toggleConfirmPasswordVisibility,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Obx(() => ElevatedButton(
      onPressed: controller.isLoading.value ? null : controller.registerWithEmail,
      child: controller.isLoading.value
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text('회원가입'),
    ));
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
          child: Text(
            '또는',
            style: Get.textTheme.bodySmall?.copyWith(
              color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildGoogleRegisterButton() {
    return Obx(() => OutlinedButton.icon(
      onPressed: controller.isLoading.value ? null : controller.registerWithGoogle,
      icon: controller.isLoading.value
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.g_mobiledata, size: 24),
      label: const Text('Google로 회원가입'),
    ));
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '이미 계정이 있으신가요? ',
          style: Get.textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: controller.goToLogin,
          child: const Text('로그인'),
        ),
      ],
    );
  }

  // 역할 선택 위젯
  Widget _buildRoleSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '계정 유형을 선택해주세요',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        Obx(() => Row(
          children: [
            Expanded(
              child: _buildRoleCard(
                context,
                UserRole.buyer,
                '구매자',
                '식자재를 주문합니다',
                Icons.shopping_cart,
                controller.selectedRole.value == UserRole.buyer,
              ),
            ),
            const SizedBox(width: AppConstants.defaultPadding),
            Expanded(
              child: _buildRoleCard(
                context,
                UserRole.seller,
                '판매자',
                '식자재를 판매합니다',
                Icons.store,
                controller.selectedRole.value == UserRole.seller,
              ),
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    UserRole role,
    String title,
    String description,
    IconData icon,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => controller.selectRole(role),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor 
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected 
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected 
                  ? Theme.of(context).primaryColor 
                  : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Get.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Get.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
