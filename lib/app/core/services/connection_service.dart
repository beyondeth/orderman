import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../data/models/connection_model.dart';

class ConnectionService extends GetxService {
  static ConnectionService get instance => Get.find<ConnectionService>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 연결 요청 생성 (구매자가 판매자에게)
  Future<bool> requestConnection(String buyerEmail, String sellerEmail) async {
    try {
      print('=== Connection request: $buyerEmail -> $sellerEmail ===');

      // 1. 판매자 이메일로 사용자 찾기
      final sellerQuery =
          await _firestore
              .collection('users')
              .where('email', isEqualTo: sellerEmail)
              .where('role', isEqualTo: 'seller')
              .get();

      if (sellerQuery.docs.isEmpty) {
        Get.snackbar('오류', '해당 이메일의 판매자를 찾을 수 없습니다.');
        return false;
      }

      final sellerDoc = sellerQuery.docs.first;
      final sellerId = sellerDoc.id;

      // 2. 구매자 정보 가져오기
      final buyerQuery =
          await _firestore
              .collection('users')
              .where('email', isEqualTo: buyerEmail)
              .where('role', isEqualTo: 'buyer')
              .get();

      if (buyerQuery.docs.isEmpty) {
        Get.snackbar('오류', '구매자 정보를 찾을 수 없습니다.');
        return false;
      }

      final buyerDoc = buyerQuery.docs.first;
      final buyerId = buyerDoc.id;

      // 3. 이미 연결 요청이 있는지 확인
      final existingConnection =
          await _firestore
              .collection('connections')
              .where('buyerId', isEqualTo: buyerId)
              .where('sellerId', isEqualTo: sellerId)
              .get();

      if (existingConnection.docs.isNotEmpty) {
        final status = existingConnection.docs.first.data()['status'];
        if (status == 'pending') {
          Get.snackbar('알림', '이미 연결 요청이 진행 중입니다.');
        } else if (status == 'approved') {
          Get.snackbar('알림', '이미 연결된 판매자입니다.');
        }
        return false;
      }

      // 4. 연결 요청 생성
      final connectionData = {
        'buyerId': buyerId,
        'sellerId': sellerId,
        'buyerEmail': buyerEmail,
        'sellerEmail': sellerEmail,
        'buyerName': buyerDoc.data()['displayName'] ?? '구매자',
        'sellerName': sellerDoc.data()['displayName'] ?? '판매자',
        'status': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('connections').add(connectionData);

      Get.snackbar('성공', '연결 요청이 전송되었습니다.');
      print('=== Connection request created successfully ===');
      return true;
    } catch (e) {
      print('=== Connection request error: $e ===');
      Get.snackbar('오류', '연결 요청 중 오류가 발생했습니다: $e');
      return false;
    }
  }

  // 판매자가 받은 연결 요청 목록 조회
  Stream<List<ConnectionModel>> getConnectionRequests(String sellerId) {
    return _firestore
        .collection('connections')
        .where('sellerId', isEqualTo: sellerId)
        .where('status', isEqualTo: 'pending')
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return ConnectionModel(
              id: doc.id,
              buyerId: data['buyerId'] ?? '',
              sellerId: data['sellerId'] ?? '',
              buyerName: data['buyerName'] ?? '구매자',
              sellerName: data['sellerName'] ?? '판매자',
              buyerEmail: data['buyerEmail'],
              sellerEmail: data['sellerEmail'],
              status: ConnectionStatus.values.firstWhere(
                (e) => e.name == data['status'],
                orElse: () => ConnectionStatus.pending,
              ),
              requestedAt:
                  (data['requestedAt'] as Timestamp?)?.toDate() ??
                  DateTime.now(),
            );
          }).toList();
        });
  }

  // 구매자의 연결된 판매자 목록 조회
  Stream<List<ConnectionModel>> getApprovedConnections(String buyerId) {
    return _firestore
        .collection('connections')
        .where('buyerId', isEqualTo: buyerId)
        .where('status', isEqualTo: 'approved')
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return ConnectionModel(
              id: doc.id,
              buyerId: data['buyerId'] ?? '',
              sellerId: data['sellerId'] ?? '',
              buyerName: data['buyerName'] ?? '구매자',
              sellerName: data['sellerName'] ?? '판매자',
              buyerEmail: data['buyerEmail'],
              sellerEmail: data['sellerEmail'],
              status: ConnectionStatus.values.firstWhere(
                (e) => e.name == data['status'],
                orElse: () => ConnectionStatus.approved,
              ),
              requestedAt:
                  (data['requestedAt'] as Timestamp?)?.toDate() ??
                  DateTime.now(),
              connectedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
            );
          }).toList();
        });
  }

  // 연결 요청 승인
  Future<bool> approveConnection(String connectionId) async {
    try {
      await _firestore.collection('connections').doc(connectionId).update({
        'status': 'approved',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar('성공', '연결 요청을 승인했습니다.');
      return true;
    } catch (e) {
      print('=== Approve connection error: $e ===');
      Get.snackbar('오류', '연결 승인 중 오류가 발생했습니다: $e');
      return false;
    }
  }

  // 연결 요청 거절
  Future<bool> rejectConnection(String connectionId) async {
    try {
      await _firestore.collection('connections').doc(connectionId).update({
        'status': 'rejected',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar('알림', '연결 요청을 거절했습니다.');
      return true;
    } catch (e) {
      print('=== Reject connection error: $e ===');
      Get.snackbar('오류', '연결 거절 중 오류가 발생했습니다: $e');
      return false;
    }
  }

  void setActiveConnection(ConnectionModel connection) {}
}
