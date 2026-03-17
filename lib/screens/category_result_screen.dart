import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

// 선택한 카테고리의 상품만 보여주는 결과 화면.
class CategoryResultScreen extends StatelessWidget {
  final String category;

  const CategoryResultScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    // 1. 전체 상품 리스트(dummyProducts)에서 선택된 카테고리와 일치하는 것만 추출
    final filteredItems =
        dummyProducts.where((product) => product.category == category).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('$category 목록'),
        centerTitle: true,
      ),
      // 2. 필터링된 상품이 없을 경우와 있을 경우를 나누어 처리
      body: filteredItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('$category 카테고리에 상품이 아직 없습니다.',
                      style: const TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 한 줄에 2개씩
                childAspectRatio: 0.68, // 홈 화면과 동일한 카드 비율
                crossAxisSpacing: 15, // 가로 간격
                mainAxisSpacing: 15, // 세로 간격
              ),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                return ProductCard(product: filteredItems[index]);
              },
            ),
    );
  }
}
