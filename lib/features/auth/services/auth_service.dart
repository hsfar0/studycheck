import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 현재 유저 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 현재 유저 정보 가져오기
  User? get currentUser => _auth.currentUser;

  // 현재 유저 정보 디버깅
  void debugCurrentUser() {
    final user = currentUser;
    if (user != null) {
      print('=== 현재 로그인된 사용자 정보 ===');
      print('UID: ${user.uid}');
      print('이메일: ${user.email}');
      print('이메일 인증 여부: ${user.emailVerified}');
      print('마지막 로그인 시간: ${user.metadata.lastSignInTime}');
      print('계정 생성 시간: ${user.metadata.creationTime}');
      print('============================');
    } else {
      print('로그인된 사용자가 없습니다.');
    }
  }

  // 이메일/비밀번호로 로그인
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugCurrentUser(); // 로그인 성공 시 사용자 정보 출력
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // 이메일/비밀번호로 회원가입
  Future<UserCredential?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugCurrentUser(); // 회원가입 성공 시 사용자 정보 출력
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
    print('로그아웃 되었습니다.');
  }

  // Firebase 인증 예외 처리
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return '비밀번호가 너무 약합니다.';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'invalid-email':
        return '유효하지 않은 이메일 형식입니다.';
      case 'user-not-found':
        return '등록되지 않은 이메일입니다.';
      case 'wrong-password':
        return '잘못된 비밀번호입니다.';
      default:
        return '인증 오류가 발생했습니다.';
    }
  }
} 