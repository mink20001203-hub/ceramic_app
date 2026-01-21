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
  // 1. StatelessWidget으로 변경하면 더 깔끔합니다.
  const MainScreen({super.key});

  // 2. 보여줄 화면들 리스트
  final List<Widget> _screens = const [
    HomeScreen(),
    CategoryScreen(),
    CartScreen(),
    MyPageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // 3. UserDataManager 감시자 호출 (상태를 실시간으로 반영)
    final userManager = Provider.of<UserDataManager>(context);

    return Scaffold(
      // 4. 앱바를 여기에 직접 넣으면 에러가 안 납니다.
      appBar: userManager.currentTabIndex == 0 // 홈 화면(0번)일 때만 앱바 표시
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
          : null, // 홈 화면이 아니면 앱바를 숨김

      // 5. 현재 선택된 탭 번호에 맞는 화면 보여주기
      body: _screens[userManager.currentTabIndex],

      // 6. 하단 탭 바 설정
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: userManager.currentTabIndex, // 저장소에 있는 번호 사용
        onTap: (index) {
          userManager.setTabIndex(index); // 탭 누르면 저장소 번호 변경
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: '카테고리'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: '장바구니'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        ],
      ),
    );
  }
}
