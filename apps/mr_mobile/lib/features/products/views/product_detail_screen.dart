import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import '../controllers/product_detail_controller.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductDetailController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        centerTitle: true,
      ),
      body: Obx(() {
        final data = controller.productDetails;
        
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.medication, size: 80, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              data['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              data['category'] as String,
              style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            _buildSection('Description', data['description'] as String),
            _buildSection('Active Ingredients', data['ingredients'] as String),
            _buildSection('Dosage Instructions', data['dosage'] as String),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current Stock', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          '${data['stock']} Units',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          data['price'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(content, style: TextStyle(color: Colors.grey[600], height: 1.5)),
        ],
      ),
    );
  }
}
