import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/user_data_manager.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';

// 결제 화면: 상품 요약과 결제 금액을 보여주고 구매를 확정한다.
class CheckoutScreen extends StatefulWidget {
  final Product product;
  final String? selectedOption;
  const CheckoutScreen({super.key, required this.product, this.selectedOption});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _mileageController =
      TextEditingController(text: '0');

  @override
  void dispose() {
    _mileageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat('#,###', 'ko_KR');
    final deliveryFee = 2500;
    final product = widget.product;
    final selectedOption = widget.selectedOption;
    final hasSale = product.isSale && product.salePrice != null;
    final itemPrice = hasSale ? product.salePrice! : product.price;
    final totalPrice = itemPrice + deliveryFee;
    final userManager = Provider.of<UserDataManager>(context);
    final selectedCoupon = userManager.selectedCoupon;
    final couponDiscount = selectedCoupon == null ||
            selectedCoupon.isUsed ||
            itemPrice < selectedCoupon.minOrderAmount
        ? 0
        : selectedCoupon.discountAmount;
    final requestedMileage =
        int.tryParse(_mileageController.text.replaceAll(',', '')) ?? 0;
    final maxMileage =
        userManager.mileage < (itemPrice - couponDiscount)
            ? userManager.mileage
            : (itemPrice - couponDiscount);
    final mileageToUse = requestedMileage > maxMileage
        ? maxMileage
        : (requestedMileage < 0 ? 0 : requestedMileage);
    final finalTotal = (itemPrice + deliveryFee) - couponDiscount - mileageToUse;

    return Scaffold(
      appBar: AppBar(title: const Text('주문/결제'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. 주문 상품 섹션
            _buildSectionTitle('주문상품'),
            ListTile(
              leading: product.image != null
                  ? Image.asset(product.image!,
                      width: 60, height: 60, fit: BoxFit.cover)
                  : Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported),
                    ),
              title: Text(product.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedOption != null)
                    Text('옵션: $selectedOption'),
                  Text('${priceFormat.format(itemPrice)}원'),
                ],
              ),
            ),
            const Divider(),

            // 2. 배송지 정보
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text('배송지 정보',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _showAddressDialog(context),
                    child: const Text('추가'),
                  ),
                ],
              ),
            ),
            Column(
              children: userManager.addresses
                  .map(
                    (addr) => GestureDetector(
                      onLongPress: () => _showAddressDialog(context, existing: addr),
                      child: RadioListTile<String>(
                        value: addr.id,
                        groupValue: userManager.selectedAddress?.id,
                        onChanged: (value) {
                          if (value != null) {
                            userManager.setSelectedAddress(value);
                          }
                        },
                        title: Text('${addr.label} · ${addr.recipient}'),
                        subtitle:
                            Text('${addr.addressLine} (${addr.phone})'),
                        dense: true,
                        secondary: PopupMenuButton<String>(
                          // 기본 설정/삭제를 위한 컨텍스트 메뉴
                          onSelected: (value) {
                            if (value == 'default') {
                              userManager.setDefaultAddress(addr.id);
                            } else if (value == 'delete') {
                              userManager.removeAddress(addr.id);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                                value: 'default', child: Text('기본으로 설정')),
                            PopupMenuItem(
                                value: 'delete', child: Text('삭제')),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const Divider(),

            // 3. 결제 수단
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text('결제수단',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _showPaymentDialog(context),
                    child: const Text('추가'),
                  ),
                ],
              ),
            ),
            Column(
              children: userManager.paymentMethods
                  .map(
                    (pm) => GestureDetector(
                      onLongPress: () => _showPaymentDialog(context, existing: pm),
                      child: RadioListTile<String>(
                        value: pm.id,
                        groupValue: userManager.selectedPayment?.id,
                        onChanged: (value) {
                          if (value != null) {
                            userManager.setSelectedPayment(value);
                          }
                        },
                        title: Text(pm.label),
                        dense: true,
                        secondary: PopupMenuButton<String>(
                          // 기본 설정/삭제를 위한 컨텍스트 메뉴
                          onSelected: (value) {
                            if (value == 'default') {
                              userManager.setDefaultPayment(pm.id);
                            } else if (value == 'delete') {
                              userManager.removePaymentMethod(pm.id);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                                value: 'default', child: Text('기본으로 설정')),
                            PopupMenuItem(
                                value: 'delete', child: Text('삭제')),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const Divider(),

            // 4. 쿠폰/마일리지
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('쿠폰/마일리지',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (selectedCoupon != null &&
                      ((selectedCoupon.allowedCategories.isNotEmpty &&
                              !selectedCoupon.allowedCategories
                                  .contains(product.category)) ||
                          (selectedCoupon.allowedProductIds.isNotEmpty &&
                              !selectedCoupon.allowedProductIds
                                  .contains(product.id))))
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('선택한 쿠폰은 현재 상품에 적용할 수 없습니다.',
                          style: TextStyle(color: Colors.red)),
                    ),
                  RadioListTile<String?>(
                    value: null,
                    groupValue: userManager.selectedCoupon?.id,
                    onChanged: (value) {
                      userManager.setSelectedCoupon(null);
                      setState(() {});
                    },
                    title: const Text('쿠폰 사용 안 함'),
                    dense: true,
                  ),
                  ...userManager.coupons
                      .where((c) => !c.isUsed)
                      .map(
                        (coupon) => RadioListTile<String?>(
                          value: coupon.id,
                          groupValue: userManager.selectedCoupon?.id,
                          onChanged: (value) {
                            final isApplicable =
                                (coupon.allowedCategories.isEmpty ||
                                        coupon.allowedCategories
                                            .contains(product.category)) &&
                                    (coupon.allowedProductIds.isEmpty ||
                                        coupon.allowedProductIds
                                            .contains(product.id)) &&
                                    itemPrice >= coupon.minOrderAmount;
                            if (!isApplicable) return;
                            userManager.setSelectedCoupon(value);
                            setState(() {});
                          },
                          title: Text(coupon.title),
                          subtitle: Text(
                              '${priceFormat.format(coupon.discountAmount)}원 할인 · ${priceFormat.format(coupon.minOrderAmount)}원 이상'),
                          dense: true,
                          enabled: (coupon.allowedCategories.isEmpty ||
                                  coupon.allowedCategories
                                      .contains(product.category)) &&
                              (coupon.allowedProductIds.isEmpty ||
                                  coupon.allowedProductIds
                                      .contains(product.id)) &&
                              itemPrice >= coupon.minOrderAmount,
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
                            hintText: '보유 ${userManager.mileage}P',
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            final raw = value.replaceAll(',', '');
                            final parsed = int.tryParse(raw) ?? 0;
                            final clamped =
                                parsed < 0 ? 0 : (parsed > maxMileage ? maxMileage : parsed);
                            final formatted =
                                NumberFormat('#,###', 'ko_KR').format(clamped);
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
                          _mileageController.text = maxMileage.toString();
                          setState(() {});
                        },
                        child: const Text('최대 사용'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),

            // 4. 결제 정보 금액 요약
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildPriceRow('상품금액', itemPrice, priceFormat),
                  _buildPriceRow('배송비', deliveryFee, priceFormat),
                  if (couponDiscount > 0)
                    _buildPriceRow('쿠폰 할인', -couponDiscount, priceFormat),
                  if (mileageToUse > 0)
                    _buildPriceRow('마일리지 사용', -mileageToUse, priceFormat),
                  const Divider(),
                  _buildPriceRow('총 결제금액', finalTotal, priceFormat,
                      isTotal: true),
                ],
              ),
            ),
          ],
        ),
      ),
      // 최종 결제하기 버튼
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: userManager.isLoggedIn
            ? ElevatedButton(
                onPressed: () {
                  if (userManager.selectedAddress == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('배송지를 선택해 주세요.')),
                    );
                    return;
                  }
            if (userManager.selectedPayment == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('결제수단을 선택해 주세요.')),
              );
              return;
            }
            if (product.stock == 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('품절 상품입니다.')),
              );
              return;
            }
            // 로그인하지 않으면 결제 불가
            if (!userManager.isLoggedIn) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('로그인 후 결제할 수 있습니다.')),
              );
              return;
            }

                  // 1. 주문 목록에 추가
                  context.read<UserDataManager>().placeSingleOrder(
                        product,
                        option: selectedOption,
                        couponId: couponDiscount > 0
                            ? userManager.selectedCoupon?.id
                            : null,
                        mileageUsed: mileageToUse,
                      );

            // 2. 만약 장바구니에 이 상품이 있다면 제거
                  context
                      .read<UserDataManager>()
                      .removeFromCart(product, option: selectedOption);

            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('주문이 완료되었습니다! 장바구니에서 상품을 비웠습니다.')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size(double.infinity, 55),
                ),
                child: Text('${priceFormat.format(finalTotal)}원 결제하기',
                    style: const TextStyle(fontSize: 18, color: Colors.white)),
              )
            : OutlinedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                  if (!mounted) return;
                  setState(() {});
                },
                child: const Text('로그인 후 결제하기'),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, int price, NumberFormat format,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text('${format.format(price)}원',
              style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  fontSize: isTotal ? 20 : 14)),
        ],
      ),
    );
  }

  void _showAddressDialog(BuildContext context, {Address? existing}) {
    final labelController =
        TextEditingController(text: existing != null ? existing.label : '');
    final nameController =
        TextEditingController(text: existing != null ? existing.recipient : '');
    final addressController =
        TextEditingController(text: existing != null ? existing.addressLine : '');
    final phoneController =
        TextEditingController(text: existing != null ? existing.phone : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? '배송지 추가' : '배송지 수정'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: labelController,
                decoration: const InputDecoration(labelText: '라벨(예: 집/회사)'),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '수령인'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: '주소'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: '연락처'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소')),
          ElevatedButton(
            onPressed: () {
              if (labelController.text.trim().isEmpty ||
                  nameController.text.trim().isEmpty ||
                  addressController.text.trim().isEmpty ||
                  phoneController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('모든 정보를 입력해 주세요.')),
                );
                return;
              }

              final manager = context.read<UserDataManager>();
              if (existing == null) {
                manager.addAddress(Address(
                  id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
                  label: labelController.text.trim(),
                  recipient: nameController.text.trim(),
                  addressLine: addressController.text.trim(),
                  phone: phoneController.text.trim(),
                ));
              } else {
                manager.updateAddress(Address(
                  id: existing.id,
                  label: labelController.text.trim(),
                  recipient: nameController.text.trim(),
                  addressLine: addressController.text.trim(),
                  phone: phoneController.text.trim(),
                ));
              }
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
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
                  if (value != null) {
                    setState(() => selectedType = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소')),
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
