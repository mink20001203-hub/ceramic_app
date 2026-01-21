import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. 변수 선언 (이 부분이 살아있어야 에러가 안 납니다)
    final List<Product> filteredProducts = dummyProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ceramic Studio'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: GridView.builder(
          // 2. 요청하신 디자인 수정 사항 적용
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.68, // 카드를 더 세로로 길게
            crossAxisSpacing: 20,
            mainAxisSpacing: 25,
          ),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            return ProductCard(product: filteredProducts[index]);
          },
        ),
      ),
    );
  }
}
