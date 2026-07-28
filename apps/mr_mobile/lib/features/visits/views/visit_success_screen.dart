import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:lottie/lottie.dart';
import '../../../app/routes.dart';

class VisitSuccessScreen extends StatelessWidget {
  const VisitSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/success.json',
                width: 200,
                height: 200,
                repeat: false,
              ),
              const SizedBox(height: 32),
              const Text(
                'Visit Confirmed!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Location verified and visit logged successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 48),
              GradientButton(
                text: 'Rate Doctor',
                onPressed: () {
                  Get.offNamed(AppRoutes.doctorRating);
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Get.offAllNamed(AppRoutes.dashboard);
                },
                child: const Text('Skip for now', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
