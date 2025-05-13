// lib/domain/repositories/product_repository.dart
import '../../data/models/product.dart';

abstract class ProductRepository {
  Stream<List<Product>> getProducts();
  Future<Product> getProduct(String id);
  Future<void> addProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String id);
}