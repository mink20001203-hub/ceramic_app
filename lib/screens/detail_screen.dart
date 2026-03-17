import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/user_data_manager.dart';
import 'checkout_screen.dart';

// 상품 상세 화면: 옵션 선택, 재고 상태, 구매 진입을 제공한다.
class DetailScreen extends StatefulWidget {
  final Product product;
  const DetailScreen({super.key, required this.product});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    if (widget.product.options.isNotEmpty) {
      _selectedOption = widget.product.options.first;
    }
  }

  // --- 장바구니 알림 바텀 시트 (기존 유지) ---
  void _showCartBottomSheet(BuildContext context, UserDataManager userManager) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  '장바구니에 상품이 담겼습니다.',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              const Text('나와 비슷한 고객들이 비교한 상품',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (context, index) => _buildSimilarProductItem(),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('쇼핑 계속하기',
                          style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // 바텀시트 닫기
                        userManager.setTabIndex(2); // 장바구니 탭으로 인덱스 변경
                        Navigator.popUntil(
                            context, (route) => route.isFirst); // 메인으로 이동
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('장바구니 보기',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimilarProductItem() {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: Icon(Icons.image, color: Colors.grey)),
          ),
          const SizedBox(height: 8),
          const Text('유사 상품 이름',
              style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
          const Text('19,900원',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // build 내에서 userManager를 가져옵니다.
    final userManager = Provider.of<UserDataManager>(context, listen: false);
    final priceFormat = NumberFormat('#,###', 'ko_KR');
    final product = widget.product;
    final hasSale = product.isSale && product.salePrice != null;
    final effectivePrice = hasSale ? product.salePrice! : product.price;
    final isSoldOut = product.stock == 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        actions: [
          // 🏠 1. 강사님 조언: 상단 홈 버튼 추가
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
          // 2. 찜하기 버튼 (기존 유지)
          Consumer<UserDataManager>(
            builder: (context, manager, child) {
              final isFav = manager.isFavorite(product);
              return IconButton(
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                color: isFav ? Colors.red : null,
                onPressed: () => manager.toggleWishlist(product),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.image != null)
                    Image.asset(product.image!,
                        width: double.infinity, height: 300, fit: BoxFit.cover)
                  else
                    Container(
                        width: double.infinity,
                        height: 300,
                        color: Colors.grey[300]),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.title,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        if (hasSale)
                          Row(
                            children: [
                              Text("${priceFormat.format(effectivePrice)}원",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(width: 8),
                              Text("${priceFormat.format(product.price)}원",
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      decoration:
                                          TextDecoration.lineThrough)),
                            ],
                          )
                        else
                          Text("${priceFormat.format(product.price)}원",
                              style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text(
                          isSoldOut ? '품절' : '재고 ${product.stock}개',
                          style: TextStyle(
                              color: isSoldOut ? Colors.red : Colors.grey),
                        ),
                        if (product.options.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text("옵션 선택",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedOption,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              isDense: true,
                            ),
                            items: product.options
                                .map((option) => DropdownMenuItem(
                                      value: option,
                                      child: Text(option),
                                    ))
                                .toList(),
                            onChanged: isSoldOut
                                ? null
                                : (value) {
                                    setState(() {
                                      _selectedOption = value;
                                    });
                                  },
                          ),
                        ],
                        const Divider(height: 40),
                        const Text("상품 설명",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        const Text("장인의 손길로 제작된 명품 도자기입니다.",
                            style: TextStyle(fontSize: 16, height: 1.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 하단 버튼 영역
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: const BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                  color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
            ]),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // ✅ CartProvider 대신 userManager를 사용하여 에러 해결
                      if (isSoldOut) return;
                      userManager.addToCart(product,
                          selectedOption: _selectedOption);
                      _showCartBottomSheet(context, userManager);
                    },
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.deepPurple),
                        minimumSize: const Size(double.infinity, 50)),
                    child: const Text("장바구니",
                        style:
                            TextStyle(fontSize: 16, color: Colors.deepPurple)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (isSoldOut) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutScreen(
                            product: product,
                            selectedOption: _selectedOption,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50)),
                    child: Text(isSoldOut ? "품절" : "지금 구매하기",
                        style: const TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
