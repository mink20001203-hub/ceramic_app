import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/user_data_manager.dart';
import 'package:provider/provider.dart';

// 결제 화면: 상품 요약과 결제 금액을 보여주고 구매를 확정한다.
class CheckoutScreen extends StatelessWidget {
  final Product product;
  final String? selectedOption;
  const CheckoutScreen({super.key, required this.product, this.selectedOption});

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat('#,###', 'ko_KR');
    final deliveryFee = 2500;
    final hasSale = product.isSale && product.salePrice != null;
    final itemPrice = hasSale ? product.salePrice! : product.price;
    final totalPrice = itemPrice + deliveryFee;
    final userManager = Provider.of<UserDataManager>(context);

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
                      ),
                    ),
                  )
                  .toList(),
            ),
            const Divider(),

            // 4. 결제 정보 금액 요약
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildPriceRow('상품금액', itemPrice, priceFormat),
                  _buildPriceRow('배송비', deliveryFee, priceFormat),
                  const Divider(),
                  _buildPriceRow('총 결제금액', totalPrice, priceFormat,
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
        child: ElevatedButton(
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

            // 1. 주문 목록에 추가
            context
                .read<UserDataManager>()
                .placeSingleOrder(product, option: selectedOption);

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
          child: Text('${priceFormat.format(totalPrice)}원 결제하기',
              style: const TextStyle(fontSize: 18, color: Colors.white)),
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
                  isDefault: existing.isDefault,
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
