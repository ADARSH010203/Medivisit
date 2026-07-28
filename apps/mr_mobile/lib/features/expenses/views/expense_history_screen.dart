import 'dart:ui';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../controllers/expense_history_controller.dart';
import '../../../app/routes.dart';

class ExpenseHistoryScreen extends StatelessWidget {
  const ExpenseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExpenseHistoryController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Expense History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: const Color(0xFF0053D3).withOpacity(0.4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
              onPressed: () {
                Get.toNamed(AppRoutes.expenseSubmission)?.then((_) => controller.refreshExpenses());
              },
              icon: PhosphorIcon(PhosphorIcons.plus(PhosphorIconsStyle.bold), size: 16, color: const Color(0xFF0053D3)),
              label: const Text(
                'Log Expense',
                style: TextStyle(color: Color(0xFF0053D3), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
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
                  'Review and manage your clinical disbursement logs.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white60 : const Color(0xFF424655),
                  ),
                ),
                const SizedBox(height: 20),

                // Top Bento Grid Summary Cards (This Month, Pending, Approved)
                Obx(() {
                  double thisMonthTotal = 0;
                  double pendingTotal = 0;
                  double approvedTotal = 0;
                  int pendingCount = 0;

                  for (var e in controller.allExpenses) {
                    thisMonthTotal += e.amount;
                    if (e.status == ExpenseStatus.pending) {
                      pendingTotal += e.amount;
                      pendingCount++;
                    } else if (e.status == ExpenseStatus.approved) {
                      approvedTotal += e.amount;
                    }
                  }

                  return Column(
                    children: [
                      _buildBentoSummaryCard(
                        'THIS MONTH',
                        '₹${thisMonthTotal.toStringAsFixed(2)}',
                        '+12.5% vs last month',
                        PhosphorIcons.calendarBlank(PhosphorIconsStyle.duotone),
                        const Color(0xFF0053D3),
                        isDark,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildBentoSummaryCard(
                              'PENDING',
                              '₹${pendingTotal.toStringAsFixed(2)}',
                              '$pendingCount items awaiting',
                              PhosphorIcons.hourglass(PhosphorIconsStyle.duotone),
                              const Color(0xFFE8A800),
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildBentoSummaryCard(
                              'APPROVED',
                              '₹${approvedTotal.toStringAsFixed(2)}',
                              'Cleared for payout',
                              PhosphorIcons.checkCircle(PhosphorIconsStyle.duotone),
                              const Color(0xFF006B5C),
                              isDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 24),

                // Filter Chips Row
                _buildFilterChips(controller, isDark),

                const SizedBox(height: 20),

                // Expense List
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (controller.filteredExpenses.isEmpty) {
                    return _buildEmptyState(isDark);
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = controller.filteredExpenses[index];
                      return _buildExpenseCard(expense, isDark);
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBentoSummaryCard(String label, String amount, String subtitle, PhosphorIconData icon, Color accentColor, bool isDark) {
    return Stack(
      children: [
        GlassCard(
          level: 2,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF727687),
                    ),
                  ),
                  PhosphorIcon(icon, size: 18, color: accentColor),
                ],
              ),
              const SizedBox(height: 10),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [accentColor, accentColor.withOpacity(0.8)],
                ).createShader(bounds),
                child: Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white60 : const Color(0xFF424655),
                ),
              ),
            ],
          ),
        ),
        // Corner Glow Orb
        Positioned(
          top: -20,
          right: -20,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withOpacity(0.15),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.25),
                  blurRadius: 32,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(ExpenseHistoryController controller, bool isDark) {
    final tabs = ['All', 'Pending', 'Approved', 'Rejected'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((tab) {
          return Obx(() {
            final isSelected = controller.selectedTab.value == tab;
            return GestureDetector(
              onTap: () => controller.setTab(tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
                            color: const Color(0xFF0053D3).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  tab,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF424655)),
                  ),
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }

  Widget _buildExpenseCard(Expense expense, bool isDark) {
    final syncService = Get.isRegistered<OfflineSyncService>() ? Get.find<OfflineSyncService>() : null;
    
    return Obx(() {
      final double? progress = syncService?.uploadProgress[expense.id];
      final bool isFailed = syncService?.isActionFailed(expense.id) ?? false;

      Color statusColor;
      String statusText;

      if (isFailed) {
        statusColor = const Color(0xFFBA1A1A);
        statusText = 'Sync Failed (Tap to retry)';
      } else if (progress != null) {
        statusColor = const Color(0xFF0053D3);
        statusText = 'Uploading receipt... ${(progress * 100).toInt()}%';
      } else {
        switch (expense.status) {
          case ExpenseStatus.approved:
            statusColor = const Color(0xFF006B5C);
            statusText = 'Approved';
            break;
          case ExpenseStatus.rejected:
            statusColor = const Color(0xFFBA1A1A);
            statusText = 'Rejected';
            break;
          case ExpenseStatus.pending:
          default:
            statusColor = const Color(0xFFE8A800);
            statusText = 'Pending';
        }
      }

      PhosphorIconData iconData;
      switch (expense.category.toLowerCase()) {
        case 'travel':
          iconData = PhosphorIcons.airplane(PhosphorIconsStyle.duotone);
          break;
        case 'food':
        case 'client meal':
          iconData = PhosphorIcons.coffee(PhosphorIconsStyle.duotone);
          break;
        case 'accommodation':
          iconData = PhosphorIcons.bed(PhosphorIconsStyle.duotone);
          break;
        default:
          iconData = PhosphorIcons.receipt(PhosphorIconsStyle.duotone);
      }

      return GestureDetector(
        onTap: isFailed ? () {
          syncService?.retryActionByDocId(expense.id);
        } : null,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            level: 2,
            padding: EdgeInsets.zero,
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Accent Left Border
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          // Square Category Icon Bubble
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xFF0053D3).withOpacity(0.1),
                              border: Border.all(color: Colors.white.withOpacity(0.4)),
                            ),
                            child: Center(
                              child: PhosphorIcon(iconData, size: 24, color: const Color(0xFF0053D3)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        expense.vendor,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : const Color(0xFF151C27),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '₹${expense.amount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : const Color(0xFF151C27),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            expense.category,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? Colors.white70 : const Color(0xFF424655),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          expense.expenseDate,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF727687),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Status Pill
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(100),
                                        border: Border.all(color: statusColor.withOpacity(0.3)),
                                      ),
                                      child: Row(
                                        children: [
                                          if (progress != null)
                                            SizedBox(
                                              width: 10,
                                              height: 10,
                                              child: CircularProgressIndicator(
                                                value: progress,
                                                strokeWidth: 2,
                                                color: statusColor,
                                              ),
                                            )
                                          else
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: statusColor,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: statusColor.withOpacity(0.6),
                                                    blurRadius: 6,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          const SizedBox(width: 4),
                                          Text(
                                            statusText,
                                            style: TextStyle(
                                              color: statusColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            PhosphorIcon(
              PhosphorIcons.receipt(PhosphorIconsStyle.duotone),
              size: 56,
              color: const Color(0xFF0053D3),
            ),
            const SizedBox(height: 12),
            Text(
              'No expenses found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF151C27),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
