// lib/screens/home_screen.dart 파일 전체 코드 (MainContent 위젯)

import 'package:flutter/material.dart';
// ... (다른 import)

import '../widgets/product_card.dart'; // ✅ 상위 폴더(lib)로 가서 widgets 폴더를 찾음
import '../models/product.dart'; // ✅ 상위 폴더(lib)로 가서 models 폴더를 찾음

class HomeScreen extends StatelessWidget {
  // 🚨 클래스 이름을 HomeScreen으로 변경
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 기존 MainScreen의 Scaffold body 내용을 여기에 붙여 넣습니다. (MainContent 내용을 그대로 사용)
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 800 ? 3 : 2;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text(
            '오늘의 추천 도자기',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dummyProducts.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.5,
            ),
            itemBuilder: (context, index) {
              return ProductCard(product: dummyProducts[index]);
            },
          ),
        ],
      ),
    );
  }
}
