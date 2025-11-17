import 'package:flutter/material.dart';
import 'package:readpulse_id/routes.dart';
import 'package:readpulse_id/features/splash/splash_screen.dart';
import 'package:readpulse_id/features/auth/login_page.dart';
import 'package:readpulse_id/features/home/home_page.dart';
import 'package:readpulse_id/features/assessment/questionnaire_page.dart';
import 'package:readpulse_id/features/assessment/result_page.dart';

void main() {
  runApp(const ReadPulseApp());
}

class ReadPulseApp extends StatelessWidget {
  const ReadPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReadPulse ID',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.home: (_) => const HomePage(),
        AppRoutes.questionnaire: (_) => const QuestionnairePage(),
        AppRoutes.result: (_) => const ResultPage(),
      },
    );
  }
}
