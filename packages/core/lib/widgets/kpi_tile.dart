import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'admin_glass_card.dart';
import '../theme/app_colors.dart';

class KpiTile extends StatelessWidget {
  final String title;
  final String value;
  final PhosphorIconData icon;
  final String trend;
  final bool isPositiveTrend;

  const KpiTile({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.trend,
    required this.isPositiveTrend,
  });

  @override
  Widget build(BuildContext context) {
    return AdminGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              PhosphorIcon(
                icon,
                color: const Color(0xFF38BDF8),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ShaderMask(
            shaderCallback: (bounds) => AppColors.adminBrandGradient.createShader(bounds),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Required for ShaderMask
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isPositiveTrend ? Icons.arrow_upward : Icons.arrow_downward,
                color: isPositiveTrend ? AppColors.success : AppColors.error,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                trend,
                style: TextStyle(
                  color: isPositiveTrend ? AppColors.success : AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'vs last week',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
