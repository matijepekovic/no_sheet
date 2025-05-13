// lib/data/repositories/product_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product.dart';

class ProductRepositoryImpl implements ProductRepository {
  final FirebaseFirestore _firestore;
  final String _userId;

  ProductRepositoryImpl({
    required FirebaseFirestore firestore,
    required String userId,
  }) : _firestore = firestore, _userId = userId;

  // Collection reference
  CollectionReference<Map<String, dynamic>> get _productsCollection =>
      _firestore.collection('products');

  @override
  Stream<List<Product>> getProducts() {
    return _productsCollection
        .where('businessId', isEqualTo: _userId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Product.fromFirestore(doc))
        .toList());
  }

  @override
  Future<Product> getProduct(String id) async {
    final doc = await _productsCollection.doc(id).get();
    if (!doc.exists) {
      throw Exception('Product not found');
    }
    return Product.fromFirestore(doc);
  }

  @override
  Future<void> addProduct(Product product) async {
    await _productsCollection.doc(product.id).set(product.toMap());
  }

  @override
  Future<void> updateProduct(Product product) async {
    await _productsCollection.doc(product.id).update(product.toMap());
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _productsCollection.doc(id).delete();
  }
}