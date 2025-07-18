import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:retry/retry.dart';

import '../../data/models/user_model.dart';

class AuthService extends GetxService {
  static AuthService get instance => Get.find<AuthService>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reactive variables
  final Rx<User?> _firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> _userModel = Rx<UserModel?>(null);
  final Rx<UserState> _userState = Rx<UserState>(UserInitial()); // UserState 추가
  final RxBool _isLoading = false.obs;
  final RxBool isAuthCheckComplete = false.obs; // 인증 확인 완료 상태

  // Getters
  User? get firebaseUser => _firebaseUser.value;
  UserModel? get userModel => _userModel.value;
  Rx<UserState> get userStateRx => _userState; // UserState getter를 Rx<UserState>로 변경
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    print('=== AuthService onInit 시작 ===');
    
    // Firebase Auth 상태 변화 감지 (bamtol 방식)
    _firebaseUser.bindStream(_auth.authStateChanges());
    
    // 사용자 상태 변화에 따른 처리
    ever(_firebaseUser, _handleAuthStateChanged);
  }

  // 사용자 상태 변화에 따른 처리
  void _handleAuthStateChanged(User? user) async {
    print('=== Auth state changed: ${user?.uid} ===');
    
    if (user == null) {
      _userModel.value = null;
      _userState.value = UserInitial(); // 로그아웃 시 초기 상태로
      print('=== 사용자 로그아웃됨 ===');
      isAuthCheckComplete.value = true; // 인증 확인 완료
    } else {
      _userState.value = UserLoading(); // 로딩 시작
      final userStateResult = await _loadUserData(user.uid);
      _userState.value = userStateResult; // 결과 반영

      if (userStateResult is UserLoaded) {
        _userModel.value = userStateResult.user;
      } else {
        _userModel.value = null; // 로드 실패 또는 새 사용자일 경우 모델은 null
      }
      isAuthCheckComplete.value = true; // 인증 확인 완료
    }
  }

  // 사용자 데이터 로드
  Future<UserState> _loadUserData(String uid) async {
    final r = RetryOptions(
      maxAttempts: 3, // 최대 3번 시도
      delayFactor: Duration(seconds: 2), // 딜레이 증가 요소 (2초, 4초, 8초)
      maxDelay: Duration(seconds: 10), // 최대 딜레이 10초
      randomizationFactor: 0.25, // 25%의 Jitter 추가
    );

    try {
      print('=== Loading user data for uid: $uid ===');
      final doc = await r.retry(
        () => _firestore.collection('users').doc(uid).get(),
        retryIf: (e) =>
            e is FirebaseException &&
            (e.code == 'unavailable' ||
                e.code == 'network-request-failed' ||
                e.code == 'internal'),
      );

      if (doc.exists && doc.data() != null) {
        final user = UserModel.fromFirestore(doc);
        print('=== User model loaded: ${user.displayName} (${user.role.name}) ===');
        return UserLoaded(user);
      } else {
        print('=== User document does not exist for uid: $uid ===');
        return UserNew();
      }
    } on FirebaseException catch (e) {
      print('=== FirebaseException loading user data: ${e.code} - ${e.message} ===');
      if (e.code == 'unavailable' || e.code == 'network-request-failed' || e.code == 'internal') {
        return UserError('네트워크 연결을 확인하거나 잠시 후 다시 시도해주세요.');
      }
      return UserError('사용자 데이터를 불러오는 데 실패했습니다: ${e.message}');
    } catch (e) {
      print('=== General error loading user data: $e ===');
      return UserError('알 수 없는 오류로 사용자 데이터를 불러오지 못했습니다.');
    }
  }

  // 외부에서 사용자 데이터 로드 (public 메서드)
  Future<UserState> loadUserData(String uid) async {
    return await _loadUserData(uid);
  }

  // 사용자 프로필 업데이트
  Future<bool> updateUserProfile({
    String? displayName,
    String? businessName,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      final currentUser = _userModel.value;
      if (currentUser == null) {
        print('=== No current user to update ===');
        return false;
      }

      final updateData = <String, dynamic>{};
      
      if (displayName != null) updateData['displayName'] = displayName;
      if (businessName != null) updateData['businessName'] = businessName;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (address != null) updateData['address'] = address;
      
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(currentUser.uid).update(updateData);
      
      // 로컬 사용자 모델 업데이트
      await _loadUserData(currentUser.uid);
      
      print('=== User profile updated successfully ===');
      return true;
    } catch (e) {
      print('=== Failed to update user profile: $e ===');
      return false;
    }
  }

  // 이메일 회원가입 (bamtol 방식)
  Future<UserModel?> signUpWithEmail(String email, String password, {UserRole? role}) async {
    try {
      _isLoading.value = true;
      print('=== AuthService: Signing up with email: $email, received role: ${role?.name} ===');

      // 1. Firebase Auth 사용자 생성
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // 2. 사용자 모델 생성
        final userModel = UserModel(
          uid: credential.user!.uid,
          email: email,
          displayName: email.split('@')[0], // 이메일 앞부분을 이름으로
          role: role ?? UserRole.buyer, // 전달받은 역할 또는 기본값: 구매자
          createdAt: DateTime.now(),
        );

        // 3. Firestore에 저장 (bamtol 방식: 직접 Map 사용)
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'uid': userModel.uid,
          'email': userModel.email,
          'displayName': userModel.displayName,
          'role': userModel.role.name,
          'phoneNumber': userModel.phoneNumber,
          'businessName': userModel.businessName,
          'createdAt': Timestamp.fromDate(userModel.createdAt),
        });

        print('=== User document saved successfully ===');
        
        // 4. 저장 확인
        final savedDoc = await _firestore.collection('users').doc(credential.user!.uid).get();
        if (savedDoc.exists) {
          _userModel.value = userModel;
          print('=== Sign up successful - User: ${userModel.displayName}, Role: ${userModel.role} ===');
          return userModel;
        } else {
          throw Exception('User document not saved properly');
        }
      }

      return null;
    } on FirebaseAuthException catch (e) {
      print('=== Firebase Auth Error: ${e.code} - ${e.message} ===');
      Get.snackbar(
        '회원가입 실패',
        _getFirebaseAuthErrorMessage(e.code),
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } catch (e) {
      print('=== Sign up error: $e ===');
      Get.snackbar(
        '회원가입 실패',
        '회원가입 중 오류가 발생했습니다: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  // 이메일 로그인
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      _isLoading.value = true;
      print('=== Signing in with email: $email ===');
      print('=== Firebase Auth instance: ${_auth.app.name} ===');
      print('=== Firebase Project ID: ${_auth.app.options.projectId} ===');

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // 인증 상태 변화로 자동으로 사용자 데이터 로드됨
        print('=== Sign in successful ===');
        return _userModel.value;
      }

      return null;
    } on FirebaseAuthException catch (e) {
      print('=== Firebase Auth Error Details ===');
      print('Error Code: ${e.code}');
      print('Error Message: ${e.message}');
      print('Error Plugin: ${e.plugin}');
      print('Stack Trace: ${e.stackTrace}');
      print('================================');
      
      Get.snackbar(
        '로그인 실패',
        _getFirebaseAuthErrorMessage(e.code),
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } catch (e) {
      print('=== General Sign in error: $e ===');
      print('Error Type: ${e.runtimeType}');
      Get.snackbar(
        '로그인 실패',
        '로그인 중 오류가 발생했습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  // Google 로그인 (placeholder - 추후 구현)
  Future<UserModel?> signInWithGoogle() async {
    try {
      _isLoading.value = true;
      print('=== Google Sign In - 아직 구현되지 않음 ===');
      
      // TODO: Google Sign In 구현
      Get.snackbar(
        '알림',
        'Google 로그인은 아직 구현되지 않았습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return null;
    } catch (e) {
      print('=== Google Sign In error: $e ===');
      Get.snackbar(
        'Google 로그인 실패',
        'Google 로그인 중 오류가 발생했습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  // 사용자 프로필 생성 (기존 Firebase 사용자용)
  Future<UserModel?> createUserProfile({
    required String displayName,
    required UserRole role,
    String? businessName,
    String? phoneNumber,
  }) async {
    try {
      _isLoading.value = true;
      final currentUser = _auth.currentUser;
      
      if (currentUser == null) {
        print('=== No current user for profile creation ===');
        return null;
      }

      print('=== Creating/Updating user profile for: ${currentUser.uid} ===');

      final userModel = UserModel(
        uid: currentUser.uid,
        email: currentUser.email ?? '',
        displayName: displayName,
        role: role,
        businessName: businessName,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
      );

      // Firestore에 저장 (덮어쓰기 허용)
      await _firestore.collection('users').doc(currentUser.uid).set({
        'uid': userModel.uid,
        'email': userModel.email,
        'displayName': userModel.displayName,
        'role': userModel.role.name,
        'phoneNumber': userModel.phoneNumber,
        'businessName': userModel.businessName,
        'createdAt': Timestamp.fromDate(userModel.createdAt),
      });

      _userModel.value = userModel;
      print('=== User profile created/updated successfully ===');
      return userModel;
    } catch (e) {
      print('=== Create user profile error: $e ===');
      Get.snackbar(
        '프로필 생성 실패',
        '사용자 프로필 생성 중 오류가 발생했습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  // 사용자 역할 업데이트
  Future<bool> updateUserRole(UserRole role) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null || _userModel.value == null) {
        return false;
      }

      await _firestore.collection('users').doc(currentUser.uid).update({
        'role': role.name,
      });

      _userModel.value = _userModel.value!.copyWith(role: role);
      print('=== User role updated to: ${role.name} ===');
      return true;
    } catch (e) {
      print('=== Update user role error: $e ===');
      return false;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      print('=== Signing out ===');
      await _auth.signOut();
      _userModel.value = null;
      print('=== Sign out successful ===');
    } catch (e) {
      print('=== Sign out error: $e ===');
    }
  }

  // Firebase Auth 에러 메시지 한국어 변환
  String _getFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return '비밀번호가 너무 약합니다.';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'invalid-email':
        return '유효하지 않은 이메일 형식입니다.';
      case 'user-not-found':
        return '등록되지 않은 사용자입니다.';
      case 'wrong-password':
        return '잘못된 비밀번호입니다.';
      case 'invalid-credential':
        return '잘못된 인증 정보입니다.';
      case 'too-many-requests':
        return '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요.';
      default:
        return '인증 오류가 발생했습니다: $code';
    }
  }
}