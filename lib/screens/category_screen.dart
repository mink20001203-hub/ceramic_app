import 'package:flutter/material.dart';
import 'category_result_screen.dart'; // ✅ 결과 화면 파일 임포트

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> categories = ['컵', '그릇', '오브제', '화병'];

    return Scaffold(
      appBar: AppBar(title: const Text('카테고리')),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(categories[index]),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // 결과 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CategoryResultScreen(category: categories[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
