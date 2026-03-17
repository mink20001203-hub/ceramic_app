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

            // 2. 배송지 정보 (틀만 작성)
            _buildSectionTitle('배송지 정보'),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('서울시 강남구 ... (기본 배송지)'),
            ),
            const Divider(),

            // 3. 결제 수단 (버튼들 틀만 작성)
            _buildSectionTitle('결제수단'),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 2,
              padding: const EdgeInsets.all(16),
              children: [
                _buildPaymentMethod('신용카드'),
                _buildPaymentMethod('네이버페이'),
                _buildPaymentMethod('카카오페이'),
              ],
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
            final userManager =
                Provider.of<UserDataManager>(context, listen: false);

            // 1. 주문 목록에 추가
            userManager.placeSingleOrder(product, option: selectedOption);

            // 2. 만약 장바구니에 이 상품이 있다면 제거
            userManager.removeFromCart(product, option: selectedOption);

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

  Widget _buildPaymentMethod(String name) {
    return Card(child: Center(child: Text(name)));
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
}
