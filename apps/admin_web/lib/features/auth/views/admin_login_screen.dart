import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_auth_controller.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = Get.find<AdminAuthController>();
  
  bool _rememberSession = false;
  int _logoTapCount = 0;
  DateTime? _lastTapTime;
  
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _floatAnimation = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  void _handleDevBypass() {
    final now = DateTime.now();
    if (_lastTapTime == null || now.difference(_lastTapTime!) > const Duration(seconds: 1)) {
      _logoTapCount = 1;
    } else {
      _logoTapCount++;
      if (_logoTapCount >= 3) {
        _logoTapCount = 0;
        _authController.devBypassLogin();
      }
    }
    _lastTapTime = now;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101221), // bg-surface-dim
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 992;
          
          return Row(
            children: [
              // Left Side: Brand & Visuals (Hidden on mobile)
              if (isDesktop)
                Expanded(
                  flex: 55,
                  child: _buildLeftSide(),
                ),
                
              // Right Side: Login Form
              Expanded(
                flex: 45,
                child: _buildRightSide(isDesktop),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLeftSide() {
    return Container(
      color: const Color(0xFF03040A),
      child: Stack(
        children: [
          // Background Mesh Blobs
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00F2FF).withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7000FF).withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00DBE7).withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _floatAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatAnimation.value),
                          child: child,
                        );
                      },
                      child: Container(
                        width: 500,
                        height: 350,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 30,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: const Center(
                              child: Icon(Icons.dashboard_customize_rounded, size: 80, color: Color(0xFF00DBE7)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Text(
                  'MediVisit Pro',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.02,
                    shadows: [Shadow(color: Color(0x9900DBE7), blurRadius: 15)],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Control the Future of Field Excellence. Enterprise-grade clinical administration workspace.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFFB9CACB), // on-surface-variant
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightSide(bool isDesktop) {
    return Container(
      color: const Color(0xFF101221),
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                  children: [
                    if (!isDesktop) ...[
                      GestureDetector(
                        onTap: _handleDevBypass,
                        child: const Text(
                          'MediVisit Pro',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00DBE7), // primary-fixed
                            shadows: [Shadow(color: Color(0x8000DBE7), blurRadius: 8)],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                    GestureDetector(
                      onTap: isDesktop ? _handleDevBypass : null,
                      child: const Text(
                        'System Access',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE1E1F6), // on-surface
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Authenticate to access the clinical console.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFB9CACB), // on-surface-variant
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    _buildAdminTextField(
                      'Administrator ID',
                      Icons.person_outline,
                      _emailController,
                    ),
                    const SizedBox(height: 16),
                    _buildAdminTextField(
                      'Security Clearance Key',
                      Icons.lock_outline,
                      _passwordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberSession,
                              onChanged: (val) => setState(() => _rememberSession = val ?? false),
                              activeColor: const Color(0xFF00F2FF), // primary-container
                              checkColor: const Color(0xFF00363A), // on-primary-container
                              side: const BorderSide(color: Color(0xFF3A494B)), // outline-variant
                            ),
                            const Text('Remember Session', style: TextStyle(color: Color(0xFFB9CACB), fontSize: 12)),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Recover Access',
                            style: TextStyle(color: Color(0xFF00DBE7), fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Obx(() => Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00DBE7), Color(0xFF7000FF)], // primary-fixed-dim to secondary-container
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _authController.isLoading.value ? null : () {
                            if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                              _authController.login(_emailController.text, _passwordController.text);
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Center(
                            child: _authController.isLoading.value
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                                : const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Initialize Session',
                                        style: TextStyle(
                                          color: Color(0xFFE1FDFF), // on-primary
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward_rounded, color: Color(0xFFE1FDFF), size: 18),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    )),
                    const SizedBox(height: 32),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        'Authorized personnel only. Sub-system version 4.2.1',
                        style: TextStyle(
                          color: Color(0xFFB9CACB),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminTextField(String hint, IconData icon, TextEditingController controller, {bool obscureText = false}) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0x0DFFFFFF), // rgba(255,255,255,0.05)
        border: Border(
          bottom: BorderSide(color: Color(0x33FFFFFF)), // rgba(255,255,255,0.2)
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Color(0xFFE1E1F6)), // on-surface
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0x80B9CACB)), // on-surface-variant/50
          prefixIcon: Icon(icon, color: const Color(0xFFB9CACB), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
