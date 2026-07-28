import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminAuthController extends GetxController {
  final AuthService _authService;

  AdminAuthController(this._authService);

  final RxBool isLoading = false.obs;
  final RxBool isAuthenticated = false.obs;
  final RxBool isAdmin = false.obs;
  final Rx<MrUser?> currentUser = Rx<MrUser?>(null);

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final user = await _authService.getFreshUserRecord();
    if (user != null) {
      if (user.role == 'admin') {
        currentUser.value = user;
        isAuthenticated.value = true;
        isAdmin.value = true;
      } else {
        await _authService.signOut();
      }
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final user = await _authService.signIn(email, password);
      
      if (user != null) {
        if (user.role == 'admin') {
          currentUser.value = user;
          isAuthenticated.value = true;
          isAdmin.value = true;
          Get.offAllNamed(AppRoutes.dashboard);
        } else {
          await _authService.signOut();
          Get.snackbar('Access Denied', 'Admin accounts only.', 
            backgroundColor: AppColors.error, colorText: Colors.white);
        }
      } else {
        Get.snackbar('Error', 'Account not found', backgroundColor: AppColors.error, colorText: Colors.white);
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred during login.';
      if (e.code == 'user-not-found') {
        message = 'Account not found.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Invalid email or password.';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many attempts. Please try again later.';
      }
      Get.snackbar('Login Failed', message, backgroundColor: AppColors.error, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Login Failed', 'Something went wrong. Please try again.', backgroundColor: AppColors.error, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    isAuthenticated.value = false;
    isAdmin.value = false;
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> resetPassword(String email) async {
    if (email.isEmpty || !email.contains('@')) {
      Get.snackbar('Error', 'Please enter a valid email address first.', backgroundColor: AppColors.error, colorText: Colors.white);
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Get.snackbar('Success', 'Password reset email sent to $email.', backgroundColor: AppColors.success, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to send reset email. Verify your email address.', backgroundColor: AppColors.error, colorText: Colors.white);
    }
  }

  void devBypassLogin() {
    if (!kDebugMode) return;
    
    currentUser.value = MrUser(
      uid: 'dev-admin-123',
      name: 'Dev Admin',
      email: 'dev@medivisit.com',
      role: 'admin',
      isVerified: true,
      isBlocked: false,
      territoryId: 'global',
      language: 'en',
      darkMode: true,
      attendanceStreak: 0,
      totalVisits: 0,
      avgRating: 0.0,
      fcmTokens: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      phone: '',
    );
    isAuthenticated.value = true;
    isAdmin.value = true;
    Get.offAllNamed(AppRoutes.dashboard);
    Get.snackbar('Dev Mode', 'Bypassed authentication successfully.', backgroundColor: AppColors.success, colorText: Colors.white);
  }
}
