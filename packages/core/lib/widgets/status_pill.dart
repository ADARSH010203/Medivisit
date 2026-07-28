import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum StatusPillType { success, error, warning, info, neutral }

class StatusPill extends StatelessWidget {
  final String text;
  final StatusPillType type;

  const StatusPill({
    super.key,
    required this.text,
    this.type = StatusPillType.neutral,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (type) {
      case StatusPillType.success:
        bgColor = AppColors.success.withOpacity(0.15);
        textColor = AppColors.success;
        break;
      case StatusPillType.error:
        bgColor = AppColors.error.withOpacity(0.15);
        textColor = AppColors.error;
        break;
      case StatusPillType.warning:
        bgColor = AppColors.warning.withOpacity(0.15);
        textColor = AppColors.warning;
        break;
      case StatusPillType.info:
        bgColor = AppColors.info.withOpacity(0.15);
        textColor = AppColors.info;
        break;
      case StatusPillType.neutral:
      default:
        bgColor = Colors.grey.withOpacity(0.15);
        textColor = Colors.grey[600]!;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
