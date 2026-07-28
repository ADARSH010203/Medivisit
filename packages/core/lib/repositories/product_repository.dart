import '../models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getAll();
  Future<Product?> getById(String id);
  Future<void> create(Product product);
  Future<void> update(String id, Map<String, dynamic> data);
  Future<void> delete(String id);
  Future<List<Product>> search(String query);
  Future<List<Product>> getByCategory(String category);
  Stream<List<Product>> streamAll();
}
