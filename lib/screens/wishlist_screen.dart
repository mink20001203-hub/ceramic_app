import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/user_data_manager.dart';

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
                  Text('찜한 상품이 없습니다.',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
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
                    leading: Image.asset(product.image!,
                        width: 50, height: 50, fit: BoxFit.cover),
                    title: Text(product.title),
                    subtitle: Text('${priceFormat.format(product.price)}원'),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        // 찜 해제 기능
                        userManager.toggleWishlist(product);
                      },
                    ),
                    onTap: () {
                      // 누르면 상세 페이지로 이동하게 만들 수도 있습니다.
                    },
                  ),
                );
              },
            ),
    );
  }
}
