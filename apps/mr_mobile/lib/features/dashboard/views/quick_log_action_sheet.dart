import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'package:get/get.dart';
import '../../../l10n/l10n.dart';
import '../../../app/routes.dart';

class QuickLogActionSheet extends StatelessWidget {
  const QuickLogActionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = L10n.tr(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.adminSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              tr.quickLog,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildActionItem(
              context,
              'Quick Doctor Visit',
              Icons.flash_on_rounded,
              const Color(0xFF7C5CFF),
              () {
                Get.back();
                Get.toNamed(AppRoutes.quickLogVisit);
              },
            ),
            const SizedBox(height: 12),
            _buildActionItem(
              context,
              tr.markDoctorVisit,
              Icons.location_on_rounded,
              AppColors.primary,
              () {
                Get.back();
                Get.toNamed(AppRoutes.visits);
              },
            ),
            const SizedBox(height: 12),
            _buildActionItem(
              context,
              tr.markAttendance,
              Icons.fingerprint_rounded,
              AppColors.secondary,
              () {
                Get.back();
                Get.toNamed(AppRoutes.markAttendance);
              },
            ),
            const SizedBox(height: 12),
            _buildActionItem(
              context,
              tr.requestLeave,
              Icons.event_busy_rounded,
              AppColors.warning,
              () {
                Get.back();
                Get.toNamed(AppRoutes.leaveRequest);
              },
            ),
            const SizedBox(height: 12),
            _buildActionItem(
              context,
              'Log Expense',
              Icons.receipt_long_rounded,
              AppColors.tertiary,
              () {
                Get.back();
                Get.toNamed(AppRoutes.expenseSubmission);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: GlassCard(
        level: 1,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
