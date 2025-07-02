import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/app_constants.dart';

class FirebaseService extends GetxService {
  static FirebaseService get instance => Get.find<FirebaseService>();

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Getters for Firebase instances
  FirebaseFirestore get firestore => _firestore;
  FirebaseAuth get auth => _auth;

  // Collection references
  CollectionReference get usersCollection => 
      _firestore.collection(AppConstants.usersCollection);
  
  CollectionReference get connectionsCollection => 
      _firestore.collection(AppConstants.connectionsCollection);
  
  CollectionReference get productsCollection => 
      _firestore.collection(AppConstants.productsCollection);
  
  CollectionReference get ordersCollection => 
      _firestore.collection(AppConstants.ordersCollection);

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeFirestore();
  }

  Future<void> _initializeFirestore() async {
    try {
      // 🚀 Firestore 성능 최적화 설정
      _firestore.settings = const Settings(
        // 오프라인 지속성 비활성화 (빌드 속도 향상)
        persistenceEnabled: false,
        // 캐시 크기 제한 (메모리 사용량 최적화)
        cacheSizeBytes: 40 * 1024 * 1024, // 40MB
        // SSL 비활성화 (개발 환경에서만)
        sslEnabled: true,
      );
      
      Get.log('Firebase Service initialized successfully');
    } catch (e) {
      Get.log('Firebase Service initialization failed: $e');
    }
  }

  // Batch write helper
  WriteBatch batch() => _firestore.batch();

  // Transaction helper
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction,
  ) {
    return _firestore.runTransaction(updateFunction);
  }

  // Error handling helper
  String getFirebaseErrorMessage(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return '접근 권한이 없습니다.';
        case 'not-found':
          return '요청한 데이터를 찾을 수 없습니다.';
        case 'already-exists':
          return '이미 존재하는 데이터입니다.';
        case 'unavailable':
          return '서비스를 일시적으로 사용할 수 없습니다.';
        case 'deadline-exceeded':
          return '요청 시간이 초과되었습니다.';
        default:
          return error.message ?? '알 수 없는 오류가 발생했습니다.';
      }
    }
    return error.toString();
  }
}
