import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/user_data_manager.dart';
import '../theme/app_tokens.dart';
import '../widgets/oud_components.dart';
import 'seller_order_detail_screen.dart';

class SellerDemoScreen extends StatefulWidget {
  const SellerDemoScreen({super.key});

  @override
  State<SellerDemoScreen> createState() => _SellerDemoScreenState();
}

class _SellerDemoScreenState extends State<SellerDemoScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _subTitleController = TextEditingController();
  final _priceController = TextEditingController(text: '0');
  final _stockController = TextEditingController(text: '10');
  final _imageController = TextEditingController();
  final _optionsController = TextEditingController();
  final _categoryController = TextEditingController(text: '컵');
  final _salePriceController = TextEditingController(text: '0');

  var _isSale = false;
  var _isSubmitting = false;

  static const _statusOptions = ['결제완료', '배송준비', '배송중', '배송완료'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _subTitleController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageController.dispose();
    _optionsController.dispose();
    _categoryController.dispose();
    _salePriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('판매자 데모'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '상품 등록/관리'),
            Tab(text: '주문 관리'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductsTab(context),
          _buildOrderManagement(context),
        ],
      ),
    );
  }

  Widget _buildProductsTab(BuildContext context) {
    final manager = context.watch<UserDataManager>();
    final products = List<Product>.from(manager.products);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        const Text(
          '새 상품 등록 후 목록에서 가격/재고 수정 및 삭제가 가능합니다.',
          style: TextStyle(color: OudColors.mutedText),
        ),
        const SizedBox(height: 12),
        OudSectionCard(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: '상품명'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? '필수 입력' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _subTitleController,
                  decoration: const InputDecoration(labelText: '부제목'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: '카테고리'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? '필수 입력' : null,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: '가격'),
                        validator: (v) =>
                            (int.tryParse(v ?? '') == null) ? '숫자 입력' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: '재고'),
                        validator: (v) =>
                            (int.tryParse(v ?? '') == null) ? '숫자 입력' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _imageController,
                  decoration: const InputDecoration(
                    labelText: '이미지 경로 (예: assets/images/mug.jpg)',
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _optionsController,
                  decoration: const InputDecoration(
                    labelText: '옵션 (쉼표 구분: S,M,L)',
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('할인 상품'),
                  value: _isSale,
                  onChanged: (v) => setState(() => _isSale = v),
                ),
                if (_isSale)
                  TextFormField(
                    controller: _salePriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '할인가'),
                    validator: (v) {
                      if (!_isSale) return null;
                      return (int.tryParse(v ?? '') == null) ? '숫자 입력' : null;
                    },
                  ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _submitProduct(context),
                  child: Text(_isSubmitting ? '등록 중...' : '상품 등록'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '등록 상품 (${products.length})',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        if (products.isEmpty)
          const SizedBox(
            height: 160,
            child: OudEmptyState(
              title: '등록된 상품이 없습니다',
              subtitle: '위 폼으로 상품을 추가해 주세요.',
              icon: Icons.inventory_2_outlined,
            ),
          )
        else
          ...products.take(30).map((product) => _productTile(context, product)),
      ],
    );
  }

  Widget _productTile(BuildContext context, Product product) {
    final format = NumberFormat('#,###', 'ko_KR');
    final sale = product.isSale && product.salePrice != null;
    final displayPrice = sale ? product.salePrice! : product.price;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OudSectionCard(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${product.category} · 재고 ${product.stock}',
                        style: const TextStyle(color: OudColors.mutedText),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₩${format.format(displayPrice)}',
                  style: const TextStyle(
                    color: OudColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showEditDialog(context, product),
                    child: const Text('수정'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _deleteProduct(context, product),
                    child: const Text('삭제'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderManagement(BuildContext context) {
    final manager = context.watch<UserDataManager>();
    final format = NumberFormat('#,###', 'ko_KR');
    final orders = List<Order>.from(manager.orders)
      ..sort((a, b) => b.date.compareTo(a.date));

    if (orders.isEmpty) {
      return const OudEmptyState(
        title: '주문 데이터가 없습니다',
        subtitle: '구매 테스트를 진행하면 주문 목록이 표시됩니다.',
        icon: Icons.receipt_long_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: orders.length,
      itemBuilder: (_, index) {
        final order = orders[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: OudSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '주문번호 ${order.id}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      DateFormat('MM.dd HH:mm').format(order.date),
                      style: const TextStyle(color: OudColors.mutedText),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '총 ${order.items.length}개 상품 · ₩${format.format(order.totalAmount)}',
                  style: const TextStyle(color: OudColors.mutedText),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: order.status,
                  decoration: const InputDecoration(labelText: '주문 상태'),
                  items: _statusOptions
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    context.read<UserDataManager>().setOrderStatus(
                          order.id,
                          value,
                          actor: '판매자',
                        );
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: order.items
                            .map((item) => OudTag(
                                  label: '${item.product.title} x${item.quantity}',
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                SellerOrderDetailScreen(orderId: order.id),
                          ),
                        );
                      },
                      child: const Text('상세'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitProduct(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final manager = context.read<UserDataManager>();
    final messenger = ScaffoldMessenger.of(context);
    final price = int.parse(_priceController.text.trim());
    final stock = int.parse(_stockController.text.trim());
    final salePrice = _isSale ? int.tryParse(_salePriceController.text.trim()) : null;
    final options = _optionsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    setState(() => _isSubmitting = true);
    try {
      await manager.addProductBySeller(
        title: _titleController.text.trim(),
        subTitle: _subTitleController.text.trim(),
        price: price,
        category: _categoryController.text.trim(),
        stock: stock,
        image: _imageController.text.trim().isEmpty
            ? null
            : _imageController.text.trim(),
        isNew: true,
        isSale: _isSale,
        salePrice: salePrice,
        options: options,
      );
      if (!mounted) return;
      _titleController.clear();
      _subTitleController.clear();
      _priceController.text = '0';
      _stockController.text = '10';
      _imageController.clear();
      _optionsController.clear();
      _categoryController.text = '컵';
      _salePriceController.text = '0';
      setState(() => _isSale = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('상품이 등록되었습니다.')),
      );
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('상품 등록 실패: Firebase 권한/설정을 확인해 주세요.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _showEditDialog(BuildContext context, Product product) async {
    final manager = context.read<UserDataManager>();
    final titleController = TextEditingController(text: product.title);
    final subtitleController = TextEditingController(text: product.subTitle);
    final categoryController = TextEditingController(text: product.category);
    final priceController = TextEditingController(text: '${product.price}');
    final stockController = TextEditingController(text: '${product.stock}');
    final imageController = TextEditingController(text: product.image ?? '');
    final optionsController = TextEditingController(text: product.options.join(','));
    var isSale = product.isSale;
    final salePriceController =
        TextEditingController(text: '${product.salePrice ?? product.price}');

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('상품 수정'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: '상품명'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: subtitleController,
                    decoration: const InputDecoration(labelText: '부제목'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: '카테고리'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '가격'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '재고'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: imageController,
                    decoration: const InputDecoration(labelText: '이미지 경로'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: optionsController,
                    decoration: const InputDecoration(labelText: '옵션(쉼표 구분)'),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('할인 상품'),
                    value: isSale,
                    onChanged: (v) => setStateDialog(() => isSale = v),
                  ),
                  if (isSale)
                    TextField(
                      controller: salePriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: '할인가'),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final price = int.tryParse(priceController.text.trim());
                  final stock = int.tryParse(stockController.text.trim());
                  final salePrice = isSale
                      ? int.tryParse(salePriceController.text.trim())
                      : null;
                  if (price == null || stock == null) return;

                  final options = optionsController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();

                  await manager.updateProductBySeller(
                    product,
                    title: titleController.text.trim(),
                    subTitle: subtitleController.text.trim(),
                    price: price,
                    category: categoryController.text.trim(),
                    stock: stock,
                    image: imageController.text.trim().isEmpty
                        ? null
                        : imageController.text.trim(),
                    isSale: isSale,
                    salePrice: salePrice,
                    options: options,
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context, true);
                },
                child: const Text('저장'),
              ),
            ],
          );
        },
      ),
    );

    titleController.dispose();
    subtitleController.dispose();
    categoryController.dispose();
    priceController.dispose();
    stockController.dispose();
    imageController.dispose();
    optionsController.dispose();
    salePriceController.dispose();

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('상품 정보가 수정되었습니다.')),
      );
    }
  }

  Future<void> _deleteProduct(BuildContext context, Product product) async {
    final manager = context.read<UserDataManager>();
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('상품 삭제'),
            content: Text('${product.title} 상품을 삭제할까요?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('삭제'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;

    try {
      await manager.deleteProductBySeller(product);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('상품이 삭제되었습니다.')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제 실패: Firebase 권한/연결을 확인해 주세요.')),
      );
    }
  }
}
