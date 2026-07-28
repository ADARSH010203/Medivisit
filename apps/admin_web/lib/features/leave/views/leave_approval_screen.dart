import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import '../controllers/leave_approval_controller.dart';
import 'package:intl/intl.dart';

class LeaveApprovalScreen extends GetView<LeaveApprovalController> {
  const LeaveApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.adminBackground,
        appBar: AppBar(
          title: const Text('Leave Approvals'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: AppColors.adminAccentStart,
            labelColor: AppColors.adminAccentStart,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
              Tab(text: 'Rejected'),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: AppColors.adminAccentStart));
          }
          
          return TabBarView(
            children: [
              _buildList(controller.pendingRequests, context, showActions: true),
              _buildList(controller.approvedRequests, context, showActions: false),
              _buildList(controller.rejectedRequests, context, showActions: false),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildList(List<LeaveRequest> requests, BuildContext context, {required bool showActions}) {
    if (requests.isEmpty) {
      return const Center(
        child: Text('No requests found in this category', style: TextStyle(color: Colors.white54)),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final req = requests[index];
        final format = DateFormat('MMM d, y');
        return Card(
          color: AppColors.adminSurface,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MR ID: ${req.mrId}', // In real app, fetch MR name or use join
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      req.leaveType,
                      style: const TextStyle(color: AppColors.adminAccentStart, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${format.format(req.startDate)} to ${format.format(req.endDate)}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  'Reason: ${req.reason}',
                  style: const TextStyle(color: Colors.white54),
                ),
                if (showActions) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _showActionDialog(context, req, 'rejected'),
                        style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                        child: const Text('Reject'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _showActionDialog(context, req, 'approved'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black),
                        child: const Text('Approve'),
                      ),
                    ],
                  ),
                ] else if (req.adminNote != null && req.adminNote!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Admin Note: ${req.adminNote}',
                    style: const TextStyle(color: Colors.orangeAccent, fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showActionDialog(BuildContext context, LeaveRequest req, String action) {
    final TextEditingController noteCtrl = TextEditingController();
    Get.defaultDialog(
      title: 'Confirm ${action.capitalizeFirst}',
      titleStyle: const TextStyle(color: Colors.white),
      backgroundColor: AppColors.adminSurface,
      content: TextField(
        controller: noteCtrl,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Add an optional note...',
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: AppColors.adminBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      textConfirm: 'Confirm',
      textCancel: 'Cancel',
      confirmTextColor: Colors.black,
      buttonColor: action == 'approved' ? Colors.greenAccent : Colors.redAccent,
      onConfirm: () {
        Get.back();
        controller.updateStatus(req, action, noteCtrl.text);
      },
    );
  }
}
