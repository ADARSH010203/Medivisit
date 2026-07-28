import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../controllers/product_catalog_controller.dart';
import '../../../app/routes.dart';

class ProductCatalogScreen extends StatelessWidget {
  const ProductCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductCatalogController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Product Catalog'),
        centerTitle: true,
      ),
      body: MeshGradientBackground(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              // ── Category chips (horizontally scrollable) ──
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    itemCount: controller.categories.length,
                    itemBuilder: (context, i) {
                      final cat = controller.categories[i];
                      return Obx(() {
                        final active = controller.selectedCategory.value == cat;
                        return GestureDetector(
                          onTap: () => controller.selectCategory(cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: active
                                  ? const LinearGradient(
                                      colors: [Color(0xFF0053D3), Color(0xFF44DDC1)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    )
                                  : null,
                              color: active ? null : Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: active
                                    ? Colors.transparent
                                    : Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                color: active ? Colors.white : const Color(0xFF424655),
                                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // ── Product Grid ──
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = controller.products[index];
                      final stock = (product['stock'] ?? 0) as int;
                      final stockLabel = stock == 0
                          ? 'OUT'
                          : stock < 20
                              ? 'LOW STOCK'
                              : 'IN STOCK';
                      final stockColor = stock == 0
                          ? const Color(0xFFBA1A1A)
                          : stock < 20
                              ? const Color(0xFFE8A800)
                              : const Color(0xFF006B5C);

                      return GlassCard(
                        level: 2,
                        padding: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image top half with stock badge overlay
                            Expanded(
                              flex: 3,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child: Container(
                                      width: double.infinity,
                                      color: AppColors.primary.withOpacity(0.07),
                                      child: Center(
                                        child: PhosphorIcon(
                                          PhosphorIcons.pill(PhosphorIconsStyle.duotone),
                                          size: 52,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: stockColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        stockLabel,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Info bottom half
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      product['category'] ?? '',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: controller.products.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.82,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        }),
      ),
      bottomNavigationBar: PillBottomNav(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) Get.toNamed(AppRoutes.dashboard);
          if (index == 1) Get.toNamed(AppRoutes.visits);
          if (index == 3) Get.toNamed(AppRoutes.profile);
        },
      ),
    );
  }
}
