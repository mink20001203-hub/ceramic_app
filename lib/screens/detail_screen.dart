import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/user_data_manager.dart';

class DetailScreen extends StatelessWidget {
  final Product product;

  const DetailScreen({super.key, required this.product});

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
                  Image.asset(
                    product.image!,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
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
                        const SizedBox(height: 10),
                        Text(
                          "${priceFormat.format(product.price)}원",
                          style: const TextStyle(
                              fontSize: 20,
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.w600),
                        ),
                        const Divider(height: 40),
                        const Text(
                          "상품 설명",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "이 도자기는 장인의 손길로 정성스럽게 제작되었습니다. 전통적인 기법과 현대적인 감각이 조화를 이루어 어느 공간에서도 빛을 발합니다.",
                          style: TextStyle(
                              fontSize: 16, color: Colors.black87, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 하단 버튼 영역
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, -5))
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      userManager.setTabIndex(2);
                      Navigator.popUntil(context, (route) => route.isFirst);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('장바구니에 담았습니다!')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.deepPurple),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
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
                        const SnackBar(content: Text('주문이 완료되었습니다!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("지금 구매하기",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
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
