import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/toss_design_system.dart';
import '../../controllers/buyer/seller_connect_controller.dart';

class SellerConnectView extends GetView<SellerConnectController> {
  const SellerConnectView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TossDesignSystem.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 제목 추가
          Text(
            '판매자 연결',
            style: TossDesignSystem.heading3,
          ),
          const SizedBox(height: TossDesignSystem.spacing20),
          // 연결 요청 섹션
          _buildConnectionRequestSection(context),

          const SizedBox(height: TossDesignSystem.spacing32),

          // 연결된 판매자 목록
          _buildConnectedSellersSection(context),
        ],
      ),
    );
  }

  Widget _buildConnectionRequestSection(BuildContext context) {
    return TossWidgets.card(
      padding: const EdgeInsets.all(TossDesignSystem.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.link, color: TossDesignSystem.primary),
              const SizedBox(width: TossDesignSystem.spacing8),
              Text(
                '새 판매자 연결',
                style: TossDesignSystem.heading4,
              ),
            ],
          ),

          const SizedBox(height: TossDesignSystem.spacing16),

          Text(
            '연결하고 싶은 판매자의 이메일을 입력해주세요.',
            style: TossDesignSystem.body2.copyWith(color: TossDesignSystem.textSecondary),
          ),

          const SizedBox(height: TossDesignSystem.spacing16),

          // 이메일 입력 필드
          TextField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: TossDesignSystem.inputDecoration(
              labelText: '판매자 이메일',
              hintText: 'seller@example.com',
              prefixIcon: const Icon(Icons.email, color: TossDesignSystem.textSecondary),
            ),
          ),

          const SizedBox(height: TossDesignSystem.spacing16),

          // 연결 요청 버튼
          Obx(
            () => SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    controller.isLoading.value
                        ? null
                        : controller.sendConnectionRequest,
                icon:
                    controller.isLoading.value
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                        : const Icon(Icons.send),
                label: Text(
                  controller.isLoading.value ? '전송 중...' : '연결 요청 보내기',
                ),
                style: TossDesignSystem.primaryButton,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedSellersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.people, color: TossDesignSystem.primary),
            const SizedBox(width: TossDesignSystem.spacing8),
            Text(
              '연결된 판매자',
              style: TossDesignSystem.heading4,
            ),
          ],
        ),

        const SizedBox(height: TossDesignSystem.spacing16),

        Obx(() {
          if (controller.isLoadingConnections.value) {
            return const Center(child: CircularProgressIndicator(color: TossDesignSystem.primary));
          }

          if (controller.connectedSellers.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.connectedSellers.length,
            separatorBuilder: (context, index) => const SizedBox(height: TossDesignSystem.spacing12),
            itemBuilder: (context, index) {
              final connection = controller.connectedSellers[index];
              return _buildSellerCard(context, connection);
            },
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return TossWidgets.card(
      padding: const EdgeInsets.all(TossDesignSystem.spacing24),
      child: Column(
        children: [
          Icon(Icons.store_outlined, size: 64, color: TossDesignSystem.gray400),
          const SizedBox(height: TossDesignSystem.spacing16),
          Text(
            '연결된 판매자가 없습니다',
            style: TossDesignSystem.heading4.copyWith(color: TossDesignSystem.textSecondary),
          ),
          const SizedBox(height: TossDesignSystem.spacing8),
          Text(
            '위에서 판매자 이메일을 입력하여\n연결 요청을 보내보세요.',
            textAlign: TextAlign.center,
            style: TossDesignSystem.body2.copyWith(color: TossDesignSystem.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerCard(BuildContext context, connection) {
    return TossWidgets.card(
      padding: const EdgeInsets.all(TossDesignSystem.spacing16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: TossDesignSystem.primary.withOpacity(0.1),
          child: const Icon(Icons.store, color: TossDesignSystem.primary),
        ),
        title: Text(
          connection.sellerName,
          style: TossDesignSystem.body1.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(connection.sellerEmail ?? '', style: TossDesignSystem.caption),
            const SizedBox(height: TossDesignSystem.spacing4),
            TossWidgets.badge(text: '연결됨', backgroundColor: TossDesignSystem.success.withOpacity(0.1), textColor: TossDesignSystem.success),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => controller.goToOrder(connection),
          style: TossDesignSystem.primaryButton.copyWith(
            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: TossDesignSystem.spacing12, vertical: TossDesignSystem.spacing8)),
          ),
          child: const Text('주문하기'),
        ),
        isThreeLine: true,
      ),
    );
  }
}