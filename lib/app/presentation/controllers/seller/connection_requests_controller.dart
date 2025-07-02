import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/connection_service.dart';
import '../../../data/models/connection_model.dart';

class ConnectionRequestsController extends GetxController {
  // Services
  AuthService get _authService => Get.find<AuthService>();
  ConnectionService get _connectionService => Get.find<ConnectionService>();

  // Reactive variables
  final RxBool isLoading = false.obs;
  final RxList<ConnectionModel> connectionRequests = <ConnectionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadConnectionRequests();
  }

  // 연결 요청 목록 로드
  void _loadConnectionRequests() {
    final currentUser = _authService.userModel;
    if (currentUser == null) return;

    isLoading.value = true;

    _connectionService.getConnectionRequests(currentUser.uid).listen(
      (requests) {
        connectionRequests.value = requests;
        isLoading.value = false;
        print('=== Loaded ${requests.length} connection requests ===');
      },
      onError: (error) {
        print('=== Error loading connection requests: $error ===');
        isLoading.value = false;
        Get.snackbar('오류', '연결 요청 목록을 불러오는데 실패했습니다.');
      },
    );
  }

  // 연결 요청 승인
  Future<void> approveRequest(String connectionId) async {
    try {
      final success = await _connectionService.approveConnection(connectionId);
      if (success) {
        // 목록에서 해당 요청 제거 (승인되면 pending 목록에서 사라짐)
        connectionRequests.removeWhere((request) => request.id == connectionId);
      }
    } catch (e) {
      print('=== Error approving connection: $e ===');
      Get.snackbar('오류', '연결 승인 중 오류가 발생했습니다.');
    }
  }

  // 연결 요청 거절
  Future<void> rejectRequest(String connectionId) async {
    try {
      final success = await _connectionService.rejectConnection(connectionId);
      if (success) {
        // 목록에서 해당 요청 제거 (거절되면 pending 목록에서 사라짐)
        connectionRequests.removeWhere((request) => request.id == connectionId);
      }
    } catch (e) {
      print('=== Error rejecting connection: $e ===');
      Get.snackbar('오류', '연결 거절 중 오류가 발생했습니다.');
    }
  }

  // 목록 새로고침
  Future<void> refreshRequests() async {
    _loadConnectionRequests();
  }
}
