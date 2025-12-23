import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/user_data_manager.dart';
import '../screens/detail_screen.dart'; // ✅ 실제 파일명에 맞춰 수정됨

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 상품 클릭 시 상세 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DetailScreen(product: product), // ✅ 클래스명 확인 필요
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 이미지 및 찜하기 버튼 (Stack 사용)
            Expanded(
              child: Stack(
                children: [
                  // 상품 이미지
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(10)),
                    child: product.image != null
                        ? Image.asset(
                            product.image!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : const Center(child: Icon(Icons.image, size: 50)),
                  ),
                  // 오른쪽 상단 하트 버튼
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<UserDataManager>(
                      builder: (context, userManager, child) {
                        final isFav = userManager.isFavorite(product);
                        return GestureDetector(
                          onTap: () {
                            userManager.toggleWishlist(product);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.black26,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.white,
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // 2. 상품 정보 (텍스트 부분)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title, // ✅ name 대신 title로 수정됨
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${product.price}원",
                    style: const TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
