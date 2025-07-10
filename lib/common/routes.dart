import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../main/profile_screen.dart';
import '../main/attendance_screen.dart';
import '../main/ranking_screen.dart';
import '../main/main_layout.dart';

class Routes {
  // 라우트 이름 상수
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String attendance = '/attendance';
  static const String ranking = '/ranking';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const MainLayout(), // 홈 화면은 출석체크 화면으로 설정
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      profile: (context) => const ProfileScreen(),
      attendance: (context) => const AttendanceScreen(),
      ranking: (context) => const RankingScreen(),
    };
  }
} 