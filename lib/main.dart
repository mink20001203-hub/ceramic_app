// lib/main.dart 파일 전체 코드 (최종 복구 버전)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ✅ 분리된 파일 임포트: 모두 lib 폴더를 기준으로 경로 지정
import 'models/user_data_manager.dart';
import 'screens/home_screen.dart';
import 'screens/my_page_screen.dart';
import 'screens/search_screen.dart';
import 'models/cart_provider.dart';
import 'screens/cart_screen.dart';
import 'screens/category_screen.dart';
import 'screens/search_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => UserDataManager()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6750A4),
      ),
      home: const SplashScreen(), // ✅ 처음 시작을 SplashScreen으로 설정
    );
  }
}
// --------------------------------------------------------
// ✅ MainScreen: 탭바와 화면 전환 관리 (StatefulWidget)
// --------------------------------------------------------

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  // ⚠️ 기존의 리스트 방식을 build 안으로 옮기거나, 직접 인덱스로 접근하게 수정합니다.
  @override
  Widget build(BuildContext context) {
    // Provider로부터 userManager를 가져옵니다.
    final userManager = Provider.of<UserDataManager>(context);

    // 표시할 화면들을 리스트로 정의 (build 안에 두어야 상태 변경 시 확실히 인지합니다)
    final List<Widget> screens = [
      const HomeScreen(),
      const CategoryScreen(),
      const CartScreen(),
      const MyPageScreen(),
    ];

    return Scaffold(
      // 1. 홈 탭(0번)일 때만 앱바를 표시하는 기존 로직 유지
      appBar: userManager.currentTabIndex == 0
          ? AppBar(
              title: const Text('도자기 스튜디오'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SearchScreen()),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            )
          : null,

      // 2. 현재 인덱스에 맞는 화면 표시
      body: screens[userManager.currentTabIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: userManager.currentTabIndex,
        onTap: (index) {
          userManager.setTabIndex(index); // 탭 클릭 시 변경
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.category), label: '카테고리'),

          // --- 장바구니 아이콘 (애니메이션 포함) ---
          BottomNavigationBarItem(
            icon: Consumer<UserDataManager>(
              builder: (context, userManager, child) {
                int count = userManager.items.length;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart),
                    if (count > 0)
                      Positioned(
                        right: -8,
                        top: -8,
                        child: TweenAnimationBuilder<double>(
                          key: ValueKey(count),
                          duration: const Duration(seconds: 1),
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 0.5 + (value * 0.7),
                              child: child,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            label: '장바구니',
          ),

          const BottomNavigationBarItem(
              icon: Icon(Icons.person), label: '마이페이지'),
        ],
      ),
    );
  }
}
