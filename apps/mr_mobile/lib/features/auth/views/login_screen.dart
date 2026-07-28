import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../l10n/l10n.dart';
import '../controllers/auth_controller.dart';
import '../../../app/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final tr = L10n.tr(context);

    return Scaffold(
      body: MeshGradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              // Logo
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA-gVrD5_lLrY5bwBS_V2ch4zu-afnLKQanr0KDygqJ_U1CuoLq-3nXP9L1rUzOW9mzUBSgYdx7g4ygZs6aF5KuJHF6nXNPoTwrfTpUb5tEsaVNJVaJAqWZm96bbhGyO74d5I9Gn6kfBGLPcOWFG_uyT7bcTvGC0Q-AlklqMM2F_jMvfcAz_PkX8cmYGvDuX7ZxHvyrx6W4RQD50aPiU2ufuuqcSo8-TVDjW12JD9HpInA7ZoqEnSwaNd7zPlBACeUeOEiP_dkIVpur',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.healing_rounded, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                tr.loginTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D1B20), // on-background
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                tr.loginSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF494551), // on-surface-variant
                ),
              ),
              const SizedBox(height: 32),
              // Form Card
              GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    AppTextField(
                      label: '', // Hidden label as per HTML design
                      hint: 'Professional Email',
                      controller: _emailController,
                      prefixIcon: _buildDuotoneIcon(Icons.mail_rounded),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      label: '',
                      hint: tr.passwordLabel,
                      controller: _passwordController,
                      prefixIcon: _buildDuotoneIcon(Icons.lock_rounded),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: ShaderMask(
                          shaderCallback: (bounds) => AppColors.brandGradient.createShader(bounds),
                          child: Text(
                            tr.forgotPassword,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.05,
                              color: Colors.white, // Required for ShaderMask to work correctly
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Sign In Button
                    Obx(() => GradientButton(
                      text: tr.loginButton,
                      isLoading: _authController.isLoading.value,
                      onPressed: () {
                        if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                          _authController.login(_emailController.text, _passwordController.text);
                        }
                      },
                    )),
                    const SizedBox(height: 32),
                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Color(0x4DCBC4D2))), // outline-variant with opacity
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: const Text(
                            'OR',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7A7582), // outline
                              letterSpacing: 0.05,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: Color(0x4DCBC4D2))),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'New Employee? ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF494551),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.register),
                          child: ShaderMask(
                            shaderCallback: (bounds) => AppColors.brandGradient.createShader(bounds),
                            child: const Text(
                              'Register here',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Trust Badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.8)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.04),
                        blurRadius: 32,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDuotoneIcon(Icons.verified_user_rounded, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Secure company login',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF494551),
                          letterSpacing: 0.05,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDuotoneIcon(IconData iconData, {double size = 24}) {
    return Container(
      width: size + 16,
      height: size + 16,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size + 8,
            height: size + 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
          Icon(
            iconData,
            color: AppColors.primary,
            size: size,
          ),
        ],
      ),
    );
  }
}
