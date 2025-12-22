import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import 'package:provider/provider.dart';
import '../models/cart_provider.dart';
import 'package:provider/provider.dart';
import '../models/cart_provider.dart';

class DetailScreen extends StatelessWidget {
  final Product product;

  const DetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final NumberFormat priceFormat = NumberFormat('#,###', 'ko_KR');

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title), // AppBar에 상품명 표시
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        // 내용이 길어질 수 있으므로 스크롤 가능하게 설정
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 상세 이미지 (화면 너비에 맞추고 높이를 적절히 고정)
            product.image != null
                ? Image.asset(
                    product.image!,
                    width: double.infinity,
                    height: 400, // 상세페이지 이미지 높이 고정
                    fit: BoxFit.cover, // 영역을 가득 채우도록 설정
                  )
                : Container(
                    width: double.infinity,
                    height: 400,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 100),
                  ),

            // 2. 상품 정보 텍스트 영역
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.subTitle,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${priceFormat.format(product.price)}원',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6750A4),
                    ),
                  ),
                  const Divider(height: 40), // 구분선
                  const Text(
                    '상품 상세 설명',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '이 상품은 장인의 손길로 정성스럽게 제작된 도자기입니다. '
                    '실생활에서 사용하기 좋으며 선물용으로도 매우 인기 있는 작품입니다.',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // 3. 하단 구매하기 버튼 예시
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // ✅ 장바구니에 담기 기능 실행
            Provider.of<CartProvider>(context, listen: false)
                .addToCart(product);

            // 담겼다는 알림(스낵바) 표시
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${product.title}이 장바구니에 담겼습니다!'),
                duration: const Duration(seconds: 2),
                action: SnackBarAction(
                  label: '이동',
                  onPressed: () {
                    // TODO: 장바구니 탭으로 이동하는 로직 추가 가능
                  },
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6750A4),
            minimumSize: const Size(double.infinity, 50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('구매하기',
              style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }
}
