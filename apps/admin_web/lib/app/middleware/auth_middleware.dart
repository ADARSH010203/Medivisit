import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/auth/controllers/admin_auth_controller.dart';
import '../routes.dart';

class AdminAuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AdminAuthController>();

    if (!authController.isAuthenticated.value) {
      return const RouteSettings(name: AppRoutes.login);
    }

    if (!authController.isAdmin.value) {
      // If user logs in but isn't an admin, redirect them out (or show an error page)
      return const RouteSettings(name: AppRoutes.login);
    }

    return null;
  }
}
