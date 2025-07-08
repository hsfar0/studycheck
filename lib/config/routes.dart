import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/profile_screen.dart';
import '../features/attendance/screens/attendance_screen.dart';
import '../features/ranking/screens/ranking_screen.dart';

class Routes {
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String attendance = '/attendance';
  static const String ranking = '/ranking';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      profile: (context) => const ProfileScreen(),
      attendance: (context) => const AttendanceScreen(),
      ranking: (context) => const RankingScreen(),
    };
  }
} 