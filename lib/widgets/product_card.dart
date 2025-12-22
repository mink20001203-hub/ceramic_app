import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ✅ 가격 포맷을 위해 필요
import '../models/product.dart';
import '../screens/detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // 가격 포맷 설정 (이미지 소스 참고)
    final NumberFormat priceFormat = NumberFormat('#,###', 'ko_KR');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. 상품 이미지 (BoxFit.cover 적용)
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: product.image != null
                    ? Image.asset(
                        product.image!,
                        fit: BoxFit.cover, // ✅ 이미지 꽉 채우기
                        width: double.infinity,
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Center(
                            child: Icon(Icons.image_not_supported)),
                      ),
              ),
            ),

            // 2. 상품 정보
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title, // ✅ name 대신 title 사용
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // 상품 부제(subTitle)가 있다면 표시 (이미지 소스 참고)
                  Text(
                    product.subTitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${priceFormat.format(product.price)}원', // ✅ 포맷팅된 가격 표시
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6750A4),
                    ),
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
