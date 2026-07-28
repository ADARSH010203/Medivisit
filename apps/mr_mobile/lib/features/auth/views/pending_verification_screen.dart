import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class PendingVerificationScreen extends StatelessWidget {
  const PendingVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MeshGradientBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: GlassCard(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pulsing icon
                  _PulsingIcon(),
                  const SizedBox(height: 28),

                  // Title
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF4F378A), Color(0xFF008080)],
                    ).createShader(bounds),
                    child: const Text(
                      'Account Under Review',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your account is pending verification by a regional administrator. This usually takes 1–2 business days.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF494551),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Contact your regional admin for assistance.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4F378A),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Status timeline
                  _buildTimeline(),

                  const SizedBox(height: 32),

                  // Logout
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text('Sign Out'),
                      onPressed: () => Get.find<AuthController>().logout(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4F378A),
                        side: const BorderSide(color: Color(0xFF4F378A)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: [
        _timelineStep(
          icon: Icons.check_circle_rounded,
          label: 'Account Created',
          color: const Color(0xFF008080),
          done: true,
        ),
        _timelineDash(),
        _timelineStep(
          icon: Icons.hourglass_top_rounded,
          label: 'Admin Verification',
          color: const Color(0xFFE8A800),
          done: false,
          active: true,
        ),
        _timelineDash(),
        _timelineStep(
          icon: Icons.rocket_launch_rounded,
          label: 'Access Granted',
          color: const Color(0xFF7A7582),
          done: false,
        ),
      ],
    );
  }

  Widget _timelineStep({
    required IconData icon,
    required String label,
    required Color color,
    required bool done,
    bool active = false,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: done || active
                ? color.withOpacity(0.15)
                : const Color(0xFFF1EFF5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: done || active ? color : const Color(0xFFCBC4D2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight:
                active ? FontWeight.w700 : FontWeight.w500,
            color: done || active
                ? const Color(0xFF1D1B20)
                : const Color(0xFF7A7582),
          ),
        ),
        if (active) ...[
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE8A800).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'In Progress',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE8A800),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _timelineDash() {
    return Padding(
      padding: const EdgeInsets.only(left: 19),
      child: Container(
        width: 2,
        height: 24,
        color: const Color(0xFFCBC4D2),
      ),
    );
  }
}

class _PulsingIcon extends StatefulWidget {
  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              const Color(0xFFE8A800).withOpacity(0.2),
              const Color(0xFFE8A800).withOpacity(0.0),
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE8A800).withOpacity(0.12),
            ),
            child: const Icon(
              Icons.hourglass_empty_rounded,
              color: Color(0xFFE8A800),
              size: 36,
            ),
          ),
        ),
      ),
    );
  }
}
