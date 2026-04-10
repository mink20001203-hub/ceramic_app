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
  int _mileageToUse = 0;
  bool _agreed = false;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<UserDataManager>();
    final format = NumberFormat('#,###', 'ko_KR');

    final items = widget.mode == CheckoutMode.cart
        ? manager.items
            .map(
              (item) => _CheckoutItem(
                product: item.product,
                quantity: item.quantity,
                option: item.option,
              ),
            )
            .toList()
        : <_CheckoutItem>[
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
          subtitle: '장바구니에서 상품을 담은 뒤 다시 시도해 주세요.',
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

    Coupon? selectedCoupon;
    if (_couponId != null) {
      for (final coupon in manager.coupons) {
        if (coupon.id == _couponId) {
          selectedCoupon = coupon;
          break;
        }
      }
    }

    final couponApplicable = selectedCoupon != null &&
        !selectedCoupon.isUsed &&
        subtotal >= selectedCoupon.minOrderAmount;
    final couponDiscount = couponApplicable ? selectedCoupon.discountAmount : 0;
    final shippingFee = subtotal >= 50000 ? 0 : 3000;
    final maxMileage = manager.mileage < (subtotal + shippingFee - couponDiscount)
        ? manager.mileage
        : (subtotal + shippingFee - couponDiscount);
    if (_mileageToUse > maxMileage) _mileageToUse = maxMileage;
    final finalAmount = subtotal + shippingFee - couponDiscount - _mileageToUse;
    final estimatedDelivery = DateFormat('M/d(EEE)', 'ko_KR').format(
      DateTime.now().add(const Duration(days: 3)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('결제'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 168),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Checkout',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -0.6),
            ),
            const SizedBox(height: 4),
            const Text(
              '배송/쿠폰/결제 정보를 확인하고 안전하게 주문하세요.',
              style: TextStyle(color: OudColors.mutedText),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                const OudTag(label: '50,000원 이상 무료배송'),
                OudTag(label: '예상 도착 $estimatedDelivery'),
                const OudTag(label: '파손 시 재배송 지원'),
              ],
            ),
            if (manager.backendError != null) ...[
              const SizedBox(height: 10),
              _warnBanner('백엔드 동기화 이슈가 감지되었습니다. 결제 후 주문내역을 꼭 확인해 주세요.'),
            ],
            const SizedBox(height: 16),
            const OudStepTitle(step: 1, title: '주문 상품'),
            OudSectionCard(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              child: Column(
                children: items.map((item) {
                  final sale = item.product.isSale && item.product.salePrice != null;
                  final unit = sale ? item.product.salePrice! : item.product.price;
                  final lineSoldOut = item.product.stock == 0;
                  final lineOver = item.quantity > item.product.stock;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: OudRadii.sm,
                          child: SizedBox(
                            width: 58,
                            height: 58,
                            child: item.product.image == null
                                ? Container(color: OudColors.surface)
                                : Image.asset(
                                    item.product.image!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(color: OudColors.surface),
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item.option ?? '기본'} / ${item.quantity}개',
                                style: const TextStyle(color: OudColors.mutedText, fontSize: 12),
                              ),
                              if (lineSoldOut)
                                const Text(
                                  '품절 상품입니다.',
                                  style: TextStyle(color: OudColors.danger, fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                              if (!lineSoldOut && lineOver)
                                Text(
                                  '재고 부족: 최대 ${item.product.stock}개 주문 가능',
                                  style: const TextStyle(color: OudColors.danger, fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          '₩${format.format(unit * item.quantity)}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
            const OudStepTitle(step: 2, title: '배송 정보'),
            OudSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _addressId,
                    decoration: const InputDecoration(
                      labelText: '배송지 선택',
                      border: OutlineInputBorder(borderRadius: OudRadii.md),
                    ),
                    items: manager.addresses
                        .map(
                          (address) => DropdownMenuItem<String>(
                            value: address.id,
                            child: Text('${address.recipient} | ${address.addressLine}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _addressId = value),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '배송비 규칙: 50,000원 미만 3,000원 / 이상 무료',
                    style: TextStyle(fontSize: 12, color: OudColors.mutedText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const OudStepTitle(step: 3, title: '쿠폰 및 마일리지'),
            OudSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String?>(
                    initialValue: _couponId,
                    decoration: const InputDecoration(
                      labelText: '쿠폰 적용',
                      border: OutlineInputBorder(borderRadius: OudRadii.md),
                    ),
                    items: <DropdownMenuItem<String?>>[
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
                  const SizedBox(height: 8),
                  Text(
                    selectedCoupon == null
                        ? '쿠폰 조건: 최소 주문금액 충족 시 자동 반영'
                        : couponApplicable
                            ? '쿠폰 적용 가능: 할인 금액이 결제금액에 반영됩니다.'
                            : '쿠폰 미적용: 최소 주문금액 ${format.format(selectedCoupon.minOrderAmount)}원 필요',
                    style: TextStyle(
                      fontSize: 12,
                      color: couponApplicable || selectedCoupon == null ? OudColors.mutedText : OudColors.danger,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('마일리지', style: OudTypography.label),
                      const Spacer(),
                      Text(
                        '${format.format(_mileageToUse)}P',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Slider(
                    value: _mileageToUse.toDouble(),
                    max: maxMileage.toDouble(),
                    onChanged: (value) => setState(() => _mileageToUse = value.toInt()),
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
            const SizedBox(height: 14),
            const OudStepTitle(step: 4, title: '결제 수단'),
            OudSectionCard(
              child: DropdownButtonFormField<String>(
                initialValue: _paymentId,
                decoration: const InputDecoration(
                  labelText: '결제 수단 선택',
                  border: OutlineInputBorder(borderRadius: OudRadii.md),
                ),
                items: manager.paymentMethods
                    .map((payment) => DropdownMenuItem<String>(value: payment.id, child: Text(payment.label)))
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
                title: const Text(
                  '주문 정보, 환불 정책, 배송 지연 가능성 안내를 확인하고 결제에 동의합니다.',
                  style: TextStyle(fontSize: 13.5, height: 1.35),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: OudColors.panelDark,
                borderRadius: OudRadii.lg,
              ),
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '결제 금액',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  OudAmountRow(label: '총 상품 금액', value: '₩${format.format(subtotal)}', dark: true),
                  OudAmountRow(label: '배송비', value: '₩${format.format(shippingFee)}', dark: true),
                  OudAmountRow(label: '쿠폰 할인', value: '-₩${format.format(couponDiscount)}', dark: true),
                  OudAmountRow(label: '마일리지 사용', value: '-₩${format.format(_mileageToUse)}', dark: true),
                  const Divider(color: OudColors.panelDarkDivider),
                  OudAmountRow(
                    label: '최종 결제 금액',
                    value: '₩${format.format(finalAmount)}',
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
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                    onPressed: _submitting
                        ? null
                        : () async {
                            if (_addressId == null || _paymentId == null) {
                              _toast('배송지와 결제 수단을 선택해 주세요.');
                              return;
                            }
                            if (!_agreed) {
                              _toast('주문 동의 체크가 필요합니다.');
                              return;
                            }

                            final soldOut = items.any((line) => line.product.stock == 0);
                            if (soldOut) {
                              _toast('품절 상품이 포함되어 결제를 진행할 수 없습니다.');
                              return;
                            }

                            final overStock = items.any((line) => line.quantity > line.product.stock);
                            if (overStock) {
                              _toast('재고 수량을 초과한 상품이 있습니다. 수량을 조정해 주세요.');
                              return;
                            }

                            final addresses = manager.addresses;
                            final payments = manager.paymentMethods;
                            if (addresses.isEmpty || payments.isEmpty) {
                              _toast('배송지 또는 결제수단 정보가 없습니다.');
                              return;
                            }

                            setState(() => _submitting = true);
                            try {
                              final address = addresses.firstWhere(
                                (item) => item.id == _addressId,
                                orElse: () => addresses.first,
                              );
                              final payment = payments.firstWhere(
                                (item) => item.id == _paymentId,
                                orElse: () => payments.first,
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
                                manager.removeFromCart(
                                  widget.product!,
                                  option: widget.selectedOption,
                                );
                              }

                              if (!mounted) return;
                              await Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OrderCompleteScreen(
                                    finalAmount: finalAmount,
                                    itemCount: items.fold<int>(0, (count, item) => count + item.quantity),
                                  ),
                                ),
                              );
                            } catch (_) {
                              if (!mounted) return;
                              _toast('결제 처리 중 오류가 발생했습니다. 네트워크 상태를 확인 후 다시 시도해 주세요.');
                            } finally {
                              if (mounted) setState(() => _submitting = false);
                            }
                          },
                    child: Text(_submitting ? '처리 중...' : '결제하기'),
                  ),
                )
              : OutlinedButton(
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
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

  Widget _warnBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE8E3),
        borderRadius: OudRadii.md,
        border: Border.all(color: const Color(0xFFF1C5B7)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: OudColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF7B3B2A), height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
