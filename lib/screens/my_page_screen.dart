import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/user_data_manager.dart';
import 'login_screen.dart';
import 'wishlist_screen.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userManager = Provider.of<UserDataManager>(context);
    final purchasedItems = userManager.purchasedProducts;
    final priceFormat = NumberFormat('#,###', 'ko_KR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (userManager.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _showLogoutConfirmDialog(context, userManager),
            ),
        ],
      ),
      body: userManager.isLoggedIn
          ? _buildFullMyPage(context, userManager, purchasedItems, priceFormat)
          : _buildLoginPrompt(context),
    );
  }

  // --- 1. 로그인 유도 화면 ---
  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle_outlined,
              size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          const Text('로그인이 필요한 서비스입니다.', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child:
                const Text('로그인하러 가기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- 2. 로그인 후 전체 UI ---
  Widget _buildFullMyPage(
      BuildContext context, userManager, purchasedItems, priceFormat) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileSection(context, userManager),
          const Divider(thickness: 8, color: Color(0xFFF5F5F5)),
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
          purchasedItems.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: Text('구매한 상품이 없습니다.')),
                )
              : ListView.builder(
                  shrinkWrap: true,
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
                          child: product.image != null
                              ? Image.asset(product.image!,
                                  width: 60, height: 60, fit: BoxFit.cover)
                              : Container(
                                  width: 60, height: 60, color: Colors.grey),
                        ),
                        title: Text(product.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('${priceFormat.format(product.price)}원'),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _showReviewDialog(
                                  context, product, userManager),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.deepPurple,
                                side:
                                    const BorderSide(color: Colors.deepPurple),
                                elevation: 0,
                                minimumSize: const Size(80, 30),
                              ),
                              child: const Text('리뷰 쓰기',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () {/* 상세 페이지 이동 */},
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  // --- 3. 프로필 섹션 위젯 ---
  Widget _buildProfileSection(
      BuildContext context, UserDataManager userManager) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
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
                  // ✅ 수정 포인트: const 삭제
                  Text('${userManager.userName}님',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoChip('마일리지', '${userManager.mileage}P'),
                      const SizedBox(width: 8),
                      _buildInfoChip('후기', '${userManager.reviewCount}건'),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WishlistScreen())),
              icon: const Icon(Icons.favorite, size: 18, color: Colors.red),
              label: const Text('찜한 상품 보기'),
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  foregroundColor: Colors.red),
            ),
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
  }

  // --- 4. 리뷰 작성 팝업창 ---
  void _showReviewDialog(BuildContext context, product, userManager) {
    final TextEditingController commentController = TextEditingController();
    double selectedRating = 5.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
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
                            color: Colors.amber),
                        onPressed: () =>
                            setState(() => selectedRating = index + 1.0),
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
                      userManager.addReview(product.id, product.title,
                          selectedRating, commentController.text);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('리뷰가 등록되었습니다! 마일리지 100P 적립!')));
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

  // --- 5. 로그아웃 확인 팝업 ---
  void _showLogoutConfirmDialog(
      BuildContext context, UserDataManager userManager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () {
              userManager.logout();
              Navigator.pop(context);
            },
            child: const Text('로그아웃', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
