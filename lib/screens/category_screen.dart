import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  // 카테고리 목록 정의
  final List<String> categories = ['전체', '컵', '접시', '오브제', '세트'];
  String selectedCategory = '전체';

  @override
  Widget build(BuildContext context) {
    // 선택된 카테고리에 맞는 상품만 필터링
    final filteredProducts = selectedCategory == '전체'
        ? dummyProducts
        : dummyProducts.where((p) => p.category == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('카테고리'), elevation: 0),
      body: Column(
        children: [
          // 카테고리 선택 바 (가로 스크롤)
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;
                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = category),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF6750A4)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // 필터링된 상품 목록
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(child: Text('해당 카테고리의 상품이 없습니다.'))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) =>
                        ProductCard(product: filteredProducts[index]),
                  ),
          ),
        ],
      ),
    );
  }
}
