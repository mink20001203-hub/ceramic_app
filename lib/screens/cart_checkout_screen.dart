import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/user_data_manager.dart';
import 'login_screen.dart';

class CartCheckoutScreen extends StatefulWidget {
  const CartCheckoutScreen({super.key});

  @override
  State<CartCheckoutScreen> createState() => _CartCheckoutScreenState();
}

class _CartCheckoutScreenState extends State<CartCheckoutScreen> {
  final TextEditingController _mileageController =
      TextEditingController(text: '0');
  bool _isAgreementChecked = false;
  bool _isSubmitting = false;
  String? _selectedCouponId;
  String? _selectedAddressId;
  String? _selectedPaymentId;

  @override
  void dispose() {
    _mileageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<UserDataManager>();
    final format = NumberFormat('#,###', 'ko_KR');
    final items = manager.items;
    final subtotal = items.fold<int>(0, (sum, item) {
      final unitPrice = (item.product.isSale && item.product.salePrice != null)
          ? item.product.salePrice!
          : item.product.price;
      return sum + unitPrice * item.quantity;
    });

    _selectedAddressId ??= manager.selectedAddress?.id;
    _selectedPaymentId ??= manager.selectedPayment?.id;

    final coupon = _selectedCouponId == null
        ? null
        : manager.coupons.firstWhere(
            (c) => c.id == _selectedCouponId,
            orElse: () => manager.coupons.first,
          );

    final couponApplicable = coupon == null
        ? false
        : (!coupon.isUsed &&
            subtotal >= coupon.minOrderAmount &&
            (coupon.allowedCategories.isEmpty ||
                items.any((i) =>
                    coupon.allowedCategories.contains(i.product.category))) &&
            (coupon.allowedProductIds.isEmpty ||
                items.any(
                    (i) => coupon.allowedProductIds.contains(i.product.id))));

    final couponDiscount = couponApplicable ? coupon!.discountAmount : 0;
    final requestedMileage =
        int.tryParse(_mileageController.text.replaceAll(',', '')) ?? 0;
    final maxMileage = manager.mileage < (subtotal - couponDiscount)
        ? manager.mileage
        : (subtotal - couponDiscount);
    final mileageToUse = requestedMileage.clamp(0, maxMileage);
    final total = subtotal - couponDiscount - mileageToUse;

    return Scaffold(
      appBar: AppBar(title: const Text('장바구니 결제'), centerTitle: true),
      body: items.isEmpty
          ? const Center(child: Text('장바구니가 비어 있습니다.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('주문 상품',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...items.map(
                    (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.product.title),
                      subtitle: Text(
                        '${item.option ?? '기본'} · ${item.quantity}개',
                      ),
                      trailing: Text(
                        '${format.format((((item.product.isSale && item.product.salePrice != null) ? item.product.salePrice! : item.product.price) * item.quantity))}원',
                      ),
                    ),
                  ),
                  const Divider(),
                  const Text('배송지',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedAddressId,
                    items: manager.addresses
                        .map((a) => DropdownMenuItem(
                              value: a.id,
                              child: Text('${a.recipient} | ${a.phone}'),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedAddressId = value),
                  ),
                  const SizedBox(height: 16),
                  const Text('결제 수단',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedPaymentId,
                    items: manager.paymentMethods
                        .map((p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(p.label),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedPaymentId = value),
                  ),
                  const Divider(height: 32),
                  const Text('쿠폰',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  RadioListTile<String?>(
                    value: null,
                    groupValue: _selectedCouponId,
                    onChanged: (_) => setState(() => _selectedCouponId = null),
                    title: const Text('쿠폰 사용 안 함'),
                    dense: true,
                  ),
                  ...manager.coupons.where((c) => !c.isUsed).map(
                        (c) => RadioListTile<String?>(
                          value: c.id,
                          groupValue: _selectedCouponId,
                          onChanged: (value) =>
                              setState(() => _selectedCouponId = value),
                          title: Text(c.title),
                          subtitle: Text(
                              '${format.format(c.discountAmount)}원 할인 · ${format.format(c.minOrderAmount)}원 이상'),
                          dense: true,
                        ),
                      ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _mileageController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: '마일리지 사용',
                            hintText: '보유 ${manager.mileage}P',
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            final raw = value.replaceAll(',', '');
                            final parsed = int.tryParse(raw) ?? 0;
                            final clamped = parsed.clamp(0, maxMileage);
                            final formatted = format.format(clamped);
                            _mileageController.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(
                                  offset: formatted.length),
                            );
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          _mileageController.text = format.format(maxMileage);
                          setState(() {});
                        },
                        child: const Text('최대 사용'),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _isAgreementChecked,
                    onChanged: (value) =>
                        setState(() => _isAgreementChecked = value ?? false),
                    title: const Text('구매동의(필수) 전자상거래법 제8조 2항'),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('상품 합계: ${format.format(subtotal)}원'),
                        Text('쿠폰 할인: -${format.format(couponDiscount)}원'),
                        Text('마일리지 사용: -${format.format(mileageToUse)}원'),
                        const SizedBox(height: 8),
                        Text(
                          '최종 결제 금액: ${format.format(total)}원',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: manager.isLoggedIn
            ? ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        if (_selectedAddressId == null ||
                            _selectedPaymentId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('배송지와 결제수단을 선택해주세요.')),
                          );
                          return;
                        }
                        if (!_isAgreementChecked) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('구매동의가 필요합니다.')),
                          );
                          return;
                        }
                        final hasSoldOut =
                            items.any((item) => item.product.stock == 0);
                        final overStock =
                            items.any((item) => item.quantity > item.product.stock);
                        if (hasSoldOut || overStock) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('재고를 확인해주세요. 품절 상품이 있습니다.')),
                          );
                          return;
                        }

                        setState(() => _isSubmitting = true);
                        try {
                          final address = manager.addresses.firstWhere(
                            (a) => a.id == _selectedAddressId,
                            orElse: () => manager.addresses.first,
                          );
                          final payment = manager.paymentMethods.firstWhere(
                            (p) => p.id == _selectedPaymentId,
                            orElse: () => manager.paymentMethods.first,
                          );

                          manager.placeOrderFromCart(
                            couponId: couponDiscount > 0 ? _selectedCouponId : null,
                            mileageUsed: mileageToUse,
                            address: address,
                            payment: payment,
                            agreementAccepted: true,
                          );
                          if (!mounted) return;
                          manager.setTabIndex(3);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('주문이 완료되었습니다.')),
                          );
                        } finally {
                          if (mounted) {
                            setState(() => _isSubmitting = false);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: Text(_isSubmitting ? '처리 중...' : '결제하기'),
              )
            : OutlinedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                  if (mounted) setState(() {});
                },
                child: const Text('로그인 후 결제하기'),
              ),
      ),
    );
  }
}
