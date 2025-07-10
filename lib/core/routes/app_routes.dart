import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/ranking/presentation/screens/ranking_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/main/screens/main_layout.dart';
class AppRoutes {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/main': (context) => const MainLayout(),
      '/login': (context) => const LoginScreen(),
      '/attendance': (context) => const AttendanceScreen(),
      '/ranking': (context) => const RankingScreen(),
      '/profile': (context) => const ProfileScreen(),
    };
  }

  // 라우트 상수
  static const String main = '/main';
  static const String login = '/login';
  static const String attendance = '/attendance';
  static const String ranking = '/ranking';
  static const String profile = '/profile';
} 