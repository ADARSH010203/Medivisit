import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/routes.dart';

class AuthController extends GetxController {
  final AuthService _authService;

  AuthController(this._authService);

  final RxBool isLoading = false.obs;
  final RxBool isAuthenticated = false.obs;
  final RxBool isVerified = false.obs;
  final Rx<MrUser?> currentUser = Rx<MrUser?>(null);
  
  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final user = await _authService.getFreshUserRecord();
    if (user != null) {
      currentUser.value = user;
      isAuthenticated.value = true;
      isVerified.value = user.isVerified;
    } else {
      isAuthenticated.value = false;
      isVerified.value = false;
    }
  }

  Future<void> checkOnboardingAndRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    if (isAuthenticated.value) {
      if (isVerified.value) {
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        Get.offAllNamed(AppRoutes.pendingVerification);
      }
    } else {
      if (hasSeenOnboarding) {
        Get.offAllNamed(AppRoutes.login);
      } else {
        Get.offAllNamed(AppRoutes.onboarding);
      }
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final user = await _authService.signIn(email, password);
      
      if (user != null) {
        currentUser.value = user;
        isAuthenticated.value = true;
        isVerified.value = user.isVerified;
        
        if (isVerified.value) {
          Get.offAllNamed(AppRoutes.dashboard);
        } else {
          Get.offAllNamed(AppRoutes.pendingVerification);
        }
      } else {
        Get.snackbar('Error', 'Invalid credentials');
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

  Future<void> register(String name, String email, String phone, String password, String territoryId) async {
    try {
      isLoading.value = true;
      final user = await _authService.signUpAndCreateRecord(email, password, name, phone, territoryId);
      
      if (user != null) {
        currentUser.value = user;
        isAuthenticated.value = true;
        isVerified.value = user.isVerified;
        Get.offAllNamed(AppRoutes.pendingVerification);
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred during registration.';
      if (e.code == 'email-already-in-use') {
        message = 'An account already exists for this email.';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak.';
      }
      Get.snackbar('Registration Failed', message, backgroundColor: AppColors.error, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Registration Failed', 'Something went wrong. Please try again.', backgroundColor: AppColors.error, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    isAuthenticated.value = false;
    isVerified.value = false;
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.login);
  }
}
