import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/user_data_manager.dart';

// 쿠폰 목록 화면
class CouponListScreen extends StatelessWidget {
  const CouponListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<UserDataManager>();
    final format = NumberFormat('#,###', 'ko_KR');
    final coupons = manager.coupons.where((c) => !c.isUsed).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('쿠폰 목록'), centerTitle: true),
      body: coupons.isEmpty
          ? const Center(child: Text('사용 가능한 쿠폰이 없습니다.'))
          : ListView.builder(
              itemCount: coupons.length,
              itemBuilder: (context, index) {
                final coupon = coupons[index];
                final categories = coupon.allowedCategories.isEmpty
                    ? '전체'
                    : coupon.allowedCategories.join(', ');
                final products = coupon.allowedProductIds.isEmpty
                    ? '전체'
                    : coupon.allowedProductIds.join(', ');

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(coupon.title,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '${format.format(coupon.discountAmount)}원 할인 · ${format.format(coupon.minOrderAmount)}원 이상\n'
                        '카테고리: $categories · 상품: $products'),
                  ),
                );
              },
            ),
    );
  }
}
