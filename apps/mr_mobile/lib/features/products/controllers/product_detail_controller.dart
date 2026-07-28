import 'package:get/get.dart';

class ProductDetailController extends GetxController {
  final isLoading = false.obs;
  
  // Mock data
  final productDetails = {
    'id': '1',
    'name': 'CardioPlus',
    'category': 'Cardiology',
    'description': 'A comprehensive cardiovascular supplement designed to support heart health and maintain healthy blood pressure levels.',
    'ingredients': 'Omega-3 fatty acids, CoQ10, L-Arginine, Magnesium',
    'dosage': '1 tablet twice daily with meals',
    'stock': 120,
    'price': '\$45.00',
  }.obs;
}
