import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/routes.dart';

// ─── Data Model ────────────────────────────────────────────────────────────
class _OnboardingData {
  final String title;
  final String subtitle;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;
  final IconData bgIcon;

  const _OnboardingData({
    required this.title,
    required this.subtitle,
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
    required this.bgIcon,
  });
}

// ─── Widget ─────────────────────────────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _floatController;
  late AnimationController _textController;
  late Animation<double> _floatAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const List<_OnboardingData> _pages = [
    _OnboardingData(
      title: 'Track Your Visits',
      subtitle:
          'Log doctor visits with GPS verification and geofencing for accurate, tamper-proof records.',
      primaryColor: Color(0xFF4F378A),
      secondaryColor: Color(0xFF008080),
      icon: Icons.location_on_rounded,
      bgIcon: Icons.map_rounded,
    ),
    _OnboardingData(
      title: 'Manage Your Territory',
      subtitle:
          'Products, samples, and expenses in one place. Stay organised across your entire region.',
      primaryColor: Color(0xFF006B5E),
      secondaryColor: Color(0xFF4F378A),
      icon: Icons.inventory_2_rounded,
      bgIcon: Icons.grid_view_rounded,
    ),
    _OnboardingData(
      title: 'Get Insights',
      subtitle:
          'AI-powered route optimisation and performance tracking to help you exceed your targets.',
      primaryColor: Color(0xFF0061A4),
      secondaryColor: Color(0xFF006B5E),
      icon: Icons.insights_rounded,
      bgIcon: Icons.bar_chart_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _floatAnim = Tween<double>(begin: 0, end: -16).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _textController.forward();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _textController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    Get.offAllNamed(AppRoutes.login);
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _textController.reset();
    _textController.forward();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];

    return Scaffold(
      body: MeshGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Top Bar ──────────────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedOpacity(
                      opacity: _currentPage > 0 ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded,
                            size: 20),
                        color: const Color(0xFF4F378A),
                        onPressed: _currentPage > 0
                            ? () => _pageController.previousPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                )
                            : null,
                      ),
                    ),
                    Image.asset('assets/logo.png', width: 36, height: 36),
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: page.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── PageView ─────────────────────────────────────────────────
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) =>
                      _buildPage(_pages[index]),
                ),
              ),

              // ── Bottom Controls ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Column(
                  children: [
                    // Dot indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (i) {
                        final active = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: active
                                ? const LinearGradient(colors: [
                                    Color(0xFF4F378A),
                                    Color(0xFF008080),
                                  ])
                                : null,
                            color: active ? null : const Color(0xFFCBC4D2),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    // CTA button
                    SizedBox(
                      width: double.infinity,
                      child: GradientButton(
                        text: _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                        onPressed: _nextPage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Page Content ──────────────────────────────────────────────────────────
  Widget _buildPage(_OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Floating illustration
          AnimatedBuilder(
            animation: _floatAnim,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, _floatAnim.value),
              child: child,
            ),
            child: _buildIllustration(data),
          ),
          const SizedBox(height: 56),
          // Fade + slide text
          FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [data.primaryColor, data.secondaryColor],
                    ).createShader(bounds),
                    child: Text(
                      data.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF494551),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Illustration ──────────────────────────────────────────────────────────
  Widget _buildIllustration(_OnboardingData data) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                data.primaryColor.withOpacity(0.12),
                data.primaryColor.withOpacity(0.0),
              ]),
            ),
          ),
          // Mid ring
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  data.primaryColor.withOpacity(0.15),
                  data.secondaryColor.withOpacity(0.05),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
              border:
                  Border.all(color: data.primaryColor.withOpacity(0.1)),
            ),
          ),
          // Inner glass card
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.6),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: data.primaryColor.withOpacity(0.25),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  blurRadius: 8,
                  offset: const Offset(-4, -4),
                ),
              ],
              border:
                  Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
            ),
            child: Center(
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [data.primaryColor, data.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Icon(data.icon, size: 56, color: Colors.white),
              ),
            ),
          ),
          // Floating mini cards
          Positioned(
            top: 20,
            right: 20,
            child: _miniCard(data.secondaryColor, data.bgIcon),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: _miniCard(data.primaryColor, Icons.check_circle_rounded),
          ),
        ],
      ),
    );
  }

  Widget _miniCard(Color color, IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
