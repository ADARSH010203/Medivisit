import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';

class AdminSidebar extends StatelessWidget {
  final String currentRoute;
  final Function(String) onNavigate;

  const AdminSidebar({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: AppColors.adminSurface,
        border: Border(
          right: BorderSide(
            color: AppColors.adminSurfaceHighlight,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.adminBrandGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.healing, color: Colors.white),
                ),
                const SizedBox(width: 16),
                const Text(
                  'MediVisit Pro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildNavItem('/admin/dashboard', 'Dashboard', Icons.dashboard_rounded),
          _buildNavItem('/admin/doctors', 'Doctors', Icons.medical_services_rounded),
          _buildNavItem('/admin/products', 'Products', Icons.inventory_2_rounded),
          _buildNavItem('/admin/tracking', 'Live Tracking', Icons.map_rounded),
          _buildNavItem('/admin/expenses', 'Expenses', Icons.receipt_long_rounded),
          _buildNavItem('/admin/mrs', 'MR Management', Icons.people_rounded),
          
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('visits')
                .where('visit_source', isEqualTo: 'self_reported')
                .where('admin_review_status', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snapshot) {
              final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
              return _buildNavItem(
                '/admin/self-reported-visits', 
                'Self-Reported Visits', 
                Icons.flash_on_rounded, 
                badgeCount: count
              );
            },
          ),

          _buildNavItem('/admin/mrs/verification', 'Verifications', Icons.verified_user_rounded), // TODO: make dynamic
          _buildNavItem('/admin/leave', 'Leave Approvals', Icons.event_available_rounded),
          _buildNavItem('/admin/reports/dashboard', 'Reports & Analytics', Icons.bar_chart_rounded),
          _buildNavItem('/admin/territories', 'Territories', Icons.map_rounded),
          _buildNavItem('/admin/settings', 'System Settings', Icons.settings_rounded),
          
          const Spacer(),
          const Divider(color: AppColors.adminSurfaceHighlight),
          _buildNavItem('/admin/login', 'Logout', Icons.logout_rounded),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNavItem(String route, String title, IconData icon, {int? badgeCount}) {
    final isActive = currentRoute == route;
    
    return InkWell(
      onTap: () => onNavigate(route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.05) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isActive ? AppColors.adminAccentStart : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.adminAccentStart : Colors.grey[400],
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[400],
                  fontSize: 15,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (badgeCount != null && badgeCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withOpacity(0.5)),
                ),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
