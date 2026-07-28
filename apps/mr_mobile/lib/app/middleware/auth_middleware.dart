import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();

    if (!authController.isAuthenticated.value) {
      return const RouteSettings(name: AppRoutes.login);
    }

    if (!authController.isVerified.value) {
      return const RouteSettings(name: AppRoutes.pendingVerification);
    }

    return null; // Proceed as normal
  }
}
