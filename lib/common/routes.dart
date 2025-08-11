import 'package:flutter/material.dart';
import '../auth/change_password.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../main/profile_screen.dart';
import '../main/attendance_screen.dart';
import '../main/ranking_screen.dart';
import '../main/main_layout.dart';

class Routes {
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String attendance = '/attendance';
  static const String ranking = '/ranking';
  static const String changepw = '/changepw';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const MainLayout(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      profile: (context) => const ProfileScreen(),
      attendance: (context) => const AttendanceScreen(),
      ranking: (context) => const RankingScreen(),
      changepw: (context) => const ChangePasswordScreen(),
    };
  }
} 
