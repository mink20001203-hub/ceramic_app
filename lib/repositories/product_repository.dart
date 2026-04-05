import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/firestore_paths.dart';
import '../models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> fetchProducts();
}

class LocalProductRepository implements ProductRepository {
  @override
  Future<List<Product>> fetchProducts() async {
    final base = List<Product>.from(dummyProducts);
    if (base.isEmpty) {
      return [];
    }

    // 로컬 데모용: Firestore 없이도 상품을 더 많이 보이게 생성
    final List<Product> expanded = [];
    int batch = 0;
    for (final factor in [1.0, 1.05, 1.1, 1.15, 1.2]) {
      batch++;
      for (final product in base) {
        final int bumpedPrice = (product.price * factor).round();
        final int? bumpedSale = product.salePrice == null
            ? null
            : (product.salePrice! * factor).round();
        expanded.add(Product(
          id: '${product.id}_v$batch',
          title: product.title,
          subTitle: product.subTitle,
          price: bumpedPrice,
          image: product.image,
          category: product.category,
          stock: product.stock,
          isNew: product.isNew,
          isSale: product.isSale,
          salePrice: bumpedSale,
          options: List<String>.from(product.options),
          sellerId: product.sellerId,
        ));
      }
    }

    return expanded;
  }
}

class FirestoreProductRepository implements ProductRepository {
  final FirebaseFirestore _db;

  FirestoreProductRepository(this._db);

  @override
  Future<List<Product>> fetchProducts() async {
    final snapshot = await _db.collection(FirestorePaths.products).get();
    return snapshot.docs.map(_fromDoc).toList();
  }

  Product _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Product(
      id: doc.id,
      title: data['title'] as String? ?? '제목 없음',
      subTitle: data['subTitle'] as String? ?? '',
      price: (data['price'] as num?)?.toInt() ?? 0,
      image: data['image'] as String?,
      category: data['category'] as String? ?? '기타',
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      isNew: data['isNew'] as bool? ?? false,
      isSale: data['isSale'] as bool? ?? false,
      salePrice: (data['salePrice'] as num?)?.toInt(),
      options:
          (data['options'] as List<dynamic>? ?? []).map((e) => '$e').toList(),
      sellerId: data['sellerId'] as String?,
    );
  }
}
