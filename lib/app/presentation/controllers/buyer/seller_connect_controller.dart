import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/connection_service.dart';
import '../../../data/models/connection_model.dart';
import '../../../routes/app_routes.dart';

class SellerConnectController extends GetxController {
  // Services
  AuthService get _authService => Get.find<AuthService>();
  ConnectionService get _connectionService => Get.find<ConnectionService>();

  // Form controllers
  final emailController = TextEditingController();

  // Reactive variables
  final RxBool isLoading = false.obs;
  final RxBool isLoadingConnections = false.obs;
  final RxList<ConnectionModel> connectedSellers = <ConnectionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadConnectedSellers();
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  // 연결된 판매자 목록 로드
  void _loadConnectedSellers() {
    final currentUser = _authService.userModel;
    if (currentUser == null) return;

    isLoadingConnections.value = true;

    _connectionService.getApprovedConnections(currentUser.uid).listen(
      (connections) {
        connectedSellers.value = connections;
        isLoadingConnections.value = false;
      },
      onError: (error) {
        print('=== Error loading connections: $error ===');
        isLoadingConnections.value = false;
        Get.snackbar('오류', '연결된 판매자 목록을 불러오는데 실패했습니다.');
      },
    );
  }

  // 연결 요청 보내기
  Future<void> sendConnectionRequest() async {
    final email = emailController.text.trim();
    
    if (email.isEmpty) {
      Get.snackbar('입력 오류', '판매자 이메일을 입력해주세요.');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar('입력 오류', '올바른 이메일 형식을 입력해주세요.');
      return;
    }

    final currentUser = _authService.userModel;
    if (currentUser == null) {
      Get.snackbar('오류', '로그인이 필요합니다.');
      return;
    }

    isLoading.value = true;

    try {
      final success = await _connectionService.requestConnection(
        currentUser.email,
        email,
      );

      if (success) {
        emailController.clear();
        // 연결 목록 새로고침
        _loadConnectedSellers();
      }
    } catch (e) {
      print('=== Connection request error: $e ===');
      Get.snackbar('오류', '연결 요청 중 오류가 발생했습니다.');
    } finally {
      isLoading.value = false;
    }
  }

  // 주문 화면으로 이동
  void goToOrder(ConnectionModel connection) {
    Get.toNamed(
      AppRoutes.orderCreate,
      arguments: {
        'connection': connection,
        'sellerId': connection.sellerId,
      },
    );
  }

  // 연결 목록 새로고침
  Future<void> refreshConnections() async {
    _loadConnectedSellers();
  }
}
