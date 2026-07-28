import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../controllers/admin_expense_controller.dart';

class AdminExpenseScreen extends StatelessWidget {
  const AdminExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminExpenseController());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Page Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Expense Management',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Geist',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Review and approve clinical disbursement requests',
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFFB9CACB),
                      fontFamily: 'Geist',
                    ),
                  ),
                ],
              ),
              // Summary Stats Pills
              Obx(() => Row(
                children: [
                  _buildSummaryPill(
                    'Pending',
                    controller.allExpenses.where((e) => e.status == ExpenseStatus.pending).length.toString(),
                    const Color(0xFFE8A800),
                  ),
                  const SizedBox(width: 8),
                  _buildSummaryPill(
                    'Approved',
                    controller.allExpenses.where((e) => e.status == ExpenseStatus.approved).length.toString(),
                    const Color(0xFF74F5FF),
                  ),
                  const SizedBox(width: 8),
                  _buildSummaryPill(
                    'Rejected',
                    controller.allExpenses.where((e) => e.status == ExpenseStatus.rejected).length.toString(),
                    const Color(0xFFFFB4AB),
                  ),
                ],
              )),
            ],
          ),

          const SizedBox(height: 24),

          // ── Filter Tabs ──
          _buildTabs(controller),

          const SizedBox(height: 20),

          // ── Expense Table ──
          AdminGlassCard(
            padding: EdgeInsets.zero,
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.all(60),
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF74F5FF))),
                );
              }

              if (controller.filteredExpenses.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(60),
                  child: Center(
                    child: Column(
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.receipt(PhosphorIconsStyle.duotone),
                          size: 48,
                          color: const Color(0xFF849495),
                        ),
                        const SizedBox(height: 12),
                        const Text('No expenses in this category.',
                            style: TextStyle(color: Color(0xFF849495), fontSize: 14)),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  // Table Column Headers
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                      color: Colors.white.withOpacity(0.01),
                    ),
                    child: const Row(
                      children: [
                        Expanded(flex: 3, child: Text('MR NAME', style: _headerStyle)),
                        Expanded(flex: 2, child: Text('CATEGORY', style: _headerStyle)),
                        Expanded(flex: 2, child: Text('VENDOR', style: _headerStyle)),
                        Expanded(flex: 2, child: Text('AMOUNT', style: _headerStyle)),
                        Expanded(flex: 2, child: Text('DATE', style: _headerStyle)),
                        Expanded(flex: 2, child: Text('STATUS', style: _headerStyle)),
                        SizedBox(width: 120, child: Text('ACTIONS', style: _headerStyle)),
                      ],
                    ),
                  ),
                  // Table Data Rows
                  ...controller.filteredExpenses.map((expense) => _buildExpenseRow(expense, controller)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseRow(Expense expense, AdminExpenseController controller) {
    Color statusColor;
    String statusText;
    switch (expense.status) {
      case ExpenseStatus.approved:
        statusColor = const Color(0xFF74F5FF);
        statusText = 'Approved';
        break;
      case ExpenseStatus.rejected:
        statusColor = const Color(0xFFFFB4AB);
        statusText = 'Rejected';
        break;
      case ExpenseStatus.pending:
      default:
        statusColor = const Color(0xFFE8A800);
        statusText = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        children: [
          // MR Name with avatar
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF74F5FF), Color(0xFF7000FF)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      (controller.mrNames[expense.mrId] ?? 'MR')[0],
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    controller.mrNames[expense.mrId] ?? 'Loading...',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Category chip
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.white.withOpacity(0.06),
              ),
              child: Text(
                expense.category,
                style: const TextStyle(
                    color: Color(0xFFB9CACB), fontSize: 12, fontFamily: 'Geist'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Vendor
          Expanded(
            flex: 2,
            child: Text(
              expense.vendor,
              style: const TextStyle(color: Color(0xFFB9CACB), fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Amount
          Expanded(
            flex: 2,
            child: Text(
              '₹${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),

          // Date
          Expanded(
            flex: 2,
            child: Text(
              expense.expenseDate,
              style: const TextStyle(color: Color(0xFFB9CACB), fontSize: 13),
            ),
          ),

          // Status pill with glowing dot
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: statusColor.withOpacity(0.1),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor,
                      boxShadow: [
                        BoxShadow(color: statusColor.withOpacity(0.8), blurRadius: 6)
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    statusText,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Geist'),
                  ),
                ],
              ),
            ),
          ),

          // Actions
          SizedBox(
            width: 120,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (expense.receiptImageUrl != null)
                  _actionIconButton(
                    PhosphorIcons.receipt(PhosphorIconsStyle.duotone),
                    const Color(0xFF74F5FF),
                    'View Receipt',
                    () => Get.dialog(
                      Dialog(
                        backgroundColor: const Color(0xFF1D1F2D),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Receipt',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(expense.receiptImageUrl!),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('Close',
                                      style: TextStyle(color: Color(0xFF74F5FF)))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (expense.status == ExpenseStatus.pending) ...[
                  _actionIconButton(
                    PhosphorIcons.checkCircle(PhosphorIconsStyle.duotone),
                    const Color(0xFF74F5FF),
                    'Approve',
                    () => controller.approveExpense(expense.id),
                  ),
                  _actionIconButton(
                    PhosphorIcons.xCircle(PhosphorIconsStyle.duotone),
                    const Color(0xFFFFB4AB),
                    'Reject',
                    () => controller.rejectExpense(expense.id),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionIconButton(
      PhosphorIconData icon, Color color, String tooltip, VoidCallback onPressed) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: color.withOpacity(0.1),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Center(
            child: PhosphorIcon(icon, size: 16, color: color),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryPill(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 6)],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$count $label',
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Geist'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(AdminExpenseController controller) {
    final tabs = ['Pending', 'Approved', 'Rejected', 'All'];
    return Obx(() => Row(
          children: tabs.map((tab) {
            final isSelected = controller.selectedTab.value == tab;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => controller.setTab(tab),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: isSelected
                        ? Colors.white.withOpacity(0.1)
                        : const Color(0xFF323443).withOpacity(0.3),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF74F5FF)
                          : Colors.white.withOpacity(0.08),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF74F5FF).withOpacity(0.15),
                              blurRadius: 12,
                              spreadRadius: -2,
                            )
                          ]
                        : null,
                  ),
                  child: Text(
                    tab.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      fontFamily: 'Geist',
                      color: isSelected ? const Color(0xFF74F5FF) : const Color(0xFFB9CACB),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ));
  }

  static const _headerStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.0,
    color: Color(0xFFB9CACB),
    fontFamily: 'Geist',
  );
}
