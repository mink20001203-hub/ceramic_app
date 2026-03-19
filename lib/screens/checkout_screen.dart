import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/user_data_manager.dart';
import 'login_screen.dart';

enum CheckoutMode { single, cart }

class CheckoutScreen extends StatefulWidget {
  final CheckoutMode mode;
  final Product? product;
  final String? selectedOption;
  final int quantity;

  const CheckoutScreen.single({
    super.key,
    required Product product,
    String? selectedOption,
    int quantity = 1,
  })  : mode = CheckoutMode.single,
        product = product,
        selectedOption = selectedOption,
        quantity = quantity;

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
  final int quantity;
  final String? option;

  _CheckoutItem({required this.product, required this.quantity, this.option});
}

class _CheckoutScreenState extends State<CheckoutScreen> {
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

    final items = widget.mode == CheckoutMode.cart
        ? manager.items
            .map((i) => _CheckoutItem(
                product: i.product, quantity: i.quantity, option: i.option))
            .toList()
        : [
            _CheckoutItem(
              product: widget.product!,
              quantity: widget.quantity,
              option: widget.selectedOption,
            )
          ];

    if (widget.mode == CheckoutMode.cart && items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('장바구니 결제'), centerTitle: true),
        body: const Center(child: Text('장바구니가 비어 있습니다.')),
      );
    }

    _selectedAddressId ??= manager.selectedAddress?.id;
    _selectedPaymentId ??= manager.selectedPayment?.id;

    int subtotal = 0;
    for (final item in items) {
      final unitPrice = (item.product.isSale && item.product.salePrice != null)
          ? item.product.salePrice!
          : item.product.price;
      subtotal += unitPrice * item.quantity;
    }

    final coupon = _selectedCouponId == null
        ? null
        : manager.coupons.firstWhere(
            (c) => c.id == _selectedCouponId,
            orElse: () => manager.coupons.first,
          );

    bool _isCouponApplicable(Coupon c) {
      if (c.isUsed) return false;
      if (subtotal < c.minOrderAmount) return false;
      final categoryOk = c.allowedCategories.isEmpty ||
          items.any((i) => c.allowedCategories.contains(i.product.category));
      final productOk = c.allowedProductIds.isEmpty ||
          items.any((i) => c.allowedProductIds.contains(i.product.id));
      return categoryOk && productOk;
    }

    final couponApplicable = coupon == null ? false : _isCouponApplicable(coupon);

    final couponDiscount = couponApplicable ? coupon!.discountAmount : 0;
    final requestedMileage =
        int.tryParse(_mileageController.text.replaceAll(',', '')) ?? 0;
    final maxMileage = manager.mileage < (subtotal - couponDiscount)
        ? manager.mileage
        : (subtotal - couponDiscount);
    final mileageToUse = requestedMileage.clamp(0, maxMileage);
    final total = subtotal - couponDiscount - mileageToUse;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode == CheckoutMode.cart ? '장바구니 결제' : '주문/결제'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('주문 상품',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...items.map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: item.product.image != null
                    ? Image.asset(item.product.image!,
                        width: 48, height: 48, fit: BoxFit.cover)
                    : Container(
                        width: 48,
                        height: 48,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported),
                      ),
                title: Text(item.product.title),
                subtitle: Text(
                  '${item.option ?? '기본'} · ${item.quantity}개',
                ),
                trailing: Text(
                  '${format.format(((item.product.isSale && item.product.salePrice != null) ? item.product.salePrice! : item.product.price) * item.quantity)}원',
                ),
              ),
            ),
            const Divider(height: 32),
            const Text('배송지',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedAddressId,
              items: manager.addresses
                  .map((a) => DropdownMenuItem(
                        value: a.id,
                        child: Text('${a.recipient} | ${a.phone}'),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedAddressId = value),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _showAddressDialog(context),
              child: const Text('배송지 추가/수정'),
            ),
            const Divider(height: 32),
            const Text('결제 수단',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedPaymentId,
              items: manager.paymentMethods
                  .map((p) => DropdownMenuItem(
                        value: p.id,
                        child: Text(p.label),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedPaymentId = value),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _showPaymentDialog(context),
              child: const Text('결제수단 추가/수정'),
            ),
            const Divider(height: 32),
            const Text('쿠폰',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (coupon != null && !couponApplicable)
              const Padding(
                padding: EdgeInsets.only(top: 6, bottom: 4),
                child: Text(
                  '선택한 쿠폰은 현재 주문에 적용할 수 없습니다.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            RadioListTile<String?>(
              value: null,
              groupValue: _selectedCouponId,
              onChanged: (_) => setState(() => _selectedCouponId = null),
              title: const Text('쿠폰 사용 안 함'),
              dense: true,
            ),
            if (manager.coupons.where((c) => !c.isUsed).isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 4, bottom: 8),
                child: Text(
                  '사용 가능한 쿠폰이 없습니다.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ...manager.coupons.where((c) => !c.isUsed).map(
                  (c) => RadioListTile<String?>(
                    value: c.id,
                    groupValue: _selectedCouponId,
                    onChanged:
                        _isCouponApplicable(c) ? (value) => setState(() => _selectedCouponId = value) : null,
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
                        selection:
                            TextSelection.collapsed(offset: formatted.length),
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
            const SizedBox(height: 12),
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
                        final overStock = items.any(
                            (item) => item.quantity > item.product.stock);
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

                          if (widget.mode == CheckoutMode.cart) {
                            manager.placeOrderFromCart(
                              couponId:
                                  couponDiscount > 0 ? _selectedCouponId : null,
                              mileageUsed: mileageToUse,
                              address: address,
                              payment: payment,
                              agreementAccepted: true,
                            );
                            manager.setTabIndex(3);
                          } else {
                            manager.placeSingleOrder(
                              widget.product!,
                              option: widget.selectedOption,
                              quantity: widget.quantity,
                              couponId:
                                  couponDiscount > 0 ? _selectedCouponId : null,
                              mileageUsed: mileageToUse,
                              address: address,
                              payment: payment,
                              agreementAccepted: true,
                            );
                            manager.removeFromCart(widget.product!,
                                option: widget.selectedOption);
                          }

                          if (!mounted) return;
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

  void _showAddressDialog(BuildContext context, {Address? existing}) {
    final labelController =
        TextEditingController(text: existing != null ? existing.label : '');
    final nameController =
        TextEditingController(text: existing != null ? existing.recipient : '');
    final addressController = TextEditingController(
        text: existing != null ? existing.addressLine : '');
    final phoneController =
        TextEditingController(text: existing != null ? existing.phone : '');
    final requestController = TextEditingController(
        text: existing != null ? existing.requestNote : '');
    String requestOption = existing != null && existing.requestNote.isNotEmpty
        ? existing.requestNote
        : '문 앞에 놓아주세요';
    bool setAsDefault = existing != null
        ? (context.read<UserDataManager>().selectedAddress?.id == existing.id)
        : true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? '배송지 추가' : '배송지 수정'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '이름'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: '휴대폰'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: addressController,
                        decoration: const InputDecoration(labelText: '주소'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('주소찾기 기능은 추후 연결됩니다.')),
                        );
                      },
                      child: const Text('주소찾기'),
                    ),
                  ],
                ),
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(labelText: '상세정보'),
                ),
                DropdownButtonFormField<String>(
                  value: requestOption,
                  decoration: const InputDecoration(labelText: '배송요청사항 선택'),
                  items: const [
                    DropdownMenuItem(
                        value: '문 앞에 놓아주세요', child: Text('문 앞에 놓아주세요')),
                    DropdownMenuItem(
                        value: '경비실에 맡겨주세요', child: Text('경비실에 맡겨주세요')),
                    DropdownMenuItem(
                        value: '배송 전 연락주세요', child: Text('배송 전 연락주세요')),
                    DropdownMenuItem(value: '직접 입력', child: Text('직접 입력')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => requestOption = value);
                  },
                ),
                if (requestOption == '직접 입력')
                  TextField(
                    controller: requestController,
                    decoration: const InputDecoration(labelText: '요청사항 직접 입력'),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: setAsDefault,
                      onChanged: (value) =>
                          setState(() => setAsDefault = value ?? false),
                    ),
                    const Text('기본 배송지로 저장'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty ||
                    phoneController.text.trim().isEmpty ||
                    addressController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('필수 정보를 입력해 주세요.')),
                  );
                  return;
                }

                final manager = context.read<UserDataManager>();
                if (existing == null) {
                  final newId = 'addr_${DateTime.now().millisecondsSinceEpoch}';
                  manager.addAddress(Address(
                    id: newId,
                    label: labelController.text.trim().isEmpty
                        ? '기본'
                        : labelController.text.trim(),
                    recipient: nameController.text.trim(),
                    addressLine: addressController.text.trim(),
                    phone: phoneController.text.trim(),
                    requestNote: requestOption == '직접 입력'
                        ? requestController.text.trim()
                        : requestOption,
                  ));
                  if (setAsDefault) {
                    manager.setDefaultAddress(newId);
                  }
                } else {
                  manager.updateAddress(Address(
                    id: existing.id,
                    label: labelController.text.trim().isEmpty
                        ? existing.label
                        : labelController.text.trim(),
                    recipient: nameController.text.trim(),
                    addressLine: addressController.text.trim(),
                    phone: phoneController.text.trim(),
                    requestNote: requestOption == '직접 입력'
                        ? requestController.text.trim()
                        : requestOption,
                    isDefault: existing.isDefault,
                  ));
                  if (setAsDefault) {
                    manager.setDefaultAddress(existing.id);
                  }
                }
                Navigator.pop(context);
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, {PaymentMethod? existing}) {
    final labelController =
        TextEditingController(text: existing != null ? existing.label : '');
    String selectedType = existing != null ? existing.type : 'CARD';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? '결제수단 추가' : '결제수단 수정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: const InputDecoration(labelText: '표시 이름'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: '유형'),
                items: const [
                  DropdownMenuItem(value: 'CARD', child: Text('신용카드')),
                  DropdownMenuItem(value: 'NAVER', child: Text('네이버페이')),
                  DropdownMenuItem(value: 'KAKAO', child: Text('카카오페이')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => selectedType = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
            ElevatedButton(
              onPressed: () {
                if (labelController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('결제수단 이름을 입력해 주세요.')),
                  );
                  return;
                }

                final manager = context.read<UserDataManager>();
                if (existing == null) {
                  manager.addPaymentMethod(PaymentMethod(
                    id: 'pm_${DateTime.now().millisecondsSinceEpoch}',
                    label: labelController.text.trim(),
                    type: selectedType,
                  ));
                } else {
                  manager.updatePaymentMethod(PaymentMethod(
                    id: existing.id,
                    label: labelController.text.trim(),
                    type: selectedType,
                  ));
                }
                Navigator.pop(context);
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}
