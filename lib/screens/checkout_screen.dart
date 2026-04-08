import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/user_data_manager.dart';
import '../theme/app_tokens.dart';
import '../widgets/oud_components.dart';
import 'login_screen.dart';
import 'order_complete_screen.dart';

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
  _CheckoutItem({required this.product, required this.quantity, required this.option});
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? _addressId;
  String? _paymentId;
  String? _couponId;
  int _mileageToUse = 0;
  bool _agreed = false;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<UserDataManager>();
    final format = NumberFormat('#,###', 'ko_KR');

    final items = widget.mode == CheckoutMode.cart
        ? manager.items
            .map((item) => _CheckoutItem(
                  product: item.product,
                  quantity: item.quantity,
                  option: item.option,
                ))
            .toList()
        : [
            _CheckoutItem(
              product: widget.product!,
              quantity: widget.quantity,
              option: widget.selectedOption,
            ),
          ];

    if (widget.mode == CheckoutMode.cart && items.isEmpty) {
      return const Scaffold(
        body: OudEmptyState(
          title: '결제할 상품이 없습니다',
          subtitle: '장바구니에서 상품을 담아 주세요.',
          icon: Icons.shopping_bag_outlined,
        ),
      );
    }

    _addressId ??= manager.selectedAddress?.id;
    _paymentId ??= manager.selectedPayment?.id;

    int subtotal = 0;
    for (final item in items) {
      final sale = item.product.isSale && item.product.salePrice != null;
      subtotal += (sale ? item.product.salePrice! : item.product.price) * item.quantity;
    }

    final selectedCoupon = _couponId == null
        ? null
        : manager.coupons.firstWhere(
            (coupon) => coupon.id == _couponId,
            orElse: () => manager.coupons.first,
          );
    final couponApplicable = selectedCoupon != null &&
        !selectedCoupon.isUsed &&
        subtotal >= selectedCoupon.minOrderAmount;
    final couponDiscount = couponApplicable ? selectedCoupon.discountAmount : 0;
    final shippingFee = subtotal >= 50000 ? 0 : 3000;
    final maxMileage = manager.mileage < (subtotal + shippingFee - couponDiscount)
        ? manager.mileage
        : (subtotal + shippingFee - couponDiscount);
    if (_mileageToUse > maxMileage) _mileageToUse = maxMileage;
    final total = subtotal + shippingFee - couponDiscount - _mileageToUse;

    return Scaffold(
      appBar: AppBar(
        title: const Text('OUD'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 150),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Checkout', style: TextStyle(fontSize: 35, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            const Text(
              '주문서를 작성하고 결제를 완료해 주세요.',
              style: TextStyle(color: OudColors.mutedText),
            ),
            const SizedBox(height: 18),
            const OudStepTitle(step: 1, title: '주문 상품'),
            OudSectionCard(
              child: Column(
                children: items.map((item) {
                  final sale = item.product.isSale && item.product.salePrice != null;
                  final unit = sale ? item.product.salePrice! : item.product.price;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: OudRadii.sm,
                          child: SizedBox(
                            width: 54,
                            height: 54,
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
                              Text(item.product.title,
                                  style: const TextStyle(fontWeight: FontWeight.w700)),
                              Text(
                                '${item.option ?? '기본'} / ${item.quantity}개',
                                style: const TextStyle(color: OudColors.mutedText),
                              ),
                            ],
                          ),
                        ),
                        Text('₩${format.format(unit * item.quantity)}',
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            const OudStepTitle(step: 2, title: '배송 정보'),
            OudSectionCard(
              child: DropdownButtonFormField<String>(
                initialValue: _addressId,
                decoration: const InputDecoration(labelText: '배송지 선택'),
                items: manager.addresses
                    .map(
                      (address) => DropdownMenuItem(
                        value: address.id,
                        child: Text('${address.recipient} | ${address.addressLine}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _addressId = value),
              ),
            ),
            const SizedBox(height: 12),
            const OudStepTitle(step: 3, title: '쿠폰 및 마일리지'),
            OudSectionCard(
              child: Column(
                children: [
                  DropdownButtonFormField<String?>(
                    initialValue: _couponId,
                    decoration: const InputDecoration(labelText: '쿠폰 적용'),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('쿠폰 사용 안 함'),
                      ),
                      ...manager.coupons.where((coupon) => !coupon.isUsed).map(
                            (coupon) => DropdownMenuItem<String?>(
                              value: coupon.id,
                              child: Text('${coupon.title} (₩${format.format(coupon.discountAmount)})'),
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
                          onChanged: (value) => setState(() => _mileageToUse = value.toInt()),
                        ),
                      ),
                      Text('${format.format(_mileageToUse)}P',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => setState(() => _mileageToUse = maxMileage),
                      child: const Text('전액 사용'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const OudStepTitle(step: 4, title: '결제 수단'),
            OudSectionCard(
              child: DropdownButtonFormField<String>(
                initialValue: _paymentId,
                decoration: const InputDecoration(labelText: '결제 수단 선택'),
                items: manager.paymentMethods
                    .map((payment) => DropdownMenuItem(value: payment.id, child: Text(payment.label)))
                    .toList(),
                onChanged: (value) => setState(() => _paymentId = value),
              ),
            ),
            const SizedBox(height: 12),
            OudSectionCard(
              child: CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _agreed,
                onChanged: (value) => setState(() => _agreed = value ?? false),
                title: const Text('구매 조건 및 결제 진행에 동의합니다.'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: OudColors.panelDark,
                borderRadius: OudRadii.lg,
              ),
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('결제 금액',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  OudAmountRow(label: '총 상품 금액', value: '₩${format.format(subtotal)}', dark: true),
                  OudAmountRow(label: '배송비', value: '₩${format.format(shippingFee)}', dark: true),
                  OudAmountRow(label: '쿠폰 할인', value: '-₩${format.format(couponDiscount)}', dark: true),
                  OudAmountRow(label: '마일리지 사용', value: '-₩${format.format(_mileageToUse)}', dark: true),
                  const Divider(color: OudColors.panelDarkDivider),
                  OudAmountRow(
                    label: '최종 결제 금액',
                    value: '₩${format.format(total)}',
                    emphasize: true,
                    dark: true,
                  ),
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
          color: OudColors.bg,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: manager.isLoggedIn
              ? OudTapScale(
                  child: ElevatedButton(
                    onPressed: _submitting
                        ? null
                        : () async {
                            if (_addressId == null || _paymentId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('배송지와 결제 수단을 선택해 주세요.')),
                              );
                              return;
                            }
                            if (!_agreed) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('결제 동의 체크가 필요합니다.')),
                              );
                              return;
                            }

                            setState(() => _submitting = true);
                            try {
                              final address = manager.addresses.firstWhere(
                                (item) => item.id == _addressId,
                                orElse: () => manager.addresses.first,
                              );
                              final payment = manager.paymentMethods.firstWhere(
                                (item) => item.id == _paymentId,
                                orElse: () => manager.paymentMethods.first,
                              );

                              if (widget.mode == CheckoutMode.cart) {
                                manager.placeOrderFromCart(
                                  couponId: couponDiscount > 0 ? _couponId : null,
                                  mileageUsed: _mileageToUse,
                                  shippingFee: shippingFee,
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
                                  shippingFee: shippingFee,
                                  address: address,
                                  payment: payment,
                                  agreementAccepted: true,
                                );
                                manager.removeFromCart(widget.product!, option: widget.selectedOption);
                              }

                              if (!mounted) return;
                              await Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OrderCompleteScreen(
                                    finalAmount: total,
                                    itemCount: items.fold<int>(0, (sum, item) => sum + item.quantity),
                                  ),
                                ),
                              );
                            } finally {
                              if (mounted) setState(() => _submitting = false);
                            }
                          },
                    child: Text(_submitting ? '처리 중...' : '결제하기'),
                  ),
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
}
