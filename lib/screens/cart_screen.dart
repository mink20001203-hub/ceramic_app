import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/user_data_manager.dart';

// 장바구니 화면: 수량 변경, 삭제, 주문 확정까지 처리한다.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat('#,###', 'ko_KR');

    // 쿠폰/마일리지 적용 결제 시트
    void _showPaymentSheet(
        BuildContext context, UserDataManager userManager) {
      String? selectedCouponId;
      int mileageToUse = 0;

      int subtotal = userManager.items.fold<int>(0, (sum, item) {
        final unitPrice = (item.product.isSale && item.product.salePrice != null)
            ? item.product.salePrice!
            : item.product.price;
        return sum + unitPrice * item.quantity;
      });

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            final coupon = selectedCouponId == null
                ? null
                : userManager.coupons
                    .firstWhere((c) => c.id == selectedCouponId);
            final couponDiscount = (coupon == null ||
                    coupon.isUsed ||
                    subtotal < coupon.minOrderAmount)
                ? 0
                : coupon.discountAmount;
            final maxMileage =
                userManager.mileage < (subtotal - couponDiscount)
                    ? userManager.mileage
                    : (subtotal - couponDiscount);
            final finalTotal = subtotal - couponDiscount - mileageToUse;

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('쿠폰/마일리지 적용',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  RadioListTile<String?>(
                    value: null,
                    groupValue: selectedCouponId,
                    onChanged: (_) => setState(() => selectedCouponId = null),
                    title: const Text('쿠폰 사용 안 함'),
                    dense: true,
                  ),
                  ...userManager.coupons
                      .where((c) => !c.isUsed)
                      .map(
                        (coupon) => RadioListTile<String?>(
                          value: coupon.id,
                          groupValue: selectedCouponId,
                          onChanged: (value) =>
                              setState(() => selectedCouponId = value),
                          title: Text(coupon.title),
                          subtitle: Text(
                              '${NumberFormat('#,###', 'ko_KR').format(coupon.discountAmount)}원 할인 · ${NumberFormat('#,###', 'ko_KR').format(coupon.minOrderAmount)}원 이상'),
                          dense: true,
                        ),
                      ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: '마일리지 사용',
                            hintText: '보유 ${userManager.mileage}P',
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            final parsed = int.tryParse(value) ?? 0;
                            setState(() {
                              mileageToUse =
                                  parsed > maxMileage ? maxMileage : parsed;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () =>
                            setState(() => mileageToUse = maxMileage),
                        child: const Text('최대 사용'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                      '최종 결제 금액: ${NumberFormat('#,###', 'ko_KR').format(finalTotal)}원'),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        userManager.placeOrderFromCart(
                          couponId: couponDiscount > 0 ? selectedCouponId : null,
                          mileageUsed: mileageToUse,
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('주문이 완료되었습니다.')),
                        );
                      },
                      child: const Text('결제하기'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

// 주문 확인 팝업을 띄우는 함수
    void _showOrderConfirmDialog(
        BuildContext context, UserDataManager userManager) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('주문 확인'),
            content: Text(
              '총 ${userManager.items.length}개의 상품을 주문하시겠습니까?\n'
              '결제 금액: ${NumberFormat('#,###', 'ko_KR').format(userManager.totalAmount)}원',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(), // 취소: 팝업 닫기
                child: const Text('취소', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (!userManager.isLoggedIn) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('로그인 후 결제할 수 있습니다.')),
                    );
                    return;
                  }
                  final hasSoldOut = userManager.items
                      .any((item) => item.product.stock == 0);
                  final overStock = userManager.items.any(
                      (item) => item.quantity > item.product.stock);
                  if (hasSoldOut || overStock) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('재고를 확인해 주세요. 품절/수량 초과 항목이 있습니다.')),
                    );
                    return;
                  }

                  // 1. 팝업 닫기
                  Navigator.of(context).pop();

                  // 2. 결제 시트로 이동(쿠폰/마일리지 적용)
                  _showPaymentSheet(context, userManager);

                  // 3. 마이페이지 탭으로 이동
                  userManager.setTabIndex(3);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple),
                child:
                    const Text('주문하기', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    }

    return Consumer<UserDataManager>(
      builder: (context, userManager, child) {
        final cartItems = userManager.items;
        // 재고 변경이 발생했을 때 장바구니 수량을 자동 보정한다.
        for (final item in cartItems) {
          if (item.product.stock == 0) continue;
          if (item.quantity > item.product.stock) {
            item.quantity = item.product.stock;
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('내 장바구니'),
            centerTitle: true,
            elevation: 0,
            actions: [
              if (cartItems.isNotEmpty)
                TextButton(
                  onPressed: () => userManager.clearCart(),
                  child:
                      const Text('전체삭제', style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
          body: cartItems.isEmpty
              ? const Center(
                  child: Text(
                    '장바구니가 비어 있습니다.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 8),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                leading: item.product.image != null
                                    ? Image.asset(
                                        item.product.image!,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[200],
                                        child: const Icon(
                                            Icons.image_not_supported),
                                      ),
                                title: Text(item.product.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (item.product.stock == 0)
                                      const Text('품절',
                                          style: TextStyle(color: Colors.red)),
                                    if (item.product.stock > 0 &&
                                        item.quantity > item.product.stock)
                                      const Text('재고 부족',
                                          style: TextStyle(color: Colors.red)),
                                    if (item.option != null)
                                      Text('옵션: ${item.option}'),
                                    Text(
                                      '${priceFormat.format(((item.product.isSale && item.product.salePrice != null) ? item.product.salePrice! : item.product.price) * item.quantity)}원',
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                          Icons.remove_circle_outline),
                                      onPressed: () => userManager
                                          .decrementQuantity(
                                              item.product.id, item.option),
                                    ),
                                    Text('${item.quantity}',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon:
                                          const Icon(Icons.add_circle_outline),
                                      onPressed: () => userManager
                                          .incrementQuantity(
                                              item.product.id, item.option),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.grey),
                                      onPressed: () => userManager
                                          .removeSingleItem(
                                              item.product.id, item.option),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('총 결제 금액',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                '${priceFormat.format(userManager.totalAmount)}원',
                                style: const TextStyle(
                                    fontSize: 22,
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: cartItems.isEmpty
                                  ? null
                                  : () => _showOrderConfirmDialog(
                                      context, userManager), // 팝업 함수 호출
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('주문하기',
                                  style: TextStyle(fontSize: 18)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
