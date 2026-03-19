import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/firestore_paths.dart';
import '../models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> fetchProducts();
}

class LocalProductRepository implements ProductRepository {
  @override
  Future<List<Product>> fetchProducts() async {
    return List<Product>.from(dummyProducts);
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
    );
  }
}
