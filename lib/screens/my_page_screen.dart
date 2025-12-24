import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/user_data_manager.dart';
import 'wishlist_screen.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ UserDataManager에서 실시간 데이터를 가져옵니다.
    final userManager = Provider.of<UserDataManager>(context);
    final purchasedItems = userManager.purchasedProducts;
    final priceFormat = NumberFormat('#,###', 'ko_KR');

    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. 사용자 프로필 및 마일리지 영역
            _buildProfileSection(userManager),
            const Divider(thickness: 8, color: Color(0xFFF5F5F5)),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WishlistScreen()),
                );
              },
              icon: const Icon(Icons.favorite, size: 18),
              label: const Text('찜한 상품 보기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[50],
                foregroundColor: Colors.pink,
                elevation: 0,
              ),
            ),

            // 2. 구매 내역 타이틀
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.shopping_bag_outlined,
                      color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  const Text('최근 구매 내역',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('총 ${purchasedItems.length}건',
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            // 3. 구매 내역 리스트 (데이터 연결)
            purchasedItems.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 50),
                    child: Center(child: Text('구매한 상품이 없습니다.')),
                  )
                : ListView.builder(
                    shrinkWrap: true, // ScrollView 안에 있으므로 필수
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: purchasedItems.length,
                    itemBuilder: (context, index) {
                      final product = purchasedItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(product.image!,
                                width: 60, height: 60, fit: BoxFit.cover),
                          ),
                          title: Text(product.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle:
                              Text('${priceFormat.format(product.price)}원'),
                          trailing: ElevatedButton(
                            onPressed: () {
                              _showReviewDialog(context, product, userManager);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('리뷰 쓰기'),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  // 상단 프로필 섹션 위젯
  Widget _buildProfileSection(UserDataManager userManager) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.deepPurple,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('도자기 애호가님',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoChip('마일리지', '${userManager.mileage}P'),
                  const SizedBox(width: 10),
                  _buildInfoChip('후기', '${userManager.reviewCount}건'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text('$label $value',
          style: const TextStyle(
              fontSize: 12,
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold)),
    );
  } // 리뷰 작성 팝업창 함수

  void _showReviewDialog(BuildContext context, product, userManager) {
    final TextEditingController commentController = TextEditingController();
    double selectedRating = 5.0; // 기본 별점

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // 팝업 내에서 별점 상태를 변경하기 위해 필요
          builder: (context, setState) {
            return AlertDialog(
              title: Text('${product.title} 리뷰 작성'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('상품은 어떠셨나요?'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() => selectedRating = index + 1.0);
                        },
                      );
                    }),
                  ),
                  TextField(
                    controller: commentController,
                    decoration:
                        const InputDecoration(hintText: '솔직한 후기를 남겨주세요.'),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('취소')),
                ElevatedButton(
                  onPressed: () {
                    if (commentController.text.isNotEmpty) {
                      userManager.addReview(
                        product.id,
                        product.title,
                        selectedRating,
                        commentController.text,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('리뷰가 등록되었습니다! 마일리지 100P 적립!')),
                      );
                    }
                  },
                  child: const Text('등록'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
