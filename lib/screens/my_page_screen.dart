import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_data_manager.dart';
import 'coupon_list_screen.dart';
import 'login_screen.dart';
import 'review_manage_screen.dart';
import 'wishlist_screen.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userManager = context.watch<UserDataManager>();

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F4),
      appBar: AppBar(
        title: const Text('OUD'),
        centerTitle: true,
        actions: [
          if (userManager.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout_outlined),
              onPressed: () => _showLogoutConfirmDialog(context, userManager),
            ),
        ],
      ),
      body: userManager.isLoggedIn
          ? _buildProfileDashboard(context, userManager)
          : _buildLoginPrompt(context),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: Color(0xFFF0EDE9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                size: 44,
                color: Color(0xFF864D34),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '로그인이 필요한 서비스입니다.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C1C19),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '쿠폰과 주문 상태, 리뷰 관리를 한 곳에서 확인하세요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF52443E)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(220, 52),
                backgroundColor: const Color(0xFF864D34),
              ),
              child: const Text('로그인하러 가기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDashboard(
    BuildContext context,
    UserDataManager userManager,
  ) {
    final paymentDone =
        userManager.orders.where((o) => o.status == '결제완료').length;
    final preparing =
        userManager.orders.where((o) => o.status == '배송준비').length;
    final shipping =
        userManager.orders.where((o) => o.status == '배송중').length;
    final delivered =
        userManager.orders.where((o) => o.status == '배송완료').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBE8E3),
                      borderRadius: BorderRadius.circular(44),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      userManager.userName.isNotEmpty
                          ? userManager.userName.substring(0, 1)
                          : 'O',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF864D34),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xFF864D34),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          userManager.userName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1C1C19),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCE7C5),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Gold Atelier',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF414A31),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '차분한 취향의 도자기 컬렉션을 모으는 중입니다.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF52443E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _wideStatCard(
                  title: 'Membership Status',
                  value:
                      '다음 등급까지 ${_formatNumber(23400 - userManager.mileage)}P 남음',
                  icon: Icons.loyalty_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _smallStatCard(
                  title: 'Points',
                  value: '${_formatNumber(userManager.mileage)}P',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _smallStatCard(
                  title: 'Coupons',
                  value: '${userManager.availableCouponCount}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),
          Row(
            children: [
              const Text(
                '주문 및 배송 현황',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C19),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('전체보기'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _orderStatusItem(
                    label: '결제완료',
                    count: paymentDone,
                    icon: Icons.shopping_bag_outlined,
                    active: paymentDone > 0,
                  ),
                ),
                _statusDivider(),
                Expanded(
                  child: _orderStatusItem(
                    label: '배송준비',
                    count: preparing,
                    icon: Icons.inventory_2_outlined,
                    active: preparing > 0,
                  ),
                ),
                _statusDivider(),
                Expanded(
                  child: _orderStatusItem(
                    label: '배송중',
                    count: shipping,
                    icon: Icons.local_shipping_outlined,
                    active: shipping > 0,
                  ),
                ),
                _statusDivider(),
                Expanded(
                  child: _orderStatusItem(
                    label: '배송완료',
                    count: delivered,
                    icon: Icons.task_alt_outlined,
                    active: delivered > 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          const Text(
            '마이 메뉴',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1C19),
            ),
          ),
          const SizedBox(height: 16),
          _menuTile(
            context,
            icon: Icons.rate_review_outlined,
            title: '나의 상품 리뷰',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReviewManageScreen()),
            ),
          ),
          _menuTile(
            context,
            icon: Icons.favorite_border,
            title: '찜한 상품',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WishlistScreen()),
            ),
          ),
          _menuTile(
            context,
            icon: Icons.confirmation_number_outlined,
            title: '쿠폰함',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CouponListScreen()),
            ),
          ),
          _menuTile(
            context,
            icon: Icons.contact_support_outlined,
            title: '1:1 문의',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('문의 기능은 준비 중입니다.')),
              );
            },
          ),
          const SizedBox(height: 10),
          _menuTile(
            context,
            icon: Icons.settings_outlined,
            title: '회원 정보 설정',
            subdued: true,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('설정 화면은 준비 중입니다.')),
              );
            },
          ),
          const SizedBox(height: 28),
          Center(
            child: TextButton(
              onPressed: () => _showLogoutConfirmDialog(context, userManager),
              child: const Text(
                'LOGOUT',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _wideStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3EE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: Color(0xFF52443E),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1C19),
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: const Color(0xFF864D34), size: 28),
        ],
      ),
    );
  }

  Widget _smallStatCard({
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: Color(0xFF52443E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF864D34),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderStatusItem({
    required String label,
    required int count,
    required IconData icon,
    required bool active,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: active ? const Color(0xFFA3654A) : const Color(0xFFF0EDE9),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: active ? Colors.white : const Color(0xFF52443E),
            size: 22,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: Color(0xFF52443E)),
        ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: active ? const Color(0xFF864D34) : const Color(0xFF9A938C),
          ),
        ),
      ],
    );
  }

  Widget _statusDivider() {
    return Container(
      width: 1,
      height: 40,
      color: const Color(0xFFD7C2BA).withOpacity(0.35),
      margin: const EdgeInsets.symmetric(horizontal: 6),
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool subdued = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: subdued ? const Color(0xFF7F776F) : const Color(0xFF52443E),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: subdued ? const Color(0xFF7F776F) : const Color(0xFF1C1C19),
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF9A938C),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatNumber(int value) {
    final text = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final reverseIndex = text.length - i;
      buffer.write(text[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }

  void _showLogoutConfirmDialog(
    BuildContext context,
    UserDataManager userManager,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              userManager.logout();
              Navigator.pop(context);
            },
            child: const Text(
              '로그아웃',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
