import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/user_data_manager.dart';
import '../widgets/product_card.dart'; // ✅ 상품 카드 재사용을 위해 추가

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userManager = Provider.of<UserDataManager>(context);
    final history = userManager.purchasedProducts;
    final wishlist = userManager.wishlist; // ✅ 찜한 목록 가져오기
    final priceFormat = NumberFormat('#,###', 'ko_KR');

    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지'), centerTitle: true),
      body: SingleChildScrollView(
        // ✅ 내용이 길어질 수 있으므로 스크롤 가능하게 변경
        child: Column(
          children: [
            // 1. 상단 프로필 영역 (기존 유지)
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.grey[50],
              child: Column(
                children: [
                  const Row(
                    children: [
                      CircleAvatar(
                          radius: 30, child: Icon(Icons.person, size: 40)),
                      SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('도자기 매니아님',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('반갑습니다!', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildInfoItem('마일리지',
                          '${priceFormat.format(userManager.mileage)}P'),
                      Container(width: 1, height: 30, color: Colors.grey[300]),
                      _buildInfoItem('나의 후기', '${userManager.reviewCount}건'),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // 2. ✅ 내가 찜한 상품 영역 (새로 추가)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  const Icon(Icons.favorite, size: 20, color: Colors.red),
                  const SizedBox(width: 8),
                  const Text('내가 찜한 상품',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text('${wishlist.length}',
                      style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),

            wishlist.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('찜한 상품이 없습니다.',
                        style: TextStyle(color: Colors.grey)),
                  )
                : SizedBox(
                    height: 220, // 찜한 상품 카드의 높이
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal, // 가로 스크롤
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: wishlist.length,
                      itemBuilder: (context, index) {
                        return SizedBox(
                          width: 160, // 카드 너비
                          child: ProductCard(product: wishlist[index]),
                        );
                      },
                    ),
                  ),

            const Divider(height: 30),

            // 3. 최근 구매 기록 영역 (기존 유지)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.history, size: 20),
                  SizedBox(width: 8),
                  Text('최근 구매 기록',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // 구매 내역 리스트 (기존 유지하되, 전체 스크롤을 위해 ListView.builder 수정)
            history.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text('구매 내역이 없습니다.'),
                  )
                : ListView.builder(
                    shrinkWrap: true, // ✅ 전체 스크롤 안에서 작동하도록 설정
                    physics:
                        const NeverScrollableScrollPhysics(), // ✅ 중복 스크롤 방지
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return ListTile(
                        leading: Image.asset(item.image!, width: 50),
                        title: Text(item.title),
                        subtitle: Text('${priceFormat.format(item.price)}원'),
                        trailing: const Text('결제완료',
                            style: TextStyle(color: Colors.deepPurple)),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 5),
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple)),
        ],
      ),
    );
  }
}
