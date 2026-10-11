import 'dart:ui';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../controllers/leaderboard_controller.dart';

class LeaderboardScreen extends GetView<LeaderboardController> {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Performance Leaderboard',
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

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                  child: Column(
                    children: [
                      // Toggle Pill (Weekly / Monthly)
                      _buildPeriodToggle(controller, isDark),

                      const SizedBox(height: 24),

                      // Podium Section (1st, 2nd, 3rd)
                      if (controller.leaderboard.length >= 3)
                        _buildPodiumSection(controller.leaderboard, isDark),

                      const SizedBox(height: 28),

                      // Ranked List (4+)
                      ...controller.leaderboard.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        if (index < 3) return const SizedBox.shrink(); // Top 3 are in Podium

                        final isCurrentUser = item.rank == 7; // Highlight current user mock

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GlassCard(
                            level: isCurrentUser ? 3 : 1,
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Rank Number Badge
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isCurrentUser
                                        ? const Color(0xFF0053D3).withOpacity(0.15)
                                        : Colors.grey.withOpacity(0.12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${item.rank}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: isCurrentUser
                                          ? const Color(0xFF0053D3)
                                          : (isDark ? Colors.white70 : const Color(0xFF424655)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            item.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: isDark ? Colors.white : const Color(0xFF151C27),
                                            ),
                                          ),
                                          if (isCurrentUser) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF0053D3).withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(100),
                                              ),
                                              child: const Text(
                                                'YOU',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF0053D3),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.territory,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF727687),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${item.score}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isCurrentUser ? const Color(0xFF0053D3) : (isDark ? Colors.white : const Color(0xFF151C27)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // Sticky Bottom Standing Card
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF101221).withOpacity(0.85) : Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF0053D3).withOpacity(0.3), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0053D3).withOpacity(0.15),
                              blurRadius: 24,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'CURRENT STANDING',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                    color: isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF727687),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Rank ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : const Color(0xFF151C27),
                                        ),
                                      ),
                                      const TextSpan(
                                        text: '#7 ',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0053D3),
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'of 24',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF727687),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'TO NEXT RANK',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                    color: isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF727687),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    PhosphorIcon(PhosphorIcons.arrowUp(PhosphorIconsStyle.bold), size: 14, color: const Color(0xFF006B5C)),
                                    const SizedBox(width: 2),
                                    const Text(
                                      '14 pts',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF006B5C),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPeriodToggle(LeaderboardController ctrl, bool isDark) {
    final periods = ['weekly', 'monthly', 'all_time'];
    final labels = {'weekly': 'Weekly', 'monthly': 'Monthly', 'all_time': 'All Time'};

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: periods.map((p) {
          final isSelected = ctrl.selectedPeriod.value == p;
          return GestureDetector(
            onTap: () => ctrl.changePeriod(p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: isSelected ? Colors.white : Colors.transparent,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                labels[p]!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? const Color(0xFF0053D3) : (isDark ? Colors.white60 : const Color(0xFF424655)),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPodiumSection(List<LeaderboardEntry> list, bool isDark) {
    final first = list[0];
    final second = list[1];
    final third = list[2];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd Place (Silver)
        Expanded(child: _buildPodiumColumn(second, 2, const Color(0xFFC0C0C0), 110, isDark)),
        const SizedBox(width: 8),
        // 1st Place (Gold Elevated Center)
        Expanded(child: _buildPodiumColumn(first, 1, const Color(0xFFFFD700), 140, isDark)),
        const SizedBox(width: 8),
        // 3rd Place (Bronze)
        Expanded(child: _buildPodiumColumn(third, 3, const Color(0xFFCD7F32), 90, isDark)),
      ],
    );
  }

  Widget _buildPodiumColumn(LeaderboardEntry entry, int rank, Color medalColor, double standHeight, bool isDark) {
    final isFirst = rank == 1;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isFirst)
          PhosphorIcon(
            PhosphorIcons.crown(PhosphorIconsStyle.fill),
            color: const Color(0xFFFFD700),
            size: 28,
          ),
        const SizedBox(height: 4),

        // Avatar with Medal Gradient Ring
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: isFirst ? 64 : 52,
              height: isFirst ? 64 : 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [medalColor, medalColor.withOpacity(0.6)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: medalColor.withOpacity(0.4),
                    blurRadius: isFirst ? 20 : 12,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: isFirst ? 58 : 46,
                  height: isFirst ? 58 : 46,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      entry.name.substring(0, 1),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isFirst ? 20 : 16,
                        color: const Color(0xFF0053D3),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Rank Number Badge
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFirst ? const Color(0xFF0053D3) : Colors.white,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isFirst ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
        Text(
          entry.name.split(' ').first,
          style: TextStyle(
            fontSize: isFirst ? 14 : 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF151C27),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${entry.score}',
          style: TextStyle(
            fontSize: isFirst ? 16 : 13,
            fontWeight: FontWeight.bold,
            color: isFirst ? const Color(0xFF0053D3) : (isDark ? Colors.white70 : const Color(0xFF424655)),
          ),
        ),
        const SizedBox(height: 8),

        // Stand Pedestal
        Container(
          height: standHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            gradient: LinearGradient(
              colors: [
                medalColor.withOpacity(isFirst ? 0.35 : 0.2),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(color: medalColor.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: medalColor.withOpacity(0.2),
                blurRadius: 16,
              ),
            ],
          ),
          child: Center(
            child: PhosphorIcon(
              isFirst ? PhosphorIcons.trophy(PhosphorIconsStyle.duotone) : PhosphorIcons.medal(PhosphorIconsStyle.duotone),
              color: medalColor,
              size: isFirst ? 32 : 24,
            ),
          ),
        ),
      ],
    );
  }
}
