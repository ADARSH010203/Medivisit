import 'dart:ui';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../controllers/achievements_controller.dart';

class AchievementsScreen extends GetView<AchievementsController> {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Achievements',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: MeshGradientBackground(
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title Header with Gradient Text
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF0053D3), Color(0xFF006B5C)],
                    ).createShader(bounds),
                    child: const Text(
                      'Your Achievements',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${controller.myBadges.length} Badges Earned',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white60 : const Color(0xFF707490),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Progress Card to Next Badge
                  GlassCard(
                    level: 2,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Next Badge: ',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : const Color(0xFF151C27),
                                        ),
                                      ),
                                      const TextSpan(
                                        text: '8 more visits',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0053D3),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Unlock 'Regional Champion' status.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white60 : const Color(0xFF424655),
                                  ),
                                ),
                              ],
                            ),
                            // Locked Trophy Icon Badge
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.withOpacity(0.15),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  PhosphorIcon(PhosphorIcons.trophy(PhosphorIconsStyle.duotone), size: 22, color: Colors.grey),
                                  Positioned(
                                    bottom: 2,
                                    right: 2,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: PhosphorIcon(PhosphorIcons.lockKey(PhosphorIconsStyle.bold), size: 10, color: Colors.black54),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Gradient Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            height: 8,
                            width: double.infinity,
                            color: isDark ? Colors.white10 : Colors.black12,
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: 0.75, // 75% progress
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF0053D3), Color(0xFF68FADD)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0053D3).withOpacity(0.5),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Medallions Grid Section Header
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'MEDALLIONS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF424655),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Medallions Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: controller.allBadges.length,
                    itemBuilder: (context, index) {
                      final badge = controller.allBadges[index];
                      final isEarned = controller.myBadges.any((mb) => mb.id == badge.id) || index < 3; // Mock first 3 earned

                      return _buildMedallionCard(badge, isEarned, index, isDark);
                    },
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMedallionCard(BadgeDefinition badge, bool isEarned, int index, bool isDark) {
    // Custom Medallion Colors: 0 = Gold, 1 = Teal, 2 = Blue, >2 = Locked
    List<Color> gradientColors;
    Color iconColor;
    PhosphorIconData iconData;

    if (index == 0) {
      gradientColors = [const Color(0xFFFFF8D6), const Color(0xFFFFD700)];
      iconColor = const Color(0xFFB8860B);
      iconData = PhosphorIcons.star(PhosphorIconsStyle.fill);
    } else if (index == 1) {
      gradientColors = [const Color(0xFFE0FEF8), const Color(0xFF68FADD)];
      iconColor = const Color(0xFF008A74);
      iconData = PhosphorIcons.fire(PhosphorIconsStyle.fill);
    } else {
      gradientColors = [const Color(0xFFDAE1FF), const Color(0xFF1A6BFF)];
      iconColor = Colors.white;
      iconData = PhosphorIcons.atom(PhosphorIconsStyle.fill);
    }

    return GlassCard(
      level: isEarned ? 2 : 1,
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Medal Icon Circle with Glow
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isEarned
                      ? LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isEarned ? null : Colors.grey.withOpacity(0.12),
                  boxShadow: isEarned
                      ? [
                          BoxShadow(
                            color: gradientColors.last.withOpacity(0.4),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                  border: isEarned ? null : Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Center(
                  child: PhosphorIcon(
                    iconData,
                    size: 36,
                    color: isEarned ? iconColor : Colors.grey,
                  ),
                ),
              ),
              if (!isEarned)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? const Color(0xFF2A313D) : Colors.white,
                      border: Border.all(color: Colors.grey.withOpacity(0.4)),
                    ),
                    child: PhosphorIcon(PhosphorIcons.lockKey(PhosphorIconsStyle.bold), size: 12, color: Colors.grey),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            badge.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isEarned ? (isDark ? Colors.white : const Color(0xFF151C27)) : (isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF727687)),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          Text(
            isEarned ? '${badge.criteriaValue}+ ${badge.criteriaType}' : 'Locked — Goal ${badge.criteriaValue}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isEarned ? const Color(0xFF0053D3) : Colors.grey,
              fontWeight: isEarned ? FontWeight.bold : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
