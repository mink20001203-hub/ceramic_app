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

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserDataManager()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
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
      title: '도자기 스튜디오',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF6750A4),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

// --------------------------------------------------------
// ✅ MainScreen: 탭바와 화면 전환 관리 (StatefulWidget)
// --------------------------------------------------------

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CategoryScreen(), // ✅ 기존 Center(...)를 CategoryScreen()으로 교체
    const CartScreen(),
    const MyPageScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 홈 화면에만 AppBar를 보여주는 함수
  AppBar? _buildAppBar() {
    if (_selectedIndex != 0) return null; // 홈 화면이 아니면 AppBar 숨김

    return AppBar(
      title: const Text('도자기 스튜디오'),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () {
            // SearchScreen으로 이동
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),

      // 🚨 현재 선택된 화면을 표시
      body: _screens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.apps), label: '카테고리'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: '장바구니'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이'),
        ],
      ),
    );
  }
}
