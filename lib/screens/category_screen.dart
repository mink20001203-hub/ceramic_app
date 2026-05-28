import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import '../widgets/oud_components.dart';
import 'category_result_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const categories = [
      ('컵', Icons.coffee_outlined),
      ('접시', Icons.flatware_outlined),
      ('볼', Icons.soup_kitchen_outlined),
      ('화병', Icons.local_florist_outlined),
      ('신상', Icons.auto_awesome_outlined),
      ('세일', Icons.sell_outlined),
    ];

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemCount: categories.length,
      itemBuilder: (_, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryResultScreen(category: category.$1),
              ),
            );
          },
          child: OudSectionCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: OudColors.surface,
                  child: Icon(category.$2, color: OudColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category.$1,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const OudTag(label: '보기'),
              ],
            ),
          ),
        );
      },
    );
  }
}
