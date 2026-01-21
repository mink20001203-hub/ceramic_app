import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/user_data_manager.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider를 통해 사용자 데이터 관리자 가져오기
    final userManager = Provider.of<UserDataManager>(context);
    final wishlist = userManager.wishlist;
    final priceFormat = NumberFormat('#,###', 'ko_KR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('찜한 상품'),
        centerTitle: true,
      ),
      body: wishlist.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    '찜한 상품이 없습니다.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                final product = wishlist[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: product.image != null
                          ? Image.asset(
                              product.image!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported),
                            ),
                    ),
                    title: Text(
                      product.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${priceFormat.format(product.price)}원',
                      style: const TextStyle(color: Colors.deepPurple),
                    ),
                    // 아이콘 두 개를 나란히 배치하기 위해 Row 사용
                    trailing: Row(
                      mainAxisSize:
                          MainAxisSize.min, // 중요: Row의 크기를 아이콘 너비만큼만 차지하게 함
                      children: [
                        // 장바구니 버튼
                        IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined),
                          onPressed: () {
                            // TODO: userManager.addToCart(product) 같은 기능을 연결하세요
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.title}을 장바구니에 담았습니다.'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                        // 찜 해제 버튼
                        IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () {
                            userManager.toggleWishlist(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('찜 목록에서 삭제되었습니다.'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      // 상세 페이지 이동 로직이 있다면 여기에 추가
                    },
                  ),
                );
              },
            ),
    );
  }
}
