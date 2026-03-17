import 'package:flutter/material.dart';
import 'dart:async';
import '../main.dart'; // ✅ main_screen.dart 대신 프로젝트의 메인 파일을 불러옵니다.

// 스플래시 화면: 잠깐 노출 후 메인 화면으로 이동한다.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF6750A4),
      body: Center(
        child: Text(
          'Ceramic Studio',
          style: TextStyle(
              fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
