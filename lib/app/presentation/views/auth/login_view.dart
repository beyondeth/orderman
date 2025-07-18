import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../controllers/auth/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppConstants.largePadding * 2),

              // 로고 및 타이틀
              _buildHeader(context),

              const SizedBox(height: AppConstants.largePadding * 2),

              // 로그인 폼
              _buildLoginForm(context),

              const SizedBox(height: AppConstants.largePadding),

              // 로그인 버튼
              _buildLoginButton(),

              const SizedBox(height: AppConstants.defaultPadding),

              // 구분선
              _buildDivider(),

              const SizedBox(height: AppConstants.defaultPadding),

              // Google 로그인 버튼
              _buildGoogleLoginButton(),

              const SizedBox(height: AppConstants.largePadding),

              // 회원가입 링크
              _buildRegisterLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.shopping_cart, size: 40, color: Colors.white),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        Text(
          '로그인',
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: AppConstants.smallPadding),

        Text(
          '식자재 주문 마켓에 오신 것을 환영합니다',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
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
          Obx(
            () => TextFormField(
              controller: controller.passwordController,
              obscureText: controller.obscurePassword.value,
              textInputAction: TextInputAction.done,
              validator: controller.validatePassword,
              onFieldSubmitted: (_) => controller.loginWithEmail(),
              decoration: InputDecoration(
                labelText: '비밀번호',
                hintText: '비밀번호를 입력하세요',
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return Obx(
      () => ElevatedButton(
        onPressed: controller.isLoading.value ? null : () {
          // 버튼 클릭 시 즉시 시각적 피드백 제공
          FocusScope.of(Get.context!).unfocus(); // 키보드 닫기
          controller.loginWithEmail();
        },
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: Theme.of(Get.context!).colorScheme.primary.withOpacity(0.6),
          disabledForegroundColor: Colors.white70,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child:
            controller.isLoading.value
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Text('로그인', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
          ),
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

  Widget _buildGoogleLoginButton() {
    return Obx(
      () => OutlinedButton.icon(
        onPressed: controller.isLoading.value ? null : () {
          FocusScope.of(Get.context!).unfocus(); // 키보드 닫기
          controller.loginWithGoogle();
        },
        style: OutlinedButton.styleFrom(
          disabledBackgroundColor: Colors.grey.withOpacity(0.1),
          disabledForegroundColor: Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        icon:
            controller.isLoading.value
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Icon(Icons.g_mobiledata, size: 24),
        label: const Text('Google로 로그인', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('계정이 없으신가요? ', style: Get.textTheme.bodyMedium),
        TextButton(
          onPressed: controller.goToRegister,
          child: const Text('회원가입'),
        ),
      ],
    );
  }
}
