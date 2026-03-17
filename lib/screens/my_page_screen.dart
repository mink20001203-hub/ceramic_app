import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/user_data_manager.dart';
import '../models/product.dart';
import 'login_screen.dart';

// 마이페이지: 로그인 상태, 구매 내역, 리뷰 작성/수정을 관리한다.
class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userManager = Provider.of<UserDataManager>(context);
    final orders = userManager.orders;
    final purchasedItems = userManager.purchasedProducts;
    final priceFormat = NumberFormat('#,###', 'ko_KR');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            const Text('마이페이지', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          if (userManager.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout_outlined),
              onPressed: () => _showLogoutConfirmDialog(context, userManager),
            ),
        ],
      ),
      body: userManager.isLoggedIn
          ? _buildFullMyPage(
              context, userManager, orders, purchasedItems, priceFormat)
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6342E8),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child:
                const Text('로그인하러 가기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- 2. 로그인 후 전체 UI ---
  Widget _buildFullMyPage(
      BuildContext context,
      UserDataManager userManager,
      List<Order> orders,
      List<Product> purchasedItems,
      NumberFormat priceFormat) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileSection(context, userManager),
          const Divider(thickness: 8, color: Color(0xFFF5F5F5)),
          _buildOrderSection(orders, priceFormat),
          const Divider(thickness: 8, color: Color(0xFFF5F5F5)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_outlined,
                    color: Color(0xFF6342E8)),
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
                    final bool hasReview = userManager.hasReview(product.id);

                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: product.image != null
                              ? Image.asset(product.image!,
                                  width: 70, height: 70, fit: BoxFit.cover)
                              : Container(
                                  width: 70, height: 70, color: Colors.grey),
                        ),
                        title: Text(product.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                                '${priceFormat.format((product.isSale && product.salePrice != null) ? product.salePrice! : product.price)}원',
                                style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => _showReviewDialog(
                                  context, product,
                                  existingReview:
                                      userManager.getReview(product.id)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: hasReview
                                    ? Colors.white
                                    : const Color(0xFF6342E8),
                                foregroundColor: hasReview
                                    ? const Color(0xFF6342E8)
                                    : Colors.white,
                                side:
                                    const BorderSide(color: Color(0xFF6342E8)),
                                elevation: 0,
                                minimumSize: const Size(100, 36),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(hasReview ? '리뷰 수정하기' : '리뷰 쓰기',
                                  style: const TextStyle(fontSize: 13)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  // --- 2-1. 주문 내역 섹션 ---
  Widget _buildOrderSection(List<Order> orders, NumberFormat priceFormat) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_outlined, color: Color(0xFF6342E8)),
              const SizedBox(width: 8),
              const Text('주문 내역',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('총 ${orders.length}건',
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          if (orders.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('주문 내역이 없습니다.',
                  style: TextStyle(color: Colors.grey)),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[orders.length - 1 - index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    onTap: () =>
                        _showOrderDetailSheet(context, order, priceFormat),
                    title: Text('주문번호 ${order.id}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${DateFormat('yyyy.MM.dd').format(order.date)} · ${order.status}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Text(
                      '${priceFormat.format(order.totalAmount)}원',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6342E8)),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // --- 3. 프로필 및 대시보드 ---
  Widget _buildProfileSection(
      BuildContext context, UserDataManager userManager) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Text('${userManager.userName}님',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              const Icon(Icons.settings_outlined, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('마일리지', '${userManager.mileage}P'),
                Container(width: 1, height: 20, color: Colors.grey[300]),
                _buildStatItem('나의 리뷰', '${userManager.reviewCount}'),
                Container(width: 1, height: 20, color: Colors.grey[300]),
                _buildStatItem('쿠폰', '3'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6342E8))),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  // --- 4. 사진 첨부 기능이 포함된 리뷰 팝업 ---
  void _showReviewDialog(BuildContext context, Product product,
      {Review? existingReview}) {
    final userManager = Provider.of<UserDataManager>(context, listen: false);
    final TextEditingController controller =
        TextEditingController(text: existingReview?.comment ?? "");
    double rating = existingReview?.rating ?? 5.0;
    String? pickedImagePath = existingReview?.imagePath;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(existingReview != null ? '후기 수정하기' : '후기 작성하기'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                      5,
                      (index) => IconButton(
                            icon: Icon(
                                index < rating ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 32),
                            onPressed: () =>
                                setDialogState(() => rating = index + 1.0),
                          )),
                ),
                const SizedBox(height: 15),

                // 📷 사진 첨부 섹션
                InkWell(
                  onTap: () {
                    setDialogState(() => pickedImagePath = product.image);
                  },
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: pickedImagePath != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(pickedImagePath!,
                                    width: double.infinity, fit: BoxFit.cover),
                              ),
                              // ✅ 에러 해결: Position -> Positioned 로 수정
                              const Positioned(
                                  right: 5,
                                  top: 5,
                                  child: Icon(Icons.check_circle,
                                      color: Color(0xFF6342E8))),
                            ],
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined,
                                  color: Colors.grey, size: 30),
                              SizedBox(height: 5),
                              Text('사진 첨부하기',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: controller,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: '내용을 입력해주세요.',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6342E8)),
              onPressed: () {
                if (existingReview != null) {
                  userManager.updateReview(
                      product.id, rating, controller.text, pickedImagePath);
                } else {
                  userManager.addReview(
                      product.id, product.title, rating, controller.text,
                      imagePath: pickedImagePath);
                }
                Navigator.pop(context);
              },
              child: Text(existingReview != null ? '수정 완료' : '등록하기',
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetailSheet(
      BuildContext context, Order order, NumberFormat priceFormat) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Consumer<UserDataManager>(
          builder: (context, manager, child) {
            final freshOrder =
                manager.orders.firstWhere((o) => o.id == order.id);
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('주문번호 ${freshOrder.id}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                      '${DateFormat('yyyy.MM.dd').format(freshOrder.date)} · ${freshOrder.status}',
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  const Text('상태 로그',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  ...freshOrder.statusLogs.map(
                    (log) => Text(
                      '${DateFormat('MM.dd HH:mm').format(log.date)} · ${log.status}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (freshOrder.status != '배송완료')
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () =>
                            manager.advanceOrderStatus(freshOrder.id),
                        child: const Text('다음 상태로 변경'),
                      ),
                    ),
                  const Divider(),
                  const Text('주문 상품',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: freshOrder.items.length,
                    itemBuilder: (context, index) {
                      final item = freshOrder.items[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.product.title),
                        subtitle: Text(
                            '옵션: ${item.option ?? '기본'} · 수량: ${item.quantity}'),
                        trailing: Text(
                          '${priceFormat.format(item.unitPrice * item.quantity)}원',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('총 결제금액',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${priceFormat.format(freshOrder.totalAmount)}원',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6342E8))),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

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
