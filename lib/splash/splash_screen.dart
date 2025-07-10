import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _initializeApp();
    }
  }

  Future<void> _initializeApp() async {
    try {
      // 여기에 필요한 모든 초기화 작업을 추가
      // 예: 설정 로드, 캐시 초기화 등
      
      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;
      
      // 약간의 지연을 주어 네비게이션 상태가 안정화되도록 함
      await Future.microtask(() {});

      if (!mounted) return;
      
      if (user != null && user.emailVerified) {
        // 로그인된 상태면 출석체크 화면으로
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // 로그인되지 않은 상태면 로그인 화면으로
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (!mounted) return;
      
      // 오류 발생 시 약간의 지연 후 스낵바 표시
      await Future.microtask(() {});
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('초기화 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '자습실 출석체크',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 