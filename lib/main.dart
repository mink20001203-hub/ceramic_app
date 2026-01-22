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

  final List<Widget> _screens = const [
    HomeScreen(),
    CategoryScreen(),
    CartScreen(),
    MyPageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final userManager = Provider.of<UserDataManager>(context);

    return Scaffold(
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
      body: _screens[userManager.currentTabIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: userManager.currentTabIndex,
        onTap: (index) {
          userManager.setTabIndex(index);
        },
        // ⚠️ 여기 items 앞에 있던 const를 반드시 지워야 합니다!
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.category), label: '카테고리'),
          BottomNavigationBarItem(
            icon: Consumer<UserDataManager>(
              builder: (context, userManager, child) {
                int cartCount = userManager.items.length;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart),
                    if (cartCount > 0)
                      Positioned(
                        right: -8,
                        top: -8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$cartCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
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
