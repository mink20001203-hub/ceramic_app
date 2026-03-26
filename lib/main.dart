import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'models/user_data_manager.dart';
import 'screens/cart_screen.dart';
import 'screens/category_screen.dart';
import 'screens/home_screen.dart';
import 'screens/my_page_screen.dart';
import 'screens/search_screen.dart';

const bool kUseRemoteProducts = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } catch (_) {
    firebaseReady = false;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserDataManager(
            firebaseReady: firebaseReady,
            remoteProductsEnabled: kUseRemoteProducts,
          ),
        ),
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
        scaffoldBackgroundColor: const Color(0xFFFAF9F6),
        primaryColor: const Color(0xFFA53C2C),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFA53C2C),
          brightness: Brightness.light,
          background: const Color(0xFFFAF9F6),
        ),
        textTheme: GoogleFonts.manropeTextTheme(
          ThemeData.light().textTheme,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFFAF9F6),
          foregroundColor: const Color(0xFF303330),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.plusJakartaSans(
            textStyle: const TextStyle(
              color: Color(0xFF303330),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFF4F4F0),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF4F4F0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA53C2C),
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFA53C2C),
            side: const BorderSide(color: Color(0xFFA53C2C)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFFA53C2C),
          unselectedItemColor: Color(0xFF5D605C),
          backgroundColor: Color(0xFFFAF9F6),
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    CategoryScreen(),
    CartScreen(),
    MyPageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentTabIndex =
        context.select((UserDataManager m) => m.currentTabIndex);

    return Scaffold(
      appBar: currentTabIndex == 0
          ? AppBar(
              title: const Text('OUD'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            )
          : null,
      body: _screens[currentTabIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentTabIndex,
        onTap: (index) => context.read<UserDataManager>().setTabIndex(index),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: '카테고리',
          ),
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
            icon: Icon(Icons.person),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }
}
