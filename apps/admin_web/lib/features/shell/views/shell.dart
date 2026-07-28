import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import '../../../app/routes.dart';

class AdminShell extends StatelessWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adminBackground,
      body: Row(
        children: [
          AdminSidebar(
            currentRoute: Get.currentRoute,
            onNavigate: (route) {
              if (route == '/admin/login') {
                // Should logout instead
                // Get.find<AdminAuthController>().logout();
                Get.offAllNamed(AppRoutes.login);
              } else {
                Get.toNamed(route);
              }
            },
          ),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}
