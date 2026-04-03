import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/user_data_manager.dart';
import '../theme/app_tokens.dart';
import '../widgets/oud_components.dart';
import 'login_screen.dart';

enum CheckoutMode { single, cart }

class CheckoutScreen extends StatefulWidget {
  final CheckoutMode mode;
  final Product? product;
  final String? selectedOption;
  final int quantity;

  const CheckoutScreen.single({
    super.key,
    required this.product,
    this.selectedOption,
    this.quantity = 1,
  }) : mode = CheckoutMode.single;

  const CheckoutScreen.cart({super.key})
      : mode = CheckoutMode.cart,
        product = null,
        selectedOption = null,
        quantity = 1;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutItem {
  final Product product;
  final String? option;
  final int quantity;

  _CheckoutItem({
    required this.product,
    required this.quantity,
    required this.option,
  });
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? _addressId;
  String? _paymentId;
  String? _couponId;
  var _mileageToUse = 0;
  var _agreed = false;
  var _submitting = false;

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<UserDataManager>();
    final format = NumberFormat('#,###', 'ko_KR');
    final items = widget.mode == CheckoutMode.cart
        ? manager.items
            .map((e) => _CheckoutItem(
                  product: e.product,
                  quantity: e.quantity,
                  option: e.option,
                ))
            .toList()
        : [
            _CheckoutItem(
              product: widget.product!,
              quantity: widget.quantity,
              option: widget.selectedOption,
            )
          ];

    if (widget.mode == CheckoutMode.cart && items.isEmpty) {
      return const Scaffold(
        body: OudEmptyState(
          title: '결제할 상품이 없습니다',
          subtitle: '장바구니에서 상품을 담아주세요.',
          icon: Icons.shopping_bag_outlined,
        ),
      );
    }

    _addressId ??= manager.selectedAddress?.id;
    _paymentId ??= manager.selectedPayment?.id;

    var subtotal = 0;
    for (final item in items) {
      final sale = item.product.isSale && item.product.salePrice != null;
      subtotal += (sale ? item.product.salePrice! : item.product.price) * item.quantity;
    }

    final selectedCoupon = _couponId == null
        ? null
        : manager.coupons.firstWhere(
            (c) => c.id == _couponId,
            orElse: () => manager.coupons.first,
          );

    final couponApplicable = selectedCoupon != null &&
        !selectedCoupon.isUsed &&
        subtotal >= selectedCoupon.minOrderAmount;
    final couponDiscount =
        couponApplicable ? selectedCoupon.discountAmount : 0;
    final maxMileage = manager.mileage < (subtotal - couponDiscount)
        ? manager.mileage
        : (subtotal - couponDiscount);
    if (_mileageToUse > maxMileage) {
      _mileageToUse = maxMileage;
    }
    final total = subtotal - couponDiscount - _mileageToUse;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('주문 상품'),
            OudSectionCard(
              child: Column(
                children: items.map((item) {
                  final sale =
                      item.product.isSale && item.product.salePrice != null;
                  final unit = sale ? item.product.salePrice! : item.product.price;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: OudRadii.sm,
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: item.product.image == null
                                ? Container(color: OudColors.surface)
                                : Image.asset(
                                    item.product.image!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        Container(color: OudColors.surface),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.title,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                '${item.option ?? '기본'} · ${item.quantity}개',
                                style: const TextStyle(color: OudColors.mutedText),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₩${format.format(unit * item.quantity)}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
            _sectionTitle('배송지'),
            OudSectionCard(
              child: DropdownButtonFormField<String>(
                initialValue: _addressId,
                decoration: const InputDecoration(labelText: '배송지 선택'),
                items: manager.addresses
                    .map(
                      (a) => DropdownMenuItem(
                        value: a.id,
                        child: Text('${a.recipient} | ${a.addressLine}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _addressId = value),
              ),
            ),
            const SizedBox(height: 14),
            _sectionTitle('결제 수단'),
            OudSectionCard(
              child: DropdownButtonFormField<String>(
                initialValue: _paymentId,
                decoration: const InputDecoration(labelText: '결제 수단 선택'),
                items: manager.paymentMethods
                    .map(
                      (p) => DropdownMenuItem(
                        value: p.id,
                        child: Text(p.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _paymentId = value),
              ),
            ),
            const SizedBox(height: 14),
            _sectionTitle('쿠폰 및 마일리지'),
            OudSectionCard(
              child: Column(
                children: [
                  DropdownButtonFormField<String?>(
                    initialValue: _couponId,
                    decoration: const InputDecoration(labelText: '쿠폰 선택'),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('쿠폰 사용 안 함'),
                      ),
                      ...manager.coupons.where((c) => !c.isUsed).map(
                            (c) => DropdownMenuItem<String?>(
                              value: c.id,
                              child: Text(
                                '${c.title} (₩${format.format(c.discountAmount)})',
                              ),
                            ),
                          ),
                    ],
                    onChanged: (value) => setState(() => _couponId = value),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _mileageToUse.toDouble(),
                          max: maxMileage.toDouble(),
                          onChanged: (value) {
                            setState(() => _mileageToUse = value.toInt());
                          },
                        ),
                      ),
                      Text(
                        '${format.format(_mileageToUse)}P',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => setState(() => _mileageToUse = maxMileage),
                      child: const Text('최대 사용'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            OudSectionCard(
              child: CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _agreed,
                onChanged: (value) => setState(() => _agreed = value ?? false),
                title: const Text('구매 동의 (필수)'),
              ),
            ),
            const SizedBox(height: 14),
            OudSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _priceRow('상품 금액', subtotal, format),
                  _priceRow('쿠폰 할인', -couponDiscount, format),
                  _priceRow('마일리지', -_mileageToUse, format),
                  const Divider(),
                  _priceRow('최종 결제 금액', total, format, emphasize: true),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          color: OudColors.bg,
          child: manager.isLoggedIn
              ? ElevatedButton(
                  onPressed: _submitting
                      ? null
                      : () async {
                          if (_addressId == null || _paymentId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('배송지와 결제수단을 선택해 주세요.')),
                            );
                            return;
                          }
                          if (!_agreed) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('구매 동의가 필요합니다.')),
                            );
                            return;
                          }

                          setState(() => _submitting = true);
                          try {
                            final address = manager.addresses.firstWhere(
                              (a) => a.id == _addressId,
                              orElse: () => manager.addresses.first,
                            );
                            final payment = manager.paymentMethods.firstWhere(
                              (p) => p.id == _paymentId,
                              orElse: () => manager.paymentMethods.first,
                            );

                            if (widget.mode == CheckoutMode.cart) {
                              manager.placeOrderFromCart(
                                couponId: couponDiscount > 0 ? _couponId : null,
                                mileageUsed: _mileageToUse,
                                address: address,
                                payment: payment,
                                agreementAccepted: true,
                              );
                            } else {
                              manager.placeSingleOrder(
                                widget.product!,
                                option: widget.selectedOption,
                                quantity: widget.quantity,
                                couponId: couponDiscount > 0 ? _couponId : null,
                                mileageUsed: _mileageToUse,
                                address: address,
                                payment: payment,
                                agreementAccepted: true,
                              );
                              manager.removeFromCart(
                                widget.product!,
                                option: widget.selectedOption,
                              );
                            }
                            if (!mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('주문이 완료되었습니다.')),
                            );
                          } finally {
                            if (mounted) {
                              setState(() => _submitting = false);
                            }
                          }
                        },
                  child: Text(_submitting ? '처리 중...' : '결제하기'),
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
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _priceRow(
    String label,
    int amount,
    NumberFormat format, {
    bool emphasize = false,
  }) {
    final color = emphasize ? OudColors.primary : OudColors.text;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: emphasize ? OudColors.text : OudColors.mutedText,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            '₩${format.format(amount)}',
            style: TextStyle(
              color: color,
              fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
              fontSize: emphasize ? 22 : 16,
            ),
          ),
        ],
      ),
    );
  }
}
