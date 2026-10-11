import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../l10n/l10n.dart';
import '../../../app/routes.dart';

class QuickLogActionSheet extends StatelessWidget {
  const QuickLogActionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = L10n.tr(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF151C27) : Colors.white; // Mobile Surface token

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: baseColor.withOpacity(0.75),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(isDark ? 0.1 : 0.4),
                width: 1.5,
              ),
            ),
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
                      color: isDark ? Colors.white24 : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  tr.quickLog,
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF151C27),
                  ),
                ),
                const SizedBox(height: 24),
                _buildActionItem(
                  context,
                  'Quick Doctor Visit',
                  PhosphorIcons.lightning(PhosphorIconsStyle.fill),
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
                  PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
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
                  PhosphorIcons.fingerprint(PhosphorIconsStyle.fill),
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
                  PhosphorIcons.calendarX(PhosphorIconsStyle.fill),
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
                  PhosphorIcons.receipt(PhosphorIconsStyle.fill),
                  AppColors.tertiary,
                  () {
                    Get.back();
                    Get.toNamed(AppRoutes.expenseSubmission);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, String title, PhosphorIconData icon, Color color, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: PhosphorIcon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF151C27),
                ),
              ),
            ),
            PhosphorIcon(
              PhosphorIcons.caretRight(), 
              color: isDark ? Colors.white38 : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
