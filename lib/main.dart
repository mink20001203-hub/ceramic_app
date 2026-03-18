// lib/main.dart 파일 전체 코드 (최종 복구 버전)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ✅ 분리된 파일 임포트: 모두 lib 폴더를 기준으로 경로 지정
import 'models/user_data_manager.dart';
import 'screens/home_screen.dart';
import 'screens/my_page_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/category_screen.dart';
import 'screens/search_screen.dart';

// 앱 시작점. Provider를 최상단에 등록해서 전역 상태를 관리한다.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool firebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } catch (_) {
    // Firebase 설정이 없으면 로컬 모드로 실행한다.
    firebaseReady = false;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => UserDataManager(firebaseReady: firebaseReady)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // lib/main.dart

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // 전체 배경 흰색
        primaryColor: const Color(0xFF6342E8), // 메인 포인트 보라색
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF222222), // 앱바 글씨 진회색
          elevation: 0, // 앱바 밑에 그림자 제거 (필수!)
          centerTitle: true,
        ),
        // 하단 네비게이션바 스타일
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF6342E8),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: const MainScreen(),
    );
  }
}
// --------------------------------------------------------
// ✅ MainScreen: 탭바와 화면 전환 관리 (StatefulWidget)
// --------------------------------------------------------

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  // 빌드마다 위젯을 다시 생성하지 않도록 화면 리스트를 고정한다.
  static const List<Widget> _screens = [
    HomeScreen(),
    CategoryScreen(),
    CartScreen(),
    MyPageScreen(),
  ];

  // ⚠️ 기존의 리스트 방식을 build 안으로 옮기거나, 직접 인덱스로 접근하게 수정합니다.
  @override
  Widget build(BuildContext context) {
    // 탭 인덱스 변경 시에만 화면이 다시 빌드되도록 선택적으로 구독한다.
    final currentTabIndex =
        context.select((UserDataManager m) => m.currentTabIndex);

    return Scaffold(
      // 1. 홈 탭(0번)일 때만 앱바를 표시하는 기존 로직 유지
      appBar: currentTabIndex == 0
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
      body: _screens[currentTabIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentTabIndex,
        onTap: (index) {
          // 탭 인덱스만 변경해서 불필요한 리빌드를 줄인다.
          context.read<UserDataManager>().setTabIndex(index);
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.category), label: '카테고리'),

          // --- 장바구니 아이콘 (애니메이션 포함) ---
          BottomNavigationBarItem(
            icon: Selector<UserDataManager, int>(
              selector: (_, manager) => manager.items.length,
              builder: (context, count, child) {
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
