import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'features/splash/screens/splash_screen.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Firebase Auth 디버깅
  final user = FirebaseAuth.instance.currentUser;
  print('\n=== Firebase Auth 디버깅 ===');
  if (user != null) {
    print('로그인 상태: 로그인됨');
    print('사용자 UID: ${user.uid}');
    print('이메일: ${user.email}');
    print('이메일 인증 여부: ${user.emailVerified}');
    print('마지막 로그인: ${user.metadata.lastSignInTime}');
    print('계정 생성 시간: ${user.metadata.creationTime}');
  } else {
    print('로그인 상태: 로그인되지 않음');
  }
  print('========================\n');

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyCheck',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(), // 항상 스플래시 스크린으로 시작
      routes: Routes.getRoutes(),
    );
  }
}
