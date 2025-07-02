// Firebase Admin SDK를 사용하여 사용자 역할 수정
const admin = require('firebase-admin');

// Firebase 프로젝트 설정
const serviceAccount = {
  // 여기에 Firebase 서비스 계정 키를 넣어야 합니다
  // 보안상 실제 키는 포함하지 않습니다
};

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://order-market-app-b8b8b.firebaseio.com"
});

const db = admin.firestore();

async function fixUserRole() {
  try {
    // test@seller.com 사용자 찾기
    const usersRef = db.collection('users');
    const snapshot = await usersRef.where('email', '==', 'test@seller.com').get();
    
    if (snapshot.empty) {
      console.log('test@seller.com 사용자를 찾을 수 없습니다.');
      return;
    }
    
    snapshot.forEach(async (doc) => {
      console.log('사용자 발견:', doc.id, doc.data());
      
      // 역할을 seller로 수정
      await doc.ref.update({
        role: 'seller',
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      
      console.log('사용자 역할을 seller로 수정했습니다.');
    });
    
  } catch (error) {
    console.error('오류:', error);
  }
}

fixUserRole();
