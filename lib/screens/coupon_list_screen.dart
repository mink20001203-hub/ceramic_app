import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/user_data_manager.dart';

class CouponListScreen extends StatelessWidget {
  const CouponListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<UserDataManager>();
    final coupons = manager.coupons;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(title: const Text('쿠폰함'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '보유 쿠폰',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Color(0xFF303330),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '사용 가능한 혜택을 먼저 확인하세요.',
              style: TextStyle(color: Color(0xFF5D605C)),
            ),
            const SizedBox(height: 20),
            if (coupons.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(child: Text('사용 가능한 쿠폰이 없습니다.')),
              )
            else
              ...coupons.map((coupon) => _CouponTicket(coupon: coupon)),
          ],
        ),
      ),
    );
  }
}

class _CouponTicket extends StatelessWidget {
  final Coupon coupon;

  const _CouponTicket({required this.coupon});

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat('#,###', 'ko_KR');
    final isUsed = coupon.isUsed;
    final leftColor = isUsed ? const Color(0xFFB1B2AF) : _accentColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 112,
              decoration: BoxDecoration(
                color: leftColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  bottomLeft: Radius.circular(28),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isUsed ? 'USED' : _leftValue(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _leftLabel(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coupon.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF303330),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${format.format(coupon.minOrderAmount)}원 이상 주문 시 사용 가능',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5D605C),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isUsed
                                ? const Color(0xFFEEEEEA)
                                : const Color(0xFFF76A80).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            isUsed ? '사용 완료' : '사용 가능',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isUsed
                                  ? const Color(0xFF797B78)
                                  : const Color(0xFFAC3149),
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (!isUsed)
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF303330),
                              foregroundColor: const Color(0xFFFAF9F6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: const Text('Use Now'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _accentColor() {
    if (coupon.discountAmount >= 10000) {
      return const Color(0xFFA53C2C);
    }
    if (coupon.discountAmount == 0) {
      return const Color(0xFF645884);
    }
    return const Color(0xFF797B78);
  }

  String _leftValue() {
    if (coupon.discountAmount > 0) {
      return '${((coupon.discountAmount / 1000).round())}K';
    }
    return 'FREE';
  }

  String _leftLabel() {
    return coupon.discountAmount > 0 ? 'DISCOUNT' : 'SHIPPING';
  }
}
