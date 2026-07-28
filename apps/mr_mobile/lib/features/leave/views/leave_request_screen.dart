import 'dart:ui';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../controllers/leave_request_controller.dart';

class LeaveRequestScreen extends StatelessWidget {
  const LeaveRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LeaveRequestController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Request Leave',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: MeshGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Submit your time off request for approval.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white60 : const Color(0xFF424655),
                  ),
                ),
                const SizedBox(height: 20),

                GlassCard(
                  level: 2,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Leave Type Chips
                      Text(
                        'LEAVE TYPE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF424655),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildLeaveTypeChips(controller, isDark),

                      const SizedBox(height: 24),

                      // Date Range Header with Duration Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'DATE RANGE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF424655),
                            ),
                          ),
                          Obx(() {
                            final start = controller.startDate.value;
                            final end = controller.endDate.value;
                            if (start != null && end != null) {
                              final days = end.difference(start).inDays + 1;
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0053D3).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(color: const Color(0xFF0053D3).withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    PhosphorIcon(PhosphorIcons.clock(PhosphorIconsStyle.bold), size: 12, color: const Color(0xFF0053D3)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$days ${days == 1 ? 'day' : 'days'}',
                                      style: const TextStyle(
                                        color: Color(0xFF0053D3),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Date Picker Trigger Card
                      GestureDetector(
                        onTap: () => controller.selectDateRange(Get.context!),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.4)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF0053D3).withOpacity(0.12),
                                ),
                                child: Center(
                                  child: PhosphorIcon(PhosphorIcons.calendar(PhosphorIconsStyle.duotone), size: 18, color: const Color(0xFF0053D3)),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Obx(() {
                                  final start = controller.startDate.value;
                                  final end = controller.endDate.value;
                                  if (start == null || end == null) {
                                    return Text(
                                      'Tap to select start & end date',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF727687),
                                      ),
                                    );
                                  }
                                  final format = DateFormat('MMM d, y');
                                  return Text(
                                    '${format.format(start)}  ➔  ${format.format(end)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF151C27),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Reason Field
                      Text(
                        'REASON',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF424655),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.4)),
                        ),
                        child: TextField(
                          controller: controller.reasonController,
                          maxLines: 3,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white : const Color(0xFF151C27),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Provide a brief explanation...',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white.withOpacity(0.4) : const Color(0xFF727687),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(14),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Document Upload Dropzone
                      Text(
                        'SUPPORTING DOCUMENTS (OPTIONAL)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF424655),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0053D3).withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF0053D3).withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF0053D3).withOpacity(0.1),
                              ),
                              child: Center(
                                child: PhosphorIcon(PhosphorIcons.uploadSimple(PhosphorIconsStyle.duotone), size: 22, color: const Color(0xFF0053D3)),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Click to upload medical certificate or proof',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0053D3),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'PDF, JPG, or PNG (max 5MB)',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white.withOpacity(0.4) : const Color(0xFF727687),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Submit Action Button
                      Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        return GradientButton(
                          text: 'SUBMIT REQUEST',
                          onPressed: controller.submitRequest,
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveTypeChips(LeaveRequestController controller, bool isDark) {
    final types = [
      {'label': 'Casual', 'icon': PhosphorIcons.sun(PhosphorIconsStyle.duotone)},
      {'label': 'Sick', 'icon': PhosphorIcons.firstAid(PhosphorIconsStyle.duotone)},
      {'label': 'Emergency', 'icon': PhosphorIcons.warningCircle(PhosphorIconsStyle.duotone)},
      {'label': 'Other', 'icon': PhosphorIcons.dotsThree(PhosphorIconsStyle.duotone)},
    ];

    return Obx(() {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: types.map((item) {
          final label = item['label'] as String;
          final icon = item['icon'] as PhosphorIconData;
          final isSelected = controller.selectedType.value == label;

          return GestureDetector(
            onTap: () => controller.selectedType.value = label,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF0053D3), Color(0xFF1A6BFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : (isDark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.6)),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.3),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0053D3).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PhosphorIcon(
                    icon,
                    size: 16,
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF424655)),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF151C27)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}
