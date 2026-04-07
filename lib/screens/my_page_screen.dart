import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_data_manager.dart';
import '../theme/app_tokens.dart';
import '../widgets/oud_components.dart';
import 'admin_role_management_screen.dart';
import 'coupon_list_screen.dart';
import 'login_screen.dart';
import 'mileage_history_screen.dart';
import 'review_manage_screen.dart';
import 'seller_demo_screen.dart';
import 'user_order_list_screen.dart';

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
                '로그인이 필요합니다',
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
    final paymentDone = manager.orders.where((order) => order.status == '결제완료').length;
    final preparing = manager.orders.where((order) => order.status == '배송준비').length;
    final shipping = manager.orders.where((order) => order.status == '배송중').length;
    final delivered = manager.orders.where((order) => order.status == '배송완료').length;
    final cancelRequested = manager.orders.where((order) => order.status == '취소요청').length;
    final canceled = manager.orders.where((order) => order.status == '취소완료').length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
      children: [
        Column(
          children: [
            const CircleAvatar(
              radius: 44,
              backgroundColor: Color(0xFFF2D8CB),
              child: Icon(Icons.person, size: 40, color: OudColors.primary),
            ),
            const SizedBox(height: 10),
            Text(
              '${manager.userName} 작가님',
              style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900),
            ),
            const Text(
              '지속 가능한 세라믹을 탐구합니다.',
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
                        color: Color(0xFFB56C59),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${manager.mileage}',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
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
                        color: Color(0xFF6D8A4B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${manager.availableCouponCount}',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Text(
          '나의 활동',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: OudColors.mutedText,
          ),
        ),
        const SizedBox(height: 8),
        OudMenuTile(
          icon: Icons.confirmation_number_outlined,
          iconBg: const Color(0xFFE8F0D9),
          title: '쿠폰함',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CouponListScreen()),
          ),
        ),
        OudMenuTile(
          icon: Icons.payments_outlined,
          iconBg: const Color(0xFFECE1F7),
          title: '마일리지 내역',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MileageHistoryScreen()),
          ),
        ),
        OudMenuTile(
          icon: Icons.rate_review_outlined,
          iconBg: const Color(0xFFF6DDDA),
          title: '내가 쓴 리뷰',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReviewManageScreen()),
          ),
        ),
        OudMenuTile(
          icon: Icons.local_shipping_outlined,
          iconBg: const Color(0xFFE7E7E7),
          title: '주문 및 배송 조회',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserOrderListScreen()),
          ),
        ),
        if (manager.isSeller)
          OudMenuTile(
            icon: Icons.storefront_outlined,
            iconBg: const Color(0xFFFFE9D8),
            title: '판매자 주문 관리',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SellerDemoScreen()),
            ),
          ),
        if (manager.isAdmin)
          OudMenuTile(
            icon: Icons.admin_panel_settings_outlined,
            iconBg: const Color(0xFFE1F0FF),
            title: '판매자 권한 관리',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminRoleManagementScreen(),
              ),
            ),
          ),
        const SizedBox(height: 16),
        const Text(
          '설정 및 지원',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: OudColors.mutedText,
          ),
        ),
        const SizedBox(height: 8),
        _simpleTextTile('고객센터'),
        _simpleTextTile('약관 및 정책'),
        const SizedBox(height: 6),
        TextButton(
          onPressed: () => _confirmLogout(context, manager),
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '로그아웃',
              style: TextStyle(color: Color(0xFFBD6E61)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        OudSectionCard(
          child: Wrap(
            spacing: 16,
            runSpacing: 10,
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
      ],
    );
  }

  Widget _simpleTextTile(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          const Icon(
            Icons.chevron_right_rounded,
            color: OudColors.mutedText,
            size: 20,
          ),
        ],
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
