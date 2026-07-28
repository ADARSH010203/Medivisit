import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_colors.dart';

class PillBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const PillBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            color: Theme.of(context).cardColor.withOpacity(0.8),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, 0, PhosphorIcons.house()),
                _buildNavItem(context, 1, PhosphorIcons.stethoscope()),
                _buildFab(context),
                _buildNavItem(context, 2, PhosphorIcons.pill()),
                _buildNavItem(context, 3, PhosphorIcons.user()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, PhosphorIconData icon) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: PhosphorIcon(
          icon,
          color: isActive ? AppColors.primary : const Color(0xFF494551),
          size: 28,
        ),
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(-1),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: AppColors.brandGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: PhosphorIcon(
            PhosphorIcons.plus(),
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
