import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import '../controllers/visit_audit_controller.dart';

class VisitAuditScreen extends StatelessWidget {
  const VisitAuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VisitAuditController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visit Audit'),
        centerTitle: true,
      ),
      body: Obx(() {
        final data = controller.visitDetails;
        
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: const Icon(Icons.person, color: AppColors.primary, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['doctorName'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            const SizedBox(height: 4),
                            StatusPill(text: data['status'] as String, type: StatusPillType.success),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildDetailRow('Date', data['date'] as String),
                  _buildDetailRow('Time', data['time'] as String),
                  _buildDetailRow('Duration', data['duration'] as String),
                  _buildDetailRow('Location Match', data['locationMatch'] as String),
                  const SizedBox(height: 16),
                  const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(data['notes'] as String, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
