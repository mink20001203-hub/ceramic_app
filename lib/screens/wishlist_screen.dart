import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/user_data_manager.dart';

// 위시리스트 화면: 찜한 상품 목록을 보여준다.
class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                final isSoldOut = product.stock == 0;
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
                    subtitle: isSoldOut
                        ? const Text('품절',
                            style: TextStyle(color: Colors.red))
                        : product.isSale && product.salePrice != null
                        ? Row(
                            children: [
                              Text(
                                '${priceFormat.format(product.salePrice)}원',
                                style: const TextStyle(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${priceFormat.format(product.price)}원',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            '${priceFormat.format(product.price)}원',
                            style: const TextStyle(color: Colors.deepPurple),
                          ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ✅ 장바구니 버튼 로직 연결
                        IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined),
                          onPressed: () {
                            // 장바구니에 상품 추가
                            if (isSoldOut) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('품절 상품은 담을 수 없습니다.')),
                              );
                              return;
                            }
                            userManager.addToCart(
                              product,
                              selectedOption: product.options.isNotEmpty
                                  ? product.options.first
                                  : null,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.title}을 장바구니에 담았습니다.'),
                                duration: const Duration(seconds: 1),
                                // 💡 팁: 장바구니로 바로 이동하는 액션 추가
                                action: SnackBarAction(
                                  label: '이동',
                                  textColor: Colors.white,
                                  onPressed: () =>
                                      userManager.setTabIndex(2), // 장바구니 탭 인덱스
                                ),
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
                  ),
                );
              },
            ),
    );
  }
}
