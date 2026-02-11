import 'package:flutter/material.dart';
import 'category_result_screen.dart'; // ✅ 결과 화면 파일 임포트

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🎨 카테고리 이름과 아이콘을 매칭한 데이터 리스트
    final List<Map<String, dynamic>> categories = [
      {'name': '컵', 'icon': Icons.coffee_outlined},
      {'name': '그릇', 'icon': Icons.flatware_outlined},
      // ✅ Adb_outlined 대신 정교한 느낌의 가구/오브제 아이콘으로 변경
      {'name': '오브제', 'icon': Icons.category_outlined},
      {'name': '화병', 'icon': Icons.local_florist_outlined},
      {'name': '신상품', 'icon': Icons.auto_awesome_outlined},
      {'name': '세일', 'icon': Icons.sell_outlined},
    ];
    return Scaffold(
      // 테마 설정에서 이미 배경색을 정했다면 생략 가능하지만, 명시적으로 흰색 지정
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            const Text('카테고리', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        // 한 줄에 3개씩 배치하는 설정
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 3열 배치
          mainAxisSpacing: 25, // 세로 간격
          crossAxisSpacing: 20, // 가로 간격
          childAspectRatio: 0.8, // 아이템의 가로 세로 비율
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final categoryName = categories[index]['name'];
          final categoryIcon = categories[index]['icon'];

          return GestureDetector(
            onTap: () {
              // 클릭 시 결과 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CategoryResultScreen(category: categoryName),
                ),
              );
            },
            child: Column(
              children: [
                // 1. 아이콘 박스 영역
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8), // 연한 회색 배경
                      borderRadius: BorderRadius.circular(16), // 부드러운 곡선
                    ),
                    child: Icon(
                      categoryIcon,
                      size: 32,
                      color: const Color(0xFF222222),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // 2. 카테고리 이름
                Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF444444),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
