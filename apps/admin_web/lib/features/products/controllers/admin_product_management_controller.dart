import 'package:get/get.dart';

class AdminProductManagementController extends GetxController {
  final isLoading = false.obs;
  
  // Mock data
  final products = <Map<String, dynamic>>[
    {
      'id': '1',
      'name': 'CardioPlus',
      'category': 'Cardiology',
      'stock': 120,
      'price': '\$45.00',
    },
    {
      'id': '2',
      'name': 'NeuroVance',
      'category': 'Neurology',
      'stock': 85,
      'price': '\$80.00',
    }
  ].obs;

  void addProduct() {
    // Show add product dialog
  }

  void editProduct(String id) {
    // Show edit product dialog
  }

  void deleteProduct(String id) {
    // Confirm and delete product
  }
}
