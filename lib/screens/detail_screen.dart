import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/user_data_manager.dart';
import 'checkout_screen.dart';

// 상품 상세 화면: 옵션/수량 선택과 구매 진입을 제공한다.
class DetailScreen extends StatefulWidget {
  final Product product;
  const DetailScreen({super.key, required this.product});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String? _selectedOption;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    if (widget.product.options.isNotEmpty) {
      _selectedOption = widget.product.options.first;
    }
  }

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
              const SizedBox(height: 16),
              const Text('비슷한 크리에이터 작품도 둘러보세요',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (context, index) => _buildSimilarProductItem(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('쇼핑 계속하기'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        userManager.setTabIndex(2);
                        Navigator.popUntil(
                            context, (route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('장바구니 보기'),
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
            height: 110,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: Icon(Icons.image, color: Colors.grey)),
          ),
          const SizedBox(height: 6),
          const Text('유사 작품',
              style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
          const Text('19,900원',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
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
                    Image.asset(
                      product.image!,
                      width: double.infinity,
                      height: 320,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: double.infinity,
                        height: 320,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    )
                  else
                    Container(
                        width: double.infinity,
                        height: 320,
                        color: Colors.grey[300]),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.title,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(product.subTitle,
                            style:
                                const TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 12),
                        if (hasSale)
                          Row(
                            children: [
                              Text('${priceFormat.format(effectivePrice)}원',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      color: Color(0xFFA53C2C),
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(width: 8),
                              Text('${priceFormat.format(product.price)}원',
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      decoration:
                                          TextDecoration.lineThrough)),
                            ],
                          )
                        else
                          Text('${priceFormat.format(product.price)}원',
                              style: const TextStyle(
                                  fontSize: 20,
                                  color: Color(0xFFA53C2C),
                                  fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text(
                          isSoldOut ? '품절' : '재고 ${product.stock}개',
                          style: TextStyle(
                              color: isSoldOut ? Colors.red : Colors.grey),
                        ),
                        if (isSoldOut)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: OutlinedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('재입고 알림을 신청했습니다.')),
                                );
                              },
                              child: const Text('재입고 알림 신청'),
                            ),
                          ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F4F0),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (product.options.isNotEmpty) ...[
                                const Text('옵션 선택',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _selectedOption,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
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
                                const SizedBox(height: 16),
                              ],
                              const Text('수량',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: isSoldOut || _quantity <= 1
                                        ? null
                                        : () {
                                            setState(() => _quantity--);
                                          },
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                  ),
                                  Text(
                                    '$_quantity',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    onPressed: isSoldOut ||
                                            _quantity >= product.stock
                                        ? null
                                        : () {
                                            setState(() => _quantity++);
                                          },
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('최대 ${product.stock}개',
                                      style:
                                          const TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text('상품 설명',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        const Text(
                          '장인의 손길로 제작된 명품 도자기입니다. '
                          '유약의 깊이와 촉감을 직접 느껴보세요.',
                          style: TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                      if (isSoldOut) return;
                      userManager.addToCartMultiple(product, _quantity,
                          selectedOption: _selectedOption);
                      _showCartBottomSheet(context, userManager);
                    },
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50)),
                    child: const Text('장바구니'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (isSoldOut) return;
                      if (!userManager.isLoggedIn) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('로그인 후 결제할 수 있습니다.')),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutScreen.single(
                            product: product,
                            selectedOption: _selectedOption,
                            quantity: _quantity,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50)),
                    child: Text(isSoldOut ? '품절' : '바로 구매하기'),
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

