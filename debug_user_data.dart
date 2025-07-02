import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';

void main() async {
  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  
  // 모든 사용자 데이터 조회
  print('=== 모든 사용자 데이터 조회 ===');
  final usersSnapshot = await firestore.collection('users').get();
  
  for (final doc in usersSnapshot.docs) {
    print('=== 사용자 ID: ${doc.id} ===');
    print('=== 데이터: ${doc.data()} ===');
    print('');
  }
  
  // test@seller.com 사용자 찾기
  final sellerQuery = await firestore
      .collection('users')
      .where('email', isEqualTo: 'test@seller.com')
      .get();
      
  if (sellerQuery.docs.isNotEmpty) {
    final sellerDoc = sellerQuery.docs.first;
    print('=== test@seller.com 사용자 발견 ===');
    print('=== ID: ${sellerDoc.id} ===');
    print('=== 현재 데이터: ${sellerDoc.data()} ===');
    
    // 역할을 seller로 수정
    await sellerDoc.reference.update({
      'role': 'seller',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    print('=== 역할을 seller로 수정 완료 ===');
    
    // 수정된 데이터 확인
    final updatedDoc = await sellerDoc.reference.get();
    print('=== 수정된 데이터: ${updatedDoc.data()} ===');
  } else {
    print('=== test@seller.com 사용자를 찾을 수 없습니다 ===');
  }
}
