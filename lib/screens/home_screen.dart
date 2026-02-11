import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  // lib/screens/home_screen.dart

  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 히어로 배너 영역 (이미지 꽉 차게)
            Container(
              height: 450,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image:
                      AssetImage('assets/images/hero_pottery.jpg'), // 고화질 사진 권장
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('다시 찾은\n우리 도자기의 결',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.2)),
                    SizedBox(height: 8),
                    Text('Seasonal Collection',
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
            ),

            // 2. 퀵 아이콘 메뉴 (가로 스크롤)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildQuickMenu(Icons.new_releases_outlined, '신상품'),
                    _buildQuickMenu(Icons.star_outline, '베스트'),
                    _buildQuickMenu(Icons.event_note_outlined, '기획전'),
                    _buildQuickMenu(Icons.card_giftcard_outlined, '선물하기'),
                    _buildQuickMenu(Icons.percent_outlined, '혜택'),
                  ],
                ),
              ),
            ),

            // 3. 기존 상품 리스트 제목
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('오늘의 추천 도자기',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            // ... 기존 GridView 코드 ...
          ],
        ),
      ),
    );
  }

  Widget _buildQuickMenu(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5), shape: BoxShape.circle),
            child: Icon(icon, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF444444))),
        ],
      ),
    );
  }
}
