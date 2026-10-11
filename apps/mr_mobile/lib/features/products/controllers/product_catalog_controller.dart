import 'package:get/get.dart';

class ProductCatalogController extends GetxController {
  final isLoading = false.obs;
  final selectedCategory = 'All'.obs;

  final allProducts = <Map<String, dynamic>>[
    {'id': '1', 'name': 'CardioPlus', 'category': 'Cardiology', 'stock': 120, 'price': '\$45.00'},
    {'id': '2', 'name': 'NeuroVance', 'category': 'Neurology', 'stock': 85, 'price': '\$80.00'},
    {'id': '3', 'name': 'PediaCare', 'category': 'Pediatrics', 'stock': 200, 'price': '\$15.50'},
    {'id': '4', 'name': 'DermaShield', 'category': 'Dermatology', 'stock': 15, 'price': '\$60.00'},
    {'id': '5', 'name': 'OncoClear', 'category': 'Oncology', 'stock': 0, 'price': '\$200.00'},
    {'id': '6', 'name': 'BoneMax', 'category': 'Orthopedics', 'stock': 55, 'price': '\$35.00'},
  ].obs;

  List<String> get categories =>
      ['All', ...allProducts.map((p) => p['category'] as String).toSet()];

  List<Map<String, dynamic>> get products => selectedCategory.value == 'All'
      ? allProducts
      : allProducts.where((p) => p['category'] == selectedCategory.value).toList();

  void selectCategory(String cat) => selectedCategory.value = cat;

  void viewProductDetail(String id) {}
}
