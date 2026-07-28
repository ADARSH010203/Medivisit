import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import '../controllers/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  final AuthController _authController = Get.find<AuthController>();
  late AnimationController _progressController;
  late AnimationController _introController;
  late AnimationController _pulseController;

  late Animation<double> _logoScale;
  late Animation<double> _textFade;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    // Progress bar animation (2.5s)
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2, milliseconds: 500),
    )..forward();

    // Intro scale/fade sequence (1.2s)
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Continuous pulse sequence (2s repeat)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeOutBack),
    );
    
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController, 
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _pulseScale = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start intro, then loop pulse
    _introController.forward().then((_) {
      _pulseController.repeat(reverse: true);
    });

    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Total wait time for the splash screen
    await Future.delayed(const Duration(seconds: 3));
    _authController.checkOnboardingAndRoute();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _introController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MeshGradientBackground(
        child: Stack(
          children: [
            // Center Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with Pedestal & Animations
                  ScaleTransition(
                    scale: _logoScale,
                    child: ScaleTransition(
                      scale: _pulseScale,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          // Pedestal glow
                          Positioned(
                            bottom: -10,
                            child: Container(
                              width: 140,
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Logo Glass Container
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.15),
                                  blurRadius: 48,
                                  offset: const Offset(0, 16),
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(28),
                                    child: Image.asset(
                                      'assets/logo.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Animated Fade-In Text Sequence
                  FadeTransition(
                    opacity: _textFade,
                    child: Column(
                      children: [
                        // Gradient Title
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF4F378A), Color(0xFF008080)], // brandGradient colors for light mode
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: const Text(
                            'MediVisit Pro',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.02,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Subtitle
                        const Text(
                          'Field Excellence, Simplified',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF494551), // on-surface-variant
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Progress Bar at Bottom
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 240,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: _progressController.value,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: AppColors.brandGradient,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

