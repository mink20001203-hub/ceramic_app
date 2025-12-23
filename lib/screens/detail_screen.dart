import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/user_data_manager.dart';

class DetailScreen extends StatelessWidget {
  final Product product;

  const DetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat('#,###', 'ko_KR');
    final userManager = Provider.of<UserDataManager>(context, listen: false);

    return Scaffold(
      // 이미지가 상단 끝까지 차도록 AppBar를 제거하고 Stack을 사용합니다.
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 대형 상품 이미지
                Hero(
                  tag: 'product-${product.title}', // 메인 화면과 연결되는 애니메이션 효과
                  child: product.image != null
                      ? Image.asset(
                          product.image!,
                          width: double.infinity,
                          height: 400,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 400,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, size: 100),
                        ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. 카테고리 및 제목
                      Text(
                        "Ceramic Collection",
                        style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.title,
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      // 3. 가격 정보
                      Text(
                        "${priceFormat.format(product.price)}원",
                        style: const TextStyle(
                            fontSize: 22,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),

                      // 4. 상품 상세 설명 (풍성하게 추가)
                      const Text(
                        "상품 설명",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${product.title}은(는) 장인의 손길로 하나하나 정성스럽게 제작된 핸드메이드 도자기입니다. "
                        "고온에서 구워내어 내구성이 뛰어나며, 천연 유약을 사용하여 은은한 광택과 함께 각 제품마다 고유한 무늬를 가지고 있는 것이 특징입니다.\n\n"
                        "일상의 식탁을 더욱 특별하게 만들어주는 감성적인 디자인을 만나보세요. 선물용으로도 매우 인기가 높습니다.",
                        style: const TextStyle(
                            fontSize: 16, height: 1.6, color: Colors.black87),
                      ),
                      const SizedBox(height: 100), // 하단 버튼 공간 확보
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 5. 상단 커스텀 뒤로가기 버튼
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 15,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),

          // 6. 하단 고정 구매하기 버튼
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5))
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  // 구매 로직 실행 (기존 기능 연결)
                  userManager.addPurchase([product]);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product.title} 구매가 완료되었습니다!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  "바로 구매하기",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
