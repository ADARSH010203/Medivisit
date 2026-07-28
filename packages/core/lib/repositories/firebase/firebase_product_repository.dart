import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/product.dart';
import '../product_repository.dart';

class FirebaseProductRepository implements ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Product>> getAll() async {
    final snapshot = await _firestore.collection('products').get();
    return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
  }

  @override
  Future<Product?> getById(String id) async {
    final doc = await _firestore.collection('products').doc(id).get();
    if (doc.exists) {
      return Product.fromFirestore(doc);
    }
    return null;
  }

  @override
  Future<void> create(Product product) {
    return _firestore.collection('products').doc(product.id).set(product.toFirestore());
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) {
    data['updated_at'] = FieldValue.serverTimestamp();
    return _firestore.collection('products').doc(id).update(data);
  }

  @override
  Future<void> delete(String id) {
    return _firestore.collection('products').doc(id).delete();
  }

  @override
  Future<List<Product>> search(String query) async {
    // Simple client-side search for phase 1
    final docs = await getAll();
    final lowerQuery = query.toLowerCase();
    return docs.where((doc) {
      return doc.name.toLowerCase().contains(lowerQuery) || 
             doc.category.toLowerCase().contains(lowerQuery) ||
             doc.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Future<List<Product>> getByCategory(String category) async {
    final snapshot = await _firestore
        .collection('products')
        .where('category', isEqualTo: category)
        .get();
    return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
  }

  @override
  Stream<List<Product>> streamAll() {
    return _firestore.collection('products').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList()
    );
  }
}
