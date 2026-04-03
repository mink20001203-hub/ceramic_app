import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_data_manager.dart';
import '../theme/app_tokens.dart';
import '../widgets/oud_components.dart';
import 'admin_role_management_screen.dart';
import 'coupon_list_screen.dart';
import 'login_screen.dart';
import 'review_manage_screen.dart';
import 'seller_demo_screen.dart';
import 'wishlist_screen.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<UserDataManager>();
    if (!manager.isLoggedIn) {
      return _loggedOut(context);
    }
    return _loggedIn(context, manager);
  }

  Widget _loggedOut(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: OudSectionCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: OudColors.surface,
                child: Icon(Icons.person_outline, color: OudColors.mutedText),
              ),
              const SizedBox(height: 12),
              const Text(
                '로그인이 필요합니다.',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                '주문 내역, 쿠폰, 리뷰 관리 기능을 사용할 수 있습니다.',
                style: TextStyle(color: OudColors.mutedText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                child: const Text('로그인'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loggedIn(BuildContext context, UserDataManager manager) {
    final paymentDone = manager.orders.where((o) => o.status == '결제완료').length;
    final preparing = manager.orders.where((o) => o.status == '배송준비').length;
    final shipping = manager.orders.where((o) => o.status == '배송중').length;
    final delivered = manager.orders.where((o) => o.status == '배송완료').length;
    final cancelRequested = manager.orders.where((o) => o.status == '취소요청').length;
    final canceled = manager.orders.where((o) => o.status == '취소완료').length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        Column(
          children: [
            const CircleAvatar(
              radius: 44,
              backgroundColor: OudColors.primarySoft,
              child: Icon(Icons.person, size: 40, color: OudColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              '${manager.userName} 님',
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
            ),
            const Text(
              '지속 가능한 세라믹을 탐색해 보세요.',
              style: TextStyle(color: OudColors.mutedText),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OudSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'POINT',
                      style: TextStyle(
                        color: OudColors.mutedText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${manager.mileage}',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OudSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'COUPON',
                      style: TextStyle(
                        color: OudColors.mutedText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${manager.availableCouponCount}',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _menuTile(
          icon: Icons.confirmation_number_outlined,
          title: '쿠폰함',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CouponListScreen()),
          ),
        ),
        _menuTile(
          icon: Icons.star_border_rounded,
          title: '마일리지 내역',
          onTap: () {},
        ),
        _menuTile(
          icon: Icons.rate_review_outlined,
          title: '내가 쓴 리뷰',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReviewManageScreen()),
          ),
        ),
        _menuTile(
          icon: Icons.favorite_border_rounded,
          title: '찜한 상품',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WishlistScreen()),
          ),
        ),
        if (manager.isSeller)
          _menuTile(
            icon: Icons.storefront_outlined,
            title: '판매자 데모 관리',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SellerDemoScreen()),
            ),
          ),
        if (manager.isAdmin)
          _menuTile(
            icon: Icons.admin_panel_settings_outlined,
            title: '판매자 권한 관리',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminRoleManagementScreen(),
              ),
            ),
          ),
        const SizedBox(height: 18),
        const Text(
          '주문 및 배송',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: OudColors.text,
          ),
        ),
        const SizedBox(height: 8),
        OudSectionCard(
          child: Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _status('결제완료', paymentDone),
              _status('배송준비', preparing),
              _status('배송중', shipping),
              _status('배송완료', delivered),
              _status('취소요청', cancelRequested),
              _status('취소완료', canceled),
            ],
          ),
        ),
        const SizedBox(height: 18),
        TextButton(
          onPressed: () => _confirmLogout(context, manager),
          child: const Text(
            '로그아웃',
            style: TextStyle(color: OudColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: OudRadii.lg,
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: OudColors.border),
              borderRadius: OudRadii.lg,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: OudColors.surface,
                  child: Icon(icon, size: 16, color: OudColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: OudColors.mutedText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _status(String label, int count) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            color: count > 0 ? OudColors.primary : OudColors.mutedText,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: OudColors.mutedText),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context, UserDataManager manager) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('현재 계정에서 로그아웃할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              manager.logout();
              Navigator.pop(context);
            },
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }
}
