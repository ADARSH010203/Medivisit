import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../controllers/admin_product_management_controller.dart';

class AdminProductManagementScreen extends StatelessWidget {
  const AdminProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminProductManagementController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Product Management', style: TextStyle(color: Colors.white, fontFamily: 'Geist')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GradientButton(
              text: '+ Add Product',
              width: 150,
              onPressed: controller.addProduct,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return AdminGlassCard(
            child: ListView.separated(
              itemCount: controller.products.length,
              separatorBuilder: (context, index) => const Divider(height: 32, color: Colors.white12),
              itemBuilder: (context, index) {
                final product = controller.products[index];
                return Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: PhosphorIcon(PhosphorIcons.pill(PhosphorIconsStyle.duotone), color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product['name'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Geist')),
                          Text(product['category'], style: TextStyle(color: Colors.grey[400], fontSize: 14, fontFamily: 'Geist')),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(product['price'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Geist')),
                        Text('Stock: ${product['stock']}', style: TextStyle(color: Colors.grey[400], fontSize: 14, fontFamily: 'Geist')),
                      ],
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      icon: PhosphorIcon(PhosphorIcons.pencilSimple(PhosphorIconsStyle.duotone), color: Colors.white70),
                      onPressed: () => controller.editProduct(product['id']),
                    ),
                    IconButton(
                      icon: PhosphorIcon(PhosphorIcons.trash(PhosphorIconsStyle.duotone), color: AppColors.error),
                      onPressed: () => controller.deleteProduct(product['id']),
                    ),
                  ],
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
