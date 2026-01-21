import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/user_data_manager.dart';

class DetailScreen extends StatelessWidget {
  final Product product;
  const DetailScreen({super.key, required this.product});

  // --- 1. 장바구니 알림 바텀 시트 함수 ---
  void _showCartBottomSheet(BuildContext context, UserDataManager userManager) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  '장바구니에 상품이 담겼습니다.',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              const Text('나와 비슷한 고객들이 비교한 상품',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 16),

              // 비슷한 상품 리스트 (가로 스크롤)
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return _buildSimilarProductItem();
                  },
                ),
              ),

              const SizedBox(height: 24),

              // 하단 버튼들
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text('쇼핑 계속하기',
                          style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // 시트 닫기
                        userManager.setTabIndex(2); // 장바구니 탭 인덱스로 설정
                        Navigator.popUntil(
                            context, (route) => route.isFirst); // 메인으로 이동
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('장바구니 보기',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 비슷한 상품 아이템 레이아웃 위젯
  Widget _buildSimilarProductItem() {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: Icon(Icons.image, color: Colors.grey)),
          ),
          const SizedBox(height: 8),
          const Text('유사 상품 이름',
              style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
          const Text('19,900원',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userManager = Provider.of<UserDataManager>(context, listen: false);
    final priceFormat = NumberFormat('#,###', 'ko_KR');

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        actions: [
          Consumer<UserDataManager>(
            builder: (context, manager, child) {
              final isFav = manager.isFavorite(product);
              return IconButton(
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                color: isFav ? Colors.red : null,
                onPressed: () => manager.toggleWishlist(product),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(product.image!,
                      width: double.infinity, height: 300, fit: BoxFit.cover),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.title,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text("${priceFormat.format(product.price)}원",
                            style: const TextStyle(
                                fontSize: 20,
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w600)),
                        const Divider(height: 40),
                        const Text("상품 설명",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        const Text("장인의 손길로 제작된 명품 도자기입니다.",
                            style: TextStyle(fontSize: 16, height: 1.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // --- 하단 고정 버튼 영역 ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: const BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                  color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
            ]),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // 1. 데이터에 추가
                      userManager.addToCart(product);
                      // 2. 바텀 시트 띄우기
                      _showCartBottomSheet(context, userManager);
                    },
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.deepPurple),
                        minimumSize: const Size(double.infinity, 50)),
                    child: const Text("장바구니",
                        style:
                            TextStyle(fontSize: 16, color: Colors.deepPurple)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      userManager.addPurchase([product]);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('주문이 완료되었습니다!')));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50)),
                    child:
                        const Text("지금 구매하기", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
