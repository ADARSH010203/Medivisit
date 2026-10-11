import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../controllers/expense_controller.dart';

class ExpenseSubmissionScreen extends StatelessWidget {
  const ExpenseSubmissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExpenseController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Submit Expense',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: PhosphorIcon(PhosphorIcons.x(PhosphorIconsStyle.bold), size: 22),
          onPressed: () => Get.back(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: MeshGradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // Scrollable Content
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Image Capture & Processing Area ──
                    _buildReceiptBentoArea(controller, isDark),

                    const SizedBox(height: 28),

                    // ── AI Extracted Details Section ──
                    Row(
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                          size: 16,
                          color: const Color(0xFF575C76),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'AI EXTRACTED DETAILS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: isDark ? Colors.white60 : const Color(0xFF424655),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Amount Card (ai-tint-panel)
                    _buildAiTintCard(
                      label: 'Total Amount',
                      child: Obx(() => Text(
                        '₹${controller.amountController.text.isNotEmpty ? controller.amountController.text : "0.00"}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF001849),
                        ),
                      )),
                      isDark: isDark,
                      onEdit: () => _showEditDialog(controller.amountController, 'Total Amount'),
                    ),
                    const SizedBox(height: 10),

                    // Vendor + Date Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildAiTintCard(
                            label: 'Vendor',
                            child: Obx(() => Text(
                              controller.vendorController.text.isNotEmpty ? controller.vendorController.text : 'No vendor',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF151C27),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
                            isDark: isDark,
                            onEdit: () => _showEditDialog(controller.vendorController, 'Vendor'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildAiTintCard(
                            label: 'Transaction Date',
                            child: Obx(() => Text(
                              controller.dateController.text.isNotEmpty ? controller.dateController.text : 'Not set',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white : const Color(0xFF151C27),
                              ),
                            )),
                            isDark: isDark,
                            onEdit: () => _showEditDialog(controller.dateController, 'Date'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Manual Fields Section ──
                    // Category Dropdown
                    Text(
                      'Expense Category',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: isDark ? Colors.white60 : const Color(0xFF424655),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Obx(() => GlassCard(
                      level: 2,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      child: DropdownButtonFormField<String>(
                        value: controller.selectedCategory.value,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        hint: const Text('Select category...'),
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.white : const Color(0xFF151C27),
                        ),
                        dropdownColor: isDark ? const Color(0xFF2A313D) : Colors.white,
                        items: controller.categories.map((cat) {
                          return DropdownMenuItem(value: cat, child: Text(cat));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) controller.selectedCategory.value = val;
                        },
                      ),
                    )),

                    const SizedBox(height: 20),

                    // Notes Field
                    Text(
                      'Business Purpose / Notes',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: isDark ? Colors.white60 : const Color(0xFF424655),
                      ),
                    ),
                    const SizedBox(height: 6),
                    GlassCard(
                      level: 2,
                      padding: const EdgeInsets.all(14),
                      child: TextField(
                        controller: controller.notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintText: 'E.g., Lunch meeting with Dr. Smith regarding new cardio equipment...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white30 : const Color(0xFF727687),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white : const Color(0xFF151C27),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Fixed Bottom Submit Button ──
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF151C27).withOpacity(0.7)
                            : Colors.white.withOpacity(0.6),
                        border: Border(
                          top: BorderSide(
                            color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ),
                      child: Obx(() => GestureDetector(
                        onTap: controller.isProcessing.value ? null : controller.submitExpense,
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0053D3), Color(0xFF0055D5)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0053D3).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              PhosphorIcon(
                                PhosphorIcons.paperPlaneTilt(PhosphorIconsStyle.fill),
                                size: 18,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                controller.isProcessing.value
                                    ? 'PROCESSING...'
                                    : 'SUBMIT FOR APPROVAL',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Receipt Bento Area (Camera Zone + Processing Thumbnail) ──
  Widget _buildReceiptBentoArea(ExpenseController controller, bool isDark) {
    return Obx(() {
      final image = controller.receiptImage.value;

      return Row(
        children: [
          // Camera / Upload Zone
          Expanded(
            child: GestureDetector(
              onTap: () => _showPickerOptions(controller),
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF0053D3).withOpacity(0.3),
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                  color: isDark ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.4),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow orb
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0053D3).withOpacity(0.1),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0053D3).withOpacity(0.1),
                            blurRadius: 40,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.camera(PhosphorIconsStyle.duotone),
                          size: 36,
                          color: const Color(0xFF0053D3),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : const Color(0xFFE2E8F8),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.15)
                                  : const Color(0xFFC2C6D8).withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PhosphorIcon(
                                PhosphorIcons.plus(PhosphorIconsStyle.bold),
                                size: 14,
                                color: isDark ? Colors.white70 : const Color(0xFF424655),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Scan Receipt',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white70 : const Color(0xFF424655),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Processing Thumbnail / Preview
          Expanded(
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : const Color(0xFFC2C6D8).withOpacity(0.4),
                ),
                color: isDark ? const Color(0xFF2A313D) : const Color(0xFFE7EEFE),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (image != null)
                    Image.file(image, fit: BoxFit.cover)
                  else
                    Center(
                      child: PhosphorIcon(
                        PhosphorIcons.image(PhosphorIconsStyle.duotone),
                        size: 40,
                        color: isDark ? Colors.white24 : const Color(0xFF727687).withOpacity(0.4),
                      ),
                    ),

                  // OCR Overlay (when processing)
                  if (controller.isProcessing.value)
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withOpacity(0.5)
                            : Colors.white.withOpacity(0.3),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF575C76).withOpacity(0.4),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: isDark
                                        ? const Color(0xFF2A313D).withOpacity(0.9)
                                        : Colors.white.withOpacity(0.9),
                                    border: Border.all(
                                      color: const Color(0xFFC1C5E3).withOpacity(0.5),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Color(0xFF575C76),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'PROCESSING...',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0,
                                          color: Color(0xFF575C76),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  // ── AI Tint Card (Tertiary-fixed tinted glass panel) ──
  Widget _buildAiTintCard({
    required String label,
    required Widget child,
    required bool isDark,
    VoidCallback? onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark
            ? const Color(0xFF575C76).withOpacity(0.15)
            : const Color(0xFFDDE1FF).withOpacity(0.25),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : const Color(0xFFC1C5E3).withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF575C76),
                ),
              ),
              if (onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.5),
                      border: Border.all(
                        color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFC2C6D8).withOpacity(0.3),
                      ),
                    ),
                    child: Center(
                      child: PhosphorIcon(
                        PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold),
                        size: 12,
                        color: isDark ? Colors.white54 : const Color(0xFF424655),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }

  void _showEditDialog(TextEditingController textController, String fieldName) {
    Get.dialog(
      AlertDialog(
        title: Text('Edit $fieldName'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter $fieldName',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(onPressed: () => Get.back(), child: const Text('Save')),
        ],
      ),
    );
  }

  void _showPickerOptions(ExpenseController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0053D3).withOpacity(0.1),
                ),
                child: Center(
                  child: PhosphorIcon(
                    PhosphorIcons.camera(PhosphorIconsStyle.duotone),
                    size: 22,
                    color: const Color(0xFF0053D3),
                  ),
                ),
              ),
              title: const Text('Take a photo', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Use camera to scan receipt', style: TextStyle(fontSize: 12)),
              onTap: () {
                Get.back();
                controller.pickReceipt(ImageSource.camera);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF006B5C).withOpacity(0.1),
                ),
                child: Center(
                  child: PhosphorIcon(
                    PhosphorIcons.image(PhosphorIconsStyle.duotone),
                    size: 22,
                    color: const Color(0xFF006B5C),
                  ),
                ),
              ),
              title: const Text('Choose from gallery', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Upload existing receipt image', style: TextStyle(fontSize: 12)),
              onTap: () {
                Get.back();
                controller.pickReceipt(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
