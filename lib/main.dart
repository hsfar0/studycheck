import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'features/splash/screens/splash_screen.dart';
import 'config/routes.dart';
import 'config/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const SplashScreen(),
      routes: Routes.getRoutes(),
    );
  }
}
